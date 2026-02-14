import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/systems/escape_system.dart';

class VoidSurgeHud extends StatelessWidget {
  final GameWorld world;

  const VoidSurgeHud({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    final player = world.player;
    final inDanger = EscapeSystem.isInDangerZone(world);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                _PixelText(
                  'SCORE ${player.score}',
                  color: VoidSurgeConstants.uiColor,
                  fontSize: 10,
                ),
                // Mass
                _PixelText(
                  'MASS ${player.mass.toStringAsFixed(1)}',
                  color: VoidSurgeConstants.playerColor,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PixelText(
                  'TIME ${world.gameTime.toInt()}s',
                  color: Colors.white54,
                  fontSize: 8,
                ),
                _PixelText(
                  'x${world.enemies.length} ENEMIES',
                  color: VoidSurgeConstants.enemyColor.withValues(alpha: 0.7),
                  fontSize: 8,
                ),
              ],
            ),

            // Active buffs
            if (player.hasSpeedBoost(world.gameTime) ||
                player.hasScoreMultiplier(world.gameTime)) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (player.hasSpeedBoost(world.gameTime))
                    _PixelText(
                      'SPD x${VoidSurgeConstants.redDwarfSpeedMultiplier.toStringAsFixed(1)}'
                      '  ${(player.speedBoostEndTime - world.gameTime).ceil()}s',
                      color: VoidSurgeConstants.redDwarfColor,
                      fontSize: 8,
                    ),
                  if (player.hasSpeedBoost(world.gameTime) &&
                      player.hasScoreMultiplier(world.gameTime))
                    const SizedBox(width: 12),
                  if (player.hasScoreMultiplier(world.gameTime))
                    _PixelText(
                      'PTS x${VoidSurgeConstants.whiteDwarfScoreMultiplier.toInt()}'
                      '  ${(player.scoreMultiplierEndTime - world.gameTime).ceil()}s',
                      color: VoidSurgeConstants.whiteDwarfColor,
                      fontSize: 8,
                    ),
                ],
              ),
            ],

            // Escape gauge
            if (inDanger) ...[
              const SizedBox(height: 8),
              _EscapeGauge(
                tapCount: player.escapeTapCount,
                maxTaps: VoidSurgeConstants.escapeTapsRequired,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PixelText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const _PixelText(this.text, {required this.color, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: fontSize,
        color: color,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _EscapeGauge extends StatelessWidget {
  final int tapCount;
  final int maxTaps;

  const _EscapeGauge({required this.tapCount, required this.maxTaps});

  @override
  Widget build(BuildContext context) {
    final progress = (tapCount / maxTaps).clamp(0.0, 1.0);

    return Column(
      children: [
        const _PixelText(
          'TAP TO ESCAPE!',
          color: VoidSurgeConstants.enemyColor,
          fontSize: 8,
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            border: Border.all(
              color: VoidSurgeConstants.enemyColor,
              width: 1,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              color: VoidSurgeConstants.enemyColor,
            ),
          ),
        ),
      ],
    );
  }
}
