import 'dart:async';
import 'dart:ui';

import 'package:forge2d/forge2d.dart';

import '../physics/bubble_simulation.dart';
import 'radio_station.dart';

class Bubble {
  final Color color;
  final double radius;
  Body? _body;
  RadioStation? _station;

  StreamController<Vector2> positionStream = StreamController();

  Vector2 get position {
    return (body != null)
        ? Vector2(body!.position.x * BubbleSimulation.ppm, body!.position.y * BubbleSimulation.ppm)
        : Vector2.zero();
  }

  double get angle {
    return (body != null) ? body!.angle : 0;
  }

  RadioStation? get station => _station;
  set station(RadioStation? value) {
    if (_station != null) {
      print('Overwriting station');
    }
    _station = value;
  }

  Body? get body => _body;
  set body(Body? value) {
    if (_body != null) {
      print('Overwriting Body');
    }
    _body = value;
  }

  Bubble({required this.color, required this.radius});

  void updateStreams() {
    positionStream.add(position);
  }

  void dispose() {
    positionStream.close();
  }
}
