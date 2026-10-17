import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

void main() {
  testWidgets('passer en français bascule tout l\'écran et le mémorise', (
    tester,
  ) async {
    final stockage = StockageMemoire('ar');
    await lancerApp(tester, stockage);

    await tester.tap(find.byTooltip('اِفْتَحِ الْإِعْدَادَاتِ'));
    await tester.pumpAndSettle();
    expect(find.text('الْإِعْدَادَاتُ'), findsOneWidget);
    // Les noms des langues restent dans leur propre langue.
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('الْعَرَبِيَّةُ'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('langue_fr')));
    await tester.pumpAndSettle();
    expect(find.text('Réglages'), findsOneWidget);
    expect(find.text('Langue de l\'application'), findsOneWidget);
    expect(stockage.lireLangue(), 'fr');

    // pageBack() cherche l'infobulle anglaise « Back » : on touche le bouton.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'accueil_titre'), 'Yasmina');
    expect(sensDe(tester, 'accueil_titre'), TextDirection.ltr);
  });
}
