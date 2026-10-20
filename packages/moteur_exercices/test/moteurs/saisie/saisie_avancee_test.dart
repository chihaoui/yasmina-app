import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_saisie.dart';

/// T49 Saisie de fraction, T50 Fluidité chronométrée et T63 Balance
/// d'équivalence (docs/moteurs/saisie-numerique.md §14) : pavé, cas arabe
/// et cas latin, déroulé complet.
void main() {
  late Partie p;

  String texteDe(WidgetTester tester, String cle) =>
      tester.widget<Text>(p.cle(cle)).data!;

  String caseTexte(WidgetTester tester, String cle) => tester
      .widget<Text>(
        find.descendant(of: p.cle(cle), matching: find.byType(Text)),
      )
      .data!;

  Color bordCase(WidgetTester tester, String cle) =>
      (tester.widget<Material>(p.cle(cle)).shape! as RoundedRectangleBorder)
          .side
          .color;

  double inclinaison(WidgetTester tester, String cle) =>
      (tester.widget<CustomPaint>(p.cle(cle)).painter! as PeintreBalance)
          .inclinaison;

  group('T49 Saisie de fraction', () {
    testWidgets('arabe : numérateur puis dénominateur au pavé, cases '
        'activées au toucher, fraction équivalente acceptée', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSaisie('T49-saisie-fraction.json'));
      expect(p.sens, TextDirection.rtl);
      expect(p.cle('pave'), findsOneWidget);
      expect(bordCase(tester, 'case_numerateur'), CouleursYasmina.clair.blue);
      expect(p.bouton.onPressed, isNull);
      await p.toucher('touche_6');
      expect(caseTexte(tester, 'case_numerateur'), '6');
      expect(p.bouton.onPressed, isNull);
      await p.toucher('case_denominateur');
      expect(bordCase(tester, 'case_denominateur'), CouleursYasmina.clair.blue);
      await p.toucher('touche_8');
      expect(caseTexte(tester, 'case_denominateur'), '8');
      expect(p.reponsesDonnees.last, {'numerateur': 6, 'denominateur': 8});
      // Effacer agit sur le champ actif, puis revient au numérateur.
      await p.toucher('touche_effacer');
      expect(caseTexte(tester, 'case_denominateur'), '');
      await p.toucher('touche_effacer');
      expect(caseTexte(tester, 'case_numerateur'), '');
      await p.toucher('touche_6');
      await p.toucher('case_denominateur');
      await p.toucher('touche_8');
      expect(p.bouton.onPressed, isNotNull);
      // 6/8 vaut 3/4 : accepté.
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('français, fraction exacte exigée : 6/8 faux puis vidé, '
        'faux deux fois révèle 3/4', (tester) async {
      p = Partie(tester);
      await p.jouer(t49Exacte());
      expect(p.sens, TextDirection.ltr);
      await p.toucher('touche_6');
      await p.toucher('case_denominateur');
      await p.toucher('touche_8');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(caseTexte(tester, 'case_numerateur'), '');
      expect(caseTexte(tester, 'case_denominateur'), '');
      await p.toucher('touche_1');
      await p.toucher('case_denominateur');
      await p.toucher('touche_4');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('saisie_reponse'), findsOneWidget);
      expect(caseTexte(tester, 'case_numerateur'), '3');
      expect(caseTexte(tester, 'case_denominateur'), '4');
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T50 Fluidité chronométrée', () {
    /// Réponse d'un énoncé « a + ? = c ».
    int complement(String enonce) {
      final nombres = RegExp(r'\d+')
          .allMatches(enonce)
          .map((m) => int.parse(m.group(0)!))
          .toList();
      return nombres.last - nombres.first;
    }

    testWidgets('arabe : départ au bouton, chronomètre, réponses touchées, '
        'une fausse marquée un instant, fin du temps, score, sans note', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleSaisie('T50-fluidite.json'));
      expect(p.bouton.libelle, 'وَاصِلْ');
      expect(p.bouton.onPressed, isNull);
      expect(p.cle('fluidite_question'), findsNothing);
      await p.toucher('fluidite_demarrer');
      expect(texteDe(tester, 'fluidite_chrono'), '30 ثَانِيَةٌ');
      expect(p.cle('fluidite_question'), findsOneWidget);
      expect(find.byType(TuileChoix), findsNWidgets(3));
      // Bonne réponse : son depot, nouvelle question.
      final enonce = texteDe(tester, 'fluidite_question');
      await p.toucher('option_${complement(enonce)}');
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      expect(p.reponsesDonnees.last, {'justes': 1, 'total': 1});
      // Mauvaise réponse : marquée un instant, comptée, puis nouvelle
      // question.
      final enonce2 = texteDe(tester, 'fluidite_question');
      final bonne = complement(enonce2);
      final options = tester
          .widgetList<TuileChoix>(find.byType(TuileChoix))
          .map((t) => int.parse(t.texte!))
          .toList();
      final mauvaise = options.firstWhere((o) => o != bonne);
      await p.toucher('option_$mauvaise');
      expect(
        tester.widget<TuileChoix>(p.cle('option_$mauvaise')).etat,
        EtatTuile.faux,
      );
      expect(p.audio.audioFactice.sons.last, SonInterface.essaiFaux);
      expect(p.reponsesDonnees.last, {'justes': 1, 'total': 2});
      await p.attendreVidage();
      // Le chronomètre descend, puis le temps s'écoule.
      await tester.pump(const Duration(seconds: 1));
      expect(texteDe(tester, 'fluidite_chrono'), '29 ثَانِيَةٌ');
      await tester.pump(const Duration(seconds: 30));
      expect(p.cle('fluidite_question'), findsNothing);
      expect(texteDe(tester, 'fluidite_score'), 'النَّتِيجَةُ: 1 مِنْ 2');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.termine, essais: 0));
      expect(find.byType(BandeauFeedback), findsNothing);
    });

    testWidgets('français, additions sans chronomètre : trois questions puis '
        'le score, Stop possible', (tester) async {
      p = Partie(tester);
      await p.jouer(t50SansChrono());
      await p.toucher('fluidite_demarrer');
      expect(p.cle('fluidite_chrono'), findsNothing);
      for (var i = 0; i < 3; i++) {
        final enonce = texteDe(tester, 'fluidite_question');
        final nombres = RegExp(r'\d+')
            .allMatches(enonce)
            .map((m) => int.parse(m.group(0)!))
            .toList();
        await p.toucher('option_${nombres[0] + nombres[1]}');
      }
      expect(texteDe(tester, 'fluidite_score'), 'Score : 3 sur 3');
      expect(p.bouton.onPressed, isNotNull);

      await p.jouer(t50SansChrono());
      await p.toucher('fluidite_demarrer');
      await p.toucher('fluidite_arreter');
      expect(p.cle('fluidite_score'), findsOneWidget);
      // Aucune question répondue : Continuer attend questions_min (1).
      expect(p.bouton.onPressed, isNull);
    });
  });

  group('T63 Balance d\'équivalence', () {
    testWidgets('arabe : la balance penche vers la droite (sac vide), se '
        'redresse avec la bonne masse, faux puis vidé, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSaisie('T63-balance.json'));
      expect(inclinaison(tester, 'balance_dessin'), greaterThan(0));
      expect(p.bouton.onPressed, isNull);
      await p.toucher('touche_9');
      // 9 + 4 à gauche contre 9 à droite : penche à gauche.
      expect(inclinaison(tester, 'balance_dessin'), lessThan(0));
      expect(p.reponsesDonnees.last, {'valeur': 9});
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(inclinaison(tester, 'balance_dessin'), greaterThan(0));
      await p.toucher('touche_5');
      expect(inclinaison(tester, 'balance_dessin'), 0);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français, sac à droite : faux deux fois révèle la masse, '
        'balance à l\'équilibre', (tester) async {
      p = Partie(tester);
      await p.jouer(t63SacADroite());
      expect(inclinaison(tester, 'balance_dessin'), lessThan(0));
      await p.toucher('touche_1');
      await p.verifier();
      await p.attendreVidage();
      // 3 : trop lourd à droite, la balance penche à droite.
      await p.toucher('touche_3');
      expect(inclinaison(tester, 'balance_dessin'), greaterThan(0));
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('saisie_reponse'), findsOneWidget);
      expect(inclinaison(tester, 'saisie_reponse'), 0);
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });
}
