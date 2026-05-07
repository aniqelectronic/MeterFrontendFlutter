import 'package:flutter/material.dart';

class UIScale {
  static const double designWidth = 1080;
  static const double designHeight = 1920;

  static double w(BuildContext context, double value) {
    return value * MediaQuery.of(context).size.width / designWidth;
  }

  static double h(BuildContext context, double value) {
    return value * MediaQuery.of(context).size.height / designHeight;
  }

  static double sp(BuildContext context, double value) {
    final scaleW = MediaQuery.of(context).size.width / designWidth;
    final scaleH = MediaQuery.of(context).size.height / designHeight;
    return value * ((scaleW + scaleH) / 2);
  }
}
