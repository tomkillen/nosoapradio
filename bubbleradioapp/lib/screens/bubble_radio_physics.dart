import 'dart:math';
import 'dart:async' as dart_async;
import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';

class BubbleSimulationWidget extends StatefulWidget {
  final BubblesSimulation bubblesSimulation =
      BubblesSimulation(size: const Size(500, 500));

  BubbleSimulationWidget({super.key});

  @override
  State<BubbleSimulationWidget> createState() => _BubbleSimulationWidgetState();
}

class _BubbleSimulationWidgetState extends State<BubbleSimulationWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblesPainter(bubblesSimulation: widget.bubblesSimulation),
      size: MediaQuery.of(context).size,
    );
  }
}

class BubblesPainter extends CustomPainter {
  final BubblesSimulation bubblesSimulation;

  BubblesPainter({required this.bubblesSimulation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubbleBody in bubblesSimulation.physics.bubbleBodys) {
      Bubble bubble = bubbleBody.userData as Bubble;
      canvas.drawCircle(Offset(bubbleBody.position.x, bubbleBody.position.y),
          bubble.radius, Paint()..color = bubble.color);
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) {
    return true;
  }
}

typedef PaintCallback = Function();

class BubblesSimulation {
  final BubblesPhysics physics;

  BubblesSimulation({required Size size})
      : physics = BubblesPhysics(
            size: size, gravity: Vector2(0, 9.8), maxNumBubbles: 5);
}

class BubblesPhysics {
  final Size size;
  final Vector2 origin;
  final World world;
  final int maxNumBubbles;
  final double minBubbleRadius = 32;
  final double maxBubbleRadius = 64;
  late final double bubbleRadiusVariance;
  final double ppm = 100;
  Vector2 gravity;
  List<Body> bubbleBodys = [];

  final _random = Random();

  // Debug colors for rendering bubbles before I have album art loading
  final List<Color> colors = [
    const Color.fromARGB(255, 62, 36, 251),
    const Color.fromARGB(255, 39, 230, 227),
    const Color.fromARGB(255, 253, 112, 33),
    const Color.fromARGB(255, 253, 66, 193),
  ];

  BubblesPhysics(
      {required this.size, required this.gravity, required this.maxNumBubbles})
      : world = World(gravity),
        origin = Vector2(size.width / 2, size.height / 2) {
    if (minBubbleRadius < 1 || maxBubbleRadius < minBubbleRadius) {
      throw ArgumentError(
          'Bubble radius must satisty minBubbleRadius >= 1 >= maxBubbleRadius, and we got $minBubbleRadius >= 1 >= $maxBubbleRadius');
    }
    bubbleRadiusVariance = maxBubbleRadius - minBubbleRadius;
    // forge2d settings
    velocityIterations = 5;
    positionIterations = 5;
  }

  void spawnBubbles(int numBubblesToSpawn) {
    // ensure we do not spawn more bubbles than we can spawn
    numBubblesToSpawn =
        min(numBubblesToSpawn, maxNumBubbles - bubbleBodys.length);
    if (numBubblesToSpawn > 0) {
      // Spawn in the desired bubbles with a brief delay per bubble
      dart_async.Timer.periodic(const Duration(milliseconds: 70), (timer) {
        double spawnX = _random.nextDouble() * origin.x + origin.x;
        _spawnBubble(Vector2(spawnX, origin.y),
            _random.nextDouble() * bubbleRadiusVariance + minBubbleRadius);
        // cancel the timer when we have spawned all of our bubbles
        numBubblesToSpawn -= 1;
        if (numBubblesToSpawn <= 0) {
          timer.cancel();
        }
      });
    }
  }

  void step(double stepDeltaSeconds) {
    world.stepDt(stepDeltaSeconds);
  }

  void _spawnBubble(Vector2 position, double ballRadius) {
    final bouncingRectangle = CircleShape()..radius = ballRadius / ppm;

    final activeFixtureDef = FixtureDef(bouncingRectangle)
      ..density = 4
      ..friction = 1
      ..restitution = .2;

    final activeBodyDef = BodyDef();
    activeBodyDef.position = position / ppm;
    activeBodyDef.type = BodyType.dynamic;
    activeBodyDef.bullet = true;
    Body boxBody = world.createBody(activeBodyDef);
    boxBody.createFixture(activeFixtureDef);
    boxBody.userData = Bubble(
        color: colors[_random.nextInt(colors.length)], radius: ballRadius);

    bubbleBodys.add(boxBody);
  }
}

class Bubble {
  final Color color;
  final double radius;

  Bubble({required this.color, required this.radius});
}
