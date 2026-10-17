import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

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

class YasminaApp extends StatelessWidget {
  const YasminaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Yasmina',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: CarteDemo(langue: 'ar')),
      ),
    );
  }
}
