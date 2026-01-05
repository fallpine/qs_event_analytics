import "package:path/path.dart";
import "package:qs_event_analytics/analytic_error_model.dart";
import "package:sqflite/sqflite.dart";

class AnalyticErrorDb {
  /// Func
  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    // if (!kReleaseMode) {
    //   await deleteDatabase(path);
    // }
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _onCreate(db: db);
      },
    );
  }

  /// 创建表
  Future<void> _onCreate({required Database db}) async {
    final Map<String, String> columns = AnalyticErrorModel.dbColumns();
    final String sqlStr = columns.entries
        .map((entry) => "${entry.key} ${entry.value}")
        .join(",");

    await db.execute("""
      CREATE TABLE IF NOT EXISTS $_tableName (
        $sqlStr
      )
    """);
  }

  // 插入数据
  Future<int?> insert({required AnalyticErrorModel row}) async {
    return await _database?.insert(_tableName, row.toJson());
  }

  /// 获取所有数据
  Future<List<AnalyticErrorModel>> queryAll() async {
    final List<Map<String, dynamic>> maps =
        await _database?.query(_tableName) ?? [];
    return List.generate(maps.length, (i) {
      return AnalyticErrorModel.fromJson(maps[i]);
    });
  }

  /// 删除数据
  Future<int?> delete({required AnalyticErrorModel row}) async {
    if (row.id == null) {
      return null;
    }
    return await _database?.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [row.id!],
    );
  }

  /// Property
  final String _dbName = "analytic_error.db";
  final String _tableName = "analytic_error_table";
  Database? _database;

  /// 单例
  static final AnalyticErrorDb _instance = AnalyticErrorDb._internal();
  AnalyticErrorDb._internal();

  static Future<AnalyticErrorDb> getInstance() async {
    _instance._database ??= await _instance._initDatabase();
    return _instance;
  }
}
