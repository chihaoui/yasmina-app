import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

void main() {
  testWidgets('interface en arabe : textes arabes, de droite à gauche', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('ar'));
    expect(texteDe(tester, 'accueil_titre'), 'يَاسْمِينَة');
    expect(texteDe(tester, 'accueil_bienvenue'), 'هَيَّا نَتَعَلَّمُ مَعًا.');
    expect(sensDe(tester, 'accueil_titre'), TextDirection.rtl);
    expect(sensDe(tester, 'accueil_bienvenue'), TextDirection.rtl);
  });

  testWidgets('interface en français : textes français, de gauche à droite', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'));
    expect(texteDe(tester, 'accueil_titre'), 'Yasmina');
    expect(texteDe(tester, 'accueil_bienvenue'), 'On apprend ensemble.');
    expect(sensDe(tester, 'accueil_titre'), TextDirection.ltr);
  });

  testWidgets('les matières de la 1re année dans une interface française', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'));
    expect(sensDe(tester, 'accueil_titre'), TextDirection.ltr);
    for (final code in ['ar', 'ma', 'ev']) {
      expect(find.byKey(ValueKey('matiere_$code')), findsOneWidget);
    }
    expect(find.text('Arabe'), findsOneWidget);
    expect(find.text('Bientôt'), findsNWidgets(2));
  });

  testWidgets("polices : Baloo pour l'interface arabe", (tester) async {
    await lancerApp(tester, StockageMemoire('ar'));
    final titre = tester.element(find.byKey(const ValueKey('accueil_titre')));
    expect(
      Theme.of(titre).textTheme.titleLarge!.fontFamily,
      PolicesYasmina.interfaceArabe,
    );
  });

  testWidgets("polices : Andika pour l'interface française", (tester) async {
    await lancerApp(tester, StockageMemoire('fr'));
    final titre = tester.element(find.byKey(const ValueKey('accueil_titre')));
    expect(
      Theme.of(titre).textTheme.titleLarge!.fontFamily,
      PolicesYasmina.latin,
    );
  });

  testWidgets("l'app suit le thème sombre de l'appareil, sans relance", (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'));
    BuildContext titre() =>
        tester.element(find.byKey(const ValueKey('accueil_titre')));
    expect(Theme.of(titre()).brightness, Brightness.light);
    expect(titre().couleurs, CouleursYasmina.clair);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();
    expect(Theme.of(titre()).brightness, Brightness.dark);
    expect(titre().couleurs, CouleursYasmina.sombre);
  });

  group('premier lancement selon les langues de l\'appareil', () {
    final cas = {
      'appareil en arabe': ([const Locale('ar', 'TN')], 'يَاسْمِينَة'),
      'appareil en français': ([const Locale('fr', 'FR')], 'Yasmina'),
      'appareil en espagnol': ([const Locale('es', 'ES')], 'يَاسْمِينَة'),
      'espagnol puis français': (
        [const Locale('es'), const Locale('fr')],
        'Yasmina',
      ),
    };
    cas.forEach((nom, valeurs) {
      testWidgets(nom, (tester) async {
        tester.platformDispatcher.localesTestValue = valeurs.$1;
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);
        final stockage = StockageMemoire();
        await lancerApp(tester, stockage);
        expect(texteDe(tester, 'accueil_titre'), valeurs.$2);
        expect(stockage.lireLangue(), isNotNull);
      });
    });
  });
}
