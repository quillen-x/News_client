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
        String timeTime = DateTime.fromMillisecondsSinceEpoch(
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
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (element.img != null && element.img!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: element.img!,
                      width: 80.w,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                  if (element.img != null && element.img!.isNotEmpty)
                    const SizedBox(
                      width: 3,
                    ),
                  Expanded(
                    child: SizedBox(
                      height: imageHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            element.word,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            timeTime,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              if (element.desc.isNotEmpty)
                Text(
                  element.desc,
                  maxLines: 5,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ]),
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
