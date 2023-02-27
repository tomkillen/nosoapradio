import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:forge2d/forge2d.dart';

import '../physics/bubble_simulation.dart';
import 'radio_station.dart';

/// A Bubble is a data structure that binds a forge2d physics body to radio
/// station data.
/// The bubble streams position updates from the physics simulation
/// to any listener using `positionStream`
class Bubble {
  /// Debug rendering color of this bubble
  final Color color;

  /// Radius of the bubble in the simulation, which defines the area it occupies
  /// for physics collisions and resolution
  final double radius;

  /// Reference to the forge2d physics body, which may be null if the body has
  /// not yet been created or has been destroyed
  Body? _body;

  /// Reference to the radio station data, which may be null if the station has
  /// not yet been loaded
  RadioStation? _station;

  /// Provides a stream of position updates driven by the physics engine
  StreamController<Vector2> positionStream = StreamController();

  /// Provides the position of the physics body, driven by the physics engine
  Vector2 get position {
    return (body != null)
        ? Vector2(body!.position.x * BubbleSimulation.ppm, body!.position.y * BubbleSimulation.ppm)
        : Vector2.zero();
  }

  /// Provides the angle of the physics body, driven by the physics engine
  double get angle {
    return (body != null) ? body!.angle : 0;
  }

  /// Get / Set the radion station data associated with this bubble
  RadioStation? get station => _station;
  set station(RadioStation? value) {
    if (_station != null) {
      if (kDebugMode) {
        print('Overwriting station');
      }
    }
    _station = value;
  }

  /// Get / Set the physics body associated with this bubble
  Body? get body => _body;
  set body(Body? value) {
    if (_body != null) {
      if (kDebugMode) {
        print('Overwriting Body');
      }
    }
    _body = value;
  }

  /// Constructs a new bubble with the specified debug color and size
  Bubble({required this.color, required this.radius});

  /// Called by the physics engine to update this bubble
  void update() {
    positionStream.add(position);
  }

  /// Disposes of this bubble and it's resources
  void dispose() {
    positionStream.close();
  }
}
