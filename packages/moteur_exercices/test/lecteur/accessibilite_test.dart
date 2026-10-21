import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../moteurs/choix/outils_choix.dart';

/// Audit d'accessibilité des 52 types (A3, nettoyage) : chaque exemple du
/// catalogue joué dans le lecteur, en mode enfant puis réponse révélée en
/// aperçu, doit passer les règles de Flutter : chaque élément touchable a
/// une cible d'au moins 48 dp (règle Android, la plus stricte) et un
/// libellé pour le lecteur d'écran, et le texte tient le contraste du design
/// system (4,5:1, 3:1 en grand). Une image sans libellé neutre (décision 33)
/// ou une cible trop petite fait échouer le test.
void main() {
  final catalogue = CatalogueExemples();
  final exemples = catalogue.tous.where(
    (e) => e.idType != null && typeParId(e.idType!)?.etat == EtatType.jouable,
  );

  Future<void> auditer(WidgetTester tester, String chemin) async {
    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
      reason: chemin,
    );
    await expectLater(
      tester,
      meetsGuideline(labeledTapTargetGuideline),
      reason: chemin,
    );
    await expectLater(
      tester,
      meetsGuideline(textContrastGuideline),
      reason: chemin,
    );
  }

  for (final exemple in exemples) {
    testWidgets('${exemple.chemin} : cibles de 48 dp, libellés, contraste', (
      tester,
    ) async {
      // La sémantique est libérée à la fin du corps du test (contrôle de
      // flutter_test avant les tearDown).
      final semantique = tester.ensureSemantics();
      final p = Partie(tester);
      // Écran de téléphone : les cibles sont mesurées dans la mise en page
      // réelle, la zone de réponse défile.
      await p.jouer(exemple.exercice!, taille: const Size(390, 844));
      await tester.pumpAndSettle();
      await auditer(tester, '${exemple.chemin} (enfant)');

      await p.jouer(
        exemple.exercice!,
        mode: ModeExercice.apercu,
        taille: const Size(390, 844),
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pumpAndSettle();
      await auditer(tester, '${exemple.chemin} (réponse révélée)');
      semantique.dispose();
    });
  }
}
