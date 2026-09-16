import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark ? const Color(0xFF101010) : const Color(0xFFF3F4F6);
    final onSurface = isDark ? const Color(0xFFF5F5F5) : const Color(0xFF111111);
    final onSurfaceVariant =
        isDark ? const Color(0xFFABABAB) : const Color(0xFF6B7280);
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.06);

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
        titleSmall: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        bodyLarge: TextStyle(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w500,
          color: onSurface,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.35,
        ),
      ),
    );
  }
}
