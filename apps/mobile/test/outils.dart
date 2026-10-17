import 'dart:io';

import 'package:flutter/services.dart';
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

/// Charge les vraies polices dans le moteur de test (par défaut, flutter_test
/// dessine des rectangles) : polices du moteur et icônes Material.
Future<void> chargerPolices() async {
  const dossier = '../../packages/moteur_exercices/fonts';
  const familles = {
    'packages/moteur_exercices/NotoNaskhArabic': 'NotoNaskhArabic',
    'packages/moteur_exercices/BalooBhaijaan2': 'BalooBhaijaan2',
    'packages/moteur_exercices/Andika': 'Andika',
  };
  for (final MapEntry(key: famille, value: fichier) in familles.entries) {
    final chargeur = FontLoader(famille);
    for (final style in ['Regular', 'Bold']) {
      chargeur.addFont(_lire('$dossier/$fichier-$style.ttf'));
    }
    await chargeur.load();
  }
  final racineFlutter = Platform.environment['FLUTTER_ROOT'];
  if (racineFlutter != null) {
    await (FontLoader('MaterialIcons')..addFont(
          _lire(
            '$racineFlutter/bin/cache/artifacts/material_fonts/'
            'MaterialIcons-Regular.otf',
          ),
        ))
        .load();
  }
}

Future<ByteData> _lire(String chemin) async =>
    ByteData.sublistView(await File(chemin).readAsBytes());
