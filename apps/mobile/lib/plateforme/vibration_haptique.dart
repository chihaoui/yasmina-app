import 'package:flutter/services.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Retour haptique de l'appareil.
class VibrationHaptique implements ServiceVibration {
  const VibrationHaptique();

  @override
  Future<void> legere() => HapticFeedback.lightImpact();
}
