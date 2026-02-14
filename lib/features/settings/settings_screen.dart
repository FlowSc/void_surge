import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/core/providers/settings_provider.dart';
import 'package:void_surge/core/providers/tutorial_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

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

              // BGM toggle
              _SettingsToggle(
                label: 'BGM',
                value: settings.bgmEnabled,
                onTap: () =>
                    ref.read(settingsProvider.notifier).toggleBgm(),
              ),

              const SizedBox(height: 12),

              // SFX toggle
              _SettingsToggle(
                label: 'SFX',
                value: settings.sfxEnabled,
                onTap: () =>
                    ref.read(settingsProvider.notifier).toggleSfx(),
              ),

              const SizedBox(height: 12),

              // Haptic toggle
              _SettingsToggle(
                label: 'HAPTIC',
                value: settings.hapticEnabled,
                onTap: () =>
                    ref.read(settingsProvider.notifier).toggleHaptic(),
              ),

              const SizedBox(height: 24),

              // Divider
              Container(
                height: 1,
                color: Colors.white12,
              ),

              const SizedBox(height: 24),

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

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? VoidSurgeConstants.uiColor : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 10,
                color: value ? Colors.white : Colors.white38,
              ),
            ),
            Text(
              value ? 'ON' : 'OFF',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 10,
                color: value
                    ? VoidSurgeConstants.uiColor
                    : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
