import 'package:data_statistics/db/table_define.dart';
import 'package:data_statistics/db/table_operation.dart';
import 'package:data_statistics/models/zhihu_model.dart';
import 'package:sqflite/sqlite_api.dart';

class ZhihuTable extends TableOperation {
  Future<List<ZHDetailModel>> query() async {
    final data = await dDatabase.query(
      DSTableDefine.zhihuTable,
      orderBy: 'created DESC',
      limit: DSTableDefine.maxHotRecords,
    );
    return List.generate(data.length, (index) {
      return ZHDetailModel.fromJson(data[index]);
    });
  }

  Future<void> insertHotBatch(List<ZHDetailModel> list) async {
    if (list.isEmpty) return;

    final batch = dDatabase.batch();
    for (final item in list) {
      batch.insert(
        DSTableDefine.zhihuTable,
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
      DELETE FROM ${DSTableDefine.zhihuTable}
      WHERE id NOT IN (
        SELECT id FROM ${DSTableDefine.zhihuTable}
        ORDER BY created DESC
        LIMIT ?
      )
    ''', [DSTableDefine.maxHotRecords]);
  }
}
