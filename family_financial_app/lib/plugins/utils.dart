import 'dart:ui';

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
}
