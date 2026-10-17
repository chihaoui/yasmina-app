import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// Goldens de l'écran « Qui joue ? » (deux profils), en clair et en sombre,
/// générés sur macOS :
/// `flutter test --update-goldens test/ecrans/profils_golden_test.dart`.
void main() {
  setUpAll(chargerPolices);

  for (final langue in ['ar', 'fr']) {
    for (final luminosite in Brightness.values) {
      final suffixe = luminosite == Brightness.dark ? '_sombre' : '';
      testWidgets('choix du profil en $langue$suffixe', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.platformBrightnessTestValue = luminosite;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await lancerApp(
          tester,
          StockageMemoire(langue),
          profils: ['Lina', 'Yassine'],
        );
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/choix_profil_$langue$suffixe.png'),
        );
      });
    }
  }
}
