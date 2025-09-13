import 'package:flutter/material.dart';
import 'package:prime_web/data/model/get_onbording_model.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/animated_text.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/next_button.dart';

class StyleTwo extends StatelessWidget {
  const StyleTwo(
      {required this.data,
      required this.currentIndex,
      required this.totalIndex,
      required this.onChanged,
      super.key});
  final OnboardingData data;
  final ValueNotifier<int> currentIndex;
  final int totalIndex;
  final VoidCallback onChanged;

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
                  ValueListenableBuilder(
                      valueListenable: currentIndex,
                      builder: (context, value, child) {
                        return NextButton(
                            showProgress: true,
                            value: ((value + 1) / totalIndex),
                            onPressed: onChanged);
                      }),
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
