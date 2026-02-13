import 'dart:math';
import 'dart:ui';

import 'package:void_surge/core/constants/void_surge_constants.dart';
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
  final int nextEntityId;
  final double lastPlanetSpawnTime;
  final double lastEnemySpawnTime;
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
    this.nextEntityId = 100,
    this.lastPlanetSpawnTime = 0,
    this.lastEnemySpawnTime = 0,
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
      final mass = VoidSurgeConstants.planetMinMass +
          rng.nextDouble() *
              (VoidSurgeConstants.planetMaxMass -
                  VoidSurgeConstants.planetMinMass);
      planets.add(Planet(
        entity: Entity(id: entityId++, position: pos, mass: mass),
        color: _randomPlanetColor(rng),
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

  GameWorld copyWith({
    Player? player,
    List<EnemyBlackHole>? enemies,
    List<Planet>? planets,
    GameCamera? camera,
    GameStatus? status,
    double? fieldRadius,
    double? gameTime,
    List<BackgroundStar>? backgroundStars,
    int? nextEntityId,
    double? lastPlanetSpawnTime,
    double? lastEnemySpawnTime,
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
      nextEntityId: nextEntityId ?? this.nextEntityId,
      lastPlanetSpawnTime: lastPlanetSpawnTime ?? this.lastPlanetSpawnTime,
      lastEnemySpawnTime: lastEnemySpawnTime ?? this.lastEnemySpawnTime,
      enemiesSpawned: enemiesSpawned ?? this.enemiesSpawned,
    );
  }
}
