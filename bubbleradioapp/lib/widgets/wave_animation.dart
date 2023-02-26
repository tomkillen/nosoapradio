import 'dart:math';

import 'package:flutter/material.dart';

class BackgroundWave extends StatefulWidget {
  final double height;
  final double speed;
  final double waveLength;

  const BackgroundWave({
    Key? key,
    required this.height,
    required this.speed,
    required this.waveLength,
  }) : super(key: key);

  @override
  State<BackgroundWave> createState() => _BackgroundWaveState();
}

class _BackgroundWaveState extends State<BackgroundWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WavePainter(
            animationValue: _animation.value,
            waveLength: widget.waveLength,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final double waveLength;

  _WavePainter({required this.animationValue, required this.waveLength});

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = size.height / 2;
    final path = Path();

    path.moveTo(0, waveHeight);
    for (var x = 0; x < size.width; x++) {
      final y = waveHeight * sin(animationValue + (pi * 2 * x / waveLength));
      path.lineTo(x.toDouble(), y + waveHeight);
    }
    path.lineTo(size.width, waveHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
