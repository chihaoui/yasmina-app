import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple de T20 passe dans
/// le lecteur en test de widget. Le même catalogue est joué par
/// apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.trace,
  );

  test('T20 est jouable, avec trois exemples (ب, ل, م)', () {
    expect(typeParId('T20')!.etat, EtatType.jouable);
    expect(exemples.map((e) => e.exercice!['donnees']['lettre']), [
      'ب',
      'ل',
      'م',
    ]);
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(p.cle('trace_zone'), findsOneWidget);
      expect(find.byType(TuileChoix), findsNWidgets(4));
      expect(p.audio.audioFactice.dits.first.langue, 'ar');
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('trace_reponse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
