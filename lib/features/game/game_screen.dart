import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/painters/void_surge_painter.dart';
import 'package:void_surge/features/game/providers/void_surge_notifier.dart';
import 'package:void_surge/features/game/widgets/game_over_overlay.dart';
import 'package:void_surge/features/game/widgets/void_surge_hud.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    ref.read(voidSurgeNotifierProvider.notifier).update(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = ref.watch(voidSurgeNotifierProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Update viewport size
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(voidSurgeNotifierProvider.notifier).updateViewportSize(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );
          });

          return GestureDetector(
            onTapDown: (details) {
              ref
                  .read(voidSurgeNotifierProvider.notifier)
                  .onTap(details.localPosition);
            },
            onPanStart: (details) {
              ref
                  .read(voidSurgeNotifierProvider.notifier)
                  .setTarget(details.localPosition);
            },
            onPanUpdate: (details) {
              ref
                  .read(voidSurgeNotifierProvider.notifier)
                  .setTarget(details.localPosition);
            },
            onPanEnd: (_) {
              ref.read(voidSurgeNotifierProvider.notifier).clearTarget();
            },
            child: Stack(
              children: [
                // Game canvas
                CustomPaint(
                  painter: VoidSurgePainter(world: world),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),

                // HUD
                VoidSurgeHud(world: world),

                // Game Over overlay
                if (world.status == GameStatus.gameOver)
                  GameOverOverlay(
                    world: world,
                    onRetry: () {
                      ref
                          .read(voidSurgeNotifierProvider.notifier)
                          .restart();
                    },
                    onHome: () {
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
