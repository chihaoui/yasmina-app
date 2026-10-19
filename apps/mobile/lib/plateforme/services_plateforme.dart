import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../dev/reglages_dev.dart';
import 'audio_mobile.dart';
import 'sons_audioplayers.dart';
import 'vibration_haptique.dart';

/// Pas encore de fichiers d'exercice à lire (emoji et synthèse vocale dans
/// le prototype) : les packs arrivent en phase B.
class AssetsAbsents implements ServiceAssets {
  const AssetsAbsents();

  @override
  Future<Uint8List?> lire(String chemin) async => null;
}

/// Services de plateforme de l'app mobile, injectés dans le lecteur.
/// Surchargé par ServicesFactices dans les tests.
final servicesExerciceProvider = Provider<ServicesExercice>(
  (ref) => ServicesExercice(
    audio: AudioMobile(
      // Interrupteur « Sons des effets » du menu développeur, lu à chaque son.
      sons: SonsAudioplayers(actifs: () => ref.read(sonsEffetsProvider)),
    ),
    vibration: const VibrationHaptique(),
    assets: const AssetsAbsents(),
  ),
);
