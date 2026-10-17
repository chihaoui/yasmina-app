import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  const cible = ValueKey('cible');

  /// Place un exercice en [langueExercice] dans une interface en
  /// [langueInterface] (locale et sens d'écriture de l'interface).
  Future<void> afficher(
    WidgetTester tester, {
    required String langueInterface,
    required String langueExercice,
  }) {
    return tester.pumpWidget(
      Localizations(
        locale: Locale(langueInterface),
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: Directionality(
          textDirection: LangueExercice.directionDe(langueInterface),
          child: LangueExercice(
            langue: langueExercice,
            child: const SizedBox(key: cible),
          ),
        ),
      ),
    );
  }

  BuildContext contexte(WidgetTester tester) =>
      tester.element(find.byKey(cible));

  testWidgets('exercice arabe dans une interface française : rtl et ar', (
    tester,
  ) async {
    await afficher(tester, langueInterface: 'fr', langueExercice: 'ar');
    expect(Directionality.of(contexte(tester)), TextDirection.rtl);
    expect(Localizations.localeOf(contexte(tester)), const Locale('ar'));
  });

  testWidgets('exercice français dans une interface arabe : ltr et fr', (
    tester,
  ) async {
    await afficher(tester, langueInterface: 'ar', langueExercice: 'fr');
    expect(Directionality.of(contexte(tester)), TextDirection.ltr);
    expect(Localizations.localeOf(contexte(tester)), const Locale('fr'));
  });

  testWidgets('exercice anglais dans une interface arabe : ltr et en', (
    tester,
  ) async {
    await afficher(tester, langueInterface: 'ar', langueExercice: 'en');
    expect(Directionality.of(contexte(tester)), TextDirection.ltr);
    expect(Localizations.localeOf(contexte(tester)), const Locale('en'));
  });

  testWidgets("la police suit la langue de l'exercice, pas l'interface", (
    tester,
  ) async {
    await afficher(tester, langueInterface: 'fr', langueExercice: 'ar');
    expect(
      DefaultTextStyle.of(contexte(tester)).style.fontFamily,
      PolicesYasmina.contenuArabe,
    );
    await afficher(tester, langueInterface: 'ar', langueExercice: 'fr');
    expect(
      DefaultTextStyle.of(contexte(tester)).style.fontFamily,
      PolicesYasmina.latin,
    );
  });

  testWidgets('sans Localizations au-dessus : le sens suit quand même', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: LangueExercice(
          langue: 'ar',
          child: SizedBox(key: cible),
        ),
      ),
    );
    expect(Directionality.of(contexte(tester)), TextDirection.rtl);
  });
}
