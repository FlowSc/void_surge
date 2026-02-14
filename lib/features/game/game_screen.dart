import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:void_surge/core/providers/settings_provider.dart';
import 'package:void_surge/core/providers/tutorial_provider.dart';
import 'package:void_surge/core/services/audio_service.dart';
import 'package:void_surge/features/game/models/game_world.dart';
import 'package:void_surge/features/game/painters/void_surge_painter.dart';
import 'package:void_surge/features/game/providers/void_surge_notifier.dart';
import 'package:void_surge/features/game/widgets/game_over_overlay.dart';
import 'package:void_surge/features/game/widgets/tutorial_overlay.dart';
import 'package:void_surge/features/game/widgets/void_surge_hud.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, this.showTutorial = false});

  final bool showTutorial;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTime = Duration.zero;
  late bool _showingTutorial;
  bool _bgmStarted = false;

  @override
  void initState() {
    super.initState();
    _showingTutorial = widget.showTutorial;
    _ticker = createTicker(_onTick);
    if (!_showingTutorial) {
      _ticker.start();
    }
    _startBgmIfEnabled();
  }

  void _startBgmIfEnabled() {
    final settings = ref.read(settingsProvider);
    if (settings.bgmEnabled) {
      ref.read(audioServiceProvider).playBgm();
      _bgmStarted = true;
    }
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

    // React to BGM setting changes
    ref.listen(settingsProvider.select((s) => s.bgmEnabled),
        (bool? prev, bool next) {
      final audio = ref.read(audioServiceProvider);
      if (next) {
        audio.playBgm();
        _bgmStarted = true;
      } else {
        audio.stopBgm();
        _bgmStarted = false;
      }
    });

    // Stop BGM on game over
    if (world.status == GameStatus.gameOver && _bgmStarted) {
      ref.read(audioServiceProvider).stopBgm();
      _bgmStarted = false;
    }

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
                      _startBgmIfEnabled();
                    },
                    onHome: () {
                      ref.read(audioServiceProvider).stopBgm();
                      Navigator.of(context).pop();
                    },
                  ),

                // Tutorial overlay
                if (_showingTutorial)
                  TutorialOverlay(
                    onComplete: () {
                      setState(() => _showingTutorial = false);
                      ref
                          .read(tutorialCompletedProvider.notifier)
                          .markCompleted();
                      _ticker.start();
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
