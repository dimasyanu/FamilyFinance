import 'package:flutter/material.dart';

class SizeUtil {
  late MediaQueryData _mediaQueryData;
  late double _screenWidth;
  late double _screenHeight;

  SizeUtil(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
  }

  EdgeInsets dynamicHorizontalPadding({required double maxPercentage}) {
    double calculatedPadding = _screenWidth * maxPercentage;

    // You can add more complex logic here, e.g.,
    if (_screenWidth > 600) { calculatedPadding = 80.0; }

    return EdgeInsets.symmetric(horizontal: calculatedPadding);
  }

  EdgeInsets dynamicVerticalPadding({required double maxPercentage}) {
    double calculatedPadding = _mediaQueryData.size.height * maxPercentage;

    // You can add more complex logic here, e.g.,
    if (_mediaQueryData.size.height > 800) { calculatedPadding = 60.0; }

    return EdgeInsets.symmetric(vertical: calculatedPadding);
  }

  EdgeInsets dynamicPadding({required double maxXPercentage, required double maxYPercentage}) {
    double calculatedXPadding = _screenWidth * maxXPercentage;
    double calculatedYPadding = _screenHeight * maxYPercentage;

    // You can add more complex logic here, e.g.,
    if (_screenWidth > 600) {
      calculatedXPadding = 80.0;
      calculatedYPadding = 60.0;
    }

    return EdgeInsets.only(
      left: calculatedXPadding,
      right: calculatedXPadding,
      top: calculatedYPadding,
      bottom: calculatedYPadding,
    );
  }
}