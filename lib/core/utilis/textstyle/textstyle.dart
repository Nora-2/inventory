// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';

class textstyle {
  static TextStyle headstyle() => TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w500,
      color: Appcolors.headingcolor,
      fontFamily: 'robto');
  static TextStyle seeall() => TextStyle(
      fontSize: 16,
      color: Appcolors.headingcolor,
      fontWeight: FontWeight.w400,
      fontFamily: 'robto');
  static TextStyle search() =>
      TextStyle(color: Appcolors.headingcolor, fontFamily: 'robto');

  static TextStyle onboard(Color color) => TextStyle(
      color: color,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      fontFamily: 'robto');
  static TextStyle onboardgr() => TextStyle(
      color: Appcolors.splachgrey,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: 'robto');

  static final kTextShadow = [
    Shadow(
        offset: const Offset(0, 0.1),
        blurRadius: 6.0,
        color: Appcolors.kTextShadowColor),
  ];

  static final kBoxShadow = [
    BoxShadow(
      color: Appcolors.kPrimaryColor,
      spreadRadius: 5,
      blurRadius: 30,
      offset: const Offset(0, 3),
    ),
  ];

  static final kHomeScreenButtonTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      shadows: textstyle.kTextShadow,
      fontFamily: 'robto');

  static final kBoldTitleTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: kTextShadow,
      fontFamily: 'robto');

  static final kTitleTextStyle =
      TextStyle(fontSize: 12, shadows: kTextShadow, fontFamily: 'robto');

  static final kDrawerDescTextStyle = TextStyle(
      fontSize: 14,
      color: Appcolors.kDrawerTextColor,
      height: 0.19,
      fontFamily: 'robto');

  static final kAppBarTitleTextStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      shadows: kTextShadow,
      fontFamily: 'robto');

  static final kSplashScreenTextStyle = TextStyle(
      fontSize: 12.0, color: Appcolors.kLightGrey, fontFamily: 'robto');

  static final kSubTitleCardBoxTextStyle = TextStyle(
      color: Appcolors.kSubTitleCardBoxColor, fontSize: 9, fontFamily: 'robto');

  static const kSmallAppBarTitleTextStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'robto');

  static const kSmallTitleTextStyle = TextStyle(fontSize: 18);

  static const kTextFieldDecoration = InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
  );

  static const kMovieAppBarTitleTextStyle = TextStyle(fontSize: 22);

  static const kDetailScreenBoldTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'robto');
  static const kDetailScreenRegularTitle =
      TextStyle(fontSize: 20, fontFamily: 'robto');
}
