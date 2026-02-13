import 'dart:math';

import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/game_world.dart';

abstract final class CameraSystem {
  static GameWorld update(GameWorld world, double dt) {
    final player = world.player;
    final camera = world.camera;

    final targetZoom = VoidSurgeConstants.cameraZoomBase /
        pow(player.mass, VoidSurgeConstants.cameraZoomExponent);

    final lerpT =
        (VoidSurgeConstants.cameraLerpSpeed * dt).clamp(0.0, 1.0);

    final newCenter = camera.center.lerp(player.position, lerpT);
    final newZoom = camera.zoom + (targetZoom - camera.zoom) * lerpT;

    return world.copyWith(
      camera: camera.copyWith(
        center: newCenter,
        zoom: newZoom,
      ),
    );
  }
}
