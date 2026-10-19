import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Sons d'interface (décision 35). Fichiers WAV dans les assets du moteur
/// (assets/sons/), provisoires générés par tool/generer_sons.dart : un
/// fichier définitif du même nom les remplace sans changer le code.
enum SonInterface {
  /// Réponse juste (validation).
  juste('juste.wav'),

  /// 1er essai faux (indice). Doux, jamais un buzzer.
  essaiFaux('essai-faux.wav'),

  /// Bonne réponse révélée (explication).
  revelee('revelee.wav'),

  /// Élément déposé (glisser-déposer).
  depot('depot.wav'),

  /// Fin d'une étape (écran de résultat).
  finEtape('fin-etape.wav');

  const SonInterface(this.fichier);

  final String fichier;

  /// Chemin dans le package moteur_exercices.
  String get asset => 'assets/sons/$fichier';

  /// Clé de l'asset vue depuis une app (préfixe du package).
  String get cleAsset => 'packages/moteur_exercices/$asset';
}

/// Voix de l'appareil (prototype) ou audios pré-générés (plus tard), et
/// sons d'interface.
abstract interface class ServiceAudio {
  /// Une voix existe pour [langue] (`ar`, `fr` ou `en`). Sans voix, [dire]
  /// ne fait rien : le lecteur reste utilisable.
  Future<bool> voixDisponible(String langue);

  /// Dit [texte] dans [langue], en coupant ce qui était en cours.
  Future<void> dire(String texte, {required String langue});

  Future<void> arreter();

  /// Joue un son d'interface, à volume bas. Ne joue rien si les sons des
  /// effets sont coupés ou si l'appareil est en mode silencieux.
  Future<void> jouerSon(SonInterface son);
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
