import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: Dimensions.font24,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.textColorPrimary,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font20,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.textColorPrimary,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: Dimensions.font18,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.textColorPrimary,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.textColorPrimary,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.textColorPrimary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.textColorPrimary,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.textColorSecondary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.textColorPrimary,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.textColorSecondary,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: Dimensions.font24,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.darkTextColorPrimary,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font20,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.darkTextColorPrimary,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: Dimensions.font18,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.darkTextColorPrimary,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.darkTextColorPrimary,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.darkTextColorPrimary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: Dimensions.font16,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.darkTextColorPrimary,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.darkTextColorSecondary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: Dimensions.font14,
      fontWeight: FontWeight.w600, // SemiBold
      color: AppColors.darkTextColorPrimary,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: Dimensions.font12,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.darkTextColorSecondary,
    ),
  );

  // Custom Highlight and Signature styles
  static TextStyle nameHighlightStyle({double? fontSize, Color? color}) => GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: FontWeight.w700, // Bold
    color: color,
  );

  static TextStyle signatureStyle({double? fontSize, Color? color}) => GoogleFonts.greatVibes(
    fontSize: fontSize,
    color: color,
  );
}
