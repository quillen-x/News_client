import 'package:data_statistics/db/table_define.dart';
import 'package:data_statistics/db/table_operation.dart';
import 'package:data_statistics/models/baidu_model.dart';
import 'package:sqflite/sqflite.dart';

class BaiduTable extends TableOperation {
  Future<List<BDDetailModel>> query() async {
    final data = await dDatabase.query(
      DSTableDefine.baiduTable,
      orderBy: 'update_time DESC',
      limit: DSTableDefine.maxHotRecords,
    );
    return List.generate(data.length, (index) {
      return BDDetailModel.fromJson(data[index]);
    });
  }

  Future<void> insertHotBatch(List<BDDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.baiduTable,
      columns: ['id', 'query'],
    );
    final idByQuery = <String, int>{};
    for (final row in existing) {
      final query = row['query']?.toString();
      final id = row['id'];
      if (query != null && id is int) {
        idByQuery[query] = id;
      }
    }

    final batch = dDatabase.batch();
    for (final item in list) {
      final json = item.toJson()..remove('id');
      final existingId = idByQuery[item.query];
      if (existingId != null) {
        batch.update(
          DSTableDefine.baiduTable,
          json,
          where: 'id = ?',
          whereArgs: [existingId],
        );
      } else {
        batch.insert(
          DSTableDefine.baiduTable,
          json,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    await batch.commit(noResult: true);
    await _trimToMax();
  }

  Future<void> trimToMax() => _trimToMax();

  Future<void> _trimToMax() async {
    await dDatabase.rawDelete('''
      DELETE FROM ${DSTableDefine.baiduTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.baiduTable}
        ORDER BY update_time DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }
}
