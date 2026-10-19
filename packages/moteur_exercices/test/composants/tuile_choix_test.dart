import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'outils.dart';

void main() {
  ShapeBorder forme(WidgetTester tester) => tester
      .widget<Material>(
        find.descendant(
          of: find.byType(TuileChoix),
          matching: find.byType(Material),
        ),
      )
      .shape!;

  Color fond(WidgetTester tester) => tester
      .widget<Material>(
        find.descendant(
          of: find.byType(TuileChoix),
          matching: find.byType(Material),
        ),
      )
      .color!;

  testWidgets('les 4 états : fond et bordure du design system', (tester) async {
    final c = CouleursYasmina.clair;
    for (final (etat, couleurFond, couleurBord) in [
      (EtatTuile.repos, c.tile, c.line),
      (EtatTuile.selectionne, c.blueSoft, c.blue),
      (EtatTuile.juste, c.oliveSoft, c.olive),
      (EtatTuile.faux, c.coralSoft, c.coral),
    ]) {
      await afficher(tester, 'fr', TuileChoix(etat: etat, texte: 'Vrai'));
      expect(fond(tester), couleurFond, reason: etat.name);
      final cote = (forme(tester) as RoundedRectangleBorder).side;
      expect(cote.color, couleurBord, reason: etat.name);
      expect(cote.width, TraitsYasmina.borderThick);
    }
  });

  testWidgets('cible de 48 et hauteur de choix, toucher', (tester) async {
    var touches = 0;
    await afficher(
      tester,
      'ar',
      TuileChoix(
        etat: EtatTuile.repos,
        texte: 'صَحِيحٌ',
        onTap: () => touches++,
      ),
    );
    final taille = tester.getSize(find.byType(TuileChoix));
    expect(taille.height, greaterThanOrEqualTo(TaillesYasmina.choiceMinHeight));
    expect(taille.width, greaterThanOrEqualTo(EspacesYasmina.targetMin));
    await tester.tap(find.byType(TuileChoix));
    expect(touches, 1);
    final texte = tester.widget<Text>(find.text('صَحِيحٌ'));
    expect(texte.style!.fontFamily, PolicesYasmina.contenuArabe);
  });

  testWidgets('sémantique : sélectionnée, libellé neutre pour un emoji seul', (
    tester,
  ) async {
    final poignee = tester.ensureSemantics();
    await afficher(
      tester,
      'fr',
      const TuileChoix(
        etat: EtatTuile.selectionne,
        emoji: '🐱',
        libelleAccessibilite: 'image 2',
        motEtat: 'juste',
      ),
    );
    expect(
      tester.getSemantics(find.byType(TuileChoix)),
      matchesSemantics(
        label: 'image 2',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
      ),
    );
    expect(find.text('juste'), findsOneWidget);
    poignee.dispose();
  });

  testWidgets(
    'texte en latin-prompt en français (texte court lu par l\'enfant)',
    (tester) async {
      await afficher(
        tester,
        'fr',
        const TuileChoix(etat: EtatTuile.repos, texte: 'Vrai'),
      );
      final texte = tester.widget<Text>(find.text('Vrai'));
      expect(texte.style!.fontFamily, PolicesYasmina.latin);
      expect(texte.style!.fontSize, StylesYasmina.latinPrompt.fontSize);
      expect(texte.style!.fontWeight, StylesYasmina.latinPrompt.fontWeight);
    },
  );
}
