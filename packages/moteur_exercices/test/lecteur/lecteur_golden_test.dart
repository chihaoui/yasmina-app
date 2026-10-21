import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../outils_polices.dart';

/// Goldens du lecteur (A1-15, CLAUDE.md §8) : T01 en arabe et T45 en
/// français, en clair et en sombre, sur un écran de téléphone (390 × 844),
/// polices réelles, graine fixe, forme féminine. Générés sur macOS :
/// `flutter test --update-goldens test/lecteur/lecteur_golden_test.dart`.
/// Les emoji s'affichent en carré (aucune police emoji en test).
void main() {
  setUpAll(chargerPolicesMoteur);
  final catalogue = CatalogueExemples();

  Map<String, dynamic> exemple(String chemin) =>
      catalogue.tous.firstWhere((e) => e.chemin == chemin).exercice!;

  for (final (nom, chemin) in [
    ('t01_ar', 'choix/T01-qcm-texte-image.json'),
    ('t45_fr', 'choix/T45-barrer.json'),
  ]) {
    for (final (theme, luminosite) in [
      ('clair', Brightness.light),
      ('sombre', Brightness.dark),
    ]) {
      testWidgets('lecteur $nom en $theme', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final exercice = exemple(chemin);
        final langue = exercice['langue'] as String;
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(langue),
            supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: ThemeYasmina.theme(langue: langue, luminosite: luminosite),
            home: Scaffold(
              body: LecteurExercice(
                exercice: exercice,
                config: ConfigExercice(
                  langue: langue,
                  formeAdresse: FormeAdresse.feminin,
                  graine: 1,
                ),
                services: ServicesFactices(),
              ),
            ),
          ),
        );
        await tester.pump();
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/lecteur_${nom}_$theme.png'),
        );
      });
    }
  }
}
