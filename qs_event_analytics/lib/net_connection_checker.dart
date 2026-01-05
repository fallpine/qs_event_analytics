import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qs_event_analytics/event_bus_tool.dart';

class NetConnectionChecker {
  /// Func
  // 其他一些初始化操作
  Future<StreamSubscription<List<ConnectivityResult>>> _initialize() async {
    /// 初始化监听网络
    await _initConnectivity();
    return _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("检查网络状态失败 + $e");
      }
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.mobile)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.wifi)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.ethernet)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.vpn)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.bluetooth)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    } else if (result.contains(ConnectivityResult.other)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    } else if (result.contains(ConnectivityResult.none)) {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    } else {
      EventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    }
  }

  /// Property
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// 单例
  static final NetConnectionChecker _instance =
      NetConnectionChecker._internal();
  NetConnectionChecker._internal();

  static Future<NetConnectionChecker> getInstance() async {
    _instance._connectivitySubscription ??= await _instance._initialize();
    return _instance;
  }
}
