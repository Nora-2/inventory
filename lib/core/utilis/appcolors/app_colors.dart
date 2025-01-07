import 'package:flutter/material.dart';

class Appcolors {
  static Color primarycolor = const Color.fromARGB(255, 205, 97, 57);
  static Color secondarycolor = const Color.fromARGB(255, 236, 131, 93);
  static Color homeBack = const Color.fromARGB(255, 134, 192, 180);
  static Color imgBorder = const Color.fromARGB(255, 131, 168, 181);
  static Color seccolor = Colors.grey;
  static Color redcolor = Colors.red;
  static Color transcolor = Colors.transparent;
  static Color whicolor = Colors.white;
  static Color green = const Color(0xff0FA125);
  static Color backcolor = Colors.black;
  static Color backsearch = const Color(0xff1D2025);
  static Color headingcolor = const Color(0xffB5B5B5);
  static Color kMainGreenColor = const Color(0xFF37A45E);
  static Color splachgrey = const Color(0xFF6A6D72);
  static Color kPrimaryColor = const Color(0xFF101010);
  static Color kLightGrey = const Color(0xFF545454);
  static Color kAppBarColor = const Color(0xFF1C1C1C);
  static Color kTextShadowColor = const Color(0x4D000000);
  static Color kBackgroundShadowColor = const Color(0x4D161616);
  static Color kDrawerLineColor = const Color(0xFF707070);
  static Color kInactiveButtonColor = const Color(0xFF474747);
  static Color kDrawerTextColor = const Color.fromARGB(255, 168, 165, 165);
  static Color kSubTitleCardBoxColor = const Color(0xFF8E8E8E);
  static Color kSearchAppBarColor = const Color(0xFF161616);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 205, 97, 57),
      Color.fromARGB(255, 236, 131, 93),
      Color.fromARGB(255, 205, 97, 57),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
