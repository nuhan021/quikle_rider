import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';

const double _heading1Size = 24;
const double _heading2Size = 20;
const double _heading3Size = 18;
const double _bodySize = 16;

TextStyle _buildStyle(
  CustomFonts font,
  double fontSize,
  FontWeight fontWeight, {
  double? lineHeight,
  Color? color,
}) {
  final scaledSize = fontSize.sp;
  final String? fontFamily;

  switch (font) {
    case CustomFonts.obviously:
      fontFamily = 'Obviously';
      break;
    case CustomFonts.manrope:
      fontFamily = 'Manrope';
      break;
    case CustomFonts.poppins:
      fontFamily = 'Poppins';
      break;
    case CustomFonts.inter:
    fontFamily = 'Inter';
      break;
  }

  return TextStyle(
    fontFamily: fontFamily,
    fontSize: scaledSize,
    fontWeight: fontWeight,
    height: lineHeight,
    color: color,
  );
}

TextStyle getTextStyle({
  CustomFonts font = CustomFonts.inter,
  double fontSize = _bodySize,
  FontWeight fontWeight = FontWeight.w400,
  double? lineHeight,
  Color? color,
}) =>
    _buildStyle(
      font,
      fontSize,
      fontWeight,
      lineHeight: lineHeight,
      color: color,
    );

TextStyle getTextStyle2({
  double fontSize = _bodySize,
  FontWeight fontWeight = FontWeight.w400,
  double? lineHeight,
  Color color = Colors.black,
}) =>
    _buildStyle(
      CustomFonts.inter,
      fontSize,
      fontWeight,
      lineHeight: lineHeight,
      color: color,
    );

TextStyle headingStyle1({
  Color? color,
  CustomFonts font = CustomFonts.inter,
  double? lineHeight,
}) =>
    _buildStyle(
      font,
      _heading1Size,
      FontWeight.w700,
      lineHeight: lineHeight,
      color: color,
    );

TextStyle headingStyle2({
  Color? color,
  CustomFonts font = CustomFonts.inter,
  double? lineHeight,
}) =>
    _buildStyle(
      font,
      _heading2Size,
      FontWeight.w700,
      lineHeight: lineHeight,
      color: color,
    );

TextStyle headingStyle3({
  Color? color,
  CustomFonts font = CustomFonts.inter,
  double? lineHeight,
}) =>
    _buildStyle(
      font,
      _heading3Size,
      FontWeight.w700,
      lineHeight: lineHeight,
      color: color,
    );

TextStyle bodyTextStyle({
  Color? color,
  FontWeight fontWeight = FontWeight.w400,
  double? lineHeight,
  CustomFonts font = CustomFonts.inter,
}) =>
    _buildStyle(
      font,
      _bodySize,
      fontWeight,
      lineHeight: lineHeight,
      color: color,
    );

TextStyle buttonTextStyle({
  Color? color,
  FontWeight fontWeight = FontWeight.w600,
  double? lineHeight,
  CustomFonts font = CustomFonts.inter,
}) =>
    _buildStyle(
      font,
      _bodySize,
      fontWeight,
      lineHeight: lineHeight,
      color: color,
    );
