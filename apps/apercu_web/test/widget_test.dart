import 'package:apercu_web/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  Future<void> lancer(WidgetTester tester) async {
    // Écran très haut : la liste déroulante des exemples (une ligne par
    // exemple du catalogue) tient entière à l'écran.
    tester.view.physicalSize = const Size(900, 4800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: ApercuApp()));
    await tester.pump();
  }

  testWidgets("l'aperçu web joue le premier exemple dans le cadre", (
    tester,
  ) async {
    await lancer(tester);
    expect(find.byType(CadreTelephone), findsOneWidget);
    expect(find.byType(LecteurExercice), findsOneWidget);
    // L'écran du cadre fait frame-width × frame-height.
    final ecran = tester.getSize(
      find.descendant(
        of: find.byType(CadreTelephone),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(
      ecran,
      const Size(TaillesYasmina.frameWidth, TaillesYasmina.frameHeight),
    );
    expect(cle('lecteur_afficher_reponse'), findsOneWidget);
  });

  group('parité web : chaque exemple d\'un type jouable', () {
    final exemples = CatalogueExemples().tous.where(
      (e) => typeParId(e.idType!)?.etat == EtatType.jouable,
    );
    for (final exemple in exemples) {
      testWidgets('${exemple.fichier} : joué, réponse révélée', (tester) async {
        await lancer(tester);
        await tester.tap(cle('apercu_exemple'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text('${exemple.idType}  ${exemple.fichier}').last,
        );
        await tester.pumpAndSettle();
        final lecteur = tester.widget<LecteurExercice>(
          find.byType(LecteurExercice),
        );
        expect(lecteur.exercice['id'], exemple.exercice!['id']);
        expect(lecteur.config.langue, exemple.langue);
        await tester.tap(cle('lecteur_afficher_reponse'));
        await tester.pump();
        final choixJustes = tester
            .widgetList<TuileChoix>(find.byType(TuileChoix))
            .where((t) => t.etat == EtatTuile.juste);
        final glissesJustes = tester
            .widgetList<TuileGlissable>(find.byType(TuileGlissable))
            .where((t) => t.etat == EtatGlissable.juste);
        // Droite numérique : le repère est sur la cible.
        final revele =
            cle('droite_reponse').evaluate().isNotEmpty ||
            cle('manipulables_reponse').evaluate().isNotEmpty ||
            cle('dictee_reponse').evaluate().isNotEmpty ||
            cle('saisie_reponse').evaluate().isNotEmpty ||
            cle('calcul_reponse').evaluate().isNotEmpty ||
            cle('scene_reponse').evaluate().isNotEmpty ||
            cle('grille_reponse').evaluate().isNotEmpty ||
            cle('simulateur_reponse').evaluate().isNotEmpty ||
            cle('recit_reponse').evaluate().isNotEmpty ||
            cle('jeux_reponse').evaluate().isNotEmpty ||
            tester
                .widgetList<MotTouchable>(find.byType(MotTouchable))
                .any((m) => m.etat == EtatMot.juste);
        expect(
          choixJustes.isNotEmpty || glissesJustes.isNotEmpty || revele,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
