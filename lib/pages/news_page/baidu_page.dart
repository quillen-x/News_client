import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_statistics/models/baidu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/news_list_item.dart';
import 'package:data_statistics/widgets/platform_news_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaiduPage extends StatelessWidget {
  final List<BDDetailModel> modelList;
  const BaiduPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return PlatformNewsPanel(
      title: '百度热搜',
      accentColor: const Color(0xFF2932E1),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: modelList.length,
        itemBuilder: (context, index) {
          final element = modelList[index];
          final hasImage = element.img != null && element.img!.isNotEmpty;
          return NewsListItem(
            title: element.word,
            leading: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: element.img!,
                      width: 44.w,
                      height: 44.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => SizedBox(
                        width: 44.w,
                        height: 44.w,
                      ),
                    ),
                  )
                : null,
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
