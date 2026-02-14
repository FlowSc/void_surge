import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class BackgroundPainter {
  static final Paint _p = Paint();
  static final Paint _fieldBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _scanlinePaint = Paint();

  static void paint(
    Canvas canvas,
    Size size,
    GameWorld world,
  ) {
    final camera = world.camera;

    // Deep space background
    _paintDeepSpace(canvas, size, world);

    // Stars as small circles
    _paintPixelStars(canvas, size, camera, world);

    // Scanline overlay
    _paintScanlines(canvas, size);

    // Field boundary
    _paintFieldBoundary(canvas, camera, world.fieldRadius, world.gameTime);
  }

  static void _paintDeepSpace(Canvas canvas, Size size, GameWorld world) {
    // Solid dark base
    _p
      ..shader = null
      ..color = const Color(0xFF050510)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _p);

    // Stepped nebula clouds (concentric circles, coarse retro feel)
    final camera = world.camera;
    _paintRetroNebula(
      canvas, size, camera,
      const Vec2(200, -150), 120,
      const Color(0xFF6644FF), 0.06,
    );
    _paintRetroNebula(
      canvas, size, camera,
      const Vec2(-300, 200), 180,
      const Color(0xFFFF3344), 0.04,
    );
    _paintRetroNebula(
      canvas, size, camera,
      const Vec2(100, 400), 100,
      const Color(0xFF00E5FF), 0.03,
    );
  }

  static void _paintRetroNebula(
    Canvas canvas,
    Size size,
    GameCamera camera,
    Vec2 worldPos,
    double worldRadius,
    Color color,
    double alpha,
  ) {
    final screenPos = camera.worldToScreen(worldPos);
    final screenRadius = worldRadius * camera.zoom;

    if (screenPos.dx < -screenRadius * 2 ||
        screenPos.dx > size.width + screenRadius * 2 ||
        screenPos.dy < -screenRadius * 2 ||
        screenPos.dy > size.height + screenRadius * 2) {
      return;
    }

    // Stepped concentric circles instead of smooth gradient
    const steps = 4;
    for (var i = steps; i >= 1; i--) {
      final ratio = i / steps;
      final stepAlpha = alpha * ratio;
      final stepR = screenRadius * ratio;

      _p
        ..shader = null
        ..color = color.withValues(alpha: stepAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(screenPos, stepR, _p);
    }
  }

  static void _paintPixelStars(
    Canvas canvas,
    Size size,
    GameCamera camera,
    GameWorld world,
  ) {
    const starColors = [
      Color(0xFFFFFFFF),
      Color(0xFFAABBFF),
      Color(0xFFFFDDAA),
      Color(0xFFFFAAAA),
      Color(0xFFDDDDFF),
    ];

    for (final star in world.backgroundStars) {
      final screenPos = camera.worldToScreen(star.position);
      if (screenPos.dx < -5 ||
          screenPos.dx > size.width + 5 ||
          screenPos.dy < -5 ||
          screenPos.dy > size.height + 5) {
        continue;
      }

      final blink = (sin(world.gameTime * 2.0 + star.blinkPhase) + 1) / 2;
      final alpha = (0.3 + blink * 0.7).clamp(0.0, 1.0);
      final colorIdx =
          (star.blinkPhase * 10).toInt().abs() % starColors.length;
      final starColor = starColors[colorIdx];

      final screenSize = star.size * camera.zoom.clamp(0.5, 1.5);
      final pixelR = screenSize < 1.2 ? 0.5 : 1.0;

      // Subtle glow for brighter stars
      if (pixelR > 0.7) {
        _p
          ..shader = null
          ..color = starColor.withValues(alpha: alpha * 0.15)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(screenPos, pixelR * 4, _p);
      }

      // Star core: crisp small circle
      _p
        ..shader = null
        ..color = starColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(screenPos, pixelR, _p);
    }
  }

  static void _paintScanlines(Canvas canvas, Size size) {
    // Subtle horizontal scanline overlay for CRT retro feel
    _scanlinePaint
      ..shader = null
      ..color = Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    const lineSpacing = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.0),
        _scanlinePaint,
      );
      y += lineSpacing;
    }
  }

  static void _paintFieldBoundary(
    Canvas canvas,
    GameCamera camera,
    double fieldRadius,
    double time,
  ) {
    const segments = 64;
    final pulse = (sin(time * 1.5) + 1) / 2;
    final borderAlpha = 0.15 + pulse * 0.15;

    _fieldBorderPaint
      ..color = Colors.white.withValues(alpha: borderAlpha)
      ..strokeWidth = 1.0;

    for (var i = 0; i < segments; i++) {
      if (i % 2 == 1) continue;
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
