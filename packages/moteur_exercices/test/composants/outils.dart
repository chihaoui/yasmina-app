import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Affiche [enfant] dans une app thémée en [langue] (`ar` : de droite à
/// gauche).
Future<void> afficher(
  WidgetTester tester,
  String langue,
  Widget enfant, {
  Brightness luminosite = Brightness.light,
}) => tester.pumpWidget(
  MaterialApp(
    locale: Locale(langue),
    supportedLocales: const [Locale('ar'), Locale('fr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeYasmina.theme(langue: langue, luminosite: luminosite),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        child: Center(child: enfant),
      ),
    ),
  ),
);
