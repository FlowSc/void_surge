import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/core/providers/tutorial_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorialCompleted = ref.watch(tutorialCompletedProvider);

    return Scaffold(
      backgroundColor: VoidSurgeConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'VOID',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 36,
                color: VoidSurgeConstants.playerColor,
                shadows: [
                  Shadow(
                    color: VoidSurgeConstants.playerColor,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const Text(
              'SURGE',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 36,
                color: VoidSurgeConstants.uiColor,
                shadows: [
                  Shadow(
                    color: VoidSurgeConstants.uiColor,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BLACK HOLE SURVIVAL',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 8,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 60),

            // Start button with pulse
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulse = sin(_pulseController.value * pi) * 0.3 + 0.7;
                return Opacity(
                  opacity: pulse,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  if (tutorialCompleted) {
                    context.go('/game');
                  } else {
                    context.go('/game?tutorial=true');
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: VoidSurgeConstants.playerColor,
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 16,
                      color: VoidSurgeConstants.playerColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Settings button
            GestureDetector(
              onTap: () => context.go('/settings'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),
            const Text(
              'TAP TO MOVE  /  TAP FAST TO ESCAPE',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 6,
                color: Colors.white24,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
