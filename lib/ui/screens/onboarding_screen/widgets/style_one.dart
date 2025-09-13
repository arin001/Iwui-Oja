import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prime_web/data/model/get_onbording_model.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/animated_text.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/next_button.dart';
import 'package:prime_web/utils/constants.dart';

class StyleOne extends StatelessWidget {
  const StyleOne(
      {required this.data,
      required this.currentIndex,
      required this.totalIndex,
      required this.onChanged,
      required this.pageController,
      super.key});
  final OnboardingData data;
  final ValueNotifier<int> currentIndex;
  final int totalIndex;
  final VoidCallback onChanged;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.network(data.image!),
        )),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .45,
          width: MediaQuery.sizeOf(context).width,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedText(
                          title: data.title!, description: data.description!),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _PageIndicator(
                              totalCount: totalIndex,
                              controller: pageController)),
                      ValueListenableBuilder(
                          valueListenable: currentIndex,
                          builder: (context, value, child) {
                            return NextButton(
                                showProgress: false,
                                value: ((value + 1) / totalIndex),
                                onPressed: onChanged);
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator(
      {required this.totalCount, required this.controller});
  final int totalCount;
  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 20, maxWidth: 50),
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: totalCount,
            itemExtent: 15.0,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    double itemOffset = 0.0;

                    final position = controller.position;
                    if (position.hasPixels && position.hasContentDimensions) {
                      itemOffset = controller.page! - index;
                    } else {
                      itemOffset = (controller.initialPage - index).toDouble();
                    }
                    final distortionRatio =
                        (1 - (itemOffset.abs() * 0.7)).clamp(0.0, 1.0);
                    final distortionValue =
                        Curves.easeOut.transform(distortionRatio);

                    return Transform.scale(
                        //to limit minimum size to 0.2
                        scale: max(distortionValue, 0.2),
                        child: const DecoratedBox(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      onboardingButtonColor1,
                                      onboardingButtonColor2
                                    ],
                                    stops: [
                                      0.0,
                                      1.0
                                    ]))));
                  });
            }));
  }
}
