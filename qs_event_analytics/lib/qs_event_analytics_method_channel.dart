import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'qs_event_analytics_platform_interface.dart';

/// An implementation of [QsEventAnalyticsPlatform] that uses method channels.
class MethodChannelQsEventAnalytics extends QsEventAnalyticsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('qs_event_analytics');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
