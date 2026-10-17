import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'outils.dart';

void main() {
  Finder miroir() => find.descendant(
    of: find.byType(BoutonIcone),
    // Transform.flip(flipX: true) : premier coefficient de la matrice à -1.
    matching: find.byWidgetPredicate(
      (w) => w is Transform && w.transform.storage[0] == -1,
    ),
  );

  for (final (langue, libelle) in [('ar', 'اِسْمَعْ'), ('fr', 'Écouter')]) {
    testWidgets('$langue : libellé d\'accessibilité et cible de 48', (
      tester,
    ) async {
      await afficher(
        tester,
        langue,
        BoutonIcone(
          icone: Icons.volume_up_rounded,
          libelle: libelle,
          rond: true,
          onPressed: () {},
        ),
      );
      expect(find.byTooltip(libelle), findsOneWidget);
      final taille = tester.getSize(find.byType(IconButton));
      expect(taille.width, greaterThanOrEqualTo(EspacesYasmina.targetMin));
      expect(taille.height, greaterThanOrEqualTo(EspacesYasmina.targetMin));
      final icone = tester.widget<Icon>(find.byIcon(Icons.volume_up_rounded));
      expect(icone.color, CouleursYasmina.clair.blue);
    });
  }

  for (final icone in [Icons.chevron_left_rounded, Icons.undo_rounded]) {
    testWidgets('flèche en miroir en arabe, une seule fois, pas en français '
        '(matchTextDirection : ${icone.matchTextDirection})', (tester) async {
      Widget fleche() => BoutonIcone(
        icone: icone,
        libelle: 'retour',
        suitLeSens: true,
        onPressed: () {},
      );
      await afficher(tester, 'ar', fleche());
      expect(miroir(), findsOneWidget);
      await afficher(tester, 'fr', fleche());
      expect(miroir(), findsNothing);
    });
  }
}
