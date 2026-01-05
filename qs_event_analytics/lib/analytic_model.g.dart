// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticModel _$AnalyticModelFromJson(Map<String, dynamic> json) =>
    AnalyticModel(
      sessionId: json['sessionId'] as String,
      eventCode: json['eventCode'] as String,
      eventName: json['eventName'] as String,
      eventType: $enumDecode(_$EventTypeEnumMap, json['eventType']),
      timestamp: (json['timestamp'] as num).toInt(),
      belongPage: json['belongPage'] as String?,
      extra: (json['extra'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$AnalyticModelToJson(AnalyticModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'eventCode': instance.eventCode,
      'eventName': instance.eventName,
      'eventType': _$EventTypeEnumMap[instance.eventType]!,
      'timestamp': instance.timestamp,
      'belongPage': instance.belongPage,
      'extra': instance.extra,
    };

const _$EventTypeEnumMap = {
  EventType.appIn: 'appIn',
  EventType.appOut: 'appOut',
  EventType.pageIn: 'pageIn',
  EventType.pageOut: 'pageOut',
  EventType.click: 'click',
  EventType.valueChange: 'valueChange',
  EventType.load: 'load',
  EventType.show: 'show',
  EventType.close: 'close',
  EventType.state: 'state',
  EventType.error: 'error',
};
