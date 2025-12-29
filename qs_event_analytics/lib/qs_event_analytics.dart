
import 'qs_event_analytics_platform_interface.dart';

class QsEventAnalytics {
  Future<String?> getPlatformVersion() {
    return QsEventAnalyticsPlatform.instance.getPlatformVersion();
  }
}
