import 'package:flutter/services.dart';

abstract final class HapticService {
  static void trigger(double absorbedMass, {required bool enabled}) {
    if (!enabled) return;

    if (absorbedMass < 1.0) {
      HapticFeedback.lightImpact();
    } else if (absorbedMass < 5.0) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}
