import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'platform_section_header.dart';

/// 单个资讯平台的面板容器：标题 + 条数 + 可滚动列表。
class PlatformNewsPanel extends StatelessWidget {
  final String title;
  final Color accentColor;
  final int itemCount;
  final Widget child;

  const PlatformNewsPanel({
    super.key,
    required this.title,
    required this.accentColor,
    required this.itemCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final panelColor = isDark ? const Color(0xFF14171E) : const Color(0xFFFFFFFF);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformSectionHeader(
            title: title,
            color: accentColor,
            itemCount: itemCount,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
