import 'package:data_statistics/models/weibo_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/platform_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
class WeiboPage extends StatelessWidget {
  final List<WBDetailModel> modelList;
  const WeiboPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return  GroupedListView<WBDetailModel, String>(
      elements: modelList,
      groupBy: (element) {
        String timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.create),
        ).toString();
        return timeTime.substring(0, 10);
      },
      groupSeparatorBuilder: (String groupByValue) {
        return const PlatformSectionHeader(
          title: '微博热搜',
          color: Color(0xFFE6162D),
        );
      },
      itemBuilder: (context, WBDetailModel element) {
        final timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.create),
        ).toString().substring(0, 16);
        return InkWell(
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
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element.title,
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
        );
      },
      itemComparator: (item1, item2) => item1.create.compareTo(item2.create),
      useStickyGroupSeparators: false,
      floatingHeader: false,
      order: GroupedListOrder.DESC,
    );
  }

}
