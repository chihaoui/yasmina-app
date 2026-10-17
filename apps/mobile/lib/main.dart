import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'l10n/app_localizations.dart';
import 'reglages/langue_interface.dart';
import 'reglages/stockage_reglages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final stockage = await StockageSharedPreferences.ouvrir();
  runApp(
    ProviderScope(
      overrides: [stockageReglagesProvider.overrideWithValue(stockage)],
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
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitre,
      debugShowCheckedModeBanner: false,
      locale: langue.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(
        body: Center(child: CarteDemo(langue: 'ar')),
      ),
    );
  }
}
