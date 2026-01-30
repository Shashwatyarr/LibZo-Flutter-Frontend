import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // 🔵 Title Font
  static TextStyle title({
    double fontSize = 48,
    FontWeight fontWeight = FontWeight.w700,
    Color color = const Color(0xFFD6ECFF),
    double letterSpacing = -1.2,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      shadows: shadows,
    );
  }

  // 🌙 Subtitle Font
  static TextStyle subtitle({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w300,
    Color color = const Color(0xB3FFFFFF), // White with opacity
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      shadows: shadows,
    );
  }
}
