import 'dart:ui';

import 'package:flutter/material.dart';

class Utils {
  static String colorToHex(
    Color color, {
    bool includeHashSign = false,
    bool enableAlpha = true,
    bool toUpperCase = true,
  }) {
    final String hex =
        (includeHashSign ? '#' : '') +
        (enableAlpha ? _padRadix((color.a * 255.0).toInt()) : '') +
        _padRadix((color.r * 255.0).toInt()) +
        _padRadix((color.g * 255.0).toInt()) +
        _padRadix((color.b * 255.0).toInt());
    return toUpperCase ? hex.toUpperCase() : hex;
  }

  static String _padRadix(int value) => value.toRadixString(16).padLeft(2, '0');

  static Color hexStringToColor(String hexString) {

    if (hexString.isEmpty) {
      return Colors.grey; // Return transparent color for empty string
    }

    // Remove any leading '#' if it exists
    hexString = hexString.replaceAll("#", "");

    // If the hex string is 6 characters long, assume full opacity (FF)
    if (hexString.length == 6) {
      hexString = "FF$hexString";
    }

    // Parse the hex string to an integer
    int hexValue = int.parse(hexString, radix: 16);

    // Return a Color object
    return Color(hexValue);
  }
}
