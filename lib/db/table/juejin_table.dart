import 'package:data_statistics/db/table_define.dart';
import 'package:data_statistics/db/table_operation.dart';
import 'package:data_statistics/models/juejin_model.dart';
import 'package:sqflite/sqflite.dart';

class JuejinTable extends TableOperation {
  Future<List<JuejinDetailModel>> query() async {
    final data = await dDatabase.query(
      DSTableDefine.juejinTable,
      orderBy: '"create" DESC',
      limit: DSTableDefine.maxHotRecords,
    );
    return List.generate(data.length, (index) {
      return JuejinDetailModel.fromJson(data[index]);
    });
  }

  Future<void> insertHotBatch(List<JuejinDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.juejinTable,
      columns: ['id', 'itemid'],
    );
    final idByItemId = <String, int>{};
    for (final row in existing) {
      final itemId = row['itemid']?.toString();
      final id = row['id'];
      if (itemId != null && id is int) {
        idByItemId[itemId] = id;
      }
    }

    final batch = dDatabase.batch();
    for (final item in list) {
      final json = item.toJson()..remove('id');
      final existingId = idByItemId[item.itemid];
      if (existingId != null) {
        batch.update(
          DSTableDefine.juejinTable,
          json,
          where: 'id = ?',
          whereArgs: [existingId],
        );
      } else {
        batch.insert(
          DSTableDefine.juejinTable,
          json,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    await batch.commit(noResult: true);
    await trimToMax();
  }

  Future<void> trimToMax() => _trimToMax();

  Future<void> _trimToMax() async {
    await dDatabase.rawDelete('''
      DELETE FROM ${DSTableDefine.juejinTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.juejinTable}
        ORDER BY "create" DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }
}
