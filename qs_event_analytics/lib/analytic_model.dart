import 'dart:convert';

class AnalyticModel {
  String? sessionId;
  String? eventCode;
  String? eventName;
  EventType? eventType;
  int? timestamp;
  String? belongPage;
  Map<String, String>? extra;

  AnalyticModel({
    required this.sessionId,
    required this.eventCode,
    required this.eventName,
    required this.eventType,
    required this.timestamp,
    required this.belongPage,
    required this.extra,
  });

  AnalyticModel.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    eventCode = json['eventCode'];
    eventName = json['eventName'];
    try {
      eventType = EventType.values.firstWhere((element) => element.name == json['eventType']);
    } catch (_) {
      eventType = null;
    }

    timestamp = json['timestamp'];
    belongPage = json['belongPage'];
    try {
      var jsonExtra = jsonDecode(json['extra']);
      if (jsonExtra is Map<String, String>) {
        extra = jsonExtra;
      } else {
        extra = null;
      }
    } catch (_) {
      extra = null;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sessionId'] = sessionId;
    data['eventCode'] = eventCode;
    data['eventName'] = eventName;
    data['eventType'] = eventType?.name;
    data['timestamp'] = timestamp;
    data['belongPage'] = belongPage;
    data['extra'] = jsonEncode(extra);

    return data;
  }
}

enum EventType {
  appIn,
  appOut,
  pageIn,
  pageOut,
  click,
  valueChange,
  load,
  show,
  close,
  state,
  error;

  // 事件类型的code
  String get typeCode {
    switch (this) {
      case EventType.appIn:
        return "in";
      case EventType.appOut:
        return "out";
      case EventType.pageIn:
        return "in";
      case EventType.pageOut:
        return "out";
      case EventType.click:
        return "click";
      case EventType.valueChange:
        return "click";
      case EventType.load:
        return "load";
      case EventType.show:
        return "in";
      case EventType.close:
        return "out";
      case EventType.state:
        return "load";
      case EventType.error:
        return "error";
    }
  }

  // firebase打点的数据类型
  String get firebaseTypeCode {
    switch (this) {
      case EventType.appIn:
        return "in";
      case EventType.appOut:
        return "out";
      case EventType.pageIn:
        return "in";
      case EventType.pageOut:
        return "out";
      case EventType.click:
        return "clk";
      case EventType.valueChange:
        return "vc";
      case EventType.load:
        return "ld";
      case EventType.show:
        return "in";
      case EventType.close:
        return "out";
      case EventType.state:
        return "";
      case EventType.error:
        return "err";
    }
  }

  String get eventNamePrefix {
    switch (this) {
      case EventType.appIn:
        return "@name";
      case EventType.appOut:
        return "@name";
      case EventType.pageIn:
        return "进入-【@name】";
      case EventType.pageOut:
        return "离开-【@name】";
      case EventType.valueChange:
        return "值改变-@name";
      case EventType.click:
        return "点击-@name";
      case EventType.load:
        return "加载-@name";
      case EventType.show:
        return "显示-【@name】";
      case EventType.close:
        return "关闭-【@name】";
      case EventType.state:
        return "状态-@name";
      case EventType.error:
        return "错误-@name";
    }
  }
}
