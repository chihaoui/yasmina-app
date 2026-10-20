import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../glisser/outils_glisser.dart';
import 'fixtures_manipulables.dart';

/// T27 Blocs base 10 et T51 Cadre de 10 (docs/moteurs/manipulables.md) :
/// réserve inépuisable glissée (vrai geste) ou touchée, retrait au toucher,
/// plateau canonique, retour au départ après le 1er essai faux, révélation.
void main() {
  late Partie p;

  String compte(WidgetTester tester) =>
      tester.widget<Text>(p.cle('blocs_compte')).data!;

  group('T27 Blocs base 10', () {
    testWidgets('arabe : barres et cubes glissés sur le plateau, touchés, '
        'retirés, compte en clair, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T27-blocs-base-10.json'));
      expect(p.sens, TextDirection.rtl);
      // La réserve au début de ligne (à droite).
      expect(
        tester.getCenter(p.cle('reserve')).dx,
        greaterThan(tester.getCenter(p.cle('plateau')).dx),
      );
      expect(compte(tester), 'الْعَشَرَاتُ: 0 وَالْوَحَدَاتُ: 0');
      expect(p.bouton.onPressed, isNull);
      for (var i = 0; i < 3; i++) {
        await p.glisser('reserve_dizaine', 'plateau');
      }
      // La réserve reste en place : elle est inépuisable.
      expect(p.cle('reserve_dizaine'), findsOneWidget);
      expect(find.byKey(const ValueKey('dizaine_2')), findsOneWidget);
      await p.glisser('reserve_unite', 'plateau');
      await p.toucher('reserve_unite');
      await p.toucher('reserve_unite');
      await p.toucher('reserve_unite');
      await p.toucher('reserve_unite');
      expect(p.reponsesDonnees.last, {'dizaines': 3, 'unites': 5});
      expect(compte(tester), 'الْعَشَرَاتُ: 3 وَالْوَحَدَاتُ: 5');
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(8));
      // Toucher un cube posé le retire.
      await p.toucher('unite_4');
      expect(p.reponsesDonnees.last, {'dizaines': 3, 'unites': 4});
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('canonique : 10e unité refusée, faux puis tout revient au '
        'départ, faux deux fois révèle 3 barres et 4 cubes', (tester) async {
      p = Partie(tester);
      await p.jouer(
        exempleManipulables('T27-blocs-base-10.json'),
        forme: FormeAdresse.feminin,
      );
      for (var i = 0; i < 10; i++) {
        await p.toucher('reserve_unite');
      }
      expect(p.reponsesDonnees.last, {'dizaines': 0, 'unites': 9});
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(9));
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(compte(tester), 'الْعَشَرَاتُ: 0 وَالْوَحَدَاتُ: 0');
      expect(find.byType(Bloc), findsNWidgets(2));
      await p.toucher('reserve_dizaine');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.cle('manipulables_reponse'), findsOneWidget);
      expect(compte(tester), 'الْعَشَرَاتُ: 3 وَالْوَحَدَاتُ: 4');
      expect(find.text('وَاصِلِي'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });

    testWidgets('mode libre : 2 barres et 14 cubes acceptés', (tester) async {
      p = Partie(tester);
      await p.jouer(t27Libre());
      await p.toucher('reserve_dizaine');
      await p.toucher('reserve_dizaine');
      for (var i = 0; i < 14; i++) {
        await p.toucher('reserve_unite');
      }
      expect(p.reponsesDonnees.last, {'dizaines': 2, 'unites': 14});
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });
  });

  group('T51 Cadre de 10', () {
    testWidgets('arabe : jeton glissé dans une case, case touchée, réserve '
        'touchée, jeton retiré, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T51-cadre-de-10.json'));
      expect(p.sens, TextDirection.rtl);
      // Première case au début de ligne (à droite de la dernière).
      expect(
        tester.getCenter(p.cle('case_0')).dx,
        greaterThan(tester.getCenter(p.cle('case_4')).dx),
      );
      expect(find.byType(Jeton), findsOneWidget);
      await p.glisser('reserve_jeton', 'case_7');
      expect(p.cle('jeton_7'), findsOneWidget);
      expect(p.reponsesDonnees.last, {'jetons': 1});
      // Une case pleine ne reçoit plus.
      await p.glisser('reserve_jeton', 'case_7');
      expect(p.reponsesDonnees.last, {'jetons': 1});
      await p.toucher('case_3');
      // Toucher la réserve remplit la première case vide.
      await p.toucher('reserve_jeton');
      expect(p.cle('jeton_0'), findsOneWidget);
      expect(p.reponsesDonnees.last, {'jetons': 3});
      await p.toucher('jeton_7');
      expect(p.reponsesDonnees.last, {'jetons': 2});
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(3));
      for (final i in [1, 2, 4, 5, 6]) {
        await p.toucher('case_$i');
      }
      expect(p.reponsesDonnees.last, {'jetons': 7});
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('faux : les jetons reviennent, puis la réponse est révélée '
        'depuis le début de ligne, aperçu', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T51-cadre-de-10.json'));
      await p.toucher('case_0');
      await p.toucher('case_9');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(find.byType(Jeton), findsOneWidget);
      await p.toucher('case_5');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('manipulables_reponse'), findsOneWidget);
      for (var i = 0; i < 7; i++) {
        expect(p.cle('jeton_$i'), findsOneWidget);
      }
      expect(p.cle('jeton_7'), findsNothing);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));

      await p.jouer(
        exempleManipulables('T51-cadre-de-10.json'),
        mode: ModeExercice.apercu,
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(find.byType(Jeton), findsNWidgets(8));
      expect(find.text('juste'), findsOneWidget);
    });
  });
}
