import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText(
      {required this.title, required this.description, super.key});
  final String title;
  final String description;

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((duration) => _fadeController.forward());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: CurvedAnimation(
            parent: _fadeController,
            curve: Interval(0.2, 1.0, curve: Curves.fastOutSlowIn)),
        child: Column(
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
