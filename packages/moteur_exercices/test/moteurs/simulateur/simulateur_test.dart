import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_simulateur.dart';

/// T57 Simulateur d'expérience et T34 Flotte ou coule
/// (docs/moteurs/simulateur.md) : prédire, observer, expliquer, cas arabe
/// et cas latin, déroulé automatique.
void main() {
  late Partie p;

  Color bordIssue(WidgetTester tester, String objet, String code) =>
      (tester.widget<Material>(p.cle('issue_${objet}_$code')).shape!
              as RoundedRectangleBorder)
          .side
          .color;

  group('T34 Flotte ou coule', () {
    testWidgets('arabe : prédictions par objet, Observer actif quand tout '
        'est prédit, cuve d\'eau, tout juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSimulateur('T34-flotte-coule.json'));
      expect(p.sens, TextDirection.rtl);
      // Mode automatique : aucun bouton du lecteur avant la fin.
      expect(p.cle('lecteur_bouton'), findsNothing);
      expect(p.cle('observation'), findsNothing);
      expect(
        tester.widget<BoutonYasmina>(p.cle('simulateur_observer')).onPressed,
        isNull,
      );
      await p.toucher('issue_o1_a');
      expect(bordIssue(tester, 'o1', 'a'), CouleursYasmina.clair.blue);
      // Changer d'avis.
      await p.toucher('issue_o1_b');
      expect(bordIssue(tester, 'o1', 'a'), CouleursYasmina.clair.line);
      await p.toucher('issue_o1_a');
      expect(p.reponsesDonnees.last, {
        'predictions': [
          {'objet': 'o1', 'issue': 'a'},
        ],
      });
      await p.toucher('issue_o2_b');
      await p.toucher('issue_o3_b');
      expect(
        tester.widget<BoutonYasmina>(p.cle('simulateur_observer')).onPressed,
        isNull,
      );
      await p.toucher('issue_o4_a');
      expect(
        tester.widget<BoutonYasmina>(p.cle('simulateur_observer')).onPressed,
        isNotNull,
      );
      await p.toucher('simulateur_observer');
      await tester.pumpAndSettle();
      // La cuve : les objets observés, les prédictions figées en juste.
      expect(p.cle('observation'), findsOneWidget);
      expect(p.cle('observe_o1'), findsOneWidget);
      expect(bordIssue(tester, 'o1', 'a'), CouleursYasmina.clair.olive);
      expect(find.text('✔'), findsNWidgets(4));
      expect(p.cle('simulateur_observer'), findsNothing);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.bouton.libelle, 'وَاصِلْ');
    });
  });

  group('T57 Simulateur d\'expérience', () {
    testWidgets('arabe, circuit : une prédiction fausse, observation puis '
        'explication', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSimulateur('T57-circuit.json'));
      await p.toucher('issue_o1_a');
      await p.toucher('issue_o2_b'); // faux : le fer conduit
      await p.toucher('issue_o3_b');
      await p.toucher('issue_o4_b');
      await p.toucher('simulateur_observer');
      await tester.pumpAndSettle();
      expect(bordIssue(tester, 'o2', 'b'), CouleursYasmina.clair.coral);
      expect(find.text('✘'), findsOneWidget);
      expect(find.text('✔'), findsNWidgets(3));
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 1));
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      // Après l'observation, les prédictions sont figées.
      await p.toucher('issue_o2_a');
      expect(bordIssue(tester, 'o2', 'b'), CouleursYasmina.clair.coral);
    });

    testWidgets('français, sans décor : issues écrites, aperçu révèle les '
        'issues réelles', (tester) async {
      p = Partie(tester);
      await p.jouer(t57Francais());
      expect(p.sens, TextDirection.ltr);
      await p.toucher('issue_o1_a');
      await p.toucher('issue_o2_b');
      await p.toucher('simulateur_observer');
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
      expect(find.text('fond'), findsWidgets);

      await p.jouer(t57Francais(), mode: ModeExercice.apercu);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('simulateur_reponse'), findsOneWidget);
      expect(bordIssue(tester, 'o1', 'a'), CouleursYasmina.clair.olive);
      expect(bordIssue(tester, 'o2', 'b'), CouleursYasmina.clair.olive);
      expect(find.text('juste'), findsOneWidget);
    });
  });
}
