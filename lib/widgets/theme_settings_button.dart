import 'package:data_statistics/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeSettingsButton extends StatefulWidget {
  const ThemeSettingsButton({super.key});

  @override
  State<ThemeSettingsButton> createState() => _ThemeSettingsButtonState();
}

class _ThemeSettingsButtonState extends State<ThemeSettingsButton> {
  bool _hovering = false;

  void _showThemeMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return const _ThemeSettingsDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right: 0,
      bottom: 0,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: SizedBox(
          width: 72.w,
          height: 72.h,
          child: AnimatedOpacity(
            opacity: _hovering ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Material(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: 0.78),
                  elevation: 0,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showThemeMenu(context),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.palette_outlined,
                        size: 18.sp,
                        color: colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSettingsDialog extends StatelessWidget {
  const _ThemeSettingsDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 360.w),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
            child: ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) {
                final current = ThemeController.instance.themeMode;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '主题设置',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '选择界面外观',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeOptionCard(
                            label: '浅色',
                            description: '明亮清晰',
                            mode: ThemeMode.light,
                            selected: current == ThemeMode.light,
                            previewLight: true,
                            onTap: () {
                              ThemeController.instance
                                  .setThemeMode(ThemeMode.light);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _ThemeOptionCard(
                            label: '深色',
                            description: '护眼低亮',
                            mode: ThemeMode.dark,
                            selected: current == ThemeMode.dark,
                            previewLight: false,
                            onTap: () {
                              ThemeController.instance
                                  .setThemeMode(ThemeMode.dark);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatefulWidget {
  final String label;
  final String description;
  final ThemeMode mode;
  final bool selected;
  final bool previewLight;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.label,
    required this.description,
    required this.mode,
    required this.selected,
    required this.previewLight,
    required this.onTap,
  });

  @override
  State<_ThemeOptionCard> createState() => _ThemeOptionCardState();
}

class _ThemeOptionCardState extends State<_ThemeOptionCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedBorder = theme.colorScheme.onSurface;
    final idleBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);
    final hoverFill = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);

    final previewBg =
        widget.previewLight ? const Color(0xFFF3F4F6) : const Color(0xFF101010);
    final previewPanel =
        widget.previewLight ? const Color(0xFFFAFAFA) : const Color(0xFF1A1A1A);
    final previewLine = widget.previewLight
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.22);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovering || widget.selected ? hoverFill : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: widget.selected ? selectedBorder : idleBorder,
            width: widget.selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.35,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: previewBg,
                        borderRadius: BorderRadius.circular(7.r),
                        border: Border.all(
                          color: widget.previewLight
                              ? Colors.black.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: previewPanel,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: previewLine,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                ...List.generate(
                                  3,
                                  (i) => Padding(
                                    padding: EdgeInsets.only(bottom: 4.h),
                                    child: Container(
                                      width: double.infinity,
                                      height: 3.h,
                                      decoration: BoxDecoration(
                                        color: previewLine.withValues(
                                          alpha: 0.55 - i * 0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(2.r),
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
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.selected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16.sp,
                          color: selectedBorder,
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium,
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
