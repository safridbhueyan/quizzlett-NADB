import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quizlett/core/theme/theme_parts/app_color.dart';

class AppInputDecorationTheme {
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(
      color: Color(0xff777980),
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: AppColors.fillColor,
    prefixIconColor: Color(0xffB4B4B4),
    suffixIconColor: Color(0xffB4B4B4),
    errorStyle: TextStyle(color: AppColors.error),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.screenBackgroundColor),
      borderRadius: BorderRadius.circular(12.r),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.screenBackgroundColor),
      borderRadius: BorderRadius.circular(12.r),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.circular(12.r),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.onSecondary),
      borderRadius: BorderRadius.circular(12.r),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.error),
      borderRadius: BorderRadius.circular(12.r),
    ),
  );
}
