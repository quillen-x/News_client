import 'package:data_statistics/models/sohu_model.dart';
import 'package:data_statistics/pages/news_webview_page.dart';
import 'package:data_statistics/widgets/platform_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';

class SohuPage extends StatelessWidget {
  final List<SohuDetailModel> modelList;
  const SohuPage({super.key, required this.modelList});

  @override
  Widget build(BuildContext context) {
    return GroupedListView<SohuDetailModel, String>(
      elements: modelList,
      groupBy: (element) {
        final time = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.create),
        ).toString();
        return time.substring(0, 10);
      },
      groupSeparatorBuilder: (String groupByValue) {
        return const PlatformSectionHeader(
          title: '搜狐 NBA',
          color: Color(0xFFFF6600),
        );
      },
      itemBuilder: (context, SohuDetailModel element) {
        final timeTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(element.create),
        ).toString().substring(0, 16);
        return InkWell(
          onTap: () {
            NewsWebViewPage.open(
              context,
              title: element.title,
              url: element.url,
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
      itemComparator: (item1, item2) {
        final id1 = item1.id ?? 0;
        final id2 = item2.id ?? 0;
        return id2.compareTo(id1);
      },
      useStickyGroupSeparators: false,
      floatingHeader: false,
      order: GroupedListOrder.DESC,
    );
  }
}
