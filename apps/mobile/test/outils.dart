import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/main.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

/// Lance l'app avec un stockage en mémoire. Les langues de l'appareil se
/// règlent avec `tester.platformDispatcher.localesTestValue`.
Future<void> lancerApp(WidgetTester tester, StockageReglages stockage) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [stockageReglagesProvider.overrideWithValue(stockage)],
      child: const YasminaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Sens d'écriture effectif du widget qui porte [cle].
TextDirection sensDe(WidgetTester tester, String cle) =>
    Directionality.of(tester.element(find.byKey(ValueKey(cle))));

/// Texte affiché par le widget Text qui porte [cle].
String? texteDe(WidgetTester tester, String cle) =>
    tester.widget<Text>(find.byKey(ValueKey(cle))).data;
