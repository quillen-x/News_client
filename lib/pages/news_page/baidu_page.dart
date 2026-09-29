import 'package:data_statistics/models/baidu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';

class BaiduPage extends StatelessWidget {
  final List<BDDetailModel> modelList;
  const BaiduPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '百度热搜',
      accentColor: const Color(0xFF2932E1),
      itemCount: modelList.length,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final element = modelList[index];
          return NewsListItem(
            rank: index + 1,
            title: element.word,
            onTap: () {
              final urlString = element.rawUrl.replaceFirstMapped(
                'm.baidu.com',
                (match) => 'www.baidu.com',
              );
              NewsWebViewPage.open(
                context,
                title: element.word,
                url: urlString,
              );
            },
          );
        },
      ),
    );
  }
}
