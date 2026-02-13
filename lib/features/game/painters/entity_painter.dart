import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/enemy_black_hole.dart';
import 'package:void_surge/features/game/models/planet.dart';
import 'package:void_surge/features/game/models/player.dart';

abstract final class EntityPainter {
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _corePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF000000);

  static final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  static void paintPlanets(
    Canvas canvas,
    GameCamera camera,
    List<Planet> planets,
    Rect visibleRect,
  ) {
    for (final planet in planets) {
      if (!visibleRect
          .inflate(planet.radius)
          .contains(planet.position.toOffset())) {
        continue;
      }

      final screenPos = camera.worldToScreen(planet.position);
      final screenRadius = planet.radius * camera.zoom;

      if (screenRadius < 0.5) continue;

      // Pixel square planet
      final pixelSize = (screenRadius * 2).clamp(2.0, 12.0);
      _fillPaint.color = planet.color;
      canvas.drawRect(
        Rect.fromCenter(
          center: screenPos,
          width: pixelSize,
          height: pixelSize,
        ),
        _fillPaint,
      );

      // Glow
      _glowPaint.color = planet.color.withValues(alpha: 0.3);
      canvas.drawRect(
        Rect.fromCenter(
          center: screenPos,
          width: pixelSize + 4,
          height: pixelSize + 4,
        ),
        _glowPaint,
      );
    }
  }

  static void paintEnemies(
    Canvas canvas,
    GameCamera camera,
    List<EnemyBlackHole> enemies,
    Rect visibleRect,
    double gameTime,
  ) {
    for (final enemy in enemies) {
      if (!visibleRect
          .inflate(enemy.radius * 2)
          .contains(enemy.position.toOffset())) {
        continue;
      }

      final screenPos = camera.worldToScreen(enemy.position);
      final screenRadius = enemy.radius * camera.zoom;

      _paintPixelBlackHole(
        canvas,
        screenPos,
        screenRadius,
        VoidSurgeConstants.enemyColor,
        gameTime,
        enemy.entity.id.toDouble(),
      );

      // Mass label
      _paintMassLabel(canvas, screenPos, screenRadius, enemy.mass);
    }
  }

  static void paintPlayer(
    Canvas canvas,
    GameCamera camera,
    Player player,
    double gameTime,
  ) {
    final screenPos = camera.worldToScreen(player.position);
    final screenRadius = player.radius * camera.zoom;

    _paintPixelBlackHole(
      canvas,
      screenPos,
      screenRadius,
      VoidSurgeConstants.playerColor,
      gameTime,
      0,
    );

    // Accretion disc (rotating pixel dots)
    _paintAccretionDisc(canvas, screenPos, screenRadius, gameTime);

    // Mass label
    _paintMassLabel(canvas, screenPos, screenRadius, player.mass);
  }

  static void _paintPixelBlackHole(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double time,
    double seed,
  ) {
    final r = radius.clamp(4.0, 200.0);

    // Outer glow (multiple layers for pixel glow effect)
    for (var i = 3; i >= 1; i--) {
      _glowPaint.color = color.withValues(alpha: 0.1 * i);
      final glowSize = r * 2 + i * 6;
      canvas.drawRect(
        Rect.fromCenter(center: center, width: glowSize, height: glowSize),
        _glowPaint,
      );
    }

    // Main body: octagon approximation (big square + rotated square)
    _fillPaint.color = color.withValues(alpha: 0.6);
    final bodySize = r * 1.6;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: bodySize, height: bodySize),
      _fillPaint,
    );

    // Rotated square overlay for octagonal effect
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);
    _fillPaint.color = color.withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: bodySize * 0.85,
        height: bodySize * 0.85,
      ),
      _fillPaint,
    );
    canvas.restore();

    // Dark core
    final coreSize = r * 0.8;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: coreSize, height: coreSize),
      _corePaint,
    );

    // Rotating pixel ring
    final ringRadius = r * 1.2;
    const ringDots = 8;
    final rotAngle = time * 1.5 + seed;
    _fillPaint.color = color.withValues(alpha: 0.8);
    for (var i = 0; i < ringDots; i++) {
      final angle = (i / ringDots) * 2 * pi + rotAngle;
      final dx = center.dx + cos(angle) * ringRadius;
      final dy = center.dy + sin(angle) * ringRadius;
      final dotSize = (r * 0.15).clamp(1.5, 4.0);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(dx, dy), width: dotSize, height: dotSize),
        _fillPaint,
      );
    }
  }

  static void _paintAccretionDisc(
    Canvas canvas,
    Offset center,
    double radius,
    double time,
  ) {
    final discRadius = radius * 1.5;
    const dots = 12;
    _fillPaint.color = VoidSurgeConstants.playerColor.withValues(alpha: 0.5);

    for (var i = 0; i < dots; i++) {
      final angle = (i / dots) * 2 * pi + time * 2.0;
      final r = discRadius + sin(time * 3 + i) * 3;
      final dx = center.dx + cos(angle) * r;
      final dy = center.dy + sin(angle) * r;
      final dotSize = (radius * 0.1).clamp(1.0, 3.0);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(dx, dy),
          width: dotSize,
          height: dotSize,
        ),
        _fillPaint,
      );
    }
  }

  static void _paintMassLabel(
    Canvas canvas,
    Offset center,
    double screenRadius,
    double mass,
  ) {
    if (screenRadius < 10) return;

    final text = mass.toStringAsFixed(1);
    _textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: (screenRadius * 0.4).clamp(6.0, 14.0),
        color: Colors.white,
      ),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(
        center.dx - _textPainter.width / 2,
        center.dy + screenRadius + 4,
      ),
    );
  }
}
