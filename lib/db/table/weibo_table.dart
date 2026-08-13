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

  Future<void> insertHotBatch(List<WBDetailModel> list) async {
    if (list.isEmpty) return;

    final existing = await dDatabase.query(
      DSTableDefine.weiboTable,
      columns: ['id', 'title'],
    );
    final idByTitle = <String, int>{};
    for (final row in existing) {
      final title = row['title']?.toString();
      final id = row['id'];
      if (title != null && id is int) {
        idByTitle[title] = id;
      }
    }

    final batch = dDatabase.batch();
    for (final item in list) {
      final json = item.toJson();
      final existingId = idByTitle[item.title];
      if (existingId != null) {
        batch.update(
          DSTableDefine.weiboTable,
          json,
          where: 'id = ?',
          whereArgs: [existingId],
        );
      } else {
        batch.insert(
          DSTableDefine.weiboTable,
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
      DELETE FROM ${DSTableDefine.weiboTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.weiboTable}
        ORDER BY "create" DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }
}
