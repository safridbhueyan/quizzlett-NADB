import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizlett/core/theme/theme_parts/app_color.dart';

class AppEvaluatedButtonThemes {
  AppEvaluatedButtonThemes._();

  //Light model Evaluated Button Theme
  static final evaluatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      foregroundColor: AppColors.onPrimary,
      backgroundColor: AppColors.primary,
      textStyle: GoogleFonts.nunitoSans(
        textStyle: TextStyle(fontSize: 18.sp),
        color: AppColors.onPrimary,
      ),

      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
    ),
  );
}
