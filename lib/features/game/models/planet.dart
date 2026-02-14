import 'dart:ui';

import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/vec2.dart';

enum PlanetType { normal, redDwarf, whiteDwarf, blackDwarf }

class Planet {
  final Entity entity;
  final Color color;
  final PlanetType type;

  const Planet({
    required this.entity,
    required this.color,
    this.type = PlanetType.normal,
  });

  double get mass => entity.mass;
  double get radius => entity.radius;
  Vec2 get position => entity.position;

  bool get isSpecial => type != PlanetType.normal;

  Planet copyWith({
    Entity? entity,
    Color? color,
    PlanetType? type,
  }) {
    return Planet(
      entity: entity ?? this.entity,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}
