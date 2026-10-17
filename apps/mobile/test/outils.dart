import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/donnees/base_yasmina.dart';
import 'package:yasmina/donnees/providers.dart';
import 'package:yasmina/main.dart';
import 'package:yasmina/profils/avatar.dart';
import 'package:yasmina/profils/depot_profils.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

/// Lance l'app avec un stockage et une base en mémoire, après avoir créé
/// [profils] (un seul profil par défaut : l'accueil s'ouvre directement).
/// Les langues de l'appareil se règlent avec
/// `tester.platformDispatcher.localesTestValue`.
Future<DepotProfils> lancerApp(
  WidgetTester tester,
  StockageReglages stockage, {
  List<String> profils = const ['Lina'],
}) async {
  // closeStreamsSynchronously : sinon drift laisse un timer en attente à la
  // fermeture des flux, que le temps simulé de testWidgets ne déclenche pas.
  final base = BaseYasmina(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
  addTearDown(() async {
    // Démonter l'arbre avant de fermer la base (flux drift en cours).
    await tester.pumpWidget(const SizedBox());
    await base.close();
  });
  final depot = DepotProfils(base);
  for (final prenom in profils) {
    await depot.creer(
      prenom: prenom,
      niveau: 1,
      avatar: Avatar.fleur,
      formeAdresse: FormeAdresse.feminin,
    );
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        stockageReglagesProvider.overrideWithValue(stockage),
        baseYasminaProvider.overrideWithValue(base),
      ],
      child: const YasminaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return depot;
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
