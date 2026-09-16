import 'dart:async';

import 'package:data_statistics/db/db_helper.dart';
import 'package:data_statistics/models/baidu_model.dart' as baidu;
import 'package:data_statistics/models/hupu_model.dart';
import 'package:data_statistics/models/hupu_nba_model.dart';
import 'package:data_statistics/models/huxiu_model.dart';
import 'package:data_statistics/models/ithome_model.dart';
import 'package:data_statistics/models/juejin_model.dart';
import 'package:data_statistics/models/kr36_model.dart';
import 'package:data_statistics/models/netease_model.dart';
import 'package:data_statistics/models/qqmusic_model.dart';
import 'package:data_statistics/models/sohu_model.dart';
import 'package:data_statistics/models/weibo_model.dart' as weibo;
import 'package:data_statistics/models/zhihu_model.dart';
import 'package:data_statistics/pages/news_page/hupu_nba_page.dart';
import 'package:data_statistics/pages/news_page/hupu_page.dart';
import 'package:data_statistics/pages/news_page/huxiu_page.dart';
import 'package:data_statistics/pages/news_page/ithome_page.dart';
import 'package:data_statistics/pages/news_page/juejin_page.dart';
import 'package:data_statistics/pages/news_page/kr36_page.dart';
import 'package:data_statistics/pages/news_page/netease_page.dart';
import 'package:data_statistics/pages/news_page/qqmusic_page.dart';
import 'package:data_statistics/pages/news_page/weibo_page.dart';
import 'package:data_statistics/pages/news_page/zhihu_page.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/request/api.dart';
import 'package:data_statistics/widgets/theme_settings_button.dart';
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
  List<Kr36DetailModel> kr36DetailModelList = [];
  List<HuxiuDetailModel> huxiuDetailModelList = [];
  List<IthomeDetailModel> ithomeDetailModelList = [];
  List<JuejinDetailModel> juejinDetailModelList = [];
  List<HupuDetailModel> hupuDetailModelList = [];
  List<QqMusicDetailModel> qqMusicDetailModelList = [];
  List<NeteaseDetailModel> neteaseDetailModelList = [];
  List<HupuNbaDetailModel> hupuNbaDetailModelList = [];

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 10), (_) => refresh());
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
        getKr36Data(),
        getHuxiuData(),
        getIthomeData(),
        getJuejinData(),
        getHupuData(),
        getQqMusicData(),
        getNeteaseData(),
        getHupuNbaData(),
      ]);

      await getAllNews();
    } catch (e, st) {
      debugPrint('[Home] 刷新失败: $e\n$st');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> getAllNews() async {
    await DbHelper.instance.getDb();

    final results = await Future.wait([
      DbHelper.instance.zhihuTable.query(),
      DbHelper.instance.baiduTable.query(),
      DbHelper.instance.weiboTable.query(),
      DbHelper.instance.sohuTable.query(),
      DbHelper.instance.kr36Table.query(),
      DbHelper.instance.huxiuTable.query(),
      DbHelper.instance.ithomeTable.query(),
      DbHelper.instance.juejinTable.query(),
      DbHelper.instance.hupuTable.query(),
      DbHelper.instance.qqMusicTable.query(),
      DbHelper.instance.neteaseTable.query(),
      DbHelper.instance.hupuNbaTable.query(),
    ]);

    if (!mounted) return;

    setState(() {
      zHDetailModelList = results[0] as List<ZHDetailModel>;
      dDDetailModelList = results[1] as List<baidu.BDDetailModel>;
      wbDetailModelList = results[2] as List<weibo.WBDetailModel>;
      sohuDetailModelList = results[3] as List<SohuDetailModel>;
      kr36DetailModelList = results[4] as List<Kr36DetailModel>;
      huxiuDetailModelList = results[5] as List<HuxiuDetailModel>;
      ithomeDetailModelList = results[6] as List<IthomeDetailModel>;
      juejinDetailModelList = results[7] as List<JuejinDetailModel>;
      hupuDetailModelList = results[8] as List<HupuDetailModel>;
      qqMusicDetailModelList = results[9] as List<QqMusicDetailModel>;
      neteaseDetailModelList = results[10] as List<NeteaseDetailModel>;
      hupuNbaDetailModelList = results[11] as List<HupuNbaDetailModel>;
    });
  }

  Future<void> getSohuData() async {
    final list = await Api.getSohuNbaNews();
    if (list.isEmpty) return;
    await DbHelper.instance.sohuTable.insertHotBatch(list);
  }

  Future<void> getKr36Data() async {
    final list = await Api.getKr36News();
    if (list.isEmpty) return;
    await DbHelper.instance.kr36Table.insertHotBatch(list);
  }

  Future<void> getHuxiuData() async {
    final list = await Api.getHuxiuNews();
    if (list.isEmpty) return;
    await DbHelper.instance.huxiuTable.insertHotBatch(list);
  }

  Future<void> getIthomeData() async {
    final list = await Api.getIthomeHotNews();
    if (list.isEmpty) return;
    await DbHelper.instance.ithomeTable.insertHotBatch(list);
  }

  Future<void> getJuejinData() async {
    final list = await Api.getJuejinNews();
    if (list.isEmpty) return;
    await DbHelper.instance.juejinTable.insertHotBatch(list);
  }

  Future<void> getHupuData() async {
    final list = await Api.getHupuBxjNews();
    if (list.isEmpty) return;
    await DbHelper.instance.hupuTable.insertHotBatch(list);
  }

  Future<void> getQqMusicData() async {
    final list = await Api.getQqMusicHotSongs();
    if (list.isEmpty) return;
    await DbHelper.instance.qqMusicTable.insertHotBatch(list);
  }

  Future<void> getNeteaseData() async {
    final list = await Api.getNeteaseHotSongs();
    if (list.isEmpty) return;
    await DbHelper.instance.neteaseTable.insertHotBatch(list);
  }

  Future<void> getHupuNbaData() async {
    final list = await Api.getHupuNbaNews();
    if (list.isEmpty) return;
    await DbHelper.instance.hupuNbaTable.insertHotBatch(list);
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

      final thumbnail = zhModel.children?.firstOrNull?.thumbnail ??
          target!.imageUrl;

      items.add(ZHDetailModel(
        id: target!.id!,
        title: target.title!,
        url: target.url!,
        type: target.type!,
        created: target.created!.toString(),
        excerpt: target.excerpt!,
        thumbnail: thumbnail,
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
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                child: newsWidget(),
              ),
            ),
          ),
          const ThemeSettingsButton(),
        ],
      ),
    );
  }

  Widget newsWidget() {
    final platforms = <Widget>[
      WeiboPage(modelList: wbDetailModelList),
      ZhihuPage(modelList: zHDetailModelList),
      BaiduPage(modelList: dDDetailModelList),
      SohuPage(modelList: sohuDetailModelList),
      Kr36Page(modelList: kr36DetailModelList),
      HuxiuPage(modelList: huxiuDetailModelList),
      IthomePage(modelList: ithomeDetailModelList),
      JuejinPage(modelList: juejinDetailModelList),
      HupuPage(modelList: hupuDetailModelList),
      QqMusicPage(modelList: qqMusicDetailModelList),
      NeteasePage(modelList: neteaseDetailModelList),
      HupuNbaPage(modelList: hupuNbaDetailModelList),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        final rowGap = 6.h;
        final colGap = 6.w;
        final halfHeight = (constraints.maxHeight - rowGap) / 2;
        final rows = <Widget>[];

        for (var i = 0; i < platforms.length; i += columns) {
          final rowChildren = platforms.skip(i).take(columns).toList();
          if (rows.isNotEmpty) {
            rows.add(SizedBox(height: rowGap));
          }
          rows.add(
            SizedBox(
              height: halfHeight,
              child: _buildPlatformRow(rowChildren, columns, colGap),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: rows),
        );
      },
    );
  }

  Widget _buildPlatformRow(List<Widget> children, int columns, double gap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: i < children.length ? children[i] : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}
