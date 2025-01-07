// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';

class ShadowlessFloatingButton extends StatelessWidget {
  final iconData;
  final onPressed;
  final backgroundColor;

  const ShadowlessFloatingButton({
    super.key,
    required this.iconData,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: FloatingActionButton(
        onPressed: null,
        disabledElevation: 0,
        backgroundColor: backgroundColor,
        child: Icon(
          iconData,
          size: 34,
          color: Appcolors.whicolor,
        ),
      ),
    );
  }
}
