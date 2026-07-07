import 'dart:io';

import 'package:data_statistics/db/table/baidu_table.dart';
import 'package:data_statistics/db/table/sohu_table.dart';
import 'package:data_statistics/db/table/weibo_table.dart';
import 'package:data_statistics/db/table/zhihu_table.dart';
import 'package:data_statistics/db/table_define.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// 数据库帮助类
class DbHelper {
  DSTableDefine dsTableDefine = DSTableDefine();
  // CategoryTable categoryTable = CategoryTable();
  ZhihuTable zhihuTable = ZhihuTable();
  BaiduTable baiduTable = BaiduTable();
  WeiboTable weiboTable = WeiboTable();
  SohuTable sohuTable = SohuTable();

  //私有构造
  DbHelper._();
  static DbHelper? _instance;
  static DbHelper get instance => _getInstance();
  factory DbHelper() {
    return instance;
  }
  static DbHelper _getInstance() {
    _instance ??= DbHelper._();
    return _instance ?? DbHelper._();
  }

  /// 数据库默认存储的路径
  /// SQLite 数据库是文件系统中由路径标识的文件。如果是relative，
  /// 这个路径是相对于 获取的路径getDatabasesPath()，
  /// Android默认的数据库目录，
  /// iOS/MacOS的documents目录。

  Future<Database>? _db;

  Future<Database>? getDb() {
    _db ??= _initDb();
    return _db;
  }

  // Guaranteed to be called only once.保证只调用一次
  Future<Database> _initDb() async {
    // 这里是我们真正创建数据库的地方 vserion代表数据库的版本，如果版本改变
    //，则db会调用onUpgrade方法进行更新操作
    
    Directory path = await getApplicationDocumentsDirectory();
    print(p.join(path.path, 'statistics', 'hot.db'));
    
    final db = await openDatabase(p.join(path.path, 'statistics', 'hot.db'),
        version: 2, onCreate: (db, version) {
      db.execute(dsTableDefine.createCategoryTable());
      db.execute(dsTableDefine.createBaiduTable());
      db.execute(dsTableDefine.createZhihuTable());
      db.execute(dsTableDefine.createWeiboTable());
      db.execute(dsTableDefine.createSohuTable());
    }, onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) {
        await db.execute(dsTableDefine.createSohuTable());
      }
    });
    
    weiboTable.database = db;
    baiduTable.database = db;
    zhihuTable.database = db;
    sohuTable.database = db;
    return db;
  }

// 关闭数据库
  close() async {
    await _db?.then((value) => value.close());
  }
}
