import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/vec2.dart';

class Player {
  final Entity entity;
  final Vec2? targetPosition;
  final bool isAlive;
  final int escapeTapCount;
  final double escapeTapWindowEnd;
  final int score;
  final int planetsEaten;
  final int blackHolesAbsorbed;

  const Player({
    required this.entity,
    this.targetPosition,
    this.isAlive = true,
    this.escapeTapCount = 0,
    this.escapeTapWindowEnd = 0,
    this.score = 0,
    this.planetsEaten = 0,
    this.blackHolesAbsorbed = 0,
  });

  double get mass => entity.mass;
  double get radius => entity.radius;
  Vec2 get position => entity.position;
  Vec2 get velocity => entity.velocity;

  Player copyWith({
    Entity? entity,
    Vec2? Function()? targetPosition,
    bool? isAlive,
    int? escapeTapCount,
    double? escapeTapWindowEnd,
    int? score,
    int? planetsEaten,
    int? blackHolesAbsorbed,
  }) {
    return Player(
      entity: entity ?? this.entity,
      targetPosition:
          targetPosition != null ? targetPosition() : this.targetPosition,
      isAlive: isAlive ?? this.isAlive,
      escapeTapCount: escapeTapCount ?? this.escapeTapCount,
      escapeTapWindowEnd: escapeTapWindowEnd ?? this.escapeTapWindowEnd,
      score: score ?? this.score,
      planetsEaten: planetsEaten ?? this.planetsEaten,
      blackHolesAbsorbed: blackHolesAbsorbed ?? this.blackHolesAbsorbed,
    );
  }
}
