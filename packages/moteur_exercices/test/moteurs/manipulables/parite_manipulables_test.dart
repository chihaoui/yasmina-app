import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple d'un type jouable
/// du moteur Manipulables passe dans le lecteur en test de widget. Le même
/// catalogue est joué par apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) =>
        typeParId(e.idType!)?.moteur == Moteur.manipulables &&
        typeParId(e.idType!)?.etat == EtatType.jouable,
  );

  test('T25 est jouable avec un exemple, T27 et T51 restent à venir', () {
    expect(exemples.map((e) => e.idType).toSet(), {'T25'});
    expect(typeParId('T27')!.etat, EtatType.aVenir);
    expect(typeParId('T51')!.etat, EtatType.aVenir);
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(p.cle('droite'), findsOneWidget);
      expect(p.audio.audioFactice.dits.first.langue, 'ar');
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      final revele =
          tester.widget<CustomPaint>(p.cle('droite_reponse')).painter!
              as PeintreDroite;
      expect(revele.valeur, exemple.exercice!['donnees']['cible']);
      expect(tester.takeException(), isNull);
    });
  }
}
