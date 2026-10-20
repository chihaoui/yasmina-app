import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'outils_glisser.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple d'un type jouable
/// du moteur Glisser-déposer passe dans le lecteur en test de widget. Le
/// même catalogue est joué par apps/apercu_web (test de widget et build
/// web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) =>
        typeParId(e.idType!)?.moteur == Moteur.glisserDeposer &&
        typeParId(e.idType!)?.etat == EtatType.jouable,
  );

  test('les 10 types du moteur sont jouables, avec un exemple chacun', () {
    expect(exemples.map((e) => e.idType).toSet(), {
      'T06',
      'T09',
      'T11',
      'T12',
      'T13',
      'T14',
      'T15',
      'T16',
      'T56',
      'T62',
    });
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(find.byType(TuileGlissable), findsWidgets);
      expect(find.byType(ZoneDepot), findsWidgets);
      expect(p.audio.audioFactice.dits.first.langue, exemple.langue);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      final justes = tester
          .widgetList<TuileGlissable>(find.byType(TuileGlissable))
          .where((t) => t.etat == EtatGlissable.juste);
      expect(justes, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
