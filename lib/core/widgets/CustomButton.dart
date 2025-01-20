
import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';

class Custombutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;

  const Custombutton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Transparent background
            shadowColor: Colors.transparent, // Remove shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: ArabicTextStyle(
                 
                  arabicFont: ArabicFont.dinNextLTArabic, fontSize: 25,color: Appcolors.whicolor),
            
              ),
            ),
          ),
        ),
      ),
    );
  }
}
