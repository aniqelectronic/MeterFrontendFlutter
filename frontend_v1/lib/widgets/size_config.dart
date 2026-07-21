import 'package:flutter/material.dart';

class SizeConfig {
  static double screenWidth = 1080;
  static double screenHeight = 1920;
  static double scaleWidth = 1;
  static double scaleHeight = 1;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    scaleWidth = size.width / screenWidth;
    scaleHeight = size.height / screenHeight;
  }

  static double sw(double width) => width * scaleWidth;
  static double sh(double height) => height * scaleHeight;
}
