import 'dart:ui';

import 'package:bubbleradioapp/features/bubblesimulation/physics/bubble_simulation.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

class PhysicsRenderer {
  double get ppm => BubbleSimulation.ppm;

  renderBody(Canvas canvas, Body body, Color? color) {
    double angle = body.angle;
    Vector2 position = body.position * ppm;

    Matrix4 matrix = Matrix4.identity()
      ..leftTranslate(position.x, position.y)
      ..rotateZ(angle);
    canvas.save();
    canvas.transform(matrix.storage);

    // If no color was specified, lets see if the body provides a color
    if (color == null && body.userData is Color) {
      color = body.userData as Color;
    }

    for (Fixture f in body.fixtures) {
      if (f.type == ShapeType.circle) {
        _drawCircleShape(canvas, f.shape as CircleShape, color);
      } else if (f.type == ShapeType.polygon) {
        _drawPolygonShape(canvas, f.shape as PolygonShape, color);
      } else if (f.type == ShapeType.chain) {
        _drawChainShape(canvas, f.shape as ChainShape, color);
      } else if (f.type == ShapeType.edge) {
        _drawEdgeShape(canvas, f.shape as EdgeShape, color);
      }
    }

    canvas.restore();
  }

  _drawCircleShape(Canvas canvas, CircleShape circle, Color? color) {
    canvas.drawCircle(
        Offset(circle.position.x * ppm, circle.position.x * ppm),
        circle.radius * ppm,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color ?? Colors.amber);
  }

  _drawPolygonShape(Canvas canvas, PolygonShape polygon, Color? color) {
    int verticesCount = polygon.vertices.length;
    List<Offset> points = [];
    for (int i = 0; i < verticesCount; i++) {
      Vector2 vertice = polygon.vertices[i] * ppm;
      points.add(Offset(vertice.x, vertice.y));
    }

    canvas.drawRect(
        Rect.fromLTRB(points[0].dx, points[2].dy, points[2].dx, points[0].dy),
        Paint()
          ..strokeWidth = 1
          ..style = PaintingStyle.fill
          ..color = color ?? Colors.blue);
  }

  _drawEdgeShape(Canvas canvas, EdgeShape edge, Color? color) {
    throw UnsupportedError('_drawEdgeShape Not implemented');
  }

  _drawChainShape(Canvas canvas, ChainShape chain, Color? color) {
    List<Offset> points = [];
    int vertexCount = chain.vertexCount;

    for (int i = 0; i < vertexCount; i++) {
      Vector2 vertex = chain.vertex(i) * ppm;
      points.add(Offset(vertex.x, vertex.y));
    }

    canvas.drawPoints(
        PointMode.lines,
        points,
        Paint()
          ..strokeWidth = 1
          ..style = PaintingStyle.fill
          ..color = color ?? Colors.green);
  }
}
