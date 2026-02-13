import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class BackgroundPainter {
  static final Paint _starPaint = Paint();
  static final Paint _fieldBorderPaint = Paint()
    ..color = VoidSurgeConstants.fieldBorderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static void paint(
    Canvas canvas,
    Size size,
    GameWorld world,
  ) {
    // Background color
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = VoidSurgeConstants.backgroundColor,
    );

    final camera = world.camera;

    // Stars
    for (final star in world.backgroundStars) {
      final screenPos = camera.worldToScreen(star.position);
      if (screenPos.dx < -10 ||
          screenPos.dx > size.width + 10 ||
          screenPos.dy < -10 ||
          screenPos.dy > size.height + 10) {
        continue;
      }

      final blink = (sin(world.gameTime * 2.0 + star.blinkPhase) + 1) / 2;
      final alpha = (0.3 + blink * 0.7).clamp(0.0, 1.0);
      _starPaint.color = Colors.white.withValues(alpha: alpha);

      final pixelSize = star.size * camera.zoom.clamp(0.3, 1.5);
      canvas.drawRect(
        Rect.fromCenter(
          center: screenPos,
          width: pixelSize,
          height: pixelSize,
        ),
        _starPaint,
      );
    }

    // Field boundary (pixelated circle approximation using dashed segments)
    _paintFieldBoundary(canvas, camera, world.fieldRadius);
  }

  static void _paintFieldBoundary(
    Canvas canvas,
    GameCamera camera,
    double fieldRadius,
  ) {
    const segments = 64;
    for (var i = 0; i < segments; i++) {
      if (i % 2 == 1) continue; // Dashed effect
      final a1 = (i / segments) * 2 * pi;
      final a2 = ((i + 1) / segments) * 2 * pi;

      final p1 = camera.worldToScreen(
        Vec2(cos(a1) * fieldRadius, sin(a1) * fieldRadius),
      );
      final p2 = camera.worldToScreen(
        Vec2(cos(a2) * fieldRadius, sin(a2) * fieldRadius),
      );

      canvas.drawLine(p1, p2, _fieldBorderPaint);
    }
  }
}
