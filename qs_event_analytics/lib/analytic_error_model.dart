class AnalyticErrorModel {
  int? id;
  String? data;

  AnalyticErrorModel({this.id, this.data});

  AnalyticErrorModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['data'] = data;

    return data;
  }

  /// 数据库表字段
  static Map<String, String> dbColumns() {
    return {"id": "INTEGER PRIMARY KEY", "data": "TEXT"};
  }
}
