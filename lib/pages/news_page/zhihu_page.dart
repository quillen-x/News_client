import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_statistics/models/zhihu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/platform_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';

class ZhihuPage extends StatelessWidget {
  final List<ZHDetailModel> modelList;
  const ZhihuPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return GroupedListView<ZHDetailModel, String>(
      elements: modelList,
      groupBy: (element) {
        final timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.created) * 1000,
        ).toString();
        return timeTime.substring(0, 10);
      },
      groupSeparatorBuilder: (String groupByValue) {
        return const PlatformSectionHeader(
          title: '知乎热榜',
          color: Color(0xFF0066FF),
        );
      },
      itemBuilder: (context, ZHDetailModel element) {
        final timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.created) * 1000,
        ).toString().substring(0, 16);
        final hasImage =
            element.thumbnail != null && element.thumbnail!.isNotEmpty;
        final imageHeight = 120.h * 0.618;
        return InkWell(
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
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage) ...[
                      CachedNetworkImage(
                        imageUrl: element.thumbnail!,
                        width: 120.w,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return SizedBox(width: 120.w, height: imageHeight);
                        },
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            element.title,
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
                SizedBox(height: 4.h),
                Text(
                  element.excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
      itemComparator: (item1, item2) => item1.created.compareTo(item2.created),
      useStickyGroupSeparators: false,
      floatingHeader: false,
      order: GroupedListOrder.DESC,
    );
  }
}
