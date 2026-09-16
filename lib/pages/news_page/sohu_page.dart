import 'package:data_statistics/models/sohu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';

class SohuPage extends StatelessWidget {
  final List<SohuDetailModel> modelList;
  const SohuPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '搜狐 NBA',
      accentColor: const Color(0xFFFF6600),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final element = modelList[index];
          return NewsListItem(
            title: element.title,
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
