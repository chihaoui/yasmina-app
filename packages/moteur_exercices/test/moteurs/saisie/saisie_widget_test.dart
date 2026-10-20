import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_saisie.dart';

/// T22 Saisie numérique et T48 Calcul posé (docs/moteurs/saisie-numerique.md).
void main() {
  late Partie p;

  String valeur(WidgetTester tester) =>
      tester.widget<Text>(p.cle('saisie_valeur')).data!;

  String caseTexte(WidgetTester tester, int i) => tester
      .widget<Text>(
        find.descendant(of: p.cle('case_$i'), matching: find.byType(Text)),
      )
      .data!;

  group('T22 Saisie numérique', () {
    testWidgets('arabe : problème dit après la consigne, pavé de gauche à '
        'droite, limite de chiffres, Effacer, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSaisie('T22-probleme.json'));
      expect(p.sens, TextDirection.rtl);
      expect(
        p.audio.audioFactice.dits.map((d) => d.texte).last,
        startsWith('فِي السَّلَّةِ'),
      );
      expect(p.cle('saisie_emoji'), findsOneWidget);
      expect(
        tester.getCenter(p.cle('touche_1')).dx,
        lessThan(tester.getCenter(p.cle('touche_3')).dx),
      );
      expect(p.bouton.onPressed, isNull);
      await p.toucher('touche_2');
      await p.toucher('touche_7');
      await p.toucher('touche_1');
      expect(valeur(tester), '271');
      // 4e chiffre ignoré (chiffres_max 3).
      await p.toucher('touche_5');
      expect(valeur(tester), '271');
      expect(p.reponsesDonnees.last, {'valeur': 271});
      await p.toucher('touche_effacer');
      expect(valeur(tester), '27');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('chiffres orientaux et unité, tolérance, faux puis vidé, '
        'révélation', (tester) async {
      p = Partie(tester);
      await p.jouer(t22Orientaux(), forme: FormeAdresse.feminin);
      expect(find.text('٣'), findsOneWidget);
      await p.toucher('touche_9');
      expect(valeur(tester), '٩ د');
      expect(p.reponsesDonnees.last, {'valeur': 9});
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(valeur(tester).trim(), 'د');
      // Tolérance 1 : 13 accepté pour 12.
      await p.toucher('touche_1');
      await p.toucher('touche_3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتِ'), findsOneWidget);

      await p.jouer(t22Orientaux());
      await p.toucher('touche_5');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('touche_6');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('saisie_reponse'), findsOneWidget);
      expect(valeur(tester), '١٢ د');
    });
  });

  group('T48 Calcul posé', () {
    testWidgets('addition : unités à droite, chiffres des unités vers les '
        'dizaines, case active, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSaisie('T48-addition-posee.json'));
      expect(
        tester.getCenter(p.cle('case_0')).dx,
        greaterThan(tester.getCenter(p.cle('case_1')).dx),
      );
      expect(caseTexte(tester, 0), '');
      await p.toucher('touche_9');
      expect(caseTexte(tester, 0), '9');
      expect(p.reponsesDonnees.last, {'valeur': 9});
      await p.toucher('touche_5');
      expect(caseTexte(tester, 1), '5');
      expect(p.reponsesDonnees.last, {'valeur': 59});
      // Tout est rempli : un chiffre de plus est ignoré.
      await p.toucher('touche_2');
      expect(p.reponsesDonnees.last, {'valeur': 59});
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('soustraction : faux puis vidé, Effacer, faux deux fois '
        'révèle le résultat', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleSaisie('T48-soustraction-posee.json'));
      await p.toucher('touche_3');
      await p.toucher('touche_4');
      expect(p.reponsesDonnees.last, {'valeur': 43});
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(caseTexte(tester, 0), '');
      await p.toucher('touche_4');
      await p.toucher('touche_4');
      await p.toucher('touche_effacer');
      await p.toucher('touche_2');
      expect(p.reponsesDonnees.last, {'valeur': 24});
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('calcul_reponse'), findsOneWidget);
      expect(caseTexte(tester, 0), '4');
      expect(caseTexte(tester, 1), '3');
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });

    testWidgets('sens gauche-droite, chiffres orientaux, retenues, aperçu', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t48GaucheDroite(), mode: ModeExercice.apercu);
      expect(
        tester.getCenter(p.cle('case_0')).dx,
        lessThan(tester.getCenter(p.cle('case_1')).dx),
      );
      expect(p.cle('case_2'), findsOneWidget);
      expect(find.text('٧'), findsWidgets);
      await p.toucher('retenue_1');
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: p.cle('retenue_1'),
                matching: find.byType(Text),
              ),
            )
            .data,
        '١',
      );
      await p.toucher('retenue_1');
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: p.cle('retenue_1'),
                matching: find.byType(Text),
              ),
            )
            .data,
        '',
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('calcul_reponse'), findsOneWidget);
      expect(caseTexte(tester, 0), '٤');
      expect(caseTexte(tester, 1), '٢');
      expect(caseTexte(tester, 2), '١');
      expect(find.text('juste'), findsOneWidget);
    });
  });
}
