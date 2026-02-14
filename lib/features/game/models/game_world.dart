import 'dart:math';
import 'dart:ui';

import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/absorption_effect.dart';
import 'package:void_surge/features/game/models/camera.dart';
import 'package:void_surge/features/game/models/enemy_black_hole.dart';
import 'package:void_surge/features/game/models/entity.dart';
import 'package:void_surge/features/game/models/planet.dart';
import 'package:void_surge/features/game/models/player.dart';
import 'package:void_surge/features/game/models/vec2.dart';

enum GameStatus { playing, gameOver }

class BackgroundStar {
  final Vec2 position;
  final double size;
  final double blinkPhase;

  const BackgroundStar({
    required this.position,
    required this.size,
    required this.blinkPhase,
  });
}

class GameWorld {
  final Player player;
  final List<EnemyBlackHole> enemies;
  final List<Planet> planets;
  final GameCamera camera;
  final GameStatus status;
  final double fieldRadius;
  final double gameTime;
  final List<BackgroundStar> backgroundStars;
  final List<AbsorptionEffect> absorptionEffects;
  final int nextEntityId;
  final double lastPlanetSpawnTime;
  final double lastEnemySpawnTime;
  final double lastLargeCelestialSpawnTime;
  final int enemiesSpawned;

  const GameWorld({
    required this.player,
    this.enemies = const [],
    this.planets = const [],
    required this.camera,
    this.status = GameStatus.playing,
    required this.fieldRadius,
    this.gameTime = 0,
    this.backgroundStars = const [],
    this.absorptionEffects = const [],
    this.nextEntityId = 100,
    this.lastPlanetSpawnTime = 0,
    this.lastEnemySpawnTime = 0,
    this.lastLargeCelestialSpawnTime = 0,
    this.enemiesSpawned = 0,
  });

  factory GameWorld.initial() {
    final rng = Random();

    const player = Player(
      entity: Entity(
        id: 0,
        position: Vec2.zero,
        mass: VoidSurgeConstants.playerInitialMass,
      ),
    );

    final stars = List.generate(200, (i) {
      return BackgroundStar(
        position: Vec2.random(rng, 2000),
        size: 1.0 + rng.nextDouble(),
        blinkPhase: rng.nextDouble() * 3.14159 * 2,
      );
    });

    final planets = <Planet>[];
    var entityId = 1;
    for (var i = 0; i < VoidSurgeConstants.initialPlanetCount; i++) {
      final pos = Vec2.random(rng, VoidSurgeConstants.initialFieldRadius * 0.9);
      if (pos.length < 50) continue;

      final isSpecial =
          rng.nextDouble() < VoidSurgeConstants.specialPlanetSpawnChance;
      final planetType = isSpecial ? _randomSpecialType(rng) : PlanetType.normal;

      final double mass;
      if (isSpecial) {
        if (planetType == PlanetType.blackDwarf) {
          mass = VoidSurgeConstants.blackDwarfMassMin +
              rng.nextDouble() *
                  (VoidSurgeConstants.blackDwarfMassMax -
                      VoidSurgeConstants.blackDwarfMassMin);
        } else {
          mass = 0.5 + rng.nextDouble() * 0.4;
        }
      } else {
        mass = VoidSurgeConstants.planetMinMass +
            rng.nextDouble() *
                (VoidSurgeConstants.planetMaxMass -
                    VoidSurgeConstants.planetMinMass);
      }

      planets.add(Planet(
        entity: Entity(id: entityId++, position: pos, mass: mass),
        color: isSpecial
            ? _specialPlanetColor(planetType)
            : _randomPlanetColor(rng),
        type: planetType,
      ));
    }

    return GameWorld(
      player: player,
      planets: planets,
      camera: const GameCamera(),
      fieldRadius: VoidSurgeConstants.initialFieldRadius,
      backgroundStars: stars,
      nextEntityId: entityId,
    );
  }

  static Color _randomPlanetColor(Random rng) {
    const colors = [
      VoidSurgeConstants.planetColor,
      Color(0xFF00FF88),
      Color(0xFFFFAA00),
      Color(0xFFFF66AA),
      Color(0xFF88DDFF),
    ];
    return colors[rng.nextInt(colors.length)];
  }

  /// Weighted random: redDwarf 40%, whiteDwarf 40%, blackDwarf 20%
  static PlanetType _randomSpecialType(Random rng) {
    final roll = rng.nextDouble();
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

  GameWorld copyWith({
    Player? player,
    List<EnemyBlackHole>? enemies,
    List<Planet>? planets,
    GameCamera? camera,
    GameStatus? status,
    double? fieldRadius,
    double? gameTime,
    List<BackgroundStar>? backgroundStars,
    List<AbsorptionEffect>? absorptionEffects,
    int? nextEntityId,
    double? lastPlanetSpawnTime,
    double? lastEnemySpawnTime,
    double? lastLargeCelestialSpawnTime,
    int? enemiesSpawned,
  }) {
    return GameWorld(
      player: player ?? this.player,
      enemies: enemies ?? this.enemies,
      planets: planets ?? this.planets,
      camera: camera ?? this.camera,
      status: status ?? this.status,
      fieldRadius: fieldRadius ?? this.fieldRadius,
      gameTime: gameTime ?? this.gameTime,
      backgroundStars: backgroundStars ?? this.backgroundStars,
      absorptionEffects: absorptionEffects ?? this.absorptionEffects,
      nextEntityId: nextEntityId ?? this.nextEntityId,
      lastPlanetSpawnTime: lastPlanetSpawnTime ?? this.lastPlanetSpawnTime,
      lastEnemySpawnTime: lastEnemySpawnTime ?? this.lastEnemySpawnTime,
      lastLargeCelestialSpawnTime:
          lastLargeCelestialSpawnTime ?? this.lastLargeCelestialSpawnTime,
      enemiesSpawned: enemiesSpawned ?? this.enemiesSpawned,
    );
  }
}
