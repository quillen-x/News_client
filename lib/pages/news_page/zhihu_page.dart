import 'package:data_statistics/models/zhihu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';

class ZhihuPage extends StatelessWidget {
  final List<ZHDetailModel> modelList;
  const ZhihuPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '知乎热榜',
      accentColor: const Color(0xFF0066FF),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final element = modelList[index];
          return NewsListItem(
            title: element.title,
            onTap: () {
              final url = element.type == 'question'
                  ? 'https://www.zhihu.com/question/${element.id}'
                  : 'https://zhuanlan.zhihu.com/p/${element.id}';
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
