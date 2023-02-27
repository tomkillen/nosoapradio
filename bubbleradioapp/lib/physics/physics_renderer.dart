import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

import 'bubble_simulation.dart';

/// Helper class for rendering physics bodies
class PhysicsRenderer {
  /// Pixels per meter for mapping physics units to UI units
  double get _ppm => BubbleSimulation.ppm;

  /// Renders the given physics body to the screen, capable of rendering
  /// circles, polygons, and edges
  renderBody(Canvas canvas, Body body, Color? color) {
    double angle = body.angle;
    Vector2 position = body.position * _ppm;

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
      } else if (f.type == ShapeType.edge) {
        _drawEdgeShape(canvas, f.shape as EdgeShape, color);
      }
    }

    canvas.restore();
  }

  /// Renders a circle body
  _drawCircleShape(Canvas canvas, CircleShape circle, Color? color) {
    canvas.drawCircle(
        Offset(circle.position.x * _ppm, circle.position.x * _ppm),
        circle.radius * _ppm,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color ?? Colors.amber);
  }

  /// Renders a polygon body
  _drawPolygonShape(Canvas canvas, PolygonShape polygon, Color? color) {
    int verticesCount = polygon.vertices.length;
    List<Offset> points = [];
    for (int i = 0; i < verticesCount; i++) {
      Vector2 vertice = polygon.vertices[i] * _ppm;
      points.add(Offset(vertice.x, vertice.y));
    }

    canvas.drawRect(
        Rect.fromLTRB(points[0].dx, points[2].dy, points[2].dx, points[0].dy),
        Paint()
          ..strokeWidth = 1
          ..style = PaintingStyle.fill
          ..color = color ?? Colors.blue);
  }

  /// Renders and edge
  _drawEdgeShape(Canvas canvas, EdgeShape edge, Color? color) {
    throw UnsupportedError('_drawEdgeShape Not implemented');
  }
}
