import 'package:flutter_test/flutter_test.dart';
import 'package:qs_event_analytics/qs_event_analytics.dart';
import 'package:qs_event_analytics/qs_event_analytics_platform_interface.dart';
import 'package:qs_event_analytics/qs_event_analytics_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockQsEventAnalyticsPlatform
    with MockPlatformInterfaceMixin
    implements QsEventAnalyticsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final QsEventAnalyticsPlatform initialPlatform = QsEventAnalyticsPlatform.instance;

  test('$MethodChannelQsEventAnalytics is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelQsEventAnalytics>());
  });

  test('getPlatformVersion', () async {
    QsEventAnalytics qsEventAnalyticsPlugin = QsEventAnalytics();
    MockQsEventAnalyticsPlatform fakePlatform = MockQsEventAnalyticsPlatform();
    QsEventAnalyticsPlatform.instance = fakePlatform;

    expect(await qsEventAnalyticsPlugin.getPlatformVersion(), '42');
  });
}
