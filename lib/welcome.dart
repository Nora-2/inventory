import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/appimage/app_images.dart';
import 'package:inventory/presentation/home/homescreen.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AnimatedSplashScreen(
        splash: Stack( // Using Stack here
          alignment: Alignment.center, // To center the widgets in the stack
          children: [
            // Background Image
            Positioned(
              top: height * 0.09,
              child: SizedBox(
                
                height: height * 0.6,
                child: Image.asset(
                  Appimage.welcome,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Logo image on top
            Positioned(
              // Adjust top for vertical position based on your layout
              top: height * 0.25,
              // To be center
              child: SizedBox(
               width: width * 0.6,
                height: height * 0.3,
                child: Image.asset(
                   Appimage.logo,
                    fit: BoxFit.cover,
                   ),
              ),
            ),

            
          ],
        ),
        nextScreen: HomePage(),
        splashIconSize: height * 0.9,
        duration: 500,
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Appcolors.whicolor,
      ),
    );
  }
}