import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
  switch (font) {
    case CustomFonts.obviously:
      return TextStyle(
        fontFamily: 'Obviously',
        fontSize: scaledSize,
        fontWeight: fontWeight,
        height: lineHeight,
        color: color,
      );
    case CustomFonts.manrope:
      return GoogleFonts.manrope(
        fontSize: scaledSize,
        fontWeight: fontWeight,
        height: lineHeight,
        color: color,
      );
    case CustomFonts.poppins:
      return GoogleFonts.poppins(
        fontSize: scaledSize,
        fontWeight: fontWeight,
        height: lineHeight,
        color: color,
      );
    case CustomFonts.inter:
    default:
      return GoogleFonts.inter(
        fontSize: scaledSize,
        fontWeight: fontWeight,
        height: lineHeight,
        color: color,
      );
  }
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
