import 'dart:convert';

import 'package:data_statistics/models/baidu_model.dart';
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
    try {
      final response = await _dio.get(
        'https://weibo.com/ajax/side/hotSearch',
        options: Options(headers: {
          'Referer': 'https://weibo.com/',
        }),
      );
      final body = _asJsonMap(response.data);
      if (body['ok'] != 1) return [];

      final realtime = body['data']?['realtime'] as List?;
      if (realtime == null) return [];

      final create = DateTime.now().millisecondsSinceEpoch.toString();
      return realtime.map((item) {
        final map = item as Map<String, dynamic>;
        final title = map['note'] as String? ?? map['word'] as String? ?? '';
        final word = map['word'] as String? ?? title;
        return weibo.WBDetailModel(
          title: title,
          scheme: 'https://s.weibo.com/weibo?q=${Uri.encodeComponent(word)}',
          itemid: map['realpos']?.toString() ?? word,
          create: create,
        );
      }).where((item) => item.title.isNotEmpty).toList();
    } catch (e, st) {
      debugPrint('[Api] 微博热搜失败: $e\n$st');
      return [];
    }
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
    const marker = 'window.blockRenderData = ';
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
