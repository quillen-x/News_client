import 'package:data_statistics/models/weibo_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';

class WeiboPage extends StatelessWidget {
  final List<WBDetailModel> modelList;
  const WeiboPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '微博热搜',
      accentColor: const Color(0xFFE6162D),
      itemCount: modelList.length,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final element = modelList[index];
          return NewsListItem(
            rank: index + 1,
            title: element.title,
            onTap: () {
              final url = element.scheme.isNotEmpty
                  ? element.scheme
                  : 'https://s.weibo.com/weibo?q=${Uri.encodeComponent(element.title)}';
              NewsWebViewPage.open(
                context,
                title: element.title,
                url: url,
              );
            },
          );
        },
      ),
    );
  }
}
