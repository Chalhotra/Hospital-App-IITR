import 'package:flutter/material.dart';

class AppColours {
  static const Color mainColor = Color(0xFFD36C6C);
  static const Color backgroundLight = Color(0xFFFFF3F3);
  static const Color textGrey = Colors.grey;
  static const Color linkRed = Colors.redAccent;
  static const Color white = Colors.white;
  static const Color borderGrey = Color(0xFFE5E5E5);
  static const Color mutedGrey = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
  static const Color bottomIconGrey = Color(0xFFBDBDBD);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color grey2 = Color(0xFFEEEEEE);
  static const Color grey3 = Color(0xFFBDBDBD);
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: AppColours.textGrey,
  );
}

class AppDimensions {
  static const double padding = 30;
  static const double inputRadius = 10;
  static const double buttonRadius = 12;
}
