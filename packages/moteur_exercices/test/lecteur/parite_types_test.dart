import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../moteurs/choix/outils_choix.dart';

/// Parité des 52 types (A1-15, CLAUDE.md §4) : chaque type jouable a au
/// moins un exemple valide dans le catalogue, et chaque exemple d'un type
/// jouable passe dans le lecteur en test de widget (aperçu, réponse
/// révélée, aucune exception), la consigne dite dans la langue de
/// l'exercice. Le même catalogue est joué par apps/apercu_web (test de
/// widget et build web) et par la séquence de test de l'app mobile
/// (apps/mobile/assets/sequences/tour-1.json).
void main() {
  final catalogue = CatalogueExemples();
  final jouables = typesExercices
      .where((t) => t.etat == EtatType.jouable)
      .toList();

  test('52 types jouables, chacun avec au moins un exemple valide', () {
    expect(jouables, hasLength(52));
    for (final t in jouables) {
      expect(
        catalogue.exemplesDuType(t.id).where((e) => e.estValide),
        isNotEmpty,
        reason: t.id,
      );
    }
  });

  test('aucun type à venir, aucun exemple non rattaché', () {
    expect(typesExercices.where((t) => t.etat == EtatType.aVenir), isEmpty);
    expect(catalogue.nonRattaches, isEmpty);
  });

  final exemples = catalogue.tous.where(
    (e) => e.idType != null && typeParId(e.idType!)?.etat == EtatType.jouable,
  );

  for (final exemple in exemples) {
    testWidgets('${exemple.chemin} : joué dans le lecteur, réponse révélée', (
      tester,
    ) async {
      final p = Partie(tester);
      await p.jouer(exemple.exercice!, mode: ModeExercice.apercu);
      expect(p.cle('lecteur_erreur'), findsNothing);
      expect(p.cle('lecteur_consigne'), findsOneWidget);
      expect(p.audio.audioFactice.dits.first.langue, exemple.langue);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
