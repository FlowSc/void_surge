import 'dart:math';

import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/enemy_black_hole.dart';
import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/planet.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class PhysicsSystem {
  static GameWorld update(GameWorld world, double dt) {
    var w = world;
    w = _applyGravity(w, dt);
    w = _integratePositions(w, dt);
    w = _resolveCollisions(w);
    w = _clampToField(w);
    return w;
  }

  static Vec2 _gravityForce(Entity a, Entity b) {
    final diff = b.position - a.position;
    final distSq = max(diff.lengthSquared,
        VoidSurgeConstants.minGravityDistance * VoidSurgeConstants.minGravityDistance);
    final force = VoidSurgeConstants.gravitationalConstant * a.mass * b.mass / distSq;
    final dir = diff.normalized;
    return dir * force;
  }

  static GameWorld _applyGravity(GameWorld world, double dt) {
    final playerEntity = world.player.entity;
    var playerVel = playerEntity.velocity;

    final updatedEnemies = <EnemyBlackHole>[];
    final updatedPlanets = <Planet>[];

    // Enemy velocities accumulator
    final enemyVels = world.enemies.map((e) => e.entity.velocity).toList();

    // Planet velocities accumulator
    final planetVels = world.planets.map((p) => p.entity.velocity).toList();

    // Player <-> Enemy gravity
    for (var i = 0; i < world.enemies.length; i++) {
      final enemy = world.enemies[i];
      final pullRadius =
          enemy.radius * VoidSurgeConstants.pullRadiusMultiplier;
      final playerPullRadius =
          playerEntity.radius * VoidSurgeConstants.pullRadiusMultiplier;
      final dist = playerEntity.position.distanceTo(enemy.position);

      if (dist < pullRadius || dist < playerPullRadius) {
        final force = _gravityForce(playerEntity, enemy.entity);
        playerVel = playerVel + force * (dt / playerEntity.mass);
        enemyVels[i] = enemyVels[i] - force * (dt / enemy.mass);
      }
    }

    // Enemy <-> Enemy gravity
    for (var i = 0; i < world.enemies.length; i++) {
      for (var j = i + 1; j < world.enemies.length; j++) {
        final a = world.enemies[i];
        final b = world.enemies[j];
        final dist = a.position.distanceTo(b.position);
        final pullA = a.radius * VoidSurgeConstants.pullRadiusMultiplier;
        final pullB = b.radius * VoidSurgeConstants.pullRadiusMultiplier;

        if (dist < pullA || dist < pullB) {
          final force = _gravityForce(a.entity, b.entity);
          enemyVels[i] = enemyVels[i] + force * (dt / a.mass);
          enemyVels[j] = enemyVels[j] - force * (dt / b.mass);
        }
      }
    }

    // Planet <-> BlackHole gravity (planets pulled toward nearby black holes)
    for (var pi = 0; pi < world.planets.length; pi++) {
      final planet = world.planets[pi];

      // Player pulls planets
      final distToPlayer = planet.position.distanceTo(playerEntity.position);
      final playerPull = playerEntity.radius * VoidSurgeConstants.pullRadiusMultiplier;
      if (distToPlayer < playerPull) {
        final force = _gravityForce(planet.entity, playerEntity);
        planetVels[pi] = planetVels[pi] + force * (dt / planet.mass);
      }

      // Enemies pull planets
      for (var ei = 0; ei < world.enemies.length; ei++) {
        final enemy = world.enemies[ei];
        final distToEnemy = planet.position.distanceTo(enemy.position);
        final enemyPull = enemy.radius * VoidSurgeConstants.pullRadiusMultiplier;
        if (distToEnemy < enemyPull) {
          final force = _gravityForce(planet.entity, enemy.entity);
          planetVels[pi] = planetVels[pi] + force * (dt / planet.mass);
        }
      }
    }

    // Build updated entities
    for (var i = 0; i < world.enemies.length; i++) {
      updatedEnemies.add(world.enemies[i].copyWith(
        entity: world.enemies[i].entity.copyWith(velocity: enemyVels[i]),
      ));
    }

    for (var i = 0; i < world.planets.length; i++) {
      updatedPlanets.add(world.planets[i].copyWith(
        entity: world.planets[i].entity.copyWith(velocity: planetVels[i]),
      ));
    }

    final updatedPlayer = world.player.copyWith(
      entity: playerEntity.copyWith(velocity: playerVel),
    );

    return world.copyWith(
      player: updatedPlayer,
      enemies: updatedEnemies,
      planets: updatedPlanets,
    );
  }

  static GameWorld _integratePositions(GameWorld world, double dt) {
    final pe = world.player.entity;
    final newPlayerEntity = pe.copyWith(
      position: pe.position + pe.velocity * dt,
    );

    final enemies = world.enemies.map((e) {
      final ent = e.entity;
      return e.copyWith(
        entity: ent.copyWith(position: ent.position + ent.velocity * dt),
      );
    }).toList();

    final planets = world.planets.map((p) {
      final ent = p.entity;
      return p.copyWith(
        entity: ent.copyWith(position: ent.position + ent.velocity * dt),
      );
    }).toList();

    return world.copyWith(
      player: world.player.copyWith(entity: newPlayerEntity),
      enemies: enemies,
      planets: planets,
    );
  }

  static GameWorld _resolveCollisions(GameWorld world) {
    var player = world.player;
    final remainingPlanets = <Planet>[];
    final remainingEnemies = List<EnemyBlackHole>.from(world.enemies);

    // Player eats planets
    for (final planet in world.planets) {
      final dist = player.position.distanceTo(planet.position);
      final absorptionDist =
          (player.radius + planet.radius) * VoidSurgeConstants.absorptionRadiusMultiplier;
      if (dist < absorptionDist) {
        final newMass =
            player.mass + planet.mass * VoidSurgeConstants.planetAbsorptionRatio;
        player = player.copyWith(
          entity: player.entity.copyWith(mass: newMass),
          score: player.score + VoidSurgeConstants.pointsPerPlanet,
          planetsEaten: player.planetsEaten + 1,
        );
      } else {
        remainingPlanets.add(planet);
      }
    }

    // Enemy eats planets
    final planetsAfterEnemies = <Planet>[];
    for (final planet in remainingPlanets) {
      var eaten = false;
      for (var i = 0; i < remainingEnemies.length; i++) {
        final enemy = remainingEnemies[i];
        final dist = enemy.position.distanceTo(planet.position);
        final absorptionDist =
            (enemy.radius + planet.radius) * VoidSurgeConstants.absorptionRadiusMultiplier;
        if (dist < absorptionDist) {
          final newMass =
              enemy.mass + planet.mass * VoidSurgeConstants.planetAbsorptionRatio;
          remainingEnemies[i] = enemy.copyWith(
            entity: enemy.entity.copyWith(mass: newMass),
          );
          eaten = true;
          break;
        }
      }
      if (!eaten) planetsAfterEnemies.add(planet);
    }

    // BlackHole vs BlackHole (player vs enemies)
    final survivingEnemies = <EnemyBlackHole>[];
    for (final enemy in remainingEnemies) {
      final dist = player.position.distanceTo(enemy.position);
      final absorptionDist =
          (player.radius + enemy.radius) * VoidSurgeConstants.absorptionRadiusMultiplier;
      if (dist < absorptionDist) {
        if (player.mass >= enemy.mass) {
          // Player absorbs enemy
          final newMass =
              player.mass + enemy.mass * VoidSurgeConstants.blackHoleAbsorptionRatio;
          player = player.copyWith(
            entity: player.entity.copyWith(mass: newMass),
            score: player.score + VoidSurgeConstants.pointsPerBlackHole,
            blackHolesAbsorbed: player.blackHolesAbsorbed + 1,
          );
        } else {
          // Player dies
          player = player.copyWith(isAlive: false);
          survivingEnemies.add(enemy);
        }
      } else {
        survivingEnemies.add(enemy);
      }
    }

    // Enemy vs Enemy
    final finalEnemies = <EnemyBlackHole>[];
    final consumed = <int>{};
    for (var i = 0; i < survivingEnemies.length; i++) {
      if (consumed.contains(i)) continue;
      var enemy = survivingEnemies[i];
      for (var j = i + 1; j < survivingEnemies.length; j++) {
        if (consumed.contains(j)) continue;
        final other = survivingEnemies[j];
        final dist = enemy.position.distanceTo(other.position);
        final absorptionDist = (enemy.radius + other.radius) *
            VoidSurgeConstants.absorptionRadiusMultiplier;
        if (dist < absorptionDist) {
          if (enemy.mass >= other.mass) {
            enemy = enemy.copyWith(
              entity: enemy.entity.copyWith(
                mass: enemy.mass +
                    other.mass * VoidSurgeConstants.blackHoleAbsorptionRatio,
              ),
            );
            consumed.add(j);
          } else {
            consumed.add(i);
            break;
          }
        }
      }
      if (!consumed.contains(i)) finalEnemies.add(enemy);
    }

    return world.copyWith(
      player: player,
      enemies: finalEnemies,
      planets: planetsAfterEnemies,
    );
  }

  static GameWorld _clampToField(GameWorld world) {
    final fieldR = world.fieldRadius;
    var player = world.player;
    final pe = player.entity;

    // Soft boundary for player
    if (pe.position.length > fieldR * 0.95) {
      final pushDir = -pe.position.normalized;
      final pushStrength = (pe.position.length - fieldR * 0.95) * 2.0;
      final newVel = pe.velocity + pushDir * pushStrength;
      player = player.copyWith(
        entity: pe.copyWith(velocity: newVel),
      );
    }

    // Clamp enemies
    final enemies = world.enemies.map((e) {
      if (e.position.length > fieldR * 0.95) {
        final pushDir = -e.position.normalized;
        final pushStrength = (e.position.length - fieldR * 0.95) * 2.0;
        return e.copyWith(
          entity: e.entity.copyWith(
            velocity: e.velocity + pushDir * pushStrength,
          ),
        );
      }
      return e;
    }).toList();

    // Remove planets outside field
    final planets =
        world.planets.where((p) => p.position.length < fieldR * 1.1).toList();

    return world.copyWith(
      player: player,
      enemies: enemies,
      planets: planets,
    );
  }
}
