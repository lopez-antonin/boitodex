import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingXSmall,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(AppDimens.paddingMedium),
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingXSmall,
        ),
      ),
    );
  }
}