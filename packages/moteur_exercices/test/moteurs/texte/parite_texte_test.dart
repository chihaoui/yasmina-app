import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple du moteur Texte
/// passe dans le lecteur en test de widget. Le même catalogue est joué par
/// apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.texte,
  );

  test('T07 et T17 sont jouables, un cas arabe et un cas français', () {
    expect(exemples.map((e) => e.idType).toSet(), {'T07', 'T17'});
    expect(exemples.map((e) => e.langue).toSet(), {'ar', 'fr'});
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(p.audio.audioFactice.dits.first.langue, exemple.langue);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      if (exemple.idType == 'T07') {
        expect(
          tester
              .widgetList<MotTouchable>(find.byType(MotTouchable))
              .where((m) => m.etat == EtatMot.juste),
          isNotEmpty,
        );
      } else {
        expect(p.cle('dictee_reponse'), findsOneWidget);
      }
      expect(find.text('juste'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
