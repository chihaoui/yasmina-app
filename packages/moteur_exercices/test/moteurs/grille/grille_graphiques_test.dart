import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_grille.dart';

/// T31 Lire un graphique, T32 Construire un graphique, T33 Symétrie et T60
/// Codage de déplacement (docs/moteurs/grille-graphiques.md) : barres
/// touchées, cellules touchées, cases du quadrillage, programme de flèches
/// joué, cas arabe et cas latin, déroulé complet.
void main() {
  late Partie p;

  /// Couleur de fond d'une case du quadrillage (la clé est sur la cible de
  /// toucher, le conteneur est dedans).
  Color couleurCase(WidgetTester tester, String cle) =>
      (tester
                  .widget<Container>(
                    find.descendant(
                      of: p.cle(cle),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration)
          .color!;

  group('T31 Lire un graphique', () {
    testWidgets('arabe : barres de gauche à droite, barre touchée, faux puis '
        'vidé, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleGrille('T31-lire-graphique.json'));
      expect(p.sens, TextDirection.rtl);
      // Les colonnes gardent l'ordre du JSON de gauche à droite.
      expect(
        tester.getCenter(p.cle('barre_s1')).dx,
        lessThan(tester.getCenter(p.cle('barre_s4')).dx),
      );
      // La barre la plus haute est la plus grande valeur (la colonne entière
      // est touchable, la barre est le conteneur dedans).
      double hauteurBarre(String id) => tester
          .getSize(
            find.descendant(
              of: p.cle('barre_$id'),
              matching: find.byType(Container),
            ),
          )
          .height;
      expect(hauteurBarre('s2'), greaterThan(hauteurBarre('s1')));
      expect(p.bouton.onPressed, isNull);
      await p.toucher('barre_s1');
      expect(p.reponsesDonnees.last, {'serie': 's1'});
      await p.toucher('barre_s4');
      expect(p.reponsesDonnees.last, {'serie': 's4'});
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(p.bouton.onPressed, isNull);
      await p.toucher('barre_s2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français, la plus petite : faux deux fois révèle la barre', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t31Moins());
      await p.toucher('barre_s1');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('barre_s1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('grille_reponse'), findsOneWidget);
      expect(
        tester.widget<GraphiqueBarres>(p.cle('grille_reponse')).choisie,
        's2',
      );
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T32 Construire un graphique', () {
    testWidgets('arabe : tableau, cellule touchée monte la barre, le sommet '
        'retouché la baisse, seules les barres fausses redescendent, juste', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleGrille('T32-construire-graphique.json'));
      expect(p.cle('tableau'), findsOneWidget);
      expect(find.text('5'), findsWidgets);
      expect(p.bouton.onPressed, isNull);
      await p.toucher('cellule_s1_3');
      expect(p.reponsesDonnees.last, {
        'valeurs': [
          {'serie': 's1', 'valeur': 3},
          {'serie': 's2', 'valeur': 0},
          {'serie': 's3', 'valeur': 0},
        ],
      });
      // Le sommet retouché baisse d'un cran.
      await p.toucher('cellule_s1_3');
      expect((p.reponsesDonnees.last as Map)['valeurs'][0]['valeur'], 2);
      await p.toucher('cellule_s1_3');
      await p.toucher('cellule_s2_4');
      expect(p.bouton.onPressed, isNull);
      await p.toucher('cellule_s3_2');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await p.attendreVidage();
      // s2 (4 au lieu de 5) redescend, s1 et s3 restent.
      expect((p.reponsesDonnees.last as Map)['valeurs'][1]['valeur'], 4);
      final valeurs = (tester
          .widget<GraphiqueBarres>(p.cle('graphique'))
          .valeurs);
      expect(valeurs, {'s1': 3, 's3': 2});
      await p.toucher('cellule_s2_5');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : faux deux fois révèle les barres du tableau', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t32Francais());
      await p.toucher('cellule_s1_1');
      await p.toucher('cellule_s2_1');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('cellule_s1_1');
      await p.toucher('cellule_s2_1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('grille_reponse'), findsOneWidget);
      expect(tester.widget<GraphiqueBarres>(p.cle('grille_reponse')).valeurs, {
        's1': 4,
        's2': 2,
      });
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T33 Symétrie', () {
    testWidgets('arabe : cases données inertes, cases de droite coloriées et '
        'décoloriées, seules les fausses s\'effacent, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleGrille('T33-symetrie.json'));
      expect(p.cle('axe'), findsOneWidget);
      expect(find.byKey(const ValueKey('case_1_3')), findsOneWidget);
      // Une case donnée ne réagit pas.
      await p.toucher('case_1_3');
      expect(p.reponsesDonnees, isEmpty);
      await p.toucher('case_1_4');
      expect(p.reponsesDonnees.last, {
        'cases': [
          [1, 4],
        ],
      });
      await p.toucher('case_1_4');
      expect(p.reponsesDonnees.last, {'cases': <Object>[]});
      // Les huit symétriques, plus une fausse.
      for (final c in [
        '1_4',
        '2_4',
        '2_5',
        '3_4',
        '3_5',
        '3_6',
        '4_4',
        '4_5',
        '5_7',
      ]) {
        await p.toucher('case_$c');
      }
      await p.verifier();
      expect(couleurCase(tester, 'case_5_7'), CouleursYasmina.clair.coral);
      await p.attendreVidage();
      expect(couleurCase(tester, 'case_5_7'), CouleursYasmina.clair.tile);
      expect(couleurCase(tester, 'case_1_4'), CouleursYasmina.clair.blue);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : faux deux fois révèle le symétrique', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t33Francais());
      await p.toucher('case_0_2');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('case_0_2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('grille_reponse'), findsOneWidget);
      expect(couleurCase(tester, 'case_0_3'), CouleursYasmina.clair.olive);
      expect(couleurCase(tester, 'case_1_2'), CouleursYasmina.clair.olive);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T60 Codage de déplacement', () {
    testWidgets('arabe : flèches ajoutées et retirées, programme joué pas à '
        'pas, obstacle qui bloque, retour, chemin juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleGrille('T60-codage.json'));
      expect(
        find.descendant(of: p.cle('case_4_0'), matching: p.cle('fleur')),
        findsOneWidget,
      );
      expect(p.bouton.onPressed, isNull);
      await p.toucher('fleche_droite');
      await p.toucher('fleche_droite');
      await p.toucher('fleche_haut');
      expect(p.reponsesDonnees.last, {
        'chemin': ['droite', 'droite', 'haut'],
      });
      await p.toucher('codage_effacer');
      expect(p.reponsesDonnees.last, {
        'chemin': ['droite', 'droite'],
      });
      // Programme qui heurte l'obstacle (3, 2) : droite, droite, haut.
      await p.toucher('fleche_haut');
      await p.toucher('codage_jouer');
      await tester.pump(const Duration(seconds: 3));
      expect(
        find.descendant(of: p.cle('case_4_2'), matching: p.cle('fleur')),
        findsOneWidget,
      );
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      // Tout revient au départ.
      expect(
        find.descendant(of: p.cle('case_4_0'), matching: p.cle('fleur')),
        findsOneWidget,
      );
      expect(p.cle('pas_0'), findsNothing);
      for (final f in ['haut', 'haut', 'droite', 'droite', 'droite']) {
        await p.toucher('fleche_$f');
      }
      await p.toucher('codage_jouer');
      await tester.pump(const Duration(seconds: 4));
      expect(
        find.descendant(of: p.cle('case_2_3'), matching: p.cle('fleur')),
        findsOneWidget,
      );
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : un autre chemin qui arrive est juste aussi, '
        'Revenir rejoue, faux deux fois révèle un chemin', (tester) async {
      p = Partie(tester);
      await p.jouer(t60Francais());
      for (final f in ['droite', 'bas', 'droite']) {
        await p.toucher('fleche_$f');
      }
      await p.toucher('codage_jouer');
      await tester.pump(const Duration(seconds: 3));
      expect(p.cle('codage_revenir'), findsOneWidget);
      await p.toucher('codage_revenir');
      expect(
        find.descendant(of: p.cle('case_0_0'), matching: p.cle('fleur')),
        findsOneWidget,
      );
      expect(p.cle('codage_jouer'), findsOneWidget);
      await p.toucher('codage_jouer');
      await tester.pump(const Duration(seconds: 3));
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);

      await p.jouer(t60Francais());
      await p.toucher('fleche_bas');
      await p.toucher('codage_jouer');
      await tester.pump(const Duration(seconds: 2));
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('fleche_bas');
      await p.toucher('codage_jouer');
      await tester.pump(const Duration(seconds: 2));
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('grille_reponse'), findsOneWidget);
      expect(p.cle('pas_2'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });
}
