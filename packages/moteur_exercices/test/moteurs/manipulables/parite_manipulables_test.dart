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

  test('les 6 types sont jouables, avec un exemple chacun', () {
    expect(exemples.map((e) => e.idType).toSet(), {
      'T25',
      'T27',
      'T51',
      'T26',
      'T29',
      'T52',
    });
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
      final donnees = exemple.exercice!['donnees'] as Map<String, dynamic>;
      switch (exemple.idType) {
        case 'T25':
          final revele =
              tester.widget<CustomPaint>(p.cle('droite_reponse')).painter!
                  as PeintreDroite;
          expect(revele.valeur, donnees['cible']);
        case 'T27':
          expect(p.cle('manipulables_reponse'), findsOneWidget);
          expect(find.byType(Bloc), findsNWidgets(2 + 3 + 4));
        case 'T51':
          expect(p.cle('manipulables_reponse'), findsOneWidget);
          expect(find.byType(Jeton), findsNWidgets(1 + 7));
        case 'T26':
          expect(p.cle('manipulables_reponse'), findsOneWidget);
          // 5 pièces de réserve, et 2 dinars 700 millimes en 4 pièces.
          expect(find.byType(Piece), findsNWidgets(5 + 4));
        case 'T29':
          expect(p.cle('manipulables_reponse'), findsOneWidget);
          final peintre =
              tester.widget<CustomPaint>(p.cle('fraction_dessin')).painter!
                  as PeintreFraction;
          expect(peintre.coloriees, hasLength(donnees['numerateur']));
        case 'T52':
          expect(p.cle('manipulables_reponse'), findsOneWidget);
          expect(find.byKey(const ValueKey('inconnue')), findsOneWidget);
      }
      expect(find.text('juste'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
