import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/enemy_black_hole.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/planet.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class AiSystem {
  static GameWorld update(GameWorld world, double dt) {
    final updatedEnemies = world.enemies.map((enemy) {
      final behavior = _decideBehavior(enemy, world);
      final steer = _computeSteerForce(enemy, behavior, world);
      final speed = VoidSurgeConstants.enemyBaseSpeed * enemy.aggressionFactor;
      final desiredVel = steer.normalized * speed;
      const drag = 2.0;
      final newVel = enemy.velocity + (desiredVel - enemy.velocity) * (drag * dt);

      return enemy.copyWith(
        entity: enemy.entity.copyWith(velocity: newVel),
        behavior: behavior,
      );
    }).toList();

    return world.copyWith(enemies: updatedEnemies);
  }

  static EnemyBehavior _decideBehavior(EnemyBlackHole enemy, GameWorld world) {
    final playerDist = enemy.position.distanceTo(world.player.position);
    final playerMass = world.player.mass;

    // Flee from bigger black holes (player or enemies)
    if (playerDist < enemy.awarenessRadius && playerMass > enemy.mass * 1.5) {
      return EnemyBehavior.fleeing;
    }
    for (final other in world.enemies) {
      if (other.entity.id == enemy.entity.id) continue;
      final dist = enemy.position.distanceTo(other.position);
      if (dist < enemy.awarenessRadius && other.mass > enemy.mass * 1.5) {
        return EnemyBehavior.fleeing;
      }
    }

    // Chase smaller player
    if (playerDist < enemy.awarenessRadius && enemy.mass > playerMass * 1.2) {
      return EnemyBehavior.chasing;
    }

    return EnemyBehavior.hunting;
  }

  static Vec2 _computeSteerForce(
    EnemyBlackHole enemy,
    EnemyBehavior behavior,
    GameWorld world,
  ) {
    switch (behavior) {
      case EnemyBehavior.hunting:
        return _huntNearestPlanet(enemy, world.planets);
      case EnemyBehavior.chasing:
        return world.player.position - enemy.position;
      case EnemyBehavior.fleeing:
        return _fleeFromThreats(enemy, world);
    }
  }

  static Vec2 _huntNearestPlanet(
    EnemyBlackHole enemy,
    List<Planet> planets,
  ) {
    if (planets.isEmpty) return Vec2.zero;

    Planet? nearest;
    var bestDist = double.infinity;
    for (final p in planets) {
      final d = enemy.position.distanceTo(p.position);
      if (d < bestDist) {
        bestDist = d;
        nearest = p;
      }
    }
    if (nearest == null) return Vec2.zero;
    return nearest.position - enemy.position;
  }

  static Vec2 _fleeFromThreats(EnemyBlackHole enemy, GameWorld world) {
    var fleeDir = Vec2.zero;

    // Flee from player if bigger
    if (world.player.mass > enemy.mass * 1.5) {
      final diff = enemy.position - world.player.position;
      if (diff.length > 0) {
        fleeDir = fleeDir + diff.normalized;
      }
    }

    // Flee from bigger enemies
    for (final other in world.enemies) {
      if (other.entity.id == enemy.entity.id) continue;
      if (other.mass > enemy.mass * 1.5) {
        final diff = enemy.position - other.position;
        if (diff.length > 0 && diff.length < enemy.awarenessRadius) {
          fleeDir = fleeDir + diff.normalized;
        }
      }
    }

    return fleeDir.length > 0 ? fleeDir.normalized : const Vec2(1, 0);
  }
}
