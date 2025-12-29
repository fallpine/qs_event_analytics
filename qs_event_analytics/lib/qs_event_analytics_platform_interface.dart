import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'qs_event_analytics_method_channel.dart';

abstract class QsEventAnalyticsPlatform extends PlatformInterface {
  /// Constructs a QsEventAnalyticsPlatform.
  QsEventAnalyticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static QsEventAnalyticsPlatform _instance = MethodChannelQsEventAnalytics();

  /// The default instance of [QsEventAnalyticsPlatform] to use.
  ///
  /// Defaults to [MethodChannelQsEventAnalytics].
  static QsEventAnalyticsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QsEventAnalyticsPlatform] when
  /// they register themselves.
  static set instance(QsEventAnalyticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
