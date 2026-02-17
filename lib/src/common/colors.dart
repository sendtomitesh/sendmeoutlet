import 'package:flutter/material.dart';
import 'package:sendme_outlet/AppConfig.dart';

class AppColors {
  static Color mainAppColor = activeApp.color!;
  static Color secondAppColor = mainAppColor.withOpacity(0.4);

  static bool brightnessDark = true;
  static Color appBarColor = const Color(0xffFFFFFF);
  static Color appBarTextColor = const Color(0xff000000);

  static Color textColorBold = const Color(0xff000000);
  static Color textColorLight = const Color(0xff7F7F7F);
  static Color textColorLighter = const Color(0xffBDBDBD);

  /// Green for Available / done status
  static Color doneStatusColor = const Color(0xFF4CAF50);

  static MaterialColor getMaterialColor(Color color) => MaterialColor(color.value, {
        50: Color.fromRGBO(color.red, color.green, color.blue, .1),
        100: Color.fromRGBO(color.red, color.green, color.blue, .2),
        200: Color.fromRGBO(color.red, color.green, color.blue, .3),
        300: Color.fromRGBO(color.red, color.green, color.blue, .4),
        400: Color.fromRGBO(color.red, color.green, color.blue, .5),
        500: Color.fromRGBO(color.red, color.green, color.blue, .6),
        600: Color.fromRGBO(color.red, color.green, color.blue, .7),
        700: Color.fromRGBO(color.red, color.green, color.blue, .8),
        800: Color.fromRGBO(color.red, color.green, color.blue, .9),
        900: Color.fromRGBO(color.red, color.green, color.blue, 1),
      });
}
