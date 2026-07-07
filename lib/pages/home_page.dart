import 'dart:async';
import 'dart:io';

import 'package:data_statistics/db/db_helper.dart';
import 'package:data_statistics/models/baidu_model.dart' as baidu;
import 'package:data_statistics/models/sohu_model.dart';
import 'package:data_statistics/models/weibo_model.dart' as weibo;
import 'package:data_statistics/models/zhihu_model.dart';
import 'package:data_statistics/pages/news_page/weibo_page.dart';
import 'package:data_statistics/pages/news_page/zhihu_page.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/request/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'news_page/baidu_page.dart';
import 'news_page/sohu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ZHDetailModel> zHDetailModelList = [];
  List<baidu.BDDetailModel> dDDetailModelList = [];
  List<weibo.WBDetailModel> wbDetailModelList = [];
  List<SohuDetailModel> sohuDetailModelList = [];

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) => refresh());
  }

  /// 启动时先读本地缓存立即展示，再后台拉取最新数据
  Future<void> _loadInitialData() async {
    await getAllNews();
    if (!mounted) return;
    refresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      debugPrint('更新时间:${DateTime.now()}');

      await Future.wait([
        getZhihuData(),
        getBaiduData(),
        getWeiboData(),
        getSohuData(),
      ]);

      await getAllNews();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> getAllNews() async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      await DbHelper.instance.getDb();
    }

    await Future.wait([
      DbHelper.instance.weiboTable.trimToMax(),
      DbHelper.instance.baiduTable.trimToMax(),
      DbHelper.instance.zhihuTable.trimToMax(),
      DbHelper.instance.sohuTable.trimToMax(),
    ]);

    final results = await Future.wait([
      DbHelper.instance.zhihuTable.query(),
      DbHelper.instance.baiduTable.query(),
      DbHelper.instance.weiboTable.query(),
      DbHelper.instance.sohuTable.query(),
    ]);

    if (!mounted) return;

    setState(() {
      zHDetailModelList = results[0] as List<ZHDetailModel>;
      dDDetailModelList = results[1] as List<baidu.BDDetailModel>;
      wbDetailModelList = results[2] as List<weibo.WBDetailModel>;
      sohuDetailModelList = results[3] as List<SohuDetailModel>;
    });
  }

  Future<void> getSohuData() async {
    final list = await Api.getSohuNbaNews();
    if (list.isEmpty) return;
    await DbHelper.instance.sohuTable.insertHotBatch(list);
  }

  Future<void> getWeiboData() async {
    final list = await Api.getWeiboNews();
    if (list.isEmpty) return;
    await DbHelper.instance.weiboTable.insertHotBatch(list);
  }

  Future<void> getZhihuData() async {
    final zhModelList = await Api.getZhihuNews();
    final items = <ZHDetailModel>[];

    for (final zhModel in zhModelList) {
      final target = zhModel.target;
      if (target?.id == null ||
          target?.title == null ||
          target?.url == null ||
          target?.type == null ||
          target?.created == null ||
          target?.excerpt == null) {
        continue;
      }

      items.add(ZHDetailModel(
        id: target!.id!,
        title: target.title!,
        url: target.url!,
        type: target.type!,
        created: target.created!.toString(),
        excerpt: target.excerpt!,
        thumbnail: zhModel.children?.firstOrNull?.thumbnail,
      ));
    }

    if (items.isEmpty) return;
    await DbHelper.instance.zhihuTable.insertHotBatch(items);
  }

  Future<void> getBaiduData() async {
    final list = await Api.getBaiduNews();
    if (list.isEmpty) return;
    await DbHelper.instance.baiduTable.insertHotBatch(list);
  }

  @override
  Widget build(BuildContext context) {
    return NewsWebViewHost(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding:  EdgeInsets.all(12.w),
          child: newsWidget(),
        ),
      ),
    );
  }

  Widget newsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: WeiboPage(modelList: wbDetailModelList),
        ),
        Expanded(
          child: ZhihuPage(modelList: zHDetailModelList),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BaiduPage(modelList: dDDetailModelList),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SohuPage(modelList: sohuDetailModelList),
        ),
      ],
    );
  }
}
