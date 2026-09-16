import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'platform_section_header.dart';

/// 单个资讯平台的面板容器：标题 + 可滚动列表。
class PlatformNewsPanel extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget child;

  const PlatformNewsPanel({
    super.key,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final panelColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFAFAFA);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformSectionHeader(title: title, color: accentColor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
