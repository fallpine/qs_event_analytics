import 'package:json_annotation/json_annotation.dart';

part 'analytic_error_model.g.dart';

@JsonSerializable()
class AnalyticErrorModel {
  // 主键
  @JsonKey(name: "id")
  final int? id;
  final String? data;

  AnalyticErrorModel({this.id, this.data});

  /// 从 JSON 创建 AnalyticErrorModel 对象
  factory AnalyticErrorModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticErrorModelFromJson(json);

  /// 将 AnalyticErrorModel 对象转为 JSON
  Map<String, dynamic> toJson() => _$AnalyticErrorModelToJson(this);

  /// 数据库表字段
  static Map<String, String> dbColumns() {
    return {"id": "INTEGER PRIMARY KEY", "data": "TEXT"};
  }
}
