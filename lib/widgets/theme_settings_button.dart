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
    final controller = ThemeController.instance;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('主题设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('浅色主题'),
                value: ThemeMode.light,
                groupValue: controller.themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    controller.setThemeMode(mode);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('深色主题'),
                value: ThemeMode.dark,
                groupValue: controller.themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    controller.setThemeMode(mode);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      right: 0,
      bottom: 0,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: SizedBox(
          width: 80.w,
          height: 80.h,
          child: AnimatedOpacity(
            opacity: _hovering ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Material(
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showThemeMenu(context),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 20.sp,
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
