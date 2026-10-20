import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../manipulables/fixtures_manipulables.dart';
import '../scene/fixtures_scene.dart';
import 'fixtures_glisser.dart';
import 'outils_glisser.dart';

/// Retrait d'un élément posé, pour tous les types à glisser (corrections
/// du test du 20 oct. 2026) : glisser l'élément posé hors de sa case le
/// renvoie dans la réserve (T06, T09, T11, T12, T13, T14, T47, T62, et les
/// blocs ou jetons de T27 et T51). Dans les zones qui construisent un mot
/// ou une suite liée (T15, T16, T56), le bouton Effacer retire la dernière
/// lettre et le toucher de la zone ne retire plus rien.
void main() {
  late Partie p;

  String motConstruit(WidgetTester tester) =>
      tester.widget<Text>(p.cle('mot_construit')).data!;

  /// Pose [element] sur [cible], puis le glisse hors de toute cible : il
  /// revient dans la réserve, la réponse est vide.
  Future<void> poserPuisSortir(
    WidgetTester tester,
    Map<String, dynamic> exercice, {
    required String element,
    required String cible,
    String? posee,
    String? conteneur,
  }) async {
    p = Partie(tester);
    await p.jouer(exercice);
    await p.glisser(element, cible);
    final dansCible = conteneur ?? cible;
    expect(p.dans(posee ?? element, dansCible), isTrue, reason: 'posé');
    final sonsAvant = p.sons.length;
    await p.glisserHors(posee ?? element);
    expect(p.dans(element, 'reserve'), isTrue, reason: 'revenu');
    expect(p.dans(posee ?? element, dansCible), isFalse);
    expect(p.etatGlissable(element), EtatGlissable.repos);
    // Un retrait n'est pas un dépôt : aucun son.
    expect(p.sons, hasLength(sonsAvant));
    expect(p.bouton.onPressed, isNull);
  }

  group('retrait par glisser hors de la case', () {
    testWidgets('T06 Texte à trous', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T06-texte-trou.json'),
        element: 'element_e1',
        cible: 'cible_t1',
      );
      expect(p.reponsesDonnees.last, {'trous': <Object>[]});
    });

    testWidgets('T09 Association', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T09-association.json'),
        element: 'element_g1',
        cible: 'cible_d1',
      );
      expect(p.reponsesDonnees.last, {'paires': <Object>[]});
    });

    testWidgets('T11 Tri en catégories (arabe)', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T11-tri-categories.json'),
        element: 'element_e1',
        cible: 'cible_k1',
      );
      expect(p.sens, TextDirection.rtl);
      expect(p.reponsesDonnees.last, {'classement': <Object>[]});
    });

    testWidgets('T12 Tableau de tri', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T12-tableau-tri.json'),
        element: 'element_e1',
        cible: 'cible_k1',
      );
    });

    testWidgets('T13 Remise en ordre', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T13-remise-en-ordre.json'),
        element: 'element_e1',
        cible: 'ligne_fin',
        posee: 'pose_e1',
        conteneur: 'ligne',
      );
      expect(p.reponsesDonnees.last, {'ordre': <Object>[]});
    });

    testWidgets('T14 Séquence d\'images (arabe)', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T14-sequence-images.json'),
        element: 'element_e1',
        cible: 'ligne_fin',
        posee: 'pose_e1',
        conteneur: 'ligne',
      );
    });

    testWidgets('T62 Frise chronologique', (tester) async {
      await poserPuisSortir(
        tester,
        exemple('T62-frise.json'),
        element: 'element_e1',
        cible: 'ligne_fin',
        posee: 'pose_e1',
        conteneur: 'ligne',
      );
    });

    testWidgets('T47 Étiqueter un schéma', (tester) async {
      await poserPuisSortir(
        tester,
        exempleScene('T47-etiqueter-schema.json'),
        element: 'element_e1',
        cible: 'cible_z1',
      );
      expect(p.reponsesDonnees.last, {'placements': <Object>[]});
    });

    testWidgets('T13 : une tuile posée glissée sur la ligne y reste', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T13-remise-en-ordre.json'));
      await p.glisser('element_e1', 'ligne_fin');
      await p.glisser('element_e2', 'ligne_fin');
      await p.glisser('pose_e1', 'ligne');
      expect(
        (p.reponsesDonnees.last as Map)['ordre'],
        unorderedEquals(['e1', 'e2']),
      );
      expect(p.dans('pose_e1', 'ligne'), isTrue);
      expect(p.dans('element_e1', 'reserve'), isFalse);
    });
  });

  group('retrait par glisser, matériel des manipulables', () {
    testWidgets('T27 : un bloc posé glissé hors du plateau est retiré, '
        'lâché sur le plateau il reste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T27-blocs-base-10.json'));
      await p.glisser('reserve_dizaine', 'plateau');
      await p.glisser('reserve_unite', 'plateau');
      expect(p.reponsesDonnees.last, {'dizaines': 1, 'unites': 1});
      await p.glisser('unite_0', 'plateau');
      expect(p.reponsesDonnees.last, {'dizaines': 1, 'unites': 1});
      await p.glisserHors('unite_0');
      expect(p.reponsesDonnees.last, {'dizaines': 1, 'unites': 0});
      await p.glisserHors('dizaine_0');
      expect(p.reponsesDonnees.last, {'dizaines': 0, 'unites': 0});
      expect(p.bouton.onPressed, isNull);
    });

    testWidgets('T51 : un jeton posé glissé hors du cadre est retiré, '
        'glissé sur une autre case il s\'y déplace', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T51-cadre-de-10.json'));
      await p.glisser('reserve_jeton', 'case_7');
      expect(p.cle('jeton_7'), findsOneWidget);
      // Sur sa propre case (le doigt s'éloigne puis revient) : il reste.
      final centre = tester.getCenter(p.cle('jeton_7'));
      final geste = await tester.startGesture(centre);
      await geste.moveTo(centre + const Offset(60, 0));
      await tester.pump();
      await geste.moveTo(centre);
      await tester.pump();
      await geste.up();
      await tester.pump();
      expect(p.cle('jeton_7'), findsOneWidget);
      expect(p.reponsesDonnees.last, {'jetons': 1});
      // Sur une autre case vide : déplacé.
      await p.glisser('jeton_7', 'case_2');
      expect(p.cle('jeton_7'), findsNothing);
      expect(p.cle('jeton_2'), findsOneWidget);
      expect(p.reponsesDonnees.last, {'jetons': 1});
      // Hors du cadre : retiré.
      await p.glisserHors('jeton_2');
      expect(p.cle('jeton_2'), findsNothing);
      expect(p.reponsesDonnees.last, {'jetons': 0});
    });
  });

  group('bouton Effacer des mots et suites liés', () {
    Future<void> effacerDernier(
      WidgetTester tester,
      Map<String, dynamic> exercice, {
      required List<String> elements,
      required String cible,
      required String attendu,
      required String apresEffacement,
    }) async {
      p = Partie(tester);
      await p.jouer(exercice);
      final effacer = p.cle('ordre_effacer');
      expect(effacer, findsOneWidget);
      expect(tester.widget<BoutonEffacer>(effacer).onPressed, isNull);
      for (final e in elements) {
        await p.glisser(e, cible);
      }
      expect(motConstruit(tester), attendu);
      // Le toucher de la zone ne retire plus rien.
      await p.toucher('ligne');
      expect(motConstruit(tester), attendu);
      // Même icône que la touche Effacer du clavier et du pavé.
      expect(
        find.descendant(
          of: effacer,
          matching: find.byIcon(Icons.backspace_outlined),
        ),
        findsOneWidget,
      );
      await p.toucher('ordre_effacer');
      expect(motConstruit(tester).trim(), apresEffacement);
      expect(p.dans(elements.last, 'reserve'), isTrue);
    }

    testWidgets('T15 Construire un mot (lettres), libellé genré', (
      tester,
    ) async {
      await effacerDernier(
        tester,
        exemple('T15-mot-lettres.json'),
        elements: ['element_e1', 'element_e3'],
        cible: 'ligne',
        attendu: 'قر',
        apresEffacement: 'ق',
      );
      expect(find.text('اِمْسَحْ'), findsOneWidget);
    });

    testWidgets('T16 Construire un mot (syllabes)', (tester) async {
      await effacerDernier(
        tester,
        exemple('T16-mot-syllabes.json'),
        elements: ['element_e1', 'element_e2'],
        cible: 'ligne',
        attendu: 'toma',
        apresEffacement: 'to',
      );
      expect(find.text('Effacer'), findsOneWidget);
    });

    testWidgets('T56 Racine et schème, au féminin', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T56-racine.json'), forme: FormeAdresse.feminin);
      expect(
        tester.widget<BoutonEffacer>(p.cle('ordre_effacer')).onPressed,
        isNull,
      );
      await p.glisser('element_e1', 'ligne');
      await p.glisser('element_e2', 'ligne');
      final avant = motConstruit(tester);
      expect(avant.split(' '), hasLength(2));
      await p.toucher('ligne');
      expect(motConstruit(tester), avant);
      expect(find.text('اِمْسَحِي'), findsOneWidget);
      await p.toucher('ordre_effacer');
      expect(
        motConstruit(tester).split(' ').where((s) => s.isNotEmpty),
        hasLength(1),
      );
      expect(p.dans('element_e2', 'reserve'), isTrue);
    });
  });
}
