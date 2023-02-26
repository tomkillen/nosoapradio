import 'dart:async';
import 'dart:ui';

import 'package:forge2d/forge2d.dart';

import '../physics/bubble_simulation.dart';
import 'radio_station.dart';

class Bubble {
  final Color color;
  final double radius;
  Body? body;
  RadioStation? station;

  StreamController<Vector2> positionStream = StreamController();

  Vector2 get position {
    return (body != null)
        ? Vector2(body!.position.x * BubbleSimulation.ppm, body!.position.y * BubbleSimulation.ppm)
        : Vector2.zero();
  }

  double get angle {
    return (body != null) ? body!.angle : 0;
  }

  Bubble({required this.color, required this.radius});

  void updateStreams() {
    positionStream.add(position);
  }

  void dispose() {
    positionStream.close();
  }
}
