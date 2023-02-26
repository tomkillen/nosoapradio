import 'package:flutter/material.dart';

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final Duration pulseDuration;
  final bool pulsing;

  const PulsingWidget({super.key, required this.child, required this.pulseDuration, required this.pulsing});

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.02, end: 1.0).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    if (widget.pulsing) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PulsingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
