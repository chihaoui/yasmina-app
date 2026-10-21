import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/parent/porte_parentale.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';
import '../parcours/fixtures_parcours.dart';

/// Audit d'accessibilité des écrans du parcours et de l'espace parent
/// (A3, nettoyage) : cibles d'au moins 48 dp, libellés pour le lecteur
/// d'écran, contraste du design system, en arabe et en français.
void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  Future<void> auditer(WidgetTester tester, String ecran) async {
    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
      reason: ecran,
    );
    await expectLater(
      tester,
      meetsGuideline(labeledTapTargetGuideline),
      reason: ecran,
    );
    await expectLater(
      tester,
      meetsGuideline(textContrastGuideline),
      reason: ecran,
    );
  }

  for (final langue in ['ar', 'fr']) {
    testWidgets('écrans enfant et parent en $langue', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final semantique = tester.ensureSemantics();
      await lancerApp(
        tester,
        StockageMemoire(langue),
        profils: ['Lina', 'Yassine'],
        catalogue: catalogueTest(),
        surcharges: [
          questionPorteProvider.overrideWithValue(const QuestionPorte(6, 7)),
        ],
      );
      await auditer(tester, 'qui joue');

      await tester.tap(find.text('Lina'));
      await tester.pumpAndSettle();
      await auditer(tester, 'accueil');

      await tester.tap(cle('matiere_ar'));
      await tester.pumpAndSettle();
      await auditer(tester, 'carte');

      await tester.tap(cle('etape_ar-1-t1-u1-e01'));
      await tester.pumpAndSettle();
      await auditer(tester, 'intro');

      await tester.tap(cle('intro_commencer'));
      await tester.pumpAndSettle();
      await auditer(tester, 'étape jouée');

      // Espace parent depuis « Qui joue ? ».
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
      await tester.tap(cle('profil_changer'));
      await tester.pumpAndSettle();
      await tester.tap(cle('espace_parent_ouvrir'));
      await tester.pumpAndSettle();
      await auditer(tester, 'porte parentale');
      await tester.enterText(cle('porte_reponse'), '42');
      await tester.tap(cle('porte_entrer'));
      await tester.pumpAndSettle();
      await auditer(tester, 'espace parent');
      semantique.dispose();
    });
  }
}
