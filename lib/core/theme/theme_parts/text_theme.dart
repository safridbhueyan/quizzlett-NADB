import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:quizlett/core/theme/theme_parts/app_color.dart';

class AppTextTheme {
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.nunitoSans(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.textColor,
    ),

    headlineMedium: GoogleFonts.nunitoSans(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textColor,
    ),

    headlineSmall: GoogleFonts.nunitoSans(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),

    titleLarge: GoogleFonts.nunitoSans(
      fontSize: 20.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.textColor,
    ),

    titleMedium: GoogleFonts.nunitoSans(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),

    titleSmall: GoogleFonts.nunitoSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColor,
    ),

    bodyLarge: GoogleFonts.nunitoSans(
      fontSize: 18.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColor,
    ),

    bodyMedium: GoogleFonts.nunitoSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColor,
    ),

    bodySmall: GoogleFonts.nunitoSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColor,
    ),

    labelLarge: GoogleFonts.nunitoSans(
      fontSize: 14,
      color: AppColors.secondaryTextColor,
      fontWeight: FontWeight.w400,
    ),

    labelMedium: GoogleFonts.nunitoSans(
      fontSize: 12,
      color: AppColors.secondaryTextColor,
      fontWeight: FontWeight.w400,
    ),

    labelSmall: GoogleFonts.nunitoSans(
      fontSize: 11.sp,
      color: AppColors.secondaryTextColor,
      fontWeight: FontWeight.w400,
    ),
  );
}
