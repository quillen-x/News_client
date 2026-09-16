import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 统一的资讯列表项：标题，带桌面悬停反馈。
class NewsListItem extends StatefulWidget {
  final String title;
  final int titleMaxLines;
  final Widget? leading;
  final VoidCallback onTap;

  const NewsListItem({
    super.key,
    required this.title,
    this.titleMaxLines = 2,
    this.leading,
    required this.onTap,
  });

  @override
  State<NewsListItem> createState() => _NewsListItemState();
}

class _NewsListItemState extends State<NewsListItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hoverColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: _hovering ? hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(4.r),
            hoverColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: 6.w),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: widget.titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
