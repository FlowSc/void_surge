import 'dart:math';
import 'dart:ui';

import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/enemy_black_hole.dart';
import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/planet.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class SpawnSystem {
  static final Random _rng = Random();

  static GameWorld update(GameWorld world) {
    var w = world;
    w = _trySpawnPlanets(w);
    w = _trySpawnLargeCelestial(w);
    w = _trySpawnEnemy(w);
    return w;
  }

  static GameWorld _trySpawnPlanets(GameWorld world) {
    if (world.planets.length >= VoidSurgeConstants.maxPlanets) return world;
    if (world.gameTime - world.lastPlanetSpawnTime <
        VoidSurgeConstants.planetSpawnInterval) {
      return world;
    }

    final pos = Vec2.random(_rng, world.fieldRadius * 0.9);
    // Don't spawn too close to player
    if (pos.distanceTo(world.player.position) < 80) return world;

    final isSpecial =
        _rng.nextDouble() < VoidSurgeConstants.specialPlanetSpawnChance;
    final planetType = isSpecial ? _randomSpecialType() : PlanetType.normal;

    final double mass;
    if (isSpecial) {
      if (planetType == PlanetType.blackDwarf) {
        mass = VoidSurgeConstants.blackDwarfMassMin +
            _rng.nextDouble() *
                (VoidSurgeConstants.blackDwarfMassMax -
                    VoidSurgeConstants.blackDwarfMassMin);
      } else {
        mass = 0.5 + _rng.nextDouble() * 0.4; // 0.5~0.9
      }
    } else {
      mass = VoidSurgeConstants.planetMinMass +
          _rng.nextDouble() *
              (VoidSurgeConstants.planetMaxMass -
                  VoidSurgeConstants.planetMinMass);
    }

    final planet = Planet(
      entity: Entity(
        id: world.nextEntityId,
        position: pos,
        mass: mass,
      ),
      color: isSpecial ? _specialPlanetColor(planetType) : _randomPlanetColor(),
      type: planetType,
    );

    return world.copyWith(
      planets: [...world.planets, planet],
      nextEntityId: world.nextEntityId + 1,
      lastPlanetSpawnTime: world.gameTime,
    );
  }

  // ─── Large Celestial Body Spawning ────────────────────────

  static GameWorld _trySpawnLargeCelestial(GameWorld world) {
    if (world.gameTime - world.lastLargeCelestialSpawnTime <
        VoidSurgeConstants.largeCelestialSpawnInterval) {
      return world;
    }

    final playerMass = world.player.mass;

    // Determine which type to spawn based on player mass thresholds
    PlanetType? typeToSpawn;
    if (playerMass >= VoidSurgeConstants.galaxyMassThreshold &&
        _countByType(world.planets, PlanetType.galaxy) <
            VoidSurgeConstants.maxGalaxies) {
      typeToSpawn = PlanetType.galaxy;
    } else if (playerMass >= VoidSurgeConstants.starClusterMassThreshold &&
        _countByType(world.planets, PlanetType.starCluster) <
            VoidSurgeConstants.maxStarClusters) {
      typeToSpawn = PlanetType.starCluster;
    } else if (playerMass >= VoidSurgeConstants.nebulaMassThreshold &&
        _countByType(world.planets, PlanetType.nebula) <
            VoidSurgeConstants.maxNebulas) {
      typeToSpawn = PlanetType.nebula;
    }

    if (typeToSpawn == null) return world;

    final pos = Vec2.random(_rng, world.fieldRadius * 0.8);
    if (pos.distanceTo(world.player.position) < 120) return world;

    final double mass;
    switch (typeToSpawn) {
      case PlanetType.nebula:
        mass = VoidSurgeConstants.nebulaMassMin +
            _rng.nextDouble() *
                (VoidSurgeConstants.nebulaMassMax -
                    VoidSurgeConstants.nebulaMassMin);
      case PlanetType.starCluster:
        mass = VoidSurgeConstants.starClusterMassMin +
            _rng.nextDouble() *
                (VoidSurgeConstants.starClusterMassMax -
                    VoidSurgeConstants.starClusterMassMin);
      case PlanetType.galaxy:
        mass = VoidSurgeConstants.galaxyMassMin +
            _rng.nextDouble() *
                (VoidSurgeConstants.galaxyMassMax -
                    VoidSurgeConstants.galaxyMassMin);
      default:
        return world;
    }

    final planet = Planet(
      entity: Entity(
        id: world.nextEntityId,
        position: pos,
        mass: mass,
      ),
      color: _specialPlanetColor(typeToSpawn),
      type: typeToSpawn,
    );

    return world.copyWith(
      planets: [...world.planets, planet],
      nextEntityId: world.nextEntityId + 1,
      lastLargeCelestialSpawnTime: world.gameTime,
    );
  }

  static int _countByType(List<Planet> planets, PlanetType type) {
    var count = 0;
    for (final p in planets) {
      if (p.type == type) count++;
    }
    return count;
  }

  // ─── Enemy Spawning ───────────────────────────────────────

  static GameWorld _trySpawnEnemy(GameWorld world) {
    if (world.gameTime < VoidSurgeConstants.firstEnemySpawnTime) return world;
    if (world.enemies.length >= VoidSurgeConstants.maxEnemies) return world;

    final timeSinceLastSpawn = world.enemiesSpawned == 0
        ? world.gameTime - VoidSurgeConstants.firstEnemySpawnTime
        : world.gameTime - world.lastEnemySpawnTime;

    if (timeSinceLastSpawn < VoidSurgeConstants.enemySpawnInterval &&
        world.enemiesSpawned > 0) {
      return world;
    }

    // Spawn at field edge, away from player
    final playerAngle = _rng.nextDouble() * 3.14159 * 2;
    final spawnAngle =
        playerAngle + 3.14159 + (_rng.nextDouble() - 0.5) * 1.5;
    final spawnDist = world.fieldRadius * 0.85;
    final pos = Vec2(
      cos(spawnAngle) * spawnDist,
      sin(spawnAngle) * spawnDist,
    );

    final massRatio = VoidSurgeConstants.enemyMinMassRatio +
        _rng.nextDouble() *
            (VoidSurgeConstants.enemyMaxMassRatio -
                VoidSurgeConstants.enemyMinMassRatio);
    final mass = world.player.mass * massRatio;

    final enemy = EnemyBlackHole(
      entity: Entity(
        id: world.nextEntityId,
        position: pos,
        mass: mass,
      ),
      aggressionFactor: 0.8 + _rng.nextDouble() * 0.4,
      awarenessRadius: 250 + _rng.nextDouble() * 100,
    );

    return world.copyWith(
      enemies: [...world.enemies, enemy],
      nextEntityId: world.nextEntityId + 1,
      lastEnemySpawnTime: world.gameTime,
      enemiesSpawned: world.enemiesSpawned + 1,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  static Color _randomPlanetColor() {
    const colors = [
      VoidSurgeConstants.planetColor,
      Color(0xFF00FF88),
      Color(0xFFFFAA00),
      Color(0xFFFF66AA),
      Color(0xFF88DDFF),
    ];
    return colors[_rng.nextInt(colors.length)];
  }

  /// Weighted random: redDwarf 40%, whiteDwarf 40%, blackDwarf 20%
  static PlanetType _randomSpecialType() {
    final roll = _rng.nextDouble();
    if (roll < 0.4) return PlanetType.redDwarf;
    if (roll < 0.8) return PlanetType.whiteDwarf;
    return PlanetType.blackDwarf;
  }

  static Color _specialPlanetColor(PlanetType type) {
    return switch (type) {
      PlanetType.redDwarf => VoidSurgeConstants.redDwarfColor,
      PlanetType.whiteDwarf => VoidSurgeConstants.whiteDwarfColor,
      PlanetType.blackDwarf => VoidSurgeConstants.blackDwarfColor,
      PlanetType.nebula => VoidSurgeConstants.nebulaColor,
      PlanetType.starCluster => VoidSurgeConstants.starClusterColor,
      PlanetType.galaxy => VoidSurgeConstants.galaxyColor,
      PlanetType.normal => VoidSurgeConstants.planetColor,
    };
  }
}
