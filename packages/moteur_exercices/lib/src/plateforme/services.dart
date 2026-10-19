import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Voix de l'appareil (prototype) ou audios pré-générés (plus tard).
abstract interface class ServiceAudio {
  /// Une voix existe pour [langue] (`ar`, `fr` ou `en`). Sans voix, [dire]
  /// ne fait rien : le lecteur reste utilisable.
  Future<bool> voixDisponible(String langue);

  /// Dit [texte] dans [langue], en coupant ce qui était en cours.
  Future<void> dire(String texte, {required String langue});

  Future<void> arreter();
}

/// Retour haptique.
abstract interface class ServiceVibration {
  /// Vibration légère (dépôt, choix d'une tuile).
  Future<void> legere();
}

/// Fichiers d'un exercice (images, audios pré-générés), lus depuis les
/// assets ou les packs téléchargés (phase B).
abstract interface class ServiceAssets {
  /// Contenu du fichier [chemin] (chemin du JSON), `null` s'il est absent.
  Future<Uint8List?> lire(String chemin);
}

/// Services de plateforme injectés dans le lecteur : une implémentation
/// mobile (apps/mobile), une web (A0-15) et une factice (tests).
class ServicesExercice {
  const ServicesExercice({
    required this.audio,
    required this.vibration,
    required this.assets,
  });

  final ServiceAudio audio;
  final ServiceVibration vibration;
  final ServiceAssets assets;

  /// Services posés au-dessus de [context] par [PorteurServices] (le
  /// lecteur les pose pour les zones de réponse).
  static ServicesExercice of(BuildContext context) {
    final porteur = context
        .dependOnInheritedWidgetOfExactType<PorteurServices>();
    assert(porteur != null, 'Aucun PorteurServices au-dessus de ce widget.');
    return porteur!.services;
  }
}

/// Rend [services] accessibles à tout le sous-arbre.
class PorteurServices extends InheritedWidget {
  const PorteurServices({
    super.key,
    required this.services,
    required super.child,
  });

  final ServicesExercice services;

  @override
  bool updateShouldNotify(PorteurServices ancien) =>
      ancien.services != services;
}
