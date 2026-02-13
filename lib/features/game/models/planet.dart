import 'dart:ui';

import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/vec2.dart';

class Planet {
  final Entity entity;
  final Color color;

  const Planet({
    required this.entity,
    required this.color,
  });

  double get mass => entity.mass;
  double get radius => entity.radius;
  Vec2 get position => entity.position;

  Planet copyWith({
    Entity? entity,
    Color? color,
  }) {
    return Planet(
      entity: entity ?? this.entity,
      color: color ?? this.color,
    );
  }
}
