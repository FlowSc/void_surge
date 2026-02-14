import 'dart:math';

import 'package:flutter/material.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final AnimationController _pulseController;

  static const _steps = [
    _TutorialStep(
      title: 'MOVE',
      description: 'TAP OR DRAG TO MOVE\nYOUR BLACK HOLE',
      color: VoidSurgeConstants.playerColor,
    ),
    _TutorialStep(
      title: 'ABSORB',
      description: 'ABSORB SMALLER PLANETS\nTO GROW',
      color: VoidSurgeConstants.planetColor,
    ),
    _TutorialStep(
      title: 'ENEMIES',
      description: 'AVOID LARGER\nBLACK HOLES',
      color: VoidSurgeConstants.enemyColor,
    ),
    _TutorialStep(
      title: 'ESCAPE',
      description: 'TAP RAPIDLY TO\nESCAPE DANGER',
      color: VoidSurgeConstants.enemyColor,
    ),
    _TutorialStep(
      title: 'SPECIAL',
      description: 'SPECIAL PLANETS GIVE\nUNIQUE BUFFS',
      color: VoidSurgeConstants.redDwarfColor,
    ),
  ];

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

  void _onTap() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step indicator
              Text(
                '${_currentStep + 1} / ${_steps.length}',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 8,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                step.title,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 28,
                  color: step.color,
                  shadows: [
                    Shadow(color: step.color, blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                step.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                  color: Colors.white70,
                  height: 2,
                ),
              ),
              const SizedBox(height: 60),

              // Tap prompt
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse =
                      sin(_pulseController.value * pi) * 0.3 + 0.7;
                  return Opacity(opacity: pulse, child: child);
                },
                child: Text(
                  isLast ? 'TAP TO START' : 'TAP TO CONTINUE',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 8,
                    color: step.color.withValues(alpha: 0.8),
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

class _TutorialStep {
  const _TutorialStep({
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final Color color;
}
