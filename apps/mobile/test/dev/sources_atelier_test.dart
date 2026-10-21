import 'package:edu_content/edu_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/dev/menu_dev.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// Les exemples de l'atelier ne sont embarqués qu'en debug et en profile
/// (A3, nettoyage) : en release, le catalogue est vide et le bouton
/// « Jouer » de la séquence de test disparaît de l'accueil.
void main() {
  test('sources de l\'atelier : tous les exemples hors release, rien en '
      'release', () {
    expect(sourcesAtelier(release: false), same(exemplesEduContent));
    expect(sourcesAtelier(release: false), isNotEmpty);
    expect(sourcesAtelier(release: true), isEmpty);
    // Les tests tournent en debug : la valeur par défaut suit kReleaseMode.
    expect(sourcesAtelier(), kReleaseMode ? isEmpty : isNotEmpty);
  });

  testWidgets('catalogue vide (release) : plus de bouton « Jouer » sur '
      'l\'accueil, les matières restent', (tester) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      surcharges: [
        catalogueExemplesProvider.overrideWithValue(
          CatalogueExemples(const {}),
        ),
      ],
    );
    expect(find.byKey(const ValueKey('accueil_jouer')), findsNothing);
    expect(find.byKey(const ValueKey('matiere_ar')), findsOneWidget);
  });
}
