# CLAUDE.md — Void Surge

## Project Overview

Black hole survival game. The player controls a growing entity that absorbs planets while avoiding enemy black holes in an expanding field.

- **App name**: Void Surge
- **Current version**: 1.0.0+1

## Tech Stack (project-specific)

- No backend, ads, IAP, or localization yet — standalone offline game
- **Persistence**: shared_preferences

## Architecture

```
lib/
├── main.dart
├── app.dart
├── core/
│   └── constants/            # VoidSurgeConstants (physics, spawning, colors)
└── features/
    ├── game/
    │   ├── models/           # GameWorld, Player, Planet, EnemyBlackHole, Entity, Vec2, Camera
    │   ├── providers/        # VoidSurgeNotifier (@riverpod game state)
    │   ├── systems/          # PhysicsSystem, SpawnSystem, AiSystem, CameraSystem, EscapeSystem
    │   ├── painters/         # CustomPainter classes (background, entities, danger zone)
    │   ├── widgets/          # HUD, GameOverOverlay
    │   └── game_screen.dart  # Main game screen
    └── home/
        └── home_screen.dart
```

## Game Architecture

- **ECS-like pattern**: Models (data) + Systems (pure logic) + Notifier (orchestrator)
- **GameWorld**: Immutable state holding Player, Planets, Enemies, Camera, field radius
- **Systems** (all pure static, no side effects):
  - `PhysicsSystem`: Gravity, velocity, absorption, collision
  - `SpawnSystem`: Planet/enemy spawning based on game time
  - `AiSystem`: Enemy black hole behavior
  - `CameraSystem`: Follow player with zoom based on mass
  - `EscapeSystem`: Tap-to-escape from danger zones (8 taps in 1.5s)
- **Rendering**: CustomPainter pipeline (background stars -> entities -> danger zone -> HUD)
- **Game loop**: `Ticker` drives `VoidSurgeNotifier.update(dt)` each frame
- **Field**: Circular, expands over time (`fieldExpansionRate: 10.0/s`)

### Key Constants

- Player: acceleration 400, max speed 250, drag 3.0
- Gravity: G=5000, pull radius 5x entity radius
- Enemies: first spawn at 15s, then every 30s, max 8

## Build Commands

```bash
# Code generation (after modifying @riverpod annotated files)
dart run build_runner build --delete-conflicting-outputs

# Verification
flutter analyze
flutter test

# Run
flutter run
```
