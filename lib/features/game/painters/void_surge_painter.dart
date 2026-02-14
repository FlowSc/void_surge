import 'package:flutter/material.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/painters/background_painter.dart';
import 'package:void_surge/features/game/painters/danger_zone_painter.dart';
import 'package:void_surge/features/game/painters/effect_painter.dart';
import 'package:void_surge/features/game/painters/entity_painter.dart';

class VoidSurgePainter extends CustomPainter {
  final GameWorld world;

  const VoidSurgePainter({required this.world});

  @override
  void paint(Canvas canvas, Size size) {
    final camera = world.camera;
    final visibleRect = camera.visibleWorldRect;

    // 1. Background + stars + field border
    BackgroundPainter.paint(canvas, size, world);

    // 2. Danger zones
    DangerZonePainter.paint(canvas, world);

    // 3. Planets
    EntityPainter.paintPlanets(
      canvas,
      camera,
      world.planets,
      visibleRect,
      world.gameTime,
    );

    // 4. Enemies
    EntityPainter.paintEnemies(
      canvas,
      camera,
      world.enemies,
      visibleRect,
      world.gameTime,
    );

    // 5. Player
    EntityPainter.paintPlayer(canvas, camera, world.player, world.gameTime);

    // 6. Absorption effects (top-most layer)
    EffectPainter.paint(
      canvas,
      camera,
      world.absorptionEffects,
      world.gameTime,
    );
  }

  @override
  bool shouldRepaint(covariant VoidSurgePainter oldDelegate) => true;
}
