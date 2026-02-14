import 'dart:ui';

import 'package:void_surge/features/game/models/vec2.dart';

class AbsorptionEffect {
  final int id;
  final Vec2 position;
  final Vec2 targetPosition;
  final Color color;
  final double startTime;
  final double duration;
  final double initialRadius;

  const AbsorptionEffect({
    required this.id,
    required this.position,
    required this.targetPosition,
    required this.color,
    required this.startTime,
    required this.duration,
    required this.initialRadius,
  });

  double progress(double gameTime) {
    return ((gameTime - startTime) / duration).clamp(0.0, 1.0);
  }

  bool isExpired(double gameTime) => gameTime - startTime > duration;
}
