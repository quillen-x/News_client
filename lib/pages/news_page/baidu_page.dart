import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_statistics/models/baidu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/platform_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';

class BaiduPage extends StatelessWidget {
  final List<BDDetailModel> modelList;
  const BaiduPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return GroupedListView<BDDetailModel, String>(
      elements: modelList,
      groupBy: (element) {
        final timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.updateTime) * 1000,
        ).toString();
        return timeTime.substring(0, 10);
      },
      groupSeparatorBuilder: (String groupByValue) {
        return const PlatformSectionHeader(
          title: '百度热搜',
          color: Color(0xFF2932E1),
        );
      },
      itemBuilder: (context, BDDetailModel element) {
        final timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.updateTime) * 1000,
        ).toString().substring(0, 16);
        final hasImage = element.img != null && element.img!.isNotEmpty;
        final imageHeight = 80.h * 0.618;
        return InkWell(
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
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage) ...[
                      CachedNetworkImage(
                        imageUrl: element.img!,
                        width: 80.w,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 3.w),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            element.word,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            timeTime,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (element.desc.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    element.desc,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      itemComparator: (item1, item2) =>
          item1.updateTime.compareTo(item2.updateTime),
      useStickyGroupSeparators: false,
      floatingHeader: false,
      order: GroupedListOrder.DESC,
    );
  }
}
