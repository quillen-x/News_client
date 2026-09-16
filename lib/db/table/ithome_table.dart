import 'package:data_statistics/db/table_define.dart';
import 'package:data_statistics/db/table_operation.dart';
import 'package:data_statistics/models/ithome_model.dart';
import 'package:sqflite/sqflite.dart';

class IthomeTable extends TableOperation {
  Future<List<IthomeDetailModel>> query() async {
    final data = await dDatabase.query(
      DSTableDefine.ithomeTable,
      orderBy: '"create" DESC',
      limit: DSTableDefine.maxHotRecords,
    );
    return List.generate(data.length, (index) {
      return IthomeDetailModel.fromJson(data[index]);
    });
  }

  Future<void> insertHotBatch(List<IthomeDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.ithomeTable,
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
          DSTableDefine.ithomeTable,
          json,
          where: 'id = ?',
          whereArgs: [existingId],
        );
      } else {
        batch.insert(
          DSTableDefine.ithomeTable,
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
      DELETE FROM ${DSTableDefine.ithomeTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.ithomeTable}
        ORDER BY "create" DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }
}
