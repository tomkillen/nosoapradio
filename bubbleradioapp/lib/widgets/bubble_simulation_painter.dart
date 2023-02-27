import 'package:flutter/material.dart';

import '../../../models/bubble.dart';
import '../../../physics/bubble_simulation.dart';
import '../../../physics/physics_renderer.dart';

/// Utility class for rendering the bubble simulation directly to the screen
/// using a CustomPainter
class BubbleSimulationPainterWidget extends LeafRenderObjectWidget {
  final BubbleSimulation bubbleSimulation;

  const BubbleSimulationPainterWidget({super.key, required this.bubbleSimulation});

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
    _paintWorld(context, offset);
  }

  void _paintWorld(PaintingContext context, Offset offset) async {
    Canvas canvas = context.canvas;
    canvas.save();
    {
      for (var body in _bubbleSimulation.world.bodies) {
        Bubble? bubble = body.userData is Bubble ? body.userData as Bubble : null;
        Color? color = bubble?.color;
        _renderer.renderBody(canvas, body, color);
      }
    }
    canvas.restore();
  }
}
