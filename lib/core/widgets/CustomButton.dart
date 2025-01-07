
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
 
    final height = MediaQuery.of(context).size.height;
    return Card(
      child: Container(
        
        height: height * 0.06,
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
          child: Center(
            child: Text(
              text,
              style: ArabicTextStyle(
                arabicFont: ArabicFont.dinNextLTArabic, fontSize: 25,color: Appcolors.whicolor),
          
            ),
          ),
        ),
      ),
    );
  }
}
