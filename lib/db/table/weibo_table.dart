import 'package:data_statistics/db/table_define.dart';
import 'package:data_statistics/db/table_operation.dart';
import 'package:data_statistics/models/weibo_model.dart';
import 'package:sqflite/sqflite.dart';

class WeiboTable extends TableOperation {
  Future<List<WBDetailModel>> query() async {
    final data = await dDatabase.query(
      DSTableDefine.weiboTable,
      orderBy: '"create" DESC',
      limit: DSTableDefine.maxHotRecords,
    );
    return List.generate(data.length, (index) {
      return WBDetailModel.fromJson(data[index]);
    });
  }

  Future<bool> queryTitle(String title) async {
    List<Map<String, Object?>> list = await dDatabase.query(
        DSTableDefine.weiboTable,
        where: 'title = ?',
        whereArgs: [title]);
    return list.isEmpty;
  }

  Future<void> insertHot(WBDetailModel bdDetailModel) async {
    if (await queryTitle(bdDetailModel.title)) {
      await dDatabase.insert(DSTableDefine.weiboTable, bdDetailModel.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> insertHotBatch(List<WBDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.weiboTable,
      columns: ['title'],
    );
    final existingTitles = existing.map((e) => e['title']).toSet();

    final batch = dDatabase.batch();
    for (final item in list) {
      if (existingTitles.contains(item.title)) continue;
      batch.insert(
        DSTableDefine.weiboTable,
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
      DELETE FROM ${DSTableDefine.weiboTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.weiboTable}
        ORDER BY "create" DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }

  Future<int> clearAll() async {
    return await dDatabase.delete(DSTableDefine.weiboTable);
  }
}
