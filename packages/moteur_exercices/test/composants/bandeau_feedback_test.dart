import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../outils_polices.dart';
import 'outils.dart';

void main() {
  Widget trois() => const Column(
    key: ValueKey('bandeaux'),
    mainAxisSize: MainAxisSize.min,
    spacing: EspacesYasmina.space3,
    children: [
      BandeauFeedback(
        variante: VarianteFeedback.validation,
        libelle: 'أَحْسَنْتِ',
        texte: 'إِجَابَتُكِ صَحِيحَةٌ: «بَابٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ.',
      ),
      LangueExercice(
        langue: 'fr',
        child: BandeauFeedback(
          variante: VarianteFeedback.indice,
          libelle: 'Indice',
          texte: 'Relis le texte : de quelle couleur est le chat ?',
        ),
      ),
      BandeauFeedback(
        variante: VarianteFeedback.explication,
        libelle: 'لِنَتَعَلَّمْ',
        texte: 'الْكَلِمَةُ الصَّحِيحَةُ هِيَ «بَابٌ»: أَوَّلُ حَرْفٍ فِيهَا الْبَاءُ.',
      ),
    ],
  );

  testWidgets('couleurs des 3 temps, styles feedback, annoncé', (tester) async {
    await afficher(tester, 'ar', trois());
    final c = CouleursYasmina.clair;
    final fonds = tester
        .widgetList<ColoredBox>(
          find.descendant(
            of: find.byType(BandeauFeedback),
            matching: find.byType(ColoredBox),
          ),
        )
        .map((b) => b.color)
        .toList();
    expect(fonds, [
      c.oliveSoft,
      c.olive,
      c.amberSoft,
      c.amber,
      c.coralSoft,
      c.coral,
    ]);
    final texteAr = tester.widget<Text>(find.textContaining('إِجَابَتُكِ'));
    expect(texteAr.style!.fontSize, StylesYasmina.feedback.fontSize);
    expect(texteAr.style!.fontFamily, PolicesYasmina.interfaceArabe);
    final texteFr = tester.widget<Text>(find.textContaining('Relis'));
    expect(texteFr.style!.fontFamily, PolicesYasmina.latin);
    expect(
      tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(BandeauFeedback),
              matching: find.byType(Semantics),
            ),
          )
          .any((s) => s.properties.liveRegion ?? false),
      isTrue,
    );
  });

  testWidgets("le bord est du côté du début de ligne", (tester) async {
    await afficher(tester, 'ar', trois());
    final bandeau = find.byType(BandeauFeedback).first;
    final bord = find
        .descendant(of: bandeau, matching: find.byType(ColoredBox))
        .last;
    // En arabe, le début de ligne est à droite.
    expect(
      tester.getTopRight(bord).dx,
      closeTo(tester.getTopRight(bandeau).dx, 0.5),
    );
  });

  group('goldens', () {
    setUpAll(chargerPolicesMoteur);
    for (final (nom, luminosite) in [
      ('clair', Brightness.light),
      ('sombre', Brightness.dark),
    ]) {
      testWidgets('BandeauFeedback en $nom', (tester) async {
        tester.view.physicalSize = const Size(390, 420);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await afficher(tester, 'ar', trois(), luminosite: luminosite);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/bandeau_feedback_$nom.png'),
        );
      });
    }
  });
}
