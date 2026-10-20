import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple du moteur Grille et
/// graphiques passe dans le lecteur en test de widget. Le même catalogue est
/// joué par apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.grilleGraphiques,
  );

  test('T31, T32, T33 et T60 sont jouables', () {
    expect(exemples.map((e) => e.idType).toSet(), {'T31', 'T32', 'T33', 'T60'});
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
      expect(p.cle('grille_reponse'), findsOneWidget);
      expect(find.text('juste'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
