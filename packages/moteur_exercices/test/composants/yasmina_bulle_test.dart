import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'outils.dart';

void main() {
  String assetAffiche(WidgetTester tester) =>
      (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
              as SvgAssetLoader)
          .assetName;

  testWidgets('les 3 humeurs affichent leur SVG', (tester) async {
    for (final humeur in HumeurYasmina.values) {
      await afficher(tester, 'ar', Yasmina(humeur: humeur));
      expect(assetAffiche(tester), humeur.asset);
    }
    expect(HumeurYasmina.values.map((h) => h.fichier), [
      'yasmina-neutral.svg',
      'yasmina-bravo.svg',
      'yasmina-encourage.svg',
    ]);
  });

  testWidgets('les SVG du moteur se chargent sans erreur', (tester) async {
    for (final humeur in HumeurYasmina.values) {
      await afficher(tester, 'fr', Yasmina(humeur: humeur));
      await tester.runAsync(
        () =>
            DefaultAssetBundle.of(tester.element(find.byType(Yasmina)))
                .load('packages/moteur_exercices/${humeur.asset}'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  final cas = {
    'ar': ('مَرْحَبًا يَا لِينَا!', PolicesYasmina.interfaceArabe),
    'fr': ('Bonjour Lina !', PolicesYasmina.latin),
  };
  cas.forEach((langue, attendu) {
    final (texte, police) = attendu;
    testWidgets('$langue : bulle, sous-titre et taille de Yasmina', (
      tester,
    ) async {
      await afficher(
        tester,
        langue,
        YasminaBulle(
          texte: texte,
          sousTitre: 'Yasmina',
          humeur: HumeurYasmina.bravo,
          taille: TaillesYasmina.yasminaReader,
        ),
      );
      final bulle = tester.widget<Text>(find.text(texte));
      expect(bulle.style!.fontFamily, police);
      expect(bulle.style!.fontSize, StylesYasmina.bubble.fontSize);
      final sousTitre = tester.widget<Text>(find.text('Yasmina'));
      expect(sousTitre.style!.color, CouleursYasmina.clair.muted);
      final taille = tester.getSize(find.byType(Yasmina));
      expect(taille.width, closeTo(TaillesYasmina.yasminaReader, 0.01));
      expect(taille.height, closeTo(TaillesYasmina.yasminaReader, 0.01));
      expect(assetAffiche(tester), HumeurYasmina.bravo.asset);
    });
  });
}
