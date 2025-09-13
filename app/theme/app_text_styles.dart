import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app32/app/theme/app_colors.dart';

class AppTextStyles {
  static final TextStyle _baseLight = GoogleFonts.roboto(
    color: AppColors.gray[900],
  );

  static final TextStyle _baseDark = GoogleFonts.roboto(
    color: AppColors.gray[900],
  );

  static final textThemeLight = TextTheme(
    displayLarge: _baseLight.copyWith(fontSize: 36.0),
    displayMedium: _baseLight.copyWith(fontSize: 32.0),
    displaySmall: _baseLight.copyWith(fontSize: 28.0),
    headlineMedium: _baseLight.copyWith(fontSize: 24.0),
    headlineSmall: _baseLight.copyWith(fontSize: 20.0),
    titleLarge: _baseLight.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 18.0,
    ),
    titleMedium: _baseLight.copyWith(fontSize: 16.0),
    titleSmall: _baseLight.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 14.0,
    ),
    bodyLarge: _baseLight.copyWith(fontSize: 16.0),
    bodyMedium: _baseLight.copyWith(fontSize: 14.0),
    bodySmall: _baseLight.copyWith(fontSize: 12.0),
    labelLarge: _baseLight.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 14.0,
    ),
    labelSmall: _baseLight.copyWith(fontSize: 10.0),
  );

  static final textThemeDark = TextTheme(
    displayLarge: _baseDark.copyWith(fontSize: 36.0),
    displayMedium: _baseDark.copyWith(fontSize: 32.0),
    displaySmall: _baseDark.copyWith(fontSize: 28.0),
    headlineMedium: _baseDark.copyWith(fontSize: 24.0),
    headlineSmall: _baseDark.copyWith(fontSize: 20.0),
    titleLarge: _baseDark.copyWith(fontWeight: FontWeight.w500, fontSize: 18.0),
    titleMedium: _baseDark.copyWith(fontSize: 16.0),
    titleSmall: _baseDark.copyWith(fontWeight: FontWeight.w500, fontSize: 14.0),
    bodyLarge: _baseDark.copyWith(fontSize: 16.0),
    bodyMedium: _baseDark.copyWith(fontSize: 14.0),
    bodySmall: _baseDark.copyWith(fontSize: 12.0),
    labelLarge: _baseDark.copyWith(fontWeight: FontWeight.w500, fontSize: 14.0),
    labelSmall: _baseDark.copyWith(fontSize: 10.0),
  );
}
