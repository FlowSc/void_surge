import 'dart:math';
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/systems/ai_system.dart';
import 'package:void_surge/features/game/systems/camera_system.dart';
import 'package:void_surge/features/game/systems/escape_system.dart';
import 'package:void_surge/features/game/systems/physics_system.dart';
import 'package:void_surge/features/game/systems/spawn_system.dart';

part 'void_surge_notifier.g.dart';

@riverpod
class VoidSurgeNotifier extends _$VoidSurgeNotifier {
  @override
  GameWorld build() {
    return GameWorld.initial();
  }

  void update(double dt) {
    if (state.status != GameStatus.playing) return;
    if (!state.player.isAlive) {
      state = state.copyWith(status: GameStatus.gameOver);
      return;
    }

    final clampedDt = min(dt, VoidSurgeConstants.maxDeltaTime);
    var world = state.copyWith(gameTime: state.gameTime + clampedDt);

    // Expand field
    world = world.copyWith(
      fieldRadius: world.fieldRadius +
          VoidSurgeConstants.fieldExpansionRate * clampedDt,
    );

    // Spawn
    world = SpawnSystem.update(world);

    // AI
    world = AiSystem.update(world, clampedDt);

    // Player movement toward target
    world = _applyPlayerMovement(world, clampedDt);

    // Physics (gravity + collisions)
    world = PhysicsSystem.update(world, clampedDt);

    // Escape system
    world = EscapeSystem.update(world);

    // Camera
    world = CameraSystem.update(world, clampedDt);

    // Death check
    if (!world.player.isAlive) {
      world = world.copyWith(status: GameStatus.gameOver);
    }

    state = world;
  }

  GameWorld _applyPlayerMovement(GameWorld world, double dt) {
    final player = world.player;
    final target = player.targetPosition;
    var vel = player.velocity;

    final speedMult = player.hasSpeedBoost(world.gameTime)
        ? VoidSurgeConstants.redDwarfSpeedMultiplier
        : 1.0;

    if (target != null) {
      final dir = (target - player.position);
      if (dir.length > 5) {
        vel = vel +
            dir.normalized *
                VoidSurgeConstants.playerAcceleration *
                speedMult *
                dt;
      }
    }

    // Apply drag
    vel = vel * (1.0 / (1.0 + VoidSurgeConstants.playerDrag * dt));

    // Clamp speed
    vel = vel.clampLength(VoidSurgeConstants.playerMaxSpeed * speedMult);

    return world.copyWith(
      player: player.copyWith(
        entity: player.entity.copyWith(velocity: vel),
      ),
    );
  }

  void setTarget(Offset screenPos) {
    final worldPos = state.camera.screenToWorld(screenPos);
    state = state.copyWith(
      player: state.player.copyWith(
        targetPosition: () => worldPos,
      ),
    );
  }

  void clearTarget() {
    state = state.copyWith(
      player: state.player.copyWith(
        targetPosition: () => null,
      ),
    );
  }

  void onTap(Offset screenPos) {
    // Try escape tap first
    if (EscapeSystem.isInDangerZone(state)) {
      state = EscapeSystem.onTap(state);
    } else {
      setTarget(screenPos);
    }
  }

  void updateViewportSize(Size size) {
    state = state.copyWith(
      camera: state.camera.copyWith(viewportSize: size),
    );
  }

  void restart() {
    state = GameWorld.initial().copyWith(
      camera: state.camera,
    );
  }
}
