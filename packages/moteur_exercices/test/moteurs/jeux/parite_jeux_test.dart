import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple du moteur Révision
/// et jeux passe dans le lecteur en test de widget. Le même catalogue est
/// joué par apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.revisionJeux,
  );

  test('T36, T37 et T38 sont jouables', () {
    expect(exemples.map((e) => e.idType).toSet(), {'T36', 'T37', 'T38'});
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('jeux_reponse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
