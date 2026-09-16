import 'dart:convert';

import 'package:data_statistics/models/baidu_model.dart';
import 'package:data_statistics/models/hupu_model.dart';
import 'package:data_statistics/models/huxiu_model.dart';
import 'package:data_statistics/models/ithome_model.dart';
import 'package:data_statistics/models/juejin_model.dart';
import 'package:data_statistics/models/kr36_model.dart';
import 'package:data_statistics/models/sohu_model.dart';
import 'package:data_statistics/models/weibo_model.dart' as weibo;
import 'package:data_statistics/models/zhihu_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Api {
  static const _defaultUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': _defaultUserAgent,
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      },
    ),
  );

  static Future<List<BDDetailModel>> getBaiduNews() async {
    try {
      final response = await _dio.get(
        'https://top.baidu.com/api/board?platform=wise&tab=realtime',
        options: Options(headers: {
          'Host': 'top.baidu.com',
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Mobile Safari/537.36',
          'Referer': 'https://top.baidu.com/board?tab=realtime',
        }),
      );
      final cards = response.data?['data']?['cards'] as List?;
      if (cards == null || cards.isEmpty) return [];

      final outerContent = cards[0]['content'] as List?;
      if (outerContent == null || outerContent.isEmpty) return [];

      final innerContent = outerContent[0]['content'] as List?;
      if (innerContent == null) return [];

      final updateTime =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      return innerContent.map((item) {
        final map = item as Map<String, dynamic>;
        final word = map['word'] as String? ?? '';
        final url = map['url'] as String? ?? '';
        final img = map['img']?.toString();
        return BDDetailModel(
          appUrl: url,
          desc: map['desc']?.toString() ?? '',
          hotScore: map['hotScore']?.toString() ??
              map['hotTag']?.toString() ??
              map['index']?.toString() ??
              '',
          img: (img != null && img.isNotEmpty) ? img : null,
          query: word,
          rawUrl: url,
          url: url,
          word: word,
          updateTime: updateTime,
        );
      }).where((item) => item.word.isNotEmpty).toList();
    } catch (e, st) {
      debugPrint('[Api] 百度热搜失败: $e\n$st');
      return [];
    }
  }

  static Future<List<ZHModel>> getZhihuNews() async {
    try {
      final response = await _dio.get(
        'https://api.zhihu.com/topstory/hot-list',
        options: Options(headers: {
          'Referer': 'https://www.zhihu.com/',
        }),
      );
      final zhiHuModel = ZhiHuModel.fromJson(response.data);
      return zhiHuModel.data ?? [];
    } catch (e, st) {
      debugPrint('[Api] 知乎热榜失败: $e\n$st');
      return [];
    }
  }

  static Future<List<weibo.WBDetailModel>> getWeiboNews() async {
    const urls = [
      'https://weibo.com/ajax/side/hotSearch',
      'https://www.weibo.com/ajax/side/hotSearch',
    ];

    Object? lastError;
    StackTrace? lastStack;

    for (final url in urls) {
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          if (attempt > 0) {
            await Future<void>.delayed(const Duration(milliseconds: 400));
          }
          final response = await _dio.get(
            url,
            options: Options(headers: {
              'Referer': 'https://weibo.com/',
              'Origin': 'https://weibo.com',
            }),
          );
          final body = _asJsonMap(response.data);
          if (body['ok'] != 1) continue;

          final realtime = body['data']?['realtime'] as List?;
          if (realtime == null) continue;

          final create = DateTime.now().millisecondsSinceEpoch.toString();
          return realtime.map((item) {
            final map = item as Map<String, dynamic>;
            final title =
                map['note'] as String? ?? map['word'] as String? ?? '';
            final word = map['word'] as String? ?? title;
            return weibo.WBDetailModel(
              title: title,
              scheme:
                  'https://s.weibo.com/weibo?q=${Uri.encodeComponent(word)}',
              itemid: map['realpos']?.toString() ?? word,
              create: create,
            );
          }).where((item) => item.title.isNotEmpty).toList();
        } catch (e, st) {
          lastError = e;
          lastStack = st;
          final isDnsError = e.toString().contains('Failed host lookup') ||
              e.toString().contains('SocketException');
          if (!isDnsError) break;
        }
      }
    }

    debugPrint('[Api] 微博热搜失败: $lastError\n$lastStack');
    return [];
  }

  static Future<List<SohuDetailModel>> getSohuNbaNews() async {
    const pageUrl = 'https://sports.sohu.com/s/nba';
    try {
      final response = await _dio.get(
        pageUrl,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Referer': 'https://sports.sohu.com/',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );
      final html = response.data?.toString() ?? '';
      final blockData = _parseBlockRenderData(html);
      if (blockData == null) return [];
      return _parseFeedConstsizeText(blockData);
    } catch (e, st) {
      debugPrint('[Api] 搜狐 NBA 失败: $e\n$st');
      return [];
    }
  }

  static Future<List<Kr36DetailModel>> getKr36News() async {
    const pageUrl = 'https://www.36kr.com/information/web_news/latest/';
    try {
      final response = await _dio.get(
        pageUrl,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Referer': 'https://www.36kr.com/',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );
      final html = response.data?.toString() ?? '';
      final initialState = _parseWindowJson(html, 'window.initialState=');
      if (initialState == null) return [];

      final itemList =
          initialState['information']?['informationList']?['itemList'];
      if (itemList is! List) return [];

      final articles = <Kr36DetailModel>[];
      for (final item in itemList) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final material = map['templateMaterial'];
        if (material is! Map) continue;
        final materialMap = Map<String, dynamic>.from(material);

        final itemId = map['itemId']?.toString() ??
            materialMap['itemId']?.toString() ??
            '';
        final title = materialMap['widgetTitle']?.toString() ?? '';
        if (itemId.isEmpty || title.isEmpty) continue;

        final publishTime = materialMap['publishTime'];
        articles.add(Kr36DetailModel(
          title: title,
          url: 'https://www.36kr.com/p/$itemId',
          summary: materialMap['summary']?.toString(),
          itemid: itemId,
          create: publishTime?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      }
      return articles.take(60).toList();
    } catch (e, st) {
      debugPrint('[Api] 36氪资讯失败: $e\n$st');
      return [];
    }
  }

  static Future<List<HuxiuDetailModel>> getHuxiuNews() async {
    try {
      final response = await _dio.get(
        'https://api-article.huxiu.com/web/article/articleList',
        queryParameters: {
          'platform': 'www',
          'page': 1,
        },
        options: Options(headers: {
          'Referer': 'https://www.huxiu.com/article/',
          'Origin': 'https://www.huxiu.com',
          'Accept': 'application/json, text/plain, */*',
        }),
      );
      final body = _asJsonMap(response.data);
      final list = body['data']?['dataList'];
      if (list is! List) return [];

      final articles = <HuxiuDetailModel>[];
      for (final item in list) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final aid = map['aid']?.toString() ?? '';
        final title = map['title']?.toString() ?? '';
        if (aid.isEmpty || title.isEmpty) continue;

        final summary = map['summary']?.toString();
        articles.add(HuxiuDetailModel(
          title: title,
          url: 'https://www.huxiu.com/article/$aid.html',
          summary: (summary != null && summary.isNotEmpty) ? summary : null,
          itemid: aid,
          create: map['dateline']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      }
      return articles.take(60).toList();
    } catch (e, st) {
      debugPrint('[Api] 虎嗅资讯失败: $e\n$st');
      return [];
    }
  }

  static Future<List<IthomeDetailModel>> getIthomeHotNews() async {
    try {
      final response = await _dio.get(
        'https://www.ithome.com/block/rank.html',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Referer': 'https://www.ithome.com/',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );
      final html = response.data?.toString() ?? '';
      return _parseIthomeDailyRank(html);
    } catch (e, st) {
      debugPrint('[Api] IT之家热榜失败: $e\n$st');
      return [];
    }
  }

  /// 解析 IT之家日榜（#d-1）
  static List<IthomeDetailModel> _parseIthomeDailyRank(String html) {
    final start = html.indexOf('id="d-1"');
    if (start == -1) return [];
    final end = html.indexOf('id="d-2"', start);
    final section = end == -1 ? html.substring(start) : html.substring(start, end);

    final pattern = RegExp(
      r'<a[^>]*href="(https://www\.ithome\.com/\d+/\d+/\d+\.htm)"[^>]*>(.*?)</a>',
      caseSensitive: false,
      dotAll: true,
    );

    final articles = <IthomeDetailModel>[];
    final seen = <String>{};
    final baseTime = DateTime.now().millisecondsSinceEpoch;
    var index = 0;

    for (final match in pattern.allMatches(section)) {
      final url = match.group(1) ?? '';
      var title = (match.group(2) ?? '')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .trim();
      if (url.isEmpty || title.isEmpty || !seen.add(url)) continue;

      articles.add(IthomeDetailModel(
        title: title,
        url: url,
        itemid: url,
        create: (baseTime - index).toString(),
      ));
      index++;
    }
    return articles.take(60).toList();
  }

  static Future<List<JuejinDetailModel>> getJuejinNews() async {
    try {
      final response = await _dio.post(
        'https://api.juejin.cn/recommend_api/v1/article/recommend_all_feed',
        queryParameters: {
          'aid': 2608,
          'uuid': 0,
          'spider': 0,
        },
        data: {
          'id_type': 2,
          'client_type': 2608,
          'sort_type': 300, // 最新
          'cursor': '0',
          'limit': 20,
        },
        options: Options(headers: {
          'Referer': 'https://juejin.cn/?sort=newest',
          'Origin': 'https://juejin.cn',
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
        }),
      );
      final body = _asJsonMap(response.data);
      final list = body['data'];
      if (list is! List) return [];

      final articles = <JuejinDetailModel>[];
      for (final item in list) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final itemInfo = map['item_info'];
        if (itemInfo is! Map) continue;
        final infoMap = Map<String, dynamic>.from(itemInfo);
        final articleInfo = infoMap['article_info'];
        if (articleInfo is! Map) continue;
        final article = Map<String, dynamic>.from(articleInfo);

        final articleId = article['article_id']?.toString() ??
            infoMap['article_id']?.toString() ??
            '';
        final title = article['title']?.toString() ?? '';
        if (articleId.isEmpty || title.isEmpty) continue;

        final brief = article['brief_content']?.toString();
        articles.add(JuejinDetailModel(
          title: title,
          url: 'https://juejin.cn/post/$articleId',
          summary: (brief != null && brief.isNotEmpty) ? brief : null,
          itemid: articleId,
          create: article['ctime']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      }
      return articles.take(60).toList();
    } catch (e, st) {
      debugPrint('[Api] 掘金最新失败: $e\n$st');
      return [];
    }
  }

  static Future<List<HupuDetailModel>> getHupuBxjNews() async {
    try {
      final response = await _dio.get(
        'https://bbs.hupu.com/bxj',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Referer': 'https://bbs.hupu.com/',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );
      final html = response.data?.toString() ?? '';
      return _parseHupuBxj(html);
    } catch (e, st) {
      debugPrint('[Api] 虎扑步行街失败: $e\n$st');
      return [];
    }
  }

  /// 解析虎扑步行街主干道帖子列表
  static List<HupuDetailModel> _parseHupuBxj(String html) {
    final pattern = RegExp(
      r'href="(/\d+\.html)"[^>]*class="[^"]*p-title[^"]*"[^>]*>(.*?)</a>',
      caseSensitive: false,
      dotAll: true,
    );

    final articles = <HupuDetailModel>[];
    final seen = <String>{};
    final baseTime = DateTime.now().millisecondsSinceEpoch;
    var index = 0;

    for (final match in pattern.allMatches(html)) {
      final path = match.group(1) ?? '';
      var title = _stripHtml(match.group(2) ?? '');
      if (path.isEmpty || title.isEmpty || !seen.add(path)) continue;

      articles.add(HupuDetailModel(
        title: title,
        url: 'https://bbs.hupu.com$path',
        itemid: path,
        create: (baseTime - index).toString(),
      ));
      index++;
    }
    return articles.take(60).toList();
  }

  static String _stripHtml(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  /// 仅解析 feed-constsize-text-pc 模块的纯文字新闻
  static List<SohuDetailModel> _parseFeedConstsizeText(
    Map<String, dynamic> blockData,
  ) {
    final block = blockData['feed-constsize-text-pc'];
    if (block is! Map) return [];

    final param = block['param'];
    if (param is! Map) return [];

    final dataWrapper = param['data'];
    if (dataWrapper is! Map) return [];

    final items = dataWrapper['data'];
    if (items is! List) return [];

    final articles = <SohuDetailModel>[];
    final baseTime = DateTime.now().millisecondsSinceEpoch;
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final title = map['title']?.toString();
      final urlRaw = map['url']?.toString();
      if (title == null ||
          title.isEmpty ||
          urlRaw == null ||
          !_isSohuArticleUrl(urlRaw)) {
        continue;
      }

      articles.add(SohuDetailModel(
        title: title,
        url: _normalizeSohuUrl(urlRaw),
        itemid: map['id']?.toString() ?? urlRaw,
        create: (baseTime - index).toString(),
      ));
    }
    return articles.take(60).toList();
  }

  static Map<String, dynamic>? _parseBlockRenderData(String html) {
    return _parseWindowJson(html, 'window.blockRenderData = ');
  }

  static Map<String, dynamic>? _parseWindowJson(String html, String marker) {
    final idx = html.indexOf(marker);
    if (idx == -1) return null;

    final start = html.indexOf('{', idx);
    if (start == -1) return null;

    var depth = 0;
    for (var i = start; i < html.length; i++) {
      final char = html[i];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          return Map<String, dynamic>.from(
            json.decode(html.substring(start, i + 1)) as Map,
          );
        }
      }
    }
    return null;
  }

  static bool _isSohuArticleUrl(String url) {
    return url.contains('sohu.com/a/') || url.startsWith('/a/');
  }

  static String _normalizeSohuUrl(String url) {
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return 'https://www.sohu.com$url';
    return url;
  }

  static Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      return Map<String, dynamic>.from(json.decode(data) as Map);
    }
    throw FormatException('Unexpected response type: ${data.runtimeType}');
  }
}
