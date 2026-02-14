import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/enemy_black_hole.dart';
import 'package:void_surge/features/game/models/planet.dart';
import 'package:void_surge/features/game/models/player.dart';

abstract final class EntityPainter {
  static final Paint _p = Paint();
  static final Paint _strokeP = Paint()..style = PaintingStyle.stroke;

  static final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  // ─── Planets (Retro Stepped Shading) ─────────────────────

  static void paintPlanets(
    Canvas canvas,
    GameCamera camera,
    List<Planet> planets,
    Rect visibleRect,
    double gameTime,
  ) {
    for (final planet in planets) {
      if (!visibleRect
          .inflate(planet.radius * 2)
          .contains(planet.position.toOffset())) {
        continue;
      }

      final pos = camera.worldToScreen(planet.position);
      final r = (planet.radius * camera.zoom).clamp(2.0, 40.0);

      if (r < 1.0) continue;

      switch (planet.type) {
        case PlanetType.redDwarf:
          _paintRedDwarf(canvas, pos, r, planet.color, gameTime);
        case PlanetType.whiteDwarf:
          _paintWhiteDwarf(canvas, pos, r, planet.color, gameTime);
        case PlanetType.blackDwarf:
          _paintBlackDwarf(canvas, pos, r, planet.color, gameTime);
        case PlanetType.normal:
          _paintPixelPlanet(canvas, pos, r, planet.color);
      }
    }
  }

  static void _paintPixelPlanet(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
  ) {
    final dark = _lerpColor(color, Colors.black, 0.5);
    final mid = _lerpColor(color, Colors.black, 0.2);
    final light = _lerpColor(color, Colors.white, 0.3);

    // Outer glow
    _p
      ..shader = null
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 1.8, _p);

    // Stepped shading: 3 concentric circles (dark → mid → light)
    // Layer 1: dark base (full circle)
    _p.color = dark;
    canvas.drawCircle(center, r, _p);

    // Layer 2: mid-tone (offset slightly top-left)
    _p.color = mid;
    canvas.drawCircle(
      Offset(center.dx - r * 0.08, center.dy - r * 0.08),
      r * 0.85,
      _p,
    );

    // Layer 3: lit face (top-left area)
    _p.color = color;
    canvas.drawCircle(
      Offset(center.dx - r * 0.2, center.dy - r * 0.2),
      r * 0.6,
      _p,
    );

    // Highlight spot
    if (r > 4) {
      _p.color = light;
      canvas.drawCircle(
        Offset(center.dx - r * 0.35, center.dy - r * 0.35),
        r * 0.2,
        _p,
      );
    }

    // Specular dot
    if (r > 6) {
      _p.color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(
        Offset(center.dx - r * 0.4, center.dy - r * 0.4),
        r * 0.08,
        _p,
      );
    }

    // 1px outline
    _strokeP
      ..shader = null
      ..color = dark.withValues(alpha: 0.8)
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, r, _strokeP);
  }

  // ─── Special Planets ─────────────────────────────────────────

  static void _paintRedDwarf(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    double gameTime,
  ) {
    // Pulsing outer glow
    final pulse = 0.8 + 0.2 * sin(gameTime * 4.0);
    _p
      ..shader = null
      ..color = color.withValues(alpha: 0.15 * pulse)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 2.5 * pulse, _p);

    // Second glow layer
    _p.color = color.withValues(alpha: 0.1 * pulse);
    canvas.drawCircle(center, r * 1.8 * pulse, _p);

    // Base planet
    _paintPixelPlanet(canvas, center, r, color);

    // Pulsing red outer ring
    _strokeP
      ..shader = null
      ..color = color.withValues(alpha: 0.6 * pulse)
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, r * 1.2, _strokeP);

    // Second ring
    _strokeP
      ..color = color.withValues(alpha: 0.3 * pulse)
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, r * 1.5 * pulse, _strokeP);
  }

  static void _paintWhiteDwarf(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    double gameTime,
  ) {
    // Bright emission glow
    _p
      ..shader = null
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 2.8, _p);
    _p.color = color.withValues(alpha: 0.2);
    canvas.drawCircle(center, r * 1.6, _p);

    // Base planet
    _paintPixelPlanet(canvas, center, r, color);

    // Star cross (+) highlight
    if (r > 4) {
      final crossLen = r * 1.8;
      final shimmer = 0.5 + 0.5 * sin(gameTime * 3.0);
      _strokeP
        ..shader = null
        ..color = Colors.white.withValues(alpha: 0.6 * shimmer)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(center.dx - crossLen, center.dy),
        Offset(center.dx + crossLen, center.dy),
        _strokeP,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - crossLen),
        Offset(center.dx, center.dy + crossLen),
        _strokeP,
      );

      // Diagonal cross (x) for extra sparkle
      final diagLen = crossLen * 0.6;
      _strokeP
        ..color = Colors.white.withValues(alpha: 0.3 * shimmer)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(center.dx - diagLen, center.dy - diagLen),
        Offset(center.dx + diagLen, center.dy + diagLen),
        _strokeP,
      );
      canvas.drawLine(
        Offset(center.dx + diagLen, center.dy - diagLen),
        Offset(center.dx - diagLen, center.dy + diagLen),
        _strokeP,
      );
    }
  }

  static void _paintBlackDwarf(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    double gameTime,
  ) {
    // Subtle purple-tinted aura
    final flicker = 0.7 + 0.3 * sin(gameTime * 2.0);
    _p
      ..shader = null
      ..color = const Color(0xFF442266).withValues(alpha: 0.08 * flicker)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 2.0, _p);

    // Dark planet body
    final dark = _lerpColor(color, Colors.black, 0.4);
    final mid = _lerpColor(color, Colors.black, 0.2);

    // Dark base
    _p.color = Colors.black.withValues(alpha: 0.8);
    canvas.drawCircle(center, r, _p);

    // Subtle surface detail
    _p.color = dark.withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(center.dx - r * 0.1, center.dy - r * 0.1),
      r * 0.85,
      _p,
    );
    _p.color = mid.withValues(alpha: 0.3);
    canvas.drawCircle(
      Offset(center.dx - r * 0.2, center.dy - r * 0.2),
      r * 0.5,
      _p,
    );

    // Purple border
    _strokeP
      ..shader = null
      ..color = const Color(0xFF6633AA).withValues(alpha: 0.5 * flicker)
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r, _strokeP);

    // Faint inner ring
    _strokeP
      ..color = const Color(0xFF442266).withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, r * 0.7, _strokeP);
  }

  // ─── Enemies ───────────────────────────────────────────────

  static void paintEnemies(
    Canvas canvas,
    GameCamera camera,
    List<EnemyBlackHole> enemies,
    Rect visibleRect,
    double gameTime,
  ) {
    for (final enemy in enemies) {
      if (!visibleRect
          .inflate(enemy.radius * 3)
          .contains(enemy.position.toOffset())) {
        continue;
      }

      final pos = camera.worldToScreen(enemy.position);
      final r = (enemy.radius * camera.zoom).clamp(6.0, 200.0);

      _paintRetroBlackHole(
        canvas,
        pos,
        r,
        VoidSurgeConstants.enemyColor,
        gameTime,
        enemy.entity.id.toDouble(),
      );

      _paintMassLabel(canvas, pos, r, enemy.mass);
    }
  }

  // ─── Player ────────────────────────────────────────────────

  static void paintPlayer(
    Canvas canvas,
    GameCamera camera,
    Player player,
    double gameTime,
  ) {
    final pos = camera.worldToScreen(player.position);
    final r = (player.radius * camera.zoom).clamp(6.0, 200.0);

    _paintRetroBlackHole(
      canvas,
      pos,
      r,
      VoidSurgeConstants.playerColor,
      gameTime,
      0,
    );

    _paintMassLabel(canvas, pos, r, player.mass);
  }

  // ─── Retro Black Hole ──────────────────────────────────────

  static void _paintRetroBlackHole(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    double time,
    double seed,
  ) {
    final bright = _lerpColor(color, Colors.white, 0.4);

    // 1) Halo glow
    _p
      ..shader = null
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 3.0, _p);
    _p.color = color.withValues(alpha: 0.1);
    canvas.drawCircle(center, r * 2.0, _p);

    // 2) Accretion disc — segmented ring (back half)
    _paintRetroAccretionDisc(canvas, center, r, color, time, seed, back: true);

    // 3) Event horizon — dark core with colored edge
    _p.color = color.withValues(alpha: 0.3);
    canvas.drawCircle(center, r * 1.05, _p);
    _p.color = const Color(0xFF000000);
    canvas.drawCircle(center, r, _p);

    // 4) Photon ring — dashed circle outline
    _paintDashedCircle(canvas, center, r * 1.1, color, time, seed);

    // 5) Inner glow ring
    _strokeP
      ..shader = null
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, r * 0.85, _strokeP);

    // 6) Accretion disc — front half
    _paintRetroAccretionDisc(canvas, center, r, color, time, seed, back: false);

    // 7) Central bright dot
    if (r > 10) {
      _p.color = bright.withValues(alpha: 0.4);
      canvas.drawCircle(center, (r * 0.08).clamp(1.0, 4.0), _p);
    }
  }

  // ─── Retro Accretion Disc (segmented dots) ─────────────────

  static void _paintRetroAccretionDisc(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    double time,
    double seed, {
    required bool back,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    const tiltY = 0.35;
    final rotSpeed = time * 0.6 + seed * 0.1;
    final bright = _lerpColor(color, Colors.white, 0.3);

    final discLayers = [
      (radius: r * 2.2, alpha: 0.15),
      (radius: r * 1.8, alpha: 0.25),
      (radius: r * 1.5, alpha: 0.35),
    ];

    const segments = 12;
    final startAngle = back ? pi : 0.0;

    for (final layer in discLayers) {
      for (var i = 0; i < segments ~/ 2; i++) {
        final segAngle = startAngle + (i / (segments / 2)) * pi + rotSpeed;
        final segAlpha = layer.alpha * (0.5 + 0.5 * ((i % 3 == 0) ? 1.0 : 0.6));

        final x = cos(segAngle) * layer.radius;
        final y = sin(segAngle) * layer.radius * tiltY;

        final segSize = (r * 0.1).clamp(1.5, 6.0);

        _p
          ..shader = null
          ..color = (i % 3 == 0 ? bright : color).withValues(alpha: segAlpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), segSize, _p);
      }
    }

    if (!back) {
      _paintRetroDiscParticles(canvas, r, color, time, seed, tiltY);
    }

    canvas.restore();
  }

  static void _paintRetroDiscParticles(
    Canvas canvas,
    double r,
    Color color,
    double time,
    double seed,
    double tiltY,
  ) {
    const count = 12;
    final bright = _lerpColor(color, Colors.white, 0.6);

    for (var i = 0; i < count; i++) {
      final phase = seed * 0.3 + i * (2 * pi / count);
      final orbitR = r * (1.3 + 0.5 * sin(i * 1.7 + seed));
      final angle = time * (0.8 + i * 0.05) + phase;

      final x = cos(angle) * orbitR;
      final y = sin(angle) * orbitR * tiltY;

      final particleAlpha = (0.3 + 0.7 * ((sin(angle) + 1) / 2)).clamp(0.0, 1.0);
      final particleSize = (r * 0.06).clamp(1.0, 3.0);

      _p
        ..shader = null
        ..color = bright.withValues(alpha: particleAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), particleSize, _p);
    }
  }

  // ─── Dashed Circle (Photon Ring) ───────────────────────────

  static void _paintDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double time,
    double seed,
  ) {
    const dashCount = 10;
    final rotation = time * 0.8 + seed;

    for (var i = 0; i < dashCount; i++) {
      final angle = (i / dashCount) * 2 * pi + rotation;
      final alpha = (0.3 + 0.6 * ((sin(angle * 2 + time) + 1) / 2)).clamp(0.0, 1.0);

      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      final dotSize = (radius * 0.08).clamp(1.5, 4.0);

      _p
        ..shader = null
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotSize, _p);
    }
  }

  // ─── Mass Label ────────────────────────────────────────────

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
        fontSize: (screenRadius * 0.35).clamp(6.0, 14.0),
        color: Colors.white.withValues(alpha: 0.9),
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 2),
        ],
      ),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(
        center.dx - _textPainter.width / 2,
        center.dy + screenRadius * 1.3 + 4,
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────

  static Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }
}
