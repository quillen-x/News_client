import 'package:data_statistics/models/juejin_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';

class JuejinPage extends StatelessWidget {
  final List<JuejinDetailModel> modelList;
  const JuejinPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '掘金最新',
      accentColor: const Color(0xFF1E80FF),
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
