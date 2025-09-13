import 'package:flutter/material.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/app/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData themeData() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'IRANSansWeb',
      primaryColor: AppColors.primaryColor,
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: AppTextStyles.textThemeDark,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: AppTextStyles.textThemeDark.bodyMedium,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
        color: AppColors.primaryColor,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // BoxShadow reusable styling
  static BoxShadow getBoxShadow() {
    return const BoxShadow(
      color: AppColors.shadowColor,
      offset: Offset(0, 3),
      blurRadius: 9,
      spreadRadius: 0,
    );
  }
}
