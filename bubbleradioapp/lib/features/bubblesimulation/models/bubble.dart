import 'dart:async';
import 'dart:ui';

import 'package:bubbleradioapp/features/bubblesimulation/physics/bubble_simulation.dart';
import 'package:bubbleradioapp/models/radio_station.dart';
import 'package:forge2d/forge2d.dart';

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
