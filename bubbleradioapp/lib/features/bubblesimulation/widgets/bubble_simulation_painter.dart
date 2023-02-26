import 'dart:ui';
import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';

import '../models/bubble.dart';
import '../physics/bubble_simulation.dart';
import '../physics/physics_renderer.dart';

class BubbleSimulationPainterWidget extends LeafRenderObjectWidget {
  final BubbleSimulation bubbleSimulation = BubbleSimulation();

  BubbleSimulationPainterWidget({super.key}) {
    final Size simSize = window.physicalSize / window.devicePixelRatio;
    bubbleSimulation.initialize(simSize, Vector2(0, -0.1));
    bubbleSimulation.spawnBubbles(1);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return BubbleSimulationRenderObject(bubbleSimulation: bubbleSimulation);
  }
}

class BubbleSimulationRenderObject extends RenderBox {
  final BubbleSimulation _bubbleSimulation;
  final PhysicsRenderer _renderer = PhysicsRenderer();

  BubbleSimulationRenderObject({required BubbleSimulation bubbleSimulation}) : _bubbleSimulation = bubbleSimulation {
    _bubbleSimulation.onNeedPaint = markNeedsPaint;
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
    canvas.save();
    {
      for (var body in _bubbleSimulation.world.bodies) {
        // Bubble? bubble = body.userData as Bubble?;
        // if (bubble != null) {
        //   _drawBubble(canvas, bubble, body);
        // }
        Bubble? bubble = body.userData is Bubble ? body.userData as Bubble : null;
        Color? color = bubble?.color;
        _renderer.renderBody(canvas, body, color);
      }
    }
    canvas.restore();
  }

  void _drawBubble(Canvas canvas, Bubble bubble, Body body) {
    double angle = body.angle;
    Vector2 position = body.position * BubbleSimulation.ppm;

    Matrix4 matrix = Matrix4.identity()
      ..leftTranslate(position.x / 2, position.y / 2)
      ..rotateZ(angle);
    canvas.save();
    {
      canvas.transform(matrix.storage);
      for (Fixture f in body.fixtures) {
        if (f.type == ShapeType.circle) {
          _drawCircleShape(canvas, f.shape as CircleShape, bubble.color);
        }
      }
    }
    canvas.restore();
  }

  void _drawCircleShape(Canvas canvas, CircleShape circle, Color color) {
    canvas.drawCircle(
        Offset.zero,
        50,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color);
  }
}
