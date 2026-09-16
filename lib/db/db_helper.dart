import 'dart:io';

import 'package:data_statistics/db/table/baidu_table.dart';
import 'package:data_statistics/db/table/hupu_table.dart';
import 'package:data_statistics/db/table/huxiu_table.dart';
import 'package:data_statistics/db/table/ithome_table.dart';
import 'package:data_statistics/db/table/juejin_table.dart';
import 'package:data_statistics/db/table/kr36_table.dart';
import 'package:data_statistics/db/table/sohu_table.dart';
import 'package:data_statistics/db/table/weibo_table.dart';
import 'package:data_statistics/db/table/zhihu_table.dart';
import 'package:data_statistics/db/table_define.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 数据库帮助类
class DbHelper {
  DSTableDefine dsTableDefine = DSTableDefine();
  ZhihuTable zhihuTable = ZhihuTable();
  BaiduTable baiduTable = BaiduTable();
  WeiboTable weiboTable = WeiboTable();
  SohuTable sohuTable = SohuTable();
  Kr36Table kr36Table = Kr36Table();
  HuxiuTable huxiuTable = HuxiuTable();
  IthomeTable ithomeTable = IthomeTable();
  JuejinTable juejinTable = JuejinTable();
  HupuTable hupuTable = HupuTable();

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

  Future<Database>? _db;

  Future<Database> getDb() {
    return _db ??= _initDb();
  }

  Future<Database> _initDb() async {
    Directory path = await getApplicationDocumentsDirectory();

    final db = await openDatabase(p.join(path.path, 'statistics', 'hot.db'),
        version: 5, onCreate: (db, version) {
      db.execute(dsTableDefine.createBaiduTable());
      db.execute(dsTableDefine.createZhihuTable());
      db.execute(dsTableDefine.createWeiboTable());
      db.execute(dsTableDefine.createSohuTable());
      db.execute(dsTableDefine.createKr36Table());
      db.execute(dsTableDefine.createHuxiuTable());
      db.execute(dsTableDefine.createIthomeTable());
      db.execute(dsTableDefine.createJuejinTable());
      db.execute(dsTableDefine.createHupuTable());
    }, onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) {
        await db.execute(dsTableDefine.createSohuTable());
      }
      if (oldV < 3) {
        await db.execute(dsTableDefine.createKr36Table());
      }
      if (oldV < 4) {
        await db.execute(dsTableDefine.createHuxiuTable());
        await db.execute(dsTableDefine.createIthomeTable());
      }
      if (oldV < 5) {
        await db.execute(dsTableDefine.createJuejinTable());
        await db.execute(dsTableDefine.createHupuTable());
      }
    });

    weiboTable.database = db;
    baiduTable.database = db;
    zhihuTable.database = db;
    sohuTable.database = db;
    kr36Table.database = db;
    huxiuTable.database = db;
    ithomeTable.database = db;
    juejinTable.database = db;
    hupuTable.database = db;
    return db;
  }

  close() async {
    await _db?.then((value) => value.close());
  }
}
