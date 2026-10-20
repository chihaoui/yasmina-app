import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'outils_choix.dart';

/// Parité mobile et web (CLAUDE.md §4) : chaque exemple du moteur Choix
/// passe dans le lecteur en test de widget. Le même catalogue est joué par
/// apps/apercu_web (test de widget et build web).
void main() {
  final exemples = CatalogueExemples().tous.where(
    (e) => typeParId(e.idType!)?.moteur == Moteur.choix,
  );

  test('tous les types du moteur Choix ont un exemple et un gabarit', () {
    final types = typesDuMoteur(Moteur.choix);
    expect(types.map((t) => t.etat), everyElement(EtatType.jouable));
    for (final type in types) {
      expect(
        exemples.where((e) => e.idType == type.id),
        isNotEmpty,
        reason: type.id,
      );
      expect(gabaritPour(type.id), isNotNull, reason: type.id);
    }
  });

  for (final exemple in exemples) {
    testWidgets('${exemple.fichier} : jouable, réponse révélée en aperçu', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(find.byType(LecteurExercice), findsOneWidget);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(find.byType(TuileChoix), findsWidgets);
      // La consigne est dite dans la langue de l'exercice.
      expect(p.audio.audioFactice.dits.first.langue, exemple.langue);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      final justes = tester
          .widgetList<TuileChoix>(find.byType(TuileChoix))
          .where((t) => t.etat == EtatTuile.juste);
      expect(justes, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
