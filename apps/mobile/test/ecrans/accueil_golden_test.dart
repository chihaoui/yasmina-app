import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// Goldens de l'accueil (CLAUDE.md §8), générés sur macOS :
/// `flutter test --update-goldens test/ecrans/accueil_golden_test.dart`.
void main() {
  setUpAll(chargerPolices);

  for (final langue in ['ar', 'fr']) {
    testWidgets('accueil en $langue', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await lancerApp(tester, StockageMemoire(langue));
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/accueil_$langue.png'),
      );
    });
  }
}
