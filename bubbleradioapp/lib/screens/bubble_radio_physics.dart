import 'dart:async' as dart_async;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';

class BubbleSimulationWidget extends LeafRenderObjectWidget {
  final BubbleSimulation bubbleSimulation = BubbleSimulation();

  BubbleSimulationWidget({super.key}) {
    final Size simSize = window.physicalSize;
    bubbleSimulation.initialize(simSize, Vector2(0, 0));
    bubbleSimulation.spawnBubbles(1);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return BubbleSimulationRenderObject(bubbleSimulation: bubbleSimulation);
  }

  // @override
  // State<BubbleSimulationWidget> createState() => _BubbleSimulationWidgetState();
}

// class _BubbleSimulationWidgetState extends State<BubbleSimulationWidget> {
//   @override
//   void initState() {
//     super.initState();
//     final Size simSize = window.physicalSize;
//     widget.bubbleSimulation.initialize(simSize, Vector2(0, 9.8));
//     widget.bubbleSimulation.spawnBubbles(3);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BubbleSimulationRenderObject(
//         bubbleSimulation: widget.bubbleSimulation);
//     // return CustomPaint(
//     //   painter: BubblesPainter(bubblesSimulation: widget.bubbleSimulation),
//     //   size: MediaQuery.of(context).size,
//     //   willChange: true,
//     // );
//   }
// }

// class BubblesPainter extends CustomPainter {
//   final BubbleSimulation bubblesSimulation;

//   BubblesPainter({required this.bubblesSimulation});

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var bubble in bubblesSimulation.bubbles) {
//       print('Drawing bubble: ${bubble.color}');
//       canvas.drawCircle(
//           bubble.offset, bubble.radius, Paint()..color = bubble.color);
//     }
//   }

//   @override
//   bool shouldRepaint(BubblesPainter oldDelegate) {
//     return true;
//   }
// }

class BubbleSimulationRenderObject extends RenderBox {
  final BubbleSimulation bubbleSimulation;

  BubbleSimulationRenderObject({required this.bubbleSimulation}) {
    bubbleSimulation.onNeedPaint = markNeedsPaint;
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _drawBubbles(context, offset);
  }

  void _drawBubbles(PaintingContext context, Offset offset) async {
    Canvas canvas = context.canvas;
    var rect = Rect.fromCenter(
        center: bubbleSimulation.offset,
        width: bubbleSimulation.size.width,
        height: bubbleSimulation.size.height);
    canvas.save();
    canvas.clipPath(Path()..addRect(rect));

    for (var body in bubbleSimulation._world.bodies) {
      Bubble? bubble = body.userData as Bubble?;
      if (bubble != null) {
        _drawBubble(canvas, bubble, body);
      }
    }

    canvas.restore();
  }

  void _drawBubble(Canvas canvas, Bubble bubble, Body body) {
    double angle = body.angle;
    Vector2 position = body.position * BubbleSimulation.ppm;
    print('Drawing bubble at $position $angle');
    Matrix4 matrix = Matrix4.identity()
      ..leftTranslate(position.x / 2, position.y / 2)
      ..rotateZ(angle);
    canvas.save();
    canvas.transform(matrix.storage);
    for (Fixture f in body.fixtures) {
      if (f.type == ShapeType.circle) {
        _drawCircleShape(canvas, f.shape as CircleShape, bubble.color);
      }
    }
    canvas.restore();
  }

  void _drawCircleShape(Canvas canvas, CircleShape circle, Color color) {
    // canvas.drawCircle(
    //     Offset(circle.position.x * BubbleSimulation.ppm,
    //         circle.position.y * BubbleSimulation.ppm),
    //     circle.radius * BubbleSimulation.ppm,
    //     Paint()
    //       ..style = PaintingStyle.fill
    //       ..color = color);
    canvas.drawCircle(
        Offset.zero,
        50,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color);
  }
}

typedef PaintCallback = Function();

class BubbleSimulation {
  // pixels per meter / pixels per unit of the sim
  static const double ppm = 100;

  final List<Bubble> bubbles = [];
  PaintCallback? onNeedPaint;

  final _random = Random();
  final World _world = World();
  Vector2 _origin = Vector2.zero();
  Size _size = Size.zero;
  Offset _offset = Offset.zero;
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

  Vector2 get origin => _origin;
  Size get size => _size;
  Offset get offset => _offset;

  BubbleSimulation() {
    // forge2d settings
    velocityIterations = 5;
    positionIterations = 5;
  }

  void initialize(Size size, Vector2 gravity) {
    _initialized = true;
    _size = size;
    _origin = Vector2(size.width / 2, size.height / 2);
    _offset = Offset(_origin.x, _origin.y);
    _world.setGravity(gravity);
    _running = true;
    _frameCallbackId =
        SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
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
      _frameCallbackId =
          SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    }
  }

  void spawnBubbles(int numBubblesToSpawn) {
    if (!_initialized) {
      throw Exception('Bubble simulation not yet initialized');
    }

    // Spawn in the desired bubbles with a brief delay per bubble
    dart_async.Timer.periodic(const Duration(milliseconds: 70), (timer) {
      double spawnX = _random.nextDouble() * _origin.x + _origin.x;
      _spawnBubble(Vector2(spawnX, _origin.y), _random.nextDouble() * 32 + 32);
      // cancel the timer when we have spawned all of our bubbles
      numBubblesToSpawn -= 1;
      if (numBubblesToSpawn <= 0) {
        timer.cancel();
      }
    });
  }

  void _frameCallback(Duration frameDelta) {
    // Calculate frame delta seconds based by converting the duration
    // milliseconds for highest available accuracy
    final double deltaTimeSeconds = frameDelta.inMicroseconds /
        Duration.microsecondsPerMillisecond /
        1000.0;

    // Tick the simulation
    _step(deltaTimeSeconds);

    // Mark we need a repaint
    onNeedPaint?.call();

    // Schedule the next frame update
    if (_running) {
      _frameCallbackId = SchedulerBinding.instance
          .scheduleFrameCallback(_frameCallback, rescheduling: true);
    }
  }

  void _step(double stepDeltaSeconds) {
    assert(_initialized);
    _world.stepDt(stepDeltaSeconds);
  }

  void _spawnBubble(Vector2 position, double radius) {
    assert(_initialized);

    final color = _colors[_random.nextInt(_colors.length)];
    final bubble = Bubble(color: color, radius: radius);
    final circleShape = CircleShape()..radius = radius / ppm;

    final activeFixtureDef = FixtureDef(circleShape)
      ..density = 4
      ..friction = 1
      ..restitution = .2;

    final activeBodyDef = BodyDef();
    activeBodyDef.position = position / ppm;
    activeBodyDef.type = BodyType.dynamic;
    activeBodyDef.bullet = true;
    activeBodyDef.userData = bubble;
    Body body = _world.createBody(activeBodyDef);
    body.createFixture(activeFixtureDef);

    bubbles.add(bubble);
  }
}

class Bubble {
  final Color color;
  final double radius;

  Bubble({required this.color, required this.radius});
}
