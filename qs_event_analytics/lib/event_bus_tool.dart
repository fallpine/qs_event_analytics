import 'dart:async';

import 'package:event_bus/event_bus.dart';

// 创建 EventBus 单例
class EventBusTool {
  static final EventBus eventBus = EventBus();

  // 发送事件
  static void sendEvent({required ScriptEventType event}) {
    EventBusTool.eventBus.fire(event);
  }

  // 监听事件
  static StreamSubscription<ScriptEventType> listenEvent({
    required ScriptEventType event,
    required Function(Map<String, dynamic>?) onEvent,
  }) {
    var streamSubscription = EventBusTool.eventBus.on<ScriptEventType>().listen((e) {
      if (event.key == e.key) {
        onEvent(e.argument);
      }
    });
    return streamSubscription;
  }
}

// 定义事件类
class ScriptEventType {
  final String key;
  final Map<String, dynamic>? argument;
  ScriptEventType(this.key, {this.argument});
}
