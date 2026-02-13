import 'dart:math';

import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/vec2.dart';

class Entity {
  final int id;
  final Vec2 position;
  final Vec2 velocity;
  final double mass;

  const Entity({
    required this.id,
    required this.position,
    this.velocity = Vec2.zero,
    required this.mass,
  });

  double get radius =>
      VoidSurgeConstants.entityBaseRadius *
      pow(mass, VoidSurgeConstants.entityRadiusExponent).toDouble();

  Entity copyWith({
    int? id,
    Vec2? position,
    Vec2? velocity,
    double? mass,
  }) {
    return Entity(
      id: id ?? this.id,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      mass: mass ?? this.mass,
    );
  }
}
