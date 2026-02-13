import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/models/vec2.dart';

abstract final class EscapeSystem {
  static GameWorld update(GameWorld world) {
    final player = world.player;

    // Reset tap count if window expired
    if (player.escapeTapCount > 0 &&
        world.gameTime > player.escapeTapWindowEnd) {
      return world.copyWith(
        player: player.copyWith(
          escapeTapCount: 0,
          escapeTapWindowEnd: 0,
        ),
      );
    }

    return world;
  }

  static bool isInDangerZone(GameWorld world) {
    final player = world.player;
    for (final enemy in world.enemies) {
      if (enemy.mass <= player.mass) continue;
      final pullRadius =
          enemy.radius * VoidSurgeConstants.pullRadiusMultiplier;
      final dist = player.position.distanceTo(enemy.position);
      if (dist < pullRadius) return true;
    }
    return false;
  }

  static GameWorld onTap(GameWorld world) {
    if (!isInDangerZone(world)) return world;

    final player = world.player;
    var tapCount = player.escapeTapCount;
    var windowEnd = player.escapeTapWindowEnd;

    // Start new window or continue
    if (tapCount == 0 || world.gameTime > windowEnd) {
      tapCount = 1;
      windowEnd = world.gameTime + VoidSurgeConstants.escapeWindowSeconds;
    } else {
      tapCount++;
    }

    // Escape boost
    if (tapCount >= VoidSurgeConstants.escapeTapsRequired) {
      final nearestThreat = _findNearestThreat(world);
      if (nearestThreat != null) {
        final escapeDir = (player.position - nearestThreat).normalized;
        final boostedVel =
            player.velocity + escapeDir * VoidSurgeConstants.escapeBoostForce;

        return world.copyWith(
          player: player.copyWith(
            entity: player.entity.copyWith(velocity: boostedVel),
            escapeTapCount: 0,
            escapeTapWindowEnd: 0,
          ),
        );
      }
    }

    return world.copyWith(
      player: player.copyWith(
        escapeTapCount: tapCount,
        escapeTapWindowEnd: windowEnd,
      ),
    );
  }

  static Vec2? _findNearestThreat(GameWorld world) {
    Vec2? nearest;
    var bestDist = double.infinity;
    for (final enemy in world.enemies) {
      if (enemy.mass <= world.player.mass) continue;
      final dist = world.player.position.distanceTo(enemy.position);
      if (dist < bestDist) {
        bestDist = dist;
        nearest = enemy.position;
      }
    }
    return nearest;
  }
}
