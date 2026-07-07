import 'package:data_statistics/db/table_define.dart';
import 'package:data_statistics/db/table_operation.dart';
import 'package:data_statistics/models/sohu_model.dart';
import 'package:sqflite/sqflite.dart';

class SohuTable extends TableOperation {
  Future<List<SohuDetailModel>> query() async {
    final data = await dDatabase.query(
      DSTableDefine.sohuTable,
      orderBy: 'id DESC',
      limit: DSTableDefine.maxHotRecords,
    );
    return List.generate(data.length, (index) {
      return SohuDetailModel.fromJson(data[index]);
    });
  }

  Future<void> insertHotBatch(List<SohuDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.sohuTable,
      columns: ['itemid'],
    );
    final existingIds = existing.map((e) => e['itemid']).toSet();

    final batch = dDatabase.batch();
    for (final item in list) {
      if (existingIds.contains(item.itemid)) continue;
      batch.insert(
        DSTableDefine.sohuTable,
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    await trimToMax();
  }

  Future<void> trimToMax() => _trimToMax();

  Future<void> _trimToMax() async {
    await dDatabase.rawDelete('''
      DELETE FROM ${DSTableDefine.sohuTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.sohuTable}
        ORDER BY id DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }

  Future<int> clearAll() async {
    return dDatabase.delete(DSTableDefine.sohuTable);
  }
}
