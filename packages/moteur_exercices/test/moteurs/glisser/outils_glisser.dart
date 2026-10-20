import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

export '../choix/outils_choix.dart';

/// Gestes du moteur Glisser-déposer dans une [Partie].
extension GestesGlisser on Partie {
  /// Vrai glisser : prend l'élément [element], le déplace jusqu'au centre
  /// de [cible] et le lâche.
  Future<void> glisser(String element, String cible) async {
    await tester.ensureVisible(cle(element));
    final geste = await tester.startGesture(tester.getCenter(cle(element)));
    await geste.moveBy(const Offset(0, 1));
    await tester.pump();
    await geste.moveTo(tester.getCenter(cle(cible)));
    await tester.pump();
    await geste.up();
    await tester.pump();
  }

  /// Vrai glisser jusqu'au bout de la ligne de réponse [cible] (côté fin
  /// de ligne, hors des tuiles posées) : l'élément s'ajoute à la fin.
  Future<void> glisserEnFin(String element, String cible) async {
    await tester.ensureVisible(cle(element));
    final geste = await tester.startGesture(tester.getCenter(cle(element)));
    await geste.moveBy(const Offset(0, 1));
    await tester.pump();
    final zone = tester.getRect(cle(cible));
    final rtl =
        Directionality.of(tester.element(cle(cible))) == TextDirection.rtl;
    await geste.moveTo(
      Offset(rtl ? zone.left + 6 : zone.right - 6, zone.center.dy),
    );
    await tester.pump();
    await geste.up();
    await tester.pump();
  }

  /// Toucher d'une zone de dépôt par son coin (hors des tuiles posées).
  Future<void> toucherZone(String cible) async {
    await tester.ensureVisible(cle(cible));
    await tester.tapAt(tester.getTopLeft(cle(cible)) + const Offset(6, 6));
    await tester.pump();
  }

  /// Glisser lâché hors de toute cible (coin de l'écran).
  Future<void> glisserHors(String element) async {
    await tester.ensureVisible(cle(element));
    final geste = await tester.startGesture(tester.getCenter(cle(element)));
    await geste.moveBy(const Offset(0, 1));
    await tester.pump();
    await geste.moveTo(const Offset(1, 1));
    await tester.pump();
    await geste.up();
    await tester.pump();
    await tester.pump(MouvementsYasmina.dureeRetour);
  }

  TuileGlissable glissable(String valeur) =>
      tester.widget<TuileGlissable>(cle(valeur));

  EtatGlissable etatGlissable(String valeur) => glissable(valeur).etat;

  /// L'élément [element] est affiché dans la cible [cible].
  bool dans(String element, String cible) => find
      .descendant(of: cle(cible), matching: cle(element))
      .evaluate()
      .isNotEmpty;

  List<SonInterface> get sons => audio.audioFactice.sons;
}
