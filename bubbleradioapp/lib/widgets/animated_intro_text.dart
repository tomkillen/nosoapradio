import 'package:flutter/material.dart';

class AnimatedTextAndImage extends StatefulWidget {
  final String topText;
  final String leftText;
  final String bottomText;
  final Image image;

  const AnimatedTextAndImage({
    Key? key,
    required this.topText,
    required this.leftText,
    required this.bottomText,
    required this.image,
  }) : super(key: key);

  @override
  State<AnimatedTextAndImage> createState() => _AnimatedTextAndImageState();
}

class _AnimatedTextAndImageState extends State<AnimatedTextAndImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _topAnimation;
  late Animation<double> _leftAnimation;
  late Animation<double> _bottomAnimation;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define the animations for each text widget and the image
    _topAnimation = Tween<double>(begin: -300, end: 100).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.25),
      ),
    );
    _leftAnimation = Tween<double>(begin: -500, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5),
      ),
    );
    _bottomAnimation = Tween<double>(begin: -500, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75),
      ),
    );
    _imageAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _topAnimation.value),
          child: child,
        ),
        child: Text(
          widget.topText,
          style: const TextStyle(fontFamily: 'ClimateCrisis', fontSize: 48, color: Color.fromARGB(255, 63, 200, 244)),
        ),
      ),
      const SizedBox(height: 32),
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(_leftAnimation.value, 50),
          child: child,
        ),
        child: Text(
          widget.leftText,
          style: const TextStyle(fontFamily: 'ClimateCrisis', color: Color.fromARGB(255, 113, 191, 69)),
        ),
      ),
      const SizedBox(height: 32),
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _bottomAnimation.value),
          child: child,
        ),
        child: Text(
          widget.bottomText,
          style: const TextStyle(fontFamily: 'ClimateCrisis', fontSize: 48, color: Color.fromARGB(255, 63, 200, 244)),
        ),
      ),
      const SizedBox(height: 32),
      Opacity(
        opacity: _imageAnimation.value,
        child: widget.image,
      ),
    ]);
  }
}
