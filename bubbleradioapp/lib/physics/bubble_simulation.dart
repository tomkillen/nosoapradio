import 'dart:async' as async;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

import '../models/bubble.dart';

/// Callback type for when the BubbleSimulation requires repainting
typedef NeedsRepaintCallback = Function();

/// A BubbleSimulation is a forge2d physics simulation that creates bubbles
/// that float in the space and collide with each other
class BubbleSimulation {
  /// pixels per meter / pixels per unit of the sim
  /// this scales the simulation down to a sane size since Box2D will suffer
  /// from floating-point inaccuracy issues when the size of the sim is larger
  /// than O(100).
  /// To really future proof this, we should calculate this scalar based on the
  /// screen size but I won't gold plate it now since most phones are O(1000)
  /// pixels and so diving by 100 brings us into the realm of nice values
  static const double ppm = 100;

  /// We prefer the integrity of the physics simulation even at the expense of
  /// skipped frames so limit the update tick to no more than 60 fps
  static const double maxDeltaTimeSeconds = 1.0 / 30.0;

  /// Default gravity to that on earth
  static const double defaultGravity = 9.8;

  /// A list of bubbles referenced by this simulation
  final List<Bubble> _bubbles = [];

  /// Physics world used by this simulation
  final World world = World();

  /// Callback event triggered when this simulation has updated it's state
  NeedsRepaintCallback? onNeedPaint;

  final _random = Random();
  Size _size = Size.zero;
  Vector3 _realGravityNormalized = Vector3(0, 1, 0); // portrait-up
  final double _gravityStrength = defaultGravity;
  final Vector2 _initialBubbleVelocity = Vector2(0, -defaultGravity / ppm);
  bool _initialized = false;
  bool _running = false;
  int? _frameCallbackId;
  async.StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Debug colors for rendering bubbles
  final List<Color> _colors = [
    const Color.fromARGB(255, 62, 36, 251),
    const Color.fromARGB(255, 39, 230, 227),
    const Color.fromARGB(255, 253, 112, 33),
    const Color.fromARGB(255, 253, 66, 193),
  ];

  /// Initializes this simulation to map to the provided size in pixels
  void initialize(Size size) {
    if (_initialized) {
      return;
    }

    _size = size;

    // Setup world
    world.setAllowSleep(false);
    _createWalls();
    _caculateWorldGravity();

    _initialized = true;

    // Now that we are initialized, start running the sim
    start();
  }

  /// Starts or resumes this physics simulation
  void start() {
    if (_initialized && !_running) {
      _running = true;

      // Start accelerometer update
      _accelerometerSubscription = accelerometerEvents.listen(_accelerometerEventHandler);

      // Start frame ticker
      _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    }
  }

  /// Pauses this physics simulation
  void stop() {
    if (_running) {
      // cancel frame ticker
      if (_frameCallbackId != null) {
        SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
        _frameCallbackId = null;
      }

      // cancel accelerometer updates
      _accelerometerSubscription?.cancel();
      _accelerometerSubscription = null;

      _running = false;
    }
  }

  /// Spawns numBubblesToSpawn with randomized locations and sizes
  void spawnBubbles(int numBubblesToSpawn) {
    if (!_initialized) {
      throw Exception('Bubble simulation not yet initialized');
    }

    // Spawn in the desired bubbles with a brief delay per bubble
    async.Timer.periodic(const Duration(milliseconds: 150), (timer) {
      double radius = _random.nextDouble() * 32 + 32;
      double x = _random.nextDouble() * (_size.width - radius * 2.0);
      double y = _random.nextDouble() * 100.0 + _size.height - 200.0;

      spawnBubble(Vector2(x, y), radius, _initialBubbleVelocity);

      numBubblesToSpawn -= 1;

      // cancel the timer when we have spawned all of our bubbles
      if (numBubblesToSpawn <= 0) {
        timer.cancel();
      }
    });
  }

  /// Spawns a bubble at the specified and with the specified size and velocity
  Bubble spawnBubble(Vector2 position, double radius, Vector2 initialVelocity) {
    assert(_initialized);

    final color = _colors[_random.nextInt(_colors.length)];
    final bubble = Bubble(color: color, radius: radius);
    final shape = CircleShape()..radius = radius / ppm;

    final fixture = FixtureDef(shape)
      ..density = 1
      ..friction = 0.3
      ..restitution = 0.5;

    final bodyDef = BodyDef()
      ..position = position / ppm
      ..type = BodyType.dynamic
      ..bullet = false
      ..userData = bubble
      ..gravityScale = Vector2(-1, -1) * (_random.nextDouble() * 0.25 + 0.75);
    bubble.body = world.createBody(bodyDef)
      ..createFixture(fixture)
      ..linearVelocity = initialVelocity
      ..linearDamping = 0.01
      ..angularDamping = 0.01;

    _bubbles.add(bubble);
    return bubble;
  }

  /// Helper method that will spawn a bubble of a random size
  Bubble spawnRandomBubble(double minSize, double maxSize) {
    return spawnBubbleWithRadius(_random.nextDouble() * (maxSize - minSize) + minSize);
  }

  /// Helper method for spawning bubbles without needing to be aware of the
  /// configuration of the simulation
  Bubble spawnBubbleWithRadius(double radius) {
    double x = _random.nextDouble() * (_size.width / 2) + _size.width * 0.25;
    double y = _random.nextDouble() * 50.0 + _size.height - 100.0;
    Vector2 position = Vector2(x, y);
    return spawnBubble(position, radius, _initialBubbleVelocity);
  }

  /// Reuses an existing bubble, respawning it at a new location
  void respawnBubble(Bubble bubble, double minSize, double maxSize) {
    if (bubble.body == null) {
      if (kDebugMode) {
        print('Bubble is not in the physics system');
      }
      return;
    } else {
      // final radius = _random.nextDouble() * (maxSize - minSize) + minSize;
      double x = _random.nextDouble() * (_size.width / 2) + _size.width / 2;
      double y = _random.nextDouble() * 50.0 + _size.height - 100.0;
      Vector2 position = Vector2(x, y);
      bubble.body!.setTransform(position, 0.0);
    }
  }

  /// Removes a bubble from this simulation
  void despawnBubble(Bubble bubble) {
    if (bubble.body != null) {
      world.destroyBody(bubble.body!);
    }
    _bubbles.remove(bubble);
  }

  /// Scheduled to be called once per frame, ideally 60 times per second
  void _frameCallback(Duration frameDelta) {
    // Calculate frame delta seconds based by converting the duration
    // milliseconds for highest available accuracy
    double deltaTimeSeconds = frameDelta.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;

    deltaTimeSeconds = min(deltaTimeSeconds, maxDeltaTimeSeconds);

    // Tick the simulation
    _step(deltaTimeSeconds);

    // Publish positions
    _updateBubbles();

    // Mark we need a repaint
    onNeedPaint?.call();

    // Schedule the next frame update
    if (_running) {
      _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_frameCallback, rescheduling: true);
    }
  }

  /// Updates the physics world
  void _step(double stepDeltaSeconds) {
    assert(_initialized);
    world.stepDt(stepDeltaSeconds);
  }

  /// Update the bubbles in this system
  void _updateBubbles() {
    assert(_initialized);
    for (var bubble in _bubbles) {
      bubble.update();
    }
  }

  /// Create the boundaries of a box around the indicated size to prevent the
  /// bubbles from floating off screen
  void _createWalls() {
    const wallThickness = 10.0 / ppm;
    // Left wall
    _createWall(Vector2(0, _size.height / 2) / ppm, Size(wallThickness, _size.height) / ppm, Colors.red);

    // Right wall
    _createWall(Vector2(_size.width, _size.height / 2) / ppm, Size(wallThickness, _size.height) / ppm, Colors.cyan);

    // Top wall
    _createWall(Vector2(_size.width / 2, 0) / ppm, Size(_size.width, wallThickness) / ppm, Colors.blue);

    // Bottom wall
    _createWall(Vector2(_size.width / 2, _size.height) / ppm, Size(_size.width, wallThickness) / ppm, Colors.green);
  }

  /// Helper method to create a wall
  Body _createWall(Vector2 position, Size size, Color color) {
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = position
      ..userData = color;
    final body = world.createBody(bodyDef);
    final shape = PolygonShape()..setAsBoxXY(size.width / 2, size.height / 2);
    final fixture = FixtureDef(shape);
    body.createFixture(fixture);
    return body;
  }

  /// Callback for receiving accelerometer data from the sensors package
  void _accelerometerEventHandler(AccelerometerEvent event) {
    _realGravityNormalized = Vector3(-event.x, event.y, event.z).normalized();
    _caculateWorldGravity();
  }

  /// Calculates the gravity for the world based on the gravity strength
  /// and the scale of the physics simulation.
  void _caculateWorldGravity() {
    // just ignore the z component. If the phone is oriented screen-up then
    // this will result in reduced world gravity which makes sense, they'll
    // float up against the screen
    Vector2 gravity = _realGravityNormalized.xy * (_gravityStrength / ppm);

    world.setGravity(gravity);
  }
}
