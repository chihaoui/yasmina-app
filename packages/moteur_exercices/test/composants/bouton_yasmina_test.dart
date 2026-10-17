import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'outils.dart';

void main() {
  BoxDecoration decoration(WidgetTester tester) =>
      tester
              .widget<AnimatedContainer>(
                find.byKey(const ValueKey('bouton_yasmina_corps')),
              )
              .decoration!
          as BoxDecoration;

  final cas = {
    'ar': ('تَحَقَّقْ', PolicesYasmina.interfaceArabe),
    'fr': ('Vérifier', PolicesYasmina.latin),
  };

  cas.forEach((langue, attendu) {
    final (libelle, police) = attendu;

    testWidgets('$langue : le relief disparaît pendant l\'appui', (
      tester,
    ) async {
      var appuis = 0;
      await afficher(
        tester,
        langue,
        BoutonYasmina(libelle: libelle, onPressed: () => appuis++),
      );
      expect(decoration(tester).boxShadow, [OmbresYasmina.shadowPress]);

      final geste = await tester.startGesture(
        tester.getCenter(find.text(libelle)),
      );
      await tester.pumpAndSettle();
      expect(decoration(tester).boxShadow, isNull);

      await geste.up();
      await tester.pumpAndSettle();
      expect(decoration(tester).boxShadow, [OmbresYasmina.shadowPress]);
      expect(appuis, 1);
    });

    testWidgets('$langue : libellé lu, police de la langue, cible de 48', (
      tester,
    ) async {
      await afficher(
        tester,
        langue,
        BoutonYasmina(libelle: libelle, onPressed: () {}),
      );
      expect(find.bySemanticsLabel(libelle), findsOneWidget);
      final texte = tester.widget<Text>(find.text(libelle));
      expect(texte.style!.fontFamily, police);
      expect(texte.style!.fontSize, StylesYasmina.buttonCta.fontSize);
      final taille = tester.getSize(
        find.byKey(const ValueKey('bouton_yasmina_corps')),
      );
      expect(taille.height, greaterThanOrEqualTo(EspacesYasmina.targetMin));
    });
  });

  testWidgets('variantes : bleu, vert et alt (sans relief, bordure blue)', (
    tester,
  ) async {
    final c = CouleursYasmina.clair;
    for (final (variante, fond) in [
      (VarianteBouton.bleu, c.blue),
      (VarianteBouton.vert, c.olive),
      (VarianteBouton.alt, c.surface),
    ]) {
      await afficher(
        tester,
        'ar',
        BoutonYasmina(libelle: 'هَيَّا', onPressed: () {}, variante: variante),
      );
      expect(decoration(tester).color, fond, reason: variante.name);
    }
    expect(decoration(tester).boxShadow, isNull);
    expect(decoration(tester).border, isNotNull);
  });

  testWidgets('désactivé : fond line, sans relief', (tester) async {
    await afficher(
      tester,
      'fr',
      const BoutonYasmina(libelle: 'Vérifier', onPressed: null),
    );
    expect(decoration(tester).color, CouleursYasmina.clair.line);
    expect(decoration(tester).boxShadow, isNull);
  });

  testWidgets('anneau de focus en blue au clavier', (tester) async {
    await afficher(
      tester,
      'fr',
      BoutonYasmina(libelle: 'Vérifier', onPressed: () {}),
    );
    expect(find.byKey(const ValueKey('bouton_yasmina_focus')), findsNothing);
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bouton_yasmina_focus')), findsOneWidget);
  });
}
