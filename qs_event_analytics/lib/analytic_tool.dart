import 'package:qs_event_analytics/analytic_model.dart';
import 'package:qs_event_analytics/firebase_analytic_tool.dart';

class AnalyticTool {
  /// Func
  /// 初始化
   Future<void> initialize() async {
    await FirebaseAnalyticTool.initialize();
  }

  /// 打点
  void addEvent({
    required String code,
    required String name,
    required EventType type,
    int? timestamp,
    required String? belongPage,
    Map<String, dynamic>? extra,
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
    ApiTool.recordEvent(
      sessionId: _sessionId,
      eventCode: code,
      eventName: type.eventNamePrefix.replaceAll("@name", name),
      eventType: type,
      timestamp: newTimestamp,
      belongPage: belongPage,
      extra: extra,
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
        failedEvents.add(model);
      },
    );
  }

  /// 记录打点事件
  static Future<void> recordEvent({
    required String sessionId,
    required String eventCode,
    required String eventName,
    required EventType eventType,
    required int timestamp,
    String? belongPage,
    Map<String, dynamic>? extra,
    required Function() onError,
  }) async {
    String deviceId = await DeviceTool.getDeviceId();
    // 获取位置信息
    final loaction = await NetRequest.getLocationByIp();
    // 获取设备系统版本
    var deviceOSVersion = await DeviceTool.getDeviceOSVersion();
    // 获取版本号
    String? appVersion = await DeviceTool.getAppVersion();
    // 将 extra 转为 JSON 字符串
    final extraContent = extra == null ? null : jsonEncode(extra);
    // 是否测试环境
    bool isTest = !kReleaseMode;

    var parameters = {
      "sessionId": sessionId,
      "uuid": deviceId,
      "eventCode": eventCode,
      "eventName": eventName,
      "eventType": eventType.typeCode,
      "eventTime": timestamp,
      "userIp": loaction?.ip ?? "",
      "countryCode": loaction?.country ?? "",
      "cityCode": loaction?.city ?? "",
      "systemVersion": deviceOSVersion,
      "appVersion": appVersion,
      "attrPage": belongPage ?? "",
      "eventContent": extraContent,
      "env": isTest ? "dev" : "prd"
    };

    var response = await NetRequest().post(
      apiUrl: kEventUrl,
      parameters: parameters,
    );

    if (response?.data["code"] != 0) {
      onError();
    } else {
      Logger.info(
          "打点成功: $eventName, eventCode: $eventCode, belongPage: $belongPage, extra: $extra, type: $eventType");
    }
  }

  /// 重新发送失败的事件
  Future<void> _resendFailedEvents() async {
    if (_isSending) return;
    if (failedEvents.isEmpty) return;

    _isSending = true;

    while (failedEvents.isNotEmpty) {
      final model = failedEvents.removeAt(0);

      bool isSuccess = true;
      await ApiTool.recordEvent(
        sessionId: model.sessionId,
        eventCode: model.eventCode,
        eventName: model.eventName,
        eventType: model.eventType,
        timestamp: model.timestamp,
        belongPage: model.belongPage,
        extra: model.extra,
        onError: () {
          failedEvents.add(model);
          isSuccess = false;
        },
      );

      // 网络异常，停止发送
      if (!isSuccess) {
        // 10秒后重试
        Future.delayed(const Duration(seconds: 10), () {
          _resendFailedEvents();
        });
        break;
      }

      // 防止长时间同步循环卡 UI
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // 移除已成功发送的
    failedEvents.removeWhere((e) => true); // 或按 success 做删除策略
    _isSending = false;
  }

  /// 用户操作行为
  void _userAction() {
    // 检查网络连接
    NetConnectionChecker.getInstance().then((checker) {
      getEver(
        checker.isNetConnected,
        disposeBag: disposeBag,
        callback: (isConnected) async {
          if (isConnected) {
            _resendFailedEvents();
          }
        },
      );

      if (checker.isNetConnected.value) {
        _resendFailedEvents();
      }
    });
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
  void returnToCurrentPage({required Map<String, dynamic> pageData}) {
    String? code = pageData["code"] as String?;
    String? name = pageData["name"] as String?;
    Map<String, dynamic>? extra = pageData["extra"] as Map<String, dynamic>?;

    if (code != null && name != null) {
      recordEvent(
        code: code,
        name: name,
        type: EventType.pageIn,
        belongPage: code,
        extra: extra,
      );
    }
  }

  /// Property
  final DisposeBag disposeBag = DisposeBag();
  final String _sessionId = const Uuid().v4();
  String currentPageCode = "";
  String _currentPageName = "";
  Map<String, dynamic>? _currentPageExtra;

  // 发送失败的点
  List<EventLogModel> failedEvents = [];
  bool _isSending = false;

  /// 单例
  static final EventLog _instance = EventLog._internal();
  EventLog._internal() {
    _userAction();
  }

  static EventLog getInstance() {
    return _instance;
  }
}