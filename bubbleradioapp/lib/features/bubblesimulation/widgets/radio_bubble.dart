import 'package:flutter/material.dart';
import '../models/bubble.dart';

class RadioBubble extends StatelessWidget {
  final Bubble bubble;

  const RadioBubble({super.key, required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: bubble.position.y - bubble.radius,
      left: bubble.position.x - bubble.radius,
      child: Container(
          width: bubble.radius,
          height: bubble.radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: NetworkImage(bubble.station!.favicon), fit: BoxFit.cover),
          ),
          child: const Image(image: AssetImage('assets/images/oily_bubble.png'))),
    );
  }
}
