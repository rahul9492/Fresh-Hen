import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import '../../core/constants/spacing.dart';

/// The display face: Fraunces, a warm, soft serif that gives headings, titles
/// and prices a crafted, farm-shop feel. Body text stays Plus Jakarta Sans.
/// Bundled in assets/google_fonts (SemiBold and Bold), so it never downloads.
abstract final class AppType {
  static TextStyle display({
    double size = 18,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        // Only SemiBold and Bold are bundled.
        fontWeight: weight.value >= 700 ? FontWeight.w700 : FontWeight.w600,
        color: color,
        height: height,
        letterSpacing: -0.2,
      );
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: Colors.white,
    );
    // Body text: Plus Jakarta Sans. Headings: Fraunces (see [AppType]).
    final base = GoogleFonts.plusJakartaSansTextTheme();
    final textTheme = base
        .copyWith(
          headlineMedium: AppType.display(size: 28, weight: FontWeight.w700, height: 1.2),
          headlineSmall: AppType.display(size: 24, weight: FontWeight.w700, height: 1.2),
          titleLarge: AppType.display(size: 21),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        foregroundColor: AppColors.ink,
        // AppBar reapplies its own overlay style, so keep the system buttons dark here too.
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        // indicatorColor: AppColors.accentSoft,
        indicatorColor: Colors.transparent, // the animated icon marks the selected tab
        surfaceTintColor: Colors.transparent,
        // No grey pill behind a tab while it is pressed or selected.
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        // A clearer pill than the default faint one.
        dragHandleColor: Color(0xFFD3D5DC),
        dragHandleSize: Size(44, 5),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
    );
  }
}
