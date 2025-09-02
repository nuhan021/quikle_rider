import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  // logo background color
  static const Color logoBg = Color(0xFF57C773);
  // Brand Colors
  static const Color primary = Color(
    0xFF1E3A5F,
  ); // Darker primary for a more professional look
  static const Color secondary = Color(
    0xFFFEC601,
  ); // Bright yellow for highlights and accents
  static const Color accent = Color(
    0xFF89A7FF,
  ); // Softer blue for a modern touch

  // Gradient Colors
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xFFFFF9A9), Color(0xFFFAD0C4), Color(0xFFFAD0C4)],
  );
  // Text Colors
  static const Color textPrimary = Color(
    0xFF212121,
  ); // Darker shade for better readability
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Neutral grey for secondary text
  static const Color textWhite = Colors.white;

  // Background Colors
  static const Color backgroundLight = Color(
    0xFFF9FAFB,
  ); // Light neutral for clean look
  static const Color backgroundDark = Color(
    0xFF121212,
  ); // Dark background for contrast in dark mode
  static const Color primaryBackground = Color(
    0xFFFFFFFF,
  ); // Pure white for primary content areas

  // Surface Colors
  static const Color surfaceLight = Color(
    0xFFE0E0E0,
  ); // Light grey for elevated surfaces
  static const Color surfaceDark = Color(
    0xFF2C2C2C,
  ); // Dark grey for elevated surfaces in dark mode

  // Container Colors
  static const Color lightContainer = Color(
    0xFFF1F8E9,
  ); // Soft green for a subtle highlight

  // Utility Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF29B6F6);

  static const Color unselected = Color(0xFFA1A1AA);
  static const Color blackText = Color(0xFF27272A);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color blackColor = Color(0xFF18181B);
  static const Color cardColor = Color(0xFFEDFCF2);

  //container color
  static const Color containerColor = Color(0xFFF9FAFB);

  //checkbox color
  static const Color checkboxColor = Color(0xFF57C773);

  //text and icon color
  static const Color textColor = Color(0xFF52525B);
  static const Color greenbutton = Color(0xFF57C773);
  static const Color bordercolor = Color(0xFFD2D6DB);
  static const Color primarytext = Color(0xFF18181B);
  static const Color hinttext = Color(0xFF71717A);

  //cards color
  static const Color cardsColor = Color(0xFFEFF8FF);
  static const Color plancardsColor = Color(0xFFFEF3F2);
  static const Color buttoncolor = Color(0xFF299DDC);
  static const Color orrenge = Color(0xFFF04438);
  static const Color button = Color(0xFFD1E9FF);
  static const Color containercolor = Color(0xFFF6FCF8);
  static const Color orrengecontainer = Color(0xFFEF6820);
  static const Color orrengebackground = Color(0xFFFEF6EE);
  static const Color greencontainer = Color(0xFFD3F8DF);
}
