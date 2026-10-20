import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple du moteur Mesure et
/// temps passe dans le lecteur en test de widget. Le même catalogue est joué
/// par apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.mesureTemps,
  );

  test('T28 et T30 sont jouables', () {
    expect(exemples.map((e) => e.idType).toSet(), {'T28', 'T30'});
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(p.audio.audioFactice.dits.first.langue, 'ar');
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('saisie_reponse'), findsOneWidget);
      if (exemple.idType == 'T28') {
        final peintre =
            tester.widget<CustomPaint>(p.cle('saisie_reponse')).painter!
                as PeintreHorloge;
        expect(peintre.totales, 6 * 60 + 30);
      }
      expect(find.text('juste'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
