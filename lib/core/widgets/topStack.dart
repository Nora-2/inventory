import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';

class TopStack extends StatelessWidget {
  final String text1;
  final String? text2;
  final Widget child;
  final VoidCallback onBackPressed;

  const TopStack({
    super.key,
    required this.text1,
    this.text2,
    required this.child,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: height * 0.21,
              decoration: const BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(70),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.primaryGradient,
              ),
              child: Container(
                height: height * 0.75,
                decoration: BoxDecoration(
                  color: Appcolors.whicolor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                  ),
                ),
                child: child,
              ),
            )
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: height * 0.05),
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: onBackPressed, // Call the passed callback
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color.fromARGB(255, 242, 238, 238),
            ),
          ),
        ),
        Positioned(
          top: height * 0.14,
          left: width * 0.43,
          child: Text(
            text1,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Appcolors.whicolor,
            ),
          ),
        )
      ],
    );
  }
}
