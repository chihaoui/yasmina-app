import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_manipulables.dart';

/// T25 Droite numérique (docs/moteurs/manipulables.md) : repère glissé le
/// long de la droite (aimant), graduation touchée, sens configurable,
/// retour au départ après le 1er essai faux, réponse révélée.
void main() {
  late Partie p;

  PeintreDroite peintre(WidgetTester tester) =>
      tester.widget<CustomPaint>(p.cle('droite_dessin')).painter!
          as PeintreDroite;

  /// Point de l'écran sur la droite, à la position normalisée [position]
  /// (0 à 1, de gauche à droite).
  Offset point(WidgetTester tester, double position) {
    final rect = tester.getRect(p.cle('droite'));
    return Offset(
      rect.left + PeintreDroite.abscisse(position, rect.width),
      rect.center.dy,
    );
  }

  Future<void> toucherValeur(WidgetTester tester, int valeur) async {
    await tester.tapAt(point(tester, peintre(tester).positionDe(valeur)));
    await tester.pump();
  }

  testWidgets('arabe : droite de gauche à droite, repère glissé avec aimant, '
      'graduation touchée, faux puis juste', (tester) async {
    p = Partie(tester);
    await p.jouer(exempleManipulables('T25-droite-numerique.json'));
    expect(p.sens, TextDirection.rtl);
    // La droite elle-même reste de gauche à droite, 0 à gauche.
    expect(
      Directionality.of(tester.element(p.cle('droite'))),
      TextDirection.ltr,
    );
    expect(peintre(tester).etiquettes, [0, 5, 10]);
    expect(peintre(tester).positionDe(0), 0);
    expect(peintre(tester).positionDe(10), 1);
    expect(peintre(tester).valeur, isNull);
    expect(p.bouton.onPressed, isNull);
    // Glisser le repère depuis le début jusqu'à 3,4 : il s'aimante à 3.
    final geste = await tester.startGesture(point(tester, 0));
    await geste.moveTo(point(tester, 0.2));
    await tester.pump();
    expect(peintre(tester).tenue, closeTo(0.2, 0.01));
    await geste.moveTo(point(tester, 0.34));
    await tester.pump();
    await geste.up();
    await tester.pump();
    expect(peintre(tester).tenue, isNull);
    expect(peintre(tester).valeur, 3);
    expect(p.reponsesDonnees.last, {'valeur': 3});
    expect(p.audio.audioFactice.sons, [SonInterface.depot]);
    expect(p.audio.vibrationFactice.legeres, 1);
    expect(p.bouton.onPressed, isNotNull);
    await p.verifier();
    expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
    await p.attendreVidage();
    // Tout revient au départ.
    expect(peintre(tester).valeur, isNull);
    expect(p.bouton.onPressed, isNull);
    // Toucher la graduation 7.
    await toucherValeur(tester, 7);
    expect(peintre(tester).valeur, 7);
    expect(p.reponsesDonnees.last, {'valeur': 7});
    await p.verifier();
    await tester.pumpAndSettle();
    expect(find.text('أَحْسَنْتَ'), findsOneWidget);
    expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
  });

  testWidgets('sens droite-gauche : 0 à droite, toucher le bout gauche '
      'donne 10, faux deux fois révèle la cible', (tester) async {
    p = Partie(tester);
    await p.jouer(t25DroiteGauche(), forme: FormeAdresse.feminin);
    expect(peintre(tester).positionDe(0), 1);
    expect(peintre(tester).positionDe(10), 0);
    await tester.tapAt(point(tester, 0.02));
    await tester.pump();
    expect(peintre(tester).valeur, 10);
    await p.verifier();
    await p.attendreVidage();
    await toucherValeur(tester, 2);
    await p.verifier();
    await tester.pumpAndSettle();
    expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
    expect(p.cle('droite_dessin'), findsNothing);
    final revele =
        tester.widget<CustomPaint>(p.cle('droite_reponse')).painter!
            as PeintreDroite;
    expect(revele.valeur, 4);
    expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
  });

  testWidgets('français : pas de 2, réperes aux bouts, aperçu avec la '
      'réponse affichée', (tester) async {
    p = Partie(tester);
    await p.jouer(t25Francais(), mode: ModeExercice.apercu);
    expect(p.sens, TextDirection.ltr);
    expect(peintre(tester).etiquettes, [0, 10, 20]);
    await toucherValeur(tester, 14);
    expect(peintre(tester).valeur, 14);
    await tester.tap(p.cle('lecteur_afficher_reponse'));
    await tester.pump();
    final revele =
        tester.widget<CustomPaint>(p.cle('droite_reponse')).painter!
            as PeintreDroite;
    expect(revele.valeur, 16);
    expect(find.text('juste'), findsOneWidget);
    expect(p.evenements!.whereType<Resultat>(), isEmpty);
  });
}
