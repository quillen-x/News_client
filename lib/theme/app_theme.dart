import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark ? const Color(0xFF121212) : Colors.white;
    final onSurface = isDark ? Colors.white : const Color(0xDE000000);
    final onSurfaceVariant = isDark ? Colors.white70 : const Color(0x99000000);
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return ThemeData(
      brightness: brightness,
      fontFamily: 'AlibabaPuHuiTi',
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: isDark ? Colors.white : Colors.black87,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: isDark ? Colors.white70 : Colors.black54,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
      ),
      dividerColor: divider,
      textTheme: TextTheme(
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w300,
          color: onSurfaceVariant,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w300,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
