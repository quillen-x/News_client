import 'package:data_statistics/models/kr36_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';

class Kr36Page extends StatelessWidget {
  final List<Kr36DetailModel> modelList;
  const Kr36Page({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '36氪推荐',
      accentColor: const Color(0xFF168EFF),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final element = modelList[index];
          return NewsListItem(
            title: element.title,
            subtitle: (element.summary != null && element.summary!.isNotEmpty)
                ? element.summary
                : null,
            onTap: () {
              NewsWebViewPage.open(
                context,
                title: element.title,
                url: element.url,
              );
            },
          );
        },
      ),
    );
  }
}
