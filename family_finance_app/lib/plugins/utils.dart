import 'dart:ui';

import 'package:flutter/material.dart';

const List<String> monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> shortMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

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

  static String formatCurrency(double amount) {
    // Format the amount as a currency string
    return 'Rp. ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  static String formatDate(DateTime date) {
    // Format the date as a string in 'dd MMM yyyy HH:mm' format
    return '${date.day.toString().padLeft(2, '0')} ${getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String getMonthName(int month) {
    // Return the month name based on the month number
    return shortMonthNames[month - 1];
  }
}
