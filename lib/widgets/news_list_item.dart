import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 统一的资讯列表项：排名 + 标题，带桌面悬停反馈。
class NewsListItem extends StatefulWidget {
  final String title;
  final int titleMaxLines;
  final int? rank;
  final Widget? leading;
  final VoidCallback onTap;

  const NewsListItem({
    super.key,
    required this.title,
    this.titleMaxLines = 2,
    this.rank,
    this.leading,
    required this.onTap,
  });

  @override
  State<NewsListItem> createState() => _NewsListItemState();
}

class _NewsListItemState extends State<NewsListItem> {
  bool _hovering = false;

  Color _rankColor(int rank, bool isDark) {
    switch (rank) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFFB8C00);
      case 3:
        return const Color(0xFFE6B422);
      default:
        return isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hoverColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovering ? hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(6.r),
            hoverColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.rank != null) ...[
                    SizedBox(
                      width: 20.w,
                      child: Text(
                        '${widget.rank}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: widget.rank! <= 3
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: 1.4,
                          color: _rankColor(widget.rank!, isDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
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
                        height: 1.4,
                        color: _hovering
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                                alpha: isDark ? 0.88 : 0.92,
                              ),
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
