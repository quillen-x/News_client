import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark ? const Color(0xFF0B0D12) : const Color(0xFFF3F5F8);
    final onSurface = isDark ? const Color(0xFFE8EAED) : const Color(0xFF111827);
    final onSurfaceVariant =
        isDark ? const Color(0xFF8B929E) : const Color(0xFF6B7280);
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final primary = isDark ? const Color(0xFF5B9DFF) : const Color(0xFF2563EB);

    return ThemeData(
      brightness: brightness,
      fontFamily: 'AlibabaPuHuiTi',
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: isDark ? const Color(0xFF8B929E) : const Color(0xFF6B7280),
        onSecondary: isDark ? Colors.black : Colors.white,
        error: const Color(0xFFE53935),
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
      ),
      dividerColor: divider,
      textTheme: TextTheme(
        titleSmall: TextStyle(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        bodyLarge: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.4,
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
