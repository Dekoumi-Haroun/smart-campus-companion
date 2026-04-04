import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// Provides complete [ThemeData] for light and dark modes.
///
/// Both themes share the same structure (card shapes, text sizes, etc.)
/// but differ in color palette, ensuring visual consistency.
class AppTheme {
  AppTheme._();

  // ── Light Theme ──
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOnSurface,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,

        // ── Typography ──
        // Body text ≥ 14 sp, headings 20–28 sp for accessibility.
        textTheme: const TextTheme(
          displaySmall: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h3,
          titleMedium: AppTextStyles.label,
          titleSmall: AppTextStyles.label,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.button,
          labelMedium: AppTextStyles.label,
          labelSmall: AppTextStyles.caption,
        ).apply(
          bodyColor: AppColors.lightOnSurface,
          displayColor: AppColors.lightOnBackground,
        ),

        // ── AppBar ──
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightOnBackground,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
            color: AppColors.lightOnBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        // ── Bottom Navigation ──
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          elevation: 8,
        ),

        // ── Cards ──
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // ── Input Fields ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ── Elevated Buttons ──
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        // ── Divider ──
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
          space: 1,
        ),

        // ── FAB ──
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        // ── Tooltip (accessibility) ──
        tooltipTheme: TooltipThemeData(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  // ── Dark Theme ──
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: Colors.black,
          secondary: AppColors.secondaryLight,
          onSecondary: Colors.black,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,

        // ── Typography ──
        textTheme: const TextTheme(
          displaySmall: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h3,
          titleMedium: AppTextStyles.label,
          titleSmall: AppTextStyles.label,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.button,
          labelMedium: AppTextStyles.label,
          labelSmall: AppTextStyles.caption,
        ).apply(
          bodyColor: AppColors.darkOnSurface,
          displayColor: AppColors.darkOnBackground,
        ),

        // ── AppBar ──
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkOnBackground,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: AppColors.darkOnBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        // ── Bottom Navigation ──
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          elevation: 8,
        ),

        // ── Cards ──
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // ── Input Fields ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ── Elevated Buttons ──
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.black,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        // ── Divider ──
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade800,
          thickness: 1,
          space: 1,
        ),

        // ── FAB ──
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondaryLight,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        // ── Tooltip (accessibility) ──
        tooltipTheme: TooltipThemeData(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
}
