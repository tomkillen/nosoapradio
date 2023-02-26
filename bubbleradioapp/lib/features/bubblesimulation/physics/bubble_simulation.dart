import 'dart:async' as dart_async;
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';

import '../models/bubble.dart';

typedef NeedsRepaintCallback = Function();

class BubbleSimulation {
  // pixels per meter / pixels per unit of the sim
  static const double ppm = 100;

  final List<Bubble> bubbles = [];
  final World world = World();
  NeedsRepaintCallback? onNeedPaint;

  final _random = Random();
  Size _size = Size.zero;
  Vector2 _gravity = Vector2.zero();
  Vector2 _initialBubbleVelocity = Vector2.zero();
  bool _initialized = false;
  bool _running = false;
  int? _frameCallbackId;

  // Debug colors for rendering bubbles before I have album art loading
  final List<Color> _colors = [
    const Color.fromARGB(255, 62, 36, 251),
    const Color.fromARGB(255, 39, 230, 227),
    const Color.fromARGB(255, 253, 112, 33),
    const Color.fromARGB(255, 253, 66, 193),
  ];

  BubbleSimulation() {
    // forge2d settings
    // velocityIterations = 5;
    // positionIterations = 5;
  }

  void initialize(Size size, Vector2 gravity) {
    assert(!_initialized);
    _initialized = true;
    _size = size;
    _gravity = gravity;
    _initialBubbleVelocity = _gravity;
    _createWalls();
    //_calculateGravity();
    world.setGravity(gravity / ppm);
    _running = true;
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
  }

  void pause() {
    if (_running) {
      if (_frameCallbackId != null) {
        SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
        _frameCallbackId = null;
      }
      _running = false;
    }
  }

  void resume() {
    if (_initialized && !_running) {
      _running = true;
      _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    }
  }

  void spawnBubbles(int numBubblesToSpawn) {
    if (!_initialized) {
      throw Exception('Bubble simulation not yet initialized');
    }

    // Spawn in the desired bubbles with a brief delay per bubble
    dart_async.Timer.periodic(const Duration(milliseconds: 150), (timer) {
      // double spawnX = _random.nextDouble() * _origin.x + _origin.x;
      // _spawnBubble(Vector2(0, 0), _random.nextDouble() * 32 + 32);
      // cancel the timer when we have spawned all of our bubbles

      double radius = _random.nextDouble() * 32 + 32;
      double x = _random.nextDouble() * (_size.width - radius * 2.0);
      double y = _random.nextDouble() * 100.0 + _size.height - 200.0;

      _spawnBubble(Vector2(x, y), radius);

      numBubblesToSpawn -= 1;
      if (numBubblesToSpawn <= 0) {
        timer.cancel();
      }
    });
  }

  void _frameCallback(Duration frameDelta) {
    // Calculate frame delta seconds based by converting the duration
    // milliseconds for highest available accuracy
    final double deltaTimeSeconds = frameDelta.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;

    // Tick the simulation
    _step(deltaTimeSeconds);

    // Mark we need a repaint
    onNeedPaint?.call();

    // Schedule the next frame update
    if (_running) {
      _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_frameCallback, rescheduling: true);
    }
  }

  void _step(double stepDeltaSeconds) {
    assert(_initialized);
    world.stepDt(stepDeltaSeconds);
  }

  void _spawnBubble(Vector2 position, double radius) {
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
      ..gravityScale = Vector2(1, 1) * (_random.nextDouble() * 0.5 + 0.5);
    bubble.body = world.createBody(bodyDef)
      ..createFixture(fixture)
      ..linearVelocity = _initialBubbleVelocity
      ..linearDamping = 0.05
      ..angularDamping = 0.05;

    bubbles.add(bubble);
  }

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
}
