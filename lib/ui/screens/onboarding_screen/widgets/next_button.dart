import 'package:flutter/material.dart';
import 'package:prime_web/ui/styles/colors.dart';

class NextButton extends StatelessWidget {
  const NextButton(
      {required this.showProgress,
      required this.value,
      required this.onPressed,
      super.key});
  final bool showProgress;
  final double value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showProgress)
            SizedBox.square(
              dimension: 70,
              child: CircularProgressIndicator(
                  strokeWidth: 3,
                  value: value,
                  backgroundColor: Color.fromARGB(255, 209, 210, 214),
                  valueColor: AlwaysStoppedAnimation(indicatorColor1)),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      onboardingButtonColor1,
                      onboardingButtonColor2,
                    ],
                    stops: [
                      0.0,
                      1.0
                    ]),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]),
            child: Icon(
              Icons.navigate_next,
              color: Colors.white,
              size: 55,
            ),
          )
        ],
      ),
    );
  }
}
