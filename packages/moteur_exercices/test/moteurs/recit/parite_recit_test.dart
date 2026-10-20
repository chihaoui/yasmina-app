import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : l'exemple du moteur Récit passe
/// dans le lecteur en test de widget. Le même catalogue est joué par
/// apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.recit,
  );

  test('T35 est jouable', () {
    expect(exemples.map((e) => e.idType).toSet(), {'T35'});
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
      expect(p.cle('recit_reponse'), findsOneWidget);
      expect(find.text('juste'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
