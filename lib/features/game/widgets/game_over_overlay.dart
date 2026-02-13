import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/models/game_world.dart';

class GameOverOverlay extends StatelessWidget {
  final GameWorld world;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const GameOverOverlay({
    super.key,
    required this.world,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final player = world.player;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 24,
                color: VoidSurgeConstants.enemyColor,
                shadows: [
                  Shadow(
                    color: VoidSurgeConstants.enemyColor,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _StatRow('SCORE', '${player.score}'),
            const SizedBox(height: 8),
            _StatRow('PLANETS', '${player.planetsEaten}'),
            const SizedBox(height: 8),
            _StatRow('BLACK HOLES', '${player.blackHolesAbsorbed}'),
            const SizedBox(height: 8),
            _StatRow('TIME', '${world.gameTime.toInt()}s'),
            const SizedBox(height: 8),
            _StatRow('MAX MASS', player.mass.toStringAsFixed(1)),
            const SizedBox(height: 40),
            _PixelButton(
              label: 'RETRY',
              color: VoidSurgeConstants.playerColor,
              onTap: onRetry,
            ),
            const SizedBox(height: 16),
            _PixelButton(
              label: 'HOME',
              color: VoidSurgeConstants.uiColor,
              onTap: onHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 8,
              color: Colors.white54,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: VoidSurgeConstants.uiColor,
          ),
        ),
      ],
    );
  }
}

class _PixelButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PixelButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 12,
            color: color,
          ),
        ),
      ),
    );
  }
}
