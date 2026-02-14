import 'dart:ui';

abstract final class VoidSurgeConstants {
  // Field
  static const double initialFieldRadius = 500.0;
  static const double fieldExpansionRate = 10.0;

  // Player
  static const double playerAcceleration = 400.0;
  static const double playerMaxSpeed = 250.0;
  static const double playerDrag = 3.0;
  static const double playerInitialMass = 1.0;

  // Planet
  static const double planetMinMass = 0.1;
  static const double planetMaxMass = 0.9;
  static const int initialPlanetCount = 40;
  static const int maxPlanets = 120;
  static const double planetSpawnInterval = 0.5;

  // Enemy
  static const double enemyBaseSpeed = 80.0;
  static const double firstEnemySpawnTime = 15.0;
  static const double enemySpawnInterval = 30.0;
  static const int maxEnemies = 8;
  static const double enemyMinMassRatio = 0.3;
  static const double enemyMaxMassRatio = 2.5;

  // Gravity
  static const double gravitationalConstant = 5000.0;
  static const double pullRadiusMultiplier = 5.0;
  static const double absorptionRadiusMultiplier = 1.2;
  static const double minGravityDistance = 20.0;
  static const double planetGravityMultiplier = 2.5;

  // Absorption effect
  static const double absorptionEffectDuration = 0.5;

  // Escape
  static const int escapeTapsRequired = 8;
  static const double escapeWindowSeconds = 1.5;
  static const double escapeBoostForce = 600.0;

  // Camera
  static const double cameraZoomBase = 2.5;
  static const double cameraZoomExponent = 0.3;
  static const double cameraLerpSpeed = 3.0;

  // Entity sizing
  static const double entityBaseRadius = 12.0;
  static const double entityRadiusExponent = 0.4;

  // Absorption
  static const double planetAbsorptionRatio = 0.5;
  static const double blackHoleAbsorptionRatio = 0.7;

  // Score
  static const int pointsPerPlanet = 10;
  static const int pointsPerBlackHole = 100;

  // Tick
  static const double maxDeltaTime = 0.05;

  // Special planets
  static const double specialPlanetSpawnChance = 0.05;
  static const double redDwarfSpeedMultiplier = 1.5;
  static const double redDwarfDuration = 5.0;
  static const double whiteDwarfScoreMultiplier = 3.0;
  static const double whiteDwarfDuration = 8.0;
  static const double blackDwarfMassBoostRatio = 0.5;

  // Colors
  static const Color playerColor = Color(0xFF6644FF);
  static const Color enemyColor = Color(0xFFFF3344);
  static const Color planetColor = Color(0xFF00E5FF);
  static const Color uiColor = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFF050510);
  static const Color fieldBorderColor = Color(0x55FFFFFF);
  static const Color redDwarfColor = Color(0xFFFF4422);
  static const Color whiteDwarfColor = Color(0xFFEEEEFF);
  static const Color blackDwarfColor = Color(0xFF334455);
}
