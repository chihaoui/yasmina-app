import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// Goldens de la carte du trimestre d'arabe 1re (contenu embarqué, première
/// étape ouverte), en clair et en sombre, générés sur macOS :
/// `flutter test --update-goldens test/ecrans/carte_golden_test.dart`.
void main() {
  setUpAll(chargerPolices);

  for (final langue in ['ar', 'fr']) {
    for (final luminosite in Brightness.values) {
      final suffixe = luminosite == Brightness.dark ? '_sombre' : '';
      testWidgets('carte en $langue$suffixe', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.platformBrightnessTestValue = luminosite;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await lancerApp(tester, StockageMemoire(langue));
        await tester.tap(find.byKey(const ValueKey('matiere_ar')));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/carte_$langue$suffixe.png'),
        );
      });
    }
  }
}
