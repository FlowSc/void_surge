import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class DangerZonePainter {
  static final Paint _p = Paint();
  static final Paint _strokeP = Paint()..style = PaintingStyle.stroke;

  static void paint(Canvas canvas, GameWorld world) {
    final camera = world.camera;
    final visibleRect = camera.visibleWorldRect;

    // Enemy danger zones
    for (final enemy in world.enemies) {
      if (enemy.mass <= world.player.mass) continue;
      final pullRadius =
          enemy.radius * VoidSurgeConstants.pullRadiusMultiplier;

      if (!_isCircleVisible(enemy.position, pullRadius, visibleRect)) continue;

      _paintDangerZone(
        canvas,
        camera,
        enemy.position,
        pullRadius,
        VoidSurgeConstants.enemyColor,
        world.gameTime,
      );
    }

    // Player gravity range (subtle)
    final playerPull =
        world.player.radius * VoidSurgeConstants.pullRadiusMultiplier;
    _paintGravityField(
      canvas,
      camera,
      world.player.position,
      playerPull,
      VoidSurgeConstants.playerColor,
      world.gameTime,
    );
  }

  static void _paintDangerZone(
    Canvas canvas,
    GameCamera camera,
    Vec2 center,
    double radius,
    Color color,
    double time,
  ) {
    final screenPos = camera.worldToScreen(center);
    final screenRadius = radius * camera.zoom;

    // Radial danger gradient fill
    _p
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.03),
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 0.85, 1.0],
      ).createShader(
          Rect.fromCircle(center: screenPos, radius: screenRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(screenPos, screenRadius, _p);
    _p.shader = null;

    // Animated dashed ring
    final pulse = (sin(time * 3) + 1) / 2;
    final dashAlpha = 0.2 + pulse * 0.3;

    _strokeP
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: dashAlpha),
          color.withValues(alpha: 0.0),
          color.withValues(alpha: dashAlpha),
          color.withValues(alpha: 0.0),
          color.withValues(alpha: dashAlpha),
          color.withValues(alpha: 0.0),
          color.withValues(alpha: dashAlpha),
          color.withValues(alpha: 0.0),
        ],
        transform: GradientRotation(time * 1.5),
      ).createShader(
          Rect.fromCircle(center: screenPos, radius: screenRadius))
      ..strokeWidth = (screenRadius * 0.02).clamp(1.0, 3.0);
    canvas.drawCircle(screenPos, screenRadius, _strokeP);
    _strokeP.shader = null;
  }

  static void _paintGravityField(
    Canvas canvas,
    GameCamera camera,
    Vec2 center,
    double radius,
    Color color,
    double time,
  ) {
    final screenPos = camera.worldToScreen(center);
    final screenRadius = radius * camera.zoom;

    _strokeP
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.0),
        ],
        transform: GradientRotation(time * 0.5),
      ).createShader(
          Rect.fromCircle(center: screenPos, radius: screenRadius))
      ..strokeWidth = 1.0;
    canvas.drawCircle(screenPos, screenRadius, _strokeP);
    _strokeP.shader = null;
  }

  static bool _isCircleVisible(Vec2 center, double radius, Rect visibleRect) {
    return visibleRect.inflate(radius).contains(center.toOffset());
  }
}
