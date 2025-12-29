import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FirebaseAnalyticTool {
  /// Func
  // 初始化
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  /// 打点
  static Future<void> addEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    // 获取版本号
    final info = await PackageInfo.fromPlatform();
    var version = info.version;
    var eventName = "${name}_${version.replaceAll(".", "")}";

    // 断言：事件名长度不能超过40
    assert(eventName.length <= 40, '事件名长度不能超过40个字符');

    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  /// Property
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
}
