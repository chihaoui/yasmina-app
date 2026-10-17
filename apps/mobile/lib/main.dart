import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'app/routeur.dart';
import 'donnees/base_yasmina.dart';
import 'donnees/providers.dart';
import 'l10n/app_localizations.dart';
import 'reglages/langue_interface.dart';
import 'reglages/stockage_reglages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  enregistrerLicencesPolices();
  final stockage = await StockageSharedPreferences.ouvrir();
  // SQLite embarqué par les build hooks de sqlite3 (iOS et Android).
  final base = BaseYasmina(driftDatabase(name: 'yasmina'));
  runApp(
    ProviderScope(
      overrides: [
        stockageReglagesProvider.overrideWithValue(stockage),
        baseYasminaProvider.overrideWithValue(base),
      ],
      child: const YasminaApp(),
    ),
  );
}

class YasminaApp extends ConsumerWidget {
  const YasminaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // La locale pose aussi le Directionality de toute l'interface.
    final langue = ref.watch(langueInterfaceProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitre,
      debugShowCheckedModeBanner: false,
      locale: langue.locale,
      theme: themeInterface(langue),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routeurProvider),
    );
  }
}

/// Thème de l'interface : Baloo Bhaijaan 2 en arabe, Andika en français,
/// l'autre écriture en secours. Les exercices gardent leur propre police
/// (LangueExercice).
ThemeData themeInterface(LangueInterface langue) {
  final arabe = langue == LangueInterface.ar;
  return ThemeData(
    fontFamily: arabe ? PolicesYasmina.interfaceArabe : PolicesYasmina.latin,
    fontFamilyFallback: [
      arabe ? PolicesYasmina.latin : PolicesYasmina.interfaceArabe,
    ],
  );
}
