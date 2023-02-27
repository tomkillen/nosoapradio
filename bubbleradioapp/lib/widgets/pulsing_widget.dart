import 'package:flutter/material.dart';

/// UI element that pulses with the specified periodicity.
/// The pulse is strong at the start and then becomes weak, like a speaker
/// blasting with noise
class PulsingWidget extends StatefulWidget {
  /// UI child that will inherit the pulse
  final Widget child;

  /// Periodicity of the pulse
  final Duration pulseDuration;

  /// Should the pulse be active
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
