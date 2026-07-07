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

  Future<bool> queryTitle(String query) async {
    List<Map<String, Object?>> list = await dDatabase.query(
        DSTableDefine.baiduTable,
        where: 'query = ?',
        whereArgs: [query]);
    return list.isEmpty;
  }

  Future<void> insertHot(BDDetailModel bdDetailModel) async {
    if (await queryTitle(bdDetailModel.query)) {
      await dDatabase.insert(DSTableDefine.baiduTable, bdDetailModel.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> insertHotBatch(List<BDDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.baiduTable,
      columns: ['query'],
    );
    final existingQueries = existing.map((e) => e['query']).toSet();

    final batch = dDatabase.batch();
    for (final item in list) {
      if (existingQueries.contains(item.query)) continue;
      batch.insert(
        DSTableDefine.baiduTable,
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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

  Future<int> clearAll() async {
    return await dDatabase.delete(DSTableDefine.baiduTable);
  }
}
