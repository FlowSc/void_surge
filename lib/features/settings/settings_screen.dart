import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/core/providers/tutorial_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: VoidSurgeConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 20,
                  color: VoidSurgeConstants.uiColor,
                  shadows: [
                    Shadow(
                      color: VoidSurgeConstants.uiColor,
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Replay Tutorial
              GestureDetector(
                onTap: () {
                  ref.read(tutorialCompletedProvider.notifier).reset();
                  context.go('/game?tutorial=true');
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: VoidSurgeConstants.playerColor,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'REPLAY TUTORIAL',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: VoidSurgeConstants.playerColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
