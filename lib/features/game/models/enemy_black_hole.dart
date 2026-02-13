import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/vec2.dart';

enum EnemyBehavior { hunting, chasing, fleeing }

class EnemyBlackHole {
  final Entity entity;
  final EnemyBehavior behavior;
  final double aggressionFactor;
  final double awarenessRadius;

  const EnemyBlackHole({
    required this.entity,
    this.behavior = EnemyBehavior.hunting,
    this.aggressionFactor = 1.0,
    this.awarenessRadius = 300.0,
  });

  double get mass => entity.mass;
  double get radius => entity.radius;
  Vec2 get position => entity.position;
  Vec2 get velocity => entity.velocity;

  EnemyBlackHole copyWith({
    Entity? entity,
    EnemyBehavior? behavior,
    double? aggressionFactor,
    double? awarenessRadius,
  }) {
    return EnemyBlackHole(
      entity: entity ?? this.entity,
      behavior: behavior ?? this.behavior,
      aggressionFactor: aggressionFactor ?? this.aggressionFactor,
      awarenessRadius: awarenessRadius ?? this.awarenessRadius,
    );
  }
}
