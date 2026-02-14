import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/features/game/models/absorption_effect.dart';
import 'package:void_surge/features/game/models/camera.dart';

abstract final class EffectPainter {
  static final Paint _p = Paint()..style = PaintingStyle.fill;

  static void paint(
    Canvas canvas,
    GameCamera camera,
    List<AbsorptionEffect> effects,
    double gameTime,
  ) {
    for (final effect in effects) {
      final t = effect.progress(gameTime);
      if (t >= 1.0) continue;

      final screenPos = camera.worldToScreen(effect.position);
      final screenTarget = camera.worldToScreen(effect.targetPosition);
      final baseR = effect.initialRadius * camera.zoom;

      _paintShrinkPhase(canvas, screenPos, screenTarget, baseR, t, effect.color);

      if (t > 0.2) {
        _paintFlash(canvas, screenPos, screenTarget, baseR, t, effect.color);
      }

      if (t > 0.25) {
        _paintParticles(
          canvas,
          screenPos,
          screenTarget,
          baseR,
          t,
          effect.color,
          effect.id,
        );
      }
    }
  }

  static void _paintShrinkPhase(
    Canvas canvas,
    Offset from,
    Offset to,
    double baseR,
    double t,
    Color color,
  ) {
    final shrinkT = (t / 0.4).clamp(0.0, 1.0);
    final eased = _easeInQuad(shrinkT);

    final currentPos = Offset.lerp(from, to, eased)!;
    final currentR = baseR * (1.0 - eased);

    if (currentR < 0.5) return;

    final alpha = (1.0 - shrinkT).clamp(0.0, 1.0);

    // Shrinking circle
    _p.color = color.withValues(alpha: alpha);
    canvas.drawCircle(currentPos, currentR, _p);

    // Inner highlight
    if (currentR > 3) {
      _p.color = Colors.white.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(
        Offset(currentPos.dx - currentR * 0.2, currentPos.dy - currentR * 0.2),
        currentR * 0.3,
        _p,
      );
    }
  }

  static void _paintFlash(
    Canvas canvas,
    Offset from,
    Offset to,
    double baseR,
    double t,
    Color color,
  ) {
    final flashT = ((t - 0.2) / 0.15).clamp(0.0, 1.0);
    if (flashT >= 1.0) return;

    final flashAlpha = (1.0 - flashT) * 0.8;
    final flashPos = Offset.lerp(from, to, 0.5)!;
    final flashR = baseR * (0.8 + flashT * 1.5);

    // White flash circle
    _p.color = Colors.white.withValues(alpha: flashAlpha);
    canvas.drawCircle(flashPos, flashR, _p);

    // Colored outer flash
    _p.color = color.withValues(alpha: flashAlpha * 0.5);
    canvas.drawCircle(flashPos, flashR * 1.5, _p);
  }

  static void _paintParticles(
    Canvas canvas,
    Offset from,
    Offset to,
    double baseR,
    double t,
    Color color,
    int seed,
  ) {
    final particleT = ((t - 0.25) / 0.75).clamp(0.0, 1.0);
    const particleCount = 10;
    final rng = Random(seed);

    final burstOrigin = Offset.lerp(from, to, 0.4)!;
    final targetOffset = to;

    for (var i = 0; i < particleCount; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 0.5 + rng.nextDouble() * 1.5;
      final particleR = (baseR * (0.08 + rng.nextDouble() * 0.1)).clamp(1.0, 4.0);

      final burstPhase = (particleT * 2.0).clamp(0.0, 1.0);
      final spiralPhase = ((particleT - 0.3) / 0.7).clamp(0.0, 1.0);

      // Burst outward
      final burstDist = baseR * speed * burstPhase;
      final burstX = cos(angle) * burstDist;
      final burstY = sin(angle) * burstDist;
      final burstPos = Offset(burstOrigin.dx + burstX, burstOrigin.dy + burstY);

      // Spiral toward target
      final spiralAngle = angle + spiralPhase * pi * 3;
      final spiralR = burstDist * (1.0 - spiralPhase);
      final spiralCenter = Offset.lerp(burstOrigin, targetOffset, spiralPhase)!;
      final spiralPos = Offset(
        spiralCenter.dx + cos(spiralAngle) * spiralR,
        spiralCenter.dy + sin(spiralAngle) * spiralR,
      );

      final pos = Offset.lerp(burstPos, spiralPos, spiralPhase.clamp(0.0, 1.0))!;
      final alpha = (1.0 - particleT * 0.8).clamp(0.0, 1.0);

      _p.color = i.isEven
          ? color.withValues(alpha: alpha)
          : Colors.white.withValues(alpha: alpha * 0.8);

      canvas.drawCircle(pos, particleR, _p);
    }
  }

  static double _easeInQuad(double t) => t * t;
}
