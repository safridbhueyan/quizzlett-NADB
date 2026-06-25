import 'package:flutter/material.dart';
import 'package:quizlett/core/theme/theme_extension/app_bar_theme.dart';
import 'package:quizlett/core/theme/theme_extension/date_picker_theme.dart';
import 'package:quizlett/core/theme/theme_extension/elevated_button.dart';
import 'package:quizlett/core/theme/theme_extension/input_decoration.dart';
import 'package:quizlett/core/theme/theme_extension/time_picker.dart';
import 'package:quizlett/core/theme/theme_parts/app_color.dart';
import 'package:quizlett/core/theme/theme_parts/text_theme.dart';

class AppTheme {
  AppTheme._();
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    inputDecorationTheme: AppInputDecorationTheme.inputDecorationTheme,
    scaffoldBackgroundColor: AppColors.screenBackgroundColor,
    appBarTheme: AppAppBarTheme.darkAppBarTheme,
    elevatedButtonTheme: AppEvaluatedButtonThemes.evaluatedButtonTheme,
    textTheme: AppTextTheme.darkTextTheme,
    colorScheme: AppColors.darkColorScheme,
    timePickerTheme: CustomTimePickerTheme.timePickerTheme,
    datePickerTheme: CustomDatePickerTheme.datePickerTheme,
  );
}
