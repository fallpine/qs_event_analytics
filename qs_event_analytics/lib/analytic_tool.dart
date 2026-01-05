import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ip_location/ip_location.dart';
import 'package:net_dio_request/net_request.dart';
import 'package:qs_event_analytics/analytic_error_db.dart';
import 'package:qs_event_analytics/analytic_error_model.dart';
import 'package:qs_event_analytics/analytic_model.dart';
import 'package:qs_event_analytics/event_bus_tool.dart';
import 'package:qs_event_analytics/firebase_analytic_tool.dart';
import 'package:qs_event_analytics/net_connection_checker.dart';
import 'package:uuid/uuid.dart';

class AnalyticTool {
  /// Func
  /// 初始化
  Future<void> initialize({
    required String userid,
    required String api,
    required String systemVersion,
    required String appVersion,
  }) async {
    _userid = userid;
    _api = api;
    _systemVersion = systemVersion;
    _appVersion = appVersion;

    await FirebaseAnalyticTool.initialize();
  }

  /// 打点
  void addEvent({
    required String code,
    required String name,
    required EventType type,
    int? timestamp,
    required String? belongPage,
    Map<String, String>? extra,
  }) {
    var newTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    if (type == EventType.pageIn) {
      // 退出上一个页面
      if (currentPageCode.isNotEmpty) {
        addEvent(
          code: currentPageCode,
          name: _currentPageName,
          type: EventType.pageOut,
          timestamp: newTimestamp - 1,
          belongPage: currentPageCode,
        );
      }
      // 记录新页面
      currentPageCode = code;
      _currentPageName = name;
      _currentPageExtra = extra;
    }

    // Firebase打点
    FirebaseAnalyticTool.addEvent(name: "${code}_${type.firebaseTypeCode}");

    // 接口记录
    recordEvent(
      sessionId: _sessionId,
      eventCode: code,
      eventName: type.eventNamePrefix.replaceAll("@name", name),
      eventType: type,
      timestamp: newTimestamp,
      belongPage: belongPage,
      extra: extra,
      onSuccess: () {},
      onError: () {
        // 记录失败的事件
        var model = AnalyticModel(
          sessionId: _sessionId,
          eventCode: code,
          eventName: name,
          eventType: type,
          timestamp: newTimestamp,
          belongPage: belongPage,
          extra: extra,
        );
        var data = jsonEncode(model);
        var errorModel = AnalyticErrorModel(data: data);
        AnalyticErrorDb.getInstance().then((db) => db.insert(row: errorModel));
      },
    );
  }

  /// 记录打点事件
  Future<void> recordEvent({
    required String sessionId,
    required String eventCode,
    required String eventName,
    required EventType eventType,
    required int timestamp,
    String? belongPage,
    Map<String, dynamic>? extra,
    required Function() onSuccess,
    required Function() onError,
  }) async {
    // 获取位置信息
    final loaction = await IpLocation.getIpLocation();
    // 将 extra 转为 JSON 字符串
    final extraContent = extra == null ? null : jsonEncode(extra);
    // 是否测试环境
    bool isTest = !kReleaseMode;

    var parameters = {
      "sessionId": sessionId,
      "uuid": _userid,
      "eventCode": eventCode,
      "eventName": eventName,
      "eventType": eventType.typeCode,
      "eventTime": timestamp,
      "userIp": loaction?.ip ?? "",
      "countryCode": loaction?.country ?? "",
      "cityCode": loaction?.city ?? "",
      "systemVersion": _systemVersion,
      "appVersion": _appVersion,
      "attrPage": belongPage ?? "",
      "eventContent": extraContent,
      "env": isTest ? "dev" : "prd",
    };
    try {
      var response = await NetRequest.shared.postJson(
        _api,
        parameters: parameters,
      );
      if (response?["code"] != 0) {
        onError();
      } else {
        onSuccess();
        if (kDebugMode) {
          print(
            "打点成功: $eventName, eventCode: $eventCode, belongPage: $belongPage, extra: $extra, type: $eventType",
          );
        }
      }
    } catch (e) {
      onError();
      return;
    }
  }

  /// 获取当前页面信息
  Map<String, dynamic> getCurrentPageData() {
    return {
      "code": currentPageCode,
      "name": _currentPageName,
      "extra": _currentPageExtra,
    };
  }

  /// 返回当前页面
  void returnToCurrentPage({required Map<String, String> pageData}) {
    String? code = pageData["code"];
    String? name = pageData["name"];
    Map<String, String>? extra = pageData["extra"] as Map<String, String>?;

    if (code != null && name != null) {
      addEvent(
        code: code,
        name: name,
        type: EventType.pageIn,
        belongPage: code,
        extra: extra,
      );
    }
  }

  /// 用户操作行为
  void _userAction() {
    EventBusTool.listenEvent(
      event: ScriptEventType("net_connect_state"),
      onEvent: (parameters) {
        final isConnected = parameters?["isConnected"] as bool?;
        if (isConnected == true) {
          // 重新发送失败事件
          _resendFailedEvents();
        }
      },
    );
    // 检查网络连接
    NetConnectionChecker.getInstance().then((checker) {});
  }

  /// 重新发送失败事件
  /// 从数据库中读取失败事件并重新发送
  Future<void> _resendFailedEvents() async {
    var db = await AnalyticErrorDb.getInstance();
    var rows = await db.queryAll();
    for (var row in rows) {
      var errorModel = AnalyticErrorModel.fromJson(jsonDecode(row.data));
      var model = AnalyticModel.fromJson(jsonDecode(errorModel.data));
      recordEvent(
        sessionId: model.sessionId,
        eventCode: model.eventCode,
        eventName: model.eventName,
        eventType: model.eventType,
        timestamp: model.timestamp,
        belongPage: model.belongPage,
        extra: model.extra,
        onSuccess: () {
          // 删除成功的事件
          db.delete(row: errorModel);
        },
        onError: () {},
      );
    }
  }

  /// Property
  String _userid = "";
  String _api = "";
  String _systemVersion = "";
  String _appVersion = "";
  final String _sessionId = const Uuid().v4();

  String currentPageCode = "";
  String _currentPageName = "";
  Map<String, dynamic>? _currentPageExtra;

  /// 单例
  static final AnalyticTool _instance = AnalyticTool._internal();
  AnalyticTool._internal() {
    _userAction();
  }

  static AnalyticTool getInstance() {
    return _instance;
  }
}
