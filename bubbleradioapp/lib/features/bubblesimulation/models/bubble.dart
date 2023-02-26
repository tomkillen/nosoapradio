import 'dart:ui';

import 'package:bubbleradioapp/features/bubblesimulation/physics/bubble_simulation.dart';
import 'package:bubbleradioapp/models/radio_station.dart';
import 'package:forge2d/forge2d.dart';

class Bubble {
  final Color color;
  final double radius;
  Body? body;
  RadioStation? station;

  Vector2 get position {
    if (body != null) {
      return Vector2(body!.position.x * BubbleSimulation.ppm, body!.position.y * BubbleSimulation.ppm);
    } else {
      return Vector2(0, 0);
    }
  }

  Bubble({required this.color, required this.radius});
}
