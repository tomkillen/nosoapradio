import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart' as forge2d;
import '../models/bubble.dart';

class RadioBubble extends StatefulWidget {
  final Bubble bubble;

  const RadioBubble({super.key, required this.bubble});

  @override
  State<RadioBubble> createState() => _RadioBubbleState();
}

class _RadioBubbleState extends State<RadioBubble> {
  forge2d.Vector2 _position = forge2d.Vector2.zero();
  double _radius = 0;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _position = widget.bubble.position;
    _radius = widget.bubble.radius;
    widget.bubble.positionStream.stream.listen((position) {
      setState(() {
        _position = position;

        // this could be it's own stream but we dont need to update this more
        // frequently than position. This suggests some packed data type should
        // be what is stream. Perhaps the bubble itself, or perhaps a matrix
        // representation
        _angle = widget.bubble.angle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: _position.y - _radius,
        left: _position.x - _radius,
        child: SizedBox(
          width: _radius * 2,
          height: _radius * 2,
          child: Stack(
            children: [
              // position inside the bubble texture
              Positioned(
                  top: 2,
                  left: 2,
                  child: SizedBox(
                    width: _radius * 2 - 4,
                    height: _radius * 2 - 4,
                    child: ClipOval(
                        child: Transform.rotate(
                            angle: _angle,
                            child: Image(image: NetworkImage(widget.bubble.station!.favicon), fit: BoxFit.cover))),
                  )),
              const Image(image: AssetImage('assets/images/oily_bubble.png'))
            ],
          ),
        ));
  }
}
