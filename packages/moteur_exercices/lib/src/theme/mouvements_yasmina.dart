import 'dart:math' as math;

/// Mouvements de l'interface, repris de la démo (`hop` et `tilt`). Seule
/// source de ces valeurs : le design system n'a pas de famille motion dans
/// tokens.json. Tout mouvement est coupé si l'appareil demande moins
/// d'animations.
abstract final class MouvementsYasmina {
  /// Un saut de Yasmina sur une réponse juste.
  static const dureeSaut = Duration(milliseconds: 900);

  /// Nombre de sauts (humeur bravo).
  static const sauts = 3;

  /// Hauteur d'un saut (px).
  static const hauteurSaut = 12.0;

  /// Un mouvement penché de Yasmina sur une réponse fausse.
  static const dureePenche = Duration(milliseconds: 1600);

  /// Nombre de mouvements penchés (humeur encourage).
  static const penches = 2;

  /// Angle du mouvement penché (6°, vers le début de ligne).
  static const anglePenche = 6 * math.pi / 180;

  /// Durée pendant laquelle une réponse fausse reste marquée avant que la
  /// sélection soit vidée (1er essai faux).
  static const dureeFaux = Duration(milliseconds: 700);
}
