import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import '../models/bubble.dart';

class RadioBubble extends StatefulWidget {
  final Bubble bubble;

  const RadioBubble({super.key, required this.bubble});

  @override
  State<RadioBubble> createState() => _RadioBubbleState();

  // @override
  // Widget build(BuildContext context) {
  //   return Positioned(
  //     top: bubble.position.y - bubble.radius,
  //     left: bubble.position.x - bubble.radius,
  //     child: Container(
  //         width: bubble.radius,
  //         height: bubble.radius,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           image: DecorationImage(image: NetworkImage(bubble.station!.favicon), fit: BoxFit.cover),
  //         ),
  //         child: const Image(image: AssetImage('assets/images/oily_bubble.png'))),
  //   );
  // }
}

class _RadioBubbleState extends State<RadioBubble> {
  Vector2 _position = Vector2.zero();
  double _radius = 0;

  @override
  void initState() {
    super.initState();
    _position = widget.bubble.position;
    _radius = widget.bubble.radius;
    widget.bubble.positionStream.stream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.y - _radius,
      left: _position.x - _radius,
      child: Container(
          width: _radius * 2,
          height: _radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: NetworkImage(widget.bubble.station!.favicon), fit: BoxFit.cover),
          ),
          child: const Image(image: AssetImage('assets/images/oily_bubble.png'))),
    );
  }
}
