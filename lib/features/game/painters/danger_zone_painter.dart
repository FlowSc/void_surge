import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class DangerZonePainter {
  static final Paint _dangerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static void paint(Canvas canvas, GameWorld world) {
    final camera = world.camera;
    final visibleRect = camera.visibleWorldRect;

    // Enemy danger zones
    for (final enemy in world.enemies) {
      if (enemy.mass <= world.player.mass) continue;
      final pullRadius =
          enemy.radius * VoidSurgeConstants.pullRadiusMultiplier;

      // Skip if not visible
      if (!_isCircleVisible(enemy.position, pullRadius, visibleRect)) continue;

      _paintPixelRing(
        canvas,
        camera,
        enemy.position,
        pullRadius,
        VoidSurgeConstants.enemyColor.withValues(alpha: 0.4),
        world.gameTime,
      );
    }

    // Player's own gravity range (subtle)
    final playerPull = world.player.radius *
        VoidSurgeConstants.pullRadiusMultiplier;
    _paintPixelRing(
      canvas,
      camera,
      world.player.position,
      playerPull,
      VoidSurgeConstants.playerColor.withValues(alpha: 0.2),
      world.gameTime,
    );
  }

  static void _paintPixelRing(
    Canvas canvas,
    GameCamera camera,
    Vec2 center,
    double radius,
    Color color,
    double time,
  ) {
    _dangerPaint.color = color;
    const segments = 32;
    final dashOffset = (time * 2) % (2 * pi / segments);

    for (var i = 0; i < segments; i++) {
      if (i % 2 == 0) continue; // Dashed
      final a1 = (i / segments) * 2 * pi + dashOffset;
      final a2 = ((i + 1) / segments) * 2 * pi + dashOffset;

      final p1 = camera.worldToScreen(
        Vec2(center.x + cos(a1) * radius, center.y + sin(a1) * radius),
      );
      final p2 = camera.worldToScreen(
        Vec2(center.x + cos(a2) * radius, center.y + sin(a2) * radius),
      );

      canvas.drawLine(p1, p2, _dangerPaint);
    }
  }

  static bool _isCircleVisible(Vec2 center, double radius, Rect visibleRect) {
    return visibleRect.inflate(radius).contains(center.toOffset());
  }
}
