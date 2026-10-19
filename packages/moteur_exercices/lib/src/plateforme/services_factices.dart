import 'dart:typed_data';

import 'services.dart';

/// Audio factice : enregistre ce qui est dit. [voix] liste les langues qui
/// ont une voix (toutes par défaut).
class AudioFactice implements ServiceAudio {
  AudioFactice({Set<String>? voix}) : voix = voix ?? {'ar', 'fr', 'en'};

  final Set<String> voix;

  /// Textes dits, dans l'ordre (y compris sans voix : la demande compte).
  final dits = <({String texte, String langue})>[];

  int arrets = 0;

  @override
  Future<bool> voixDisponible(String langue) async => voix.contains(langue);

  @override
  Future<void> dire(String texte, {required String langue}) async =>
      dits.add((texte: texte, langue: langue));

  @override
  Future<void> arreter() async => arrets++;
}

/// Vibration factice : compte les vibrations.
class VibrationFactice implements ServiceVibration {
  int legeres = 0;

  @override
  Future<void> legere() async => legeres++;
}

/// Assets factices, en mémoire.
class AssetsFactices implements ServiceAssets {
  AssetsFactices([Map<String, Uint8List>? fichiers])
    : fichiers = fichiers ?? {};

  final Map<String, Uint8List> fichiers;

  @override
  Future<Uint8List?> lire(String chemin) async => fichiers[chemin];
}

/// Services factices pour les tests (et l'aperçu web jusqu'à A0-15).
class ServicesFactices extends ServicesExercice {
  ServicesFactices({Set<String>? voix})
    : super(
        audio: AudioFactice(voix: voix),
        vibration: VibrationFactice(),
        assets: AssetsFactices(),
      );

  AudioFactice get audioFactice => audio as AudioFactice;

  VibrationFactice get vibrationFactice => vibration as VibrationFactice;
}
