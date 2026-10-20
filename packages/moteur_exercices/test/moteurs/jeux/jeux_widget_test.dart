import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_jeux.dart';

/// T36 Flashcards (sans note), T37 Memory et T38 Mots mêlés (automatiques)
/// (docs/moteurs/revision-jeux.md), avec les corrections du test du
/// 20 oct. 2026 : memory à grille pleine sur 3 colonnes et cartes de taille
/// fixe, mots mêlés lettre à lettre ou au doigt glissé, erreur signalée par
/// la lettre rouge, une secousse et le son essaiFaux.
void main() {
  late Partie p;

  CarteRevision carte(WidgetTester tester, String cle) =>
      tester.widget<CarteRevision>(
        find.descendant(
          of: p.cle(cle),
          matching: find.byType(CarteRevision),
          matchRoot: true,
        ),
      );

  String compteur(WidgetTester tester) =>
      tester.widget<Text>(p.cle('cartes_compteur')).data!;

  EtatCase etatCase(WidgetTester tester, String cle) =>
      tester.widget<CaseGrille>(p.cle(cle)).etat;

  group('T36 Flashcards', () {
    testWidgets('arabe : carte retournée au toucher, je savais, à revoir '
        'revient en fin de paquet, Continuer dès que tout est vu, sans note', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T36-flashcards.json'));
      expect(p.sens, TextDirection.rtl);
      expect(compteur(tester), '1 / 4');
      expect(carte(tester, 'carte').cachee, isTrue);
      expect(p.bouton.libelle, 'وَاصِلْ');
      expect(p.bouton.onPressed, isNull);
      expect(tester.widget<BoutonYasmina>(p.cle('carte_su')).onPressed, isNull);
      // Retourner, écouter le mot, « je savais ».
      await p.toucher('carte');
      expect(carte(tester, 'carte').cachee, isFalse);
      expect(carte(tester, 'carte').face.texte, isNotNull);
      final premierMot = carte(tester, 'carte').face.texte;
      await p.toucher('carte_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, premierMot);
      await p.toucher('carte_su');
      expect(compteur(tester), '2 / 4');
      expect(carte(tester, 'carte').cachee, isTrue);
      // « À revoir » : la carte revient en fin de paquet.
      await p.toucher('carte');
      final aRevoir = carte(tester, 'carte').face.texte;
      await p.toucher('carte_a_revoir');
      expect(compteur(tester), '3 / 5');
      await p.toucher('carte');
      await p.toucher('carte_su');
      await p.toucher('carte');
      await p.toucher('carte_su');
      // Toutes les cartes demandées sont vues : Continuer actif.
      expect(compteur(tester), '5 / 5');
      expect(p.bouton.onPressed, isNotNull);
      expect(p.reponsesDonnees.last, {
        'cartes': ['c1', 'c2', 'c3', 'c4'],
        'a_revoir': [
          // L'id de la carte à revoir, retrouvé par son verso.
          ...['c1', 'c2', 'c3', 'c4'].where(
            (id) =>
                (exempleJeux('T36-flashcards.json')['donnees']['cartes']
                        as List)
                    .cast<Map<String, dynamic>>()
                    .firstWhere((c) => c['id'] == id)['verso']['texte'] ==
                aRevoir,
          ),
        ],
      });
      // La carte revenue, une seule fois.
      await p.toucher('carte');
      expect(carte(tester, 'carte').face.texte, aRevoir);
      await p.toucher('carte_a_revoir');
      expect(compteur(tester), '5 / 5');
      expect(tester.widget<BoutonYasmina>(p.cle('carte_su')).onPressed, isNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.termine, essais: 0));
      expect(find.byType(BandeauFeedback), findsNothing);
      expect(p.audio.audioFactice.sons, isEmpty);
    });

    testWidgets('aperçu : afficher la réponse retourne la carte, Rejouer', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(
        exempleJeux('T36-flashcards.json'),
        mode: ModeExercice.apercu,
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('jeux_reponse'), findsOneWidget);
      expect(carte(tester, 'jeux_reponse').cachee, isFalse);
      await tester.tap(p.cle('lecteur_rejouer'));
      await tester.pump();
      expect(compteur(tester), '1 / 4');
      expect(carte(tester, 'carte').cachee, isTrue);
    });
  });

  group('T37 Memory', () {
    testWidgets('français, 2e année : 12 cartes sur 3 colonnes, paire fausse '
        'refermée, paire juste gardée avec son, fin automatique juste', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T37-memory.json'));
      expect(find.byType(CarteRevision), findsNWidgets(12));
      // Mode automatique : aucun bouton avant la fin.
      expect(p.cle('lecteur_bouton'), findsNothing);
      await p.toucher('carte_p1a');
      expect(carte(tester, 'carte_p1a').etat, EtatCarte.retournee);
      await p.toucher('carte_p2b');
      expect(carte(tester, 'carte_p1a').etat, EtatCarte.fausse);
      // Une troisième carte est ignorée pendant l'attente.
      await p.toucher('carte_p3a');
      expect(carte(tester, 'carte_p3a').etat, EtatCarte.cachee);
      await p.attendreVidage();
      expect(carte(tester, 'carte_p1a').etat, EtatCarte.cachee);
      await p.toucher('carte_p1a');
      await p.toucher('carte_p1b');
      expect(carte(tester, 'carte_p1a').etat, EtatCarte.trouvee);
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      expect(p.reponsesDonnees.last, {
        'paires': ['p1'],
        'essais': 2,
      });
      for (final id in ['p2', 'p3', 'p4', 'p5', 'p6']) {
        await p.toucher('carte_${id}a');
        await p.toucher('carte_${id}b');
      }
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(find.text('Bravo'), findsOneWidget);
      expect(p.bouton.libelle, 'Continuer');
      // Le son juste part à la fin automatique, le dépôt de la dernière
      // paire est joué au rebuild qui suit.
      expect(p.audio.audioFactice.sons, contains(SonInterface.juste));
      expect(
        p.audio.audioFactice.sons.where((s) => s == SonInterface.depot),
        hasLength(6),
      );
    });

    testWidgets('trop d\'essais : fin automatique fausse, explication', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t37EssaisMax());
      await p.toucher('carte_p1a');
      await p.toucher('carte_p2a');
      await p.attendreVidage();
      await p.toucher('carte_p1a');
      await p.toucher('carte_p2b');
      await p.attendreVidage();
      for (final id in ['p1', 'p2', 'p3']) {
        await p.toucher('carte_${id}a');
        await p.toucher('carte_${id}b');
      }
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 1));
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
    });

    for (final (niveau, paires) in [(1, 3), (4, 9), (6, 12)]) {
      testWidgets('grille pleine 3 × ${paires * 2 ~/ 3} en ${niveau}e année '
          'sur 390 × 844 dp : cartes de taille fixe (au moins 48 dp), '
          'sans défilement', (tester) async {
        p = Partie(tester);
        await p.jouer(
          t37Niveau(niveau, paires: paires),
          taille: const Size(390, 844),
        );
        final cartes = find.byType(CarteRevision);
        expect(cartes, findsNWidgets(paires * 2));
        final rects = [
          for (var i = 0; i < paires * 2; i++) tester.getRect(cartes.at(i)),
        ];
        // Même taille pour toutes, au moins 48 dp.
        for (final r in rects) {
          expect(r.size, rects.first.size);
          expect(r.height, greaterThanOrEqualTo(EspacesYasmina.targetMin));
          expect(r.width, greaterThanOrEqualTo(EspacesYasmina.targetMin));
        }
        // Trois colonnes : trois cartes par hauteur.
        final hauteurs = rects.map((r) => r.top).toSet();
        expect(hauteurs, hasLength(paires * 2 ~/ 3));
        for (final h in hauteurs) {
          expect(rects.where((r) => r.top == h), hasLength(3));
        }
        // Tout tient à l'écran : la zone du lecteur ne défile pas.
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        expect(position.maxScrollExtent, 0);
        expect(rects.last.bottom, lessThanOrEqualTo(844));
        // Face visible : même hauteur que face cachée.
        await p.toucher('carte_p1a');
        expect(tester.getRect(cartes.first).size, rects.first.size);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('T38 Mots mêlés', () {
    testWidgets('arabe : lettres touchées une à une de droite à gauche, '
        'lettre fausse en rouge puis sélection vidée avec le son essaiFaux, '
        'colonne lue à l\'envers, fin automatique', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T38-mots-meles.json'));
      expect(p.cle('grille'), findsOneWidget);
      // Les cases suivent l'index de colonne, de gauche à droite.
      expect(
        tester.getCenter(p.cle('case_0_0')).dx,
        lessThan(tester.getCenter(p.cle('case_0_4')).dx),
      );
      // قلم : ق (0,3), ل (0,2), م (0,1), lu de droite à gauche.
      await p.toucher('case_0_3');
      expect(etatCase(tester, 'case_0_3'), EtatCase.selectionnee);
      await p.toucher('case_0_2');
      expect(p.reponsesDonnees, isEmpty);
      await p.toucher('case_0_1');
      expect(p.reponsesDonnees.last, {
        'mots': ['m1'],
      });
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      expect(etatCase(tester, 'case_0_2'), EtatCase.trouvee);
      final barre = tester.widget<Text>(p.cle('mot_m1')).style!.decoration;
      expect(barre, TextDecoration.lineThrough);
      // د (1,3) commence درس, puis ح (2,2) ne prolonge aucun mot : rouge,
      // son essaiFaux, puis toute la sélection se vide. Rien n'est perdu.
      await p.toucher('case_1_3');
      expect(etatCase(tester, 'case_1_3'), EtatCase.selectionnee);
      await p.toucher('case_2_2');
      expect(etatCase(tester, 'case_2_2'), EtatCase.fausse);
      expect(etatCase(tester, 'case_1_3'), EtatCase.selectionnee);
      expect(p.audio.audioFactice.sons.last, SonInterface.essaiFaux);
      expect(p.reponsesDonnees, hasLength(1));
      // Pendant l'effet d'erreur, les touchers sont ignorés.
      await p.toucher('case_1_2');
      expect(etatCase(tester, 'case_1_2'), EtatCase.repos);
      await p.attendreVidage();
      expect(etatCase(tester, 'case_2_2'), EtatCase.repos);
      expect(etatCase(tester, 'case_1_3'), EtatCase.repos);
      // Une lettre qui ne commence aucun mot est fausse tout de suite.
      await p.toucher('case_2_4');
      expect(etatCase(tester, 'case_2_4'), EtatCase.fausse);
      await p.attendreVidage();
      // درس, puis كتاب à l'envers (dernière lettre d'abord).
      for (final c in ['case_1_3', 'case_1_2', 'case_1_1']) {
        await p.toucher(c);
      }
      expect(p.reponsesDonnees.last, {
        'mots': ['m1', 'm2'],
      });
      for (final c in ['case_4_0', 'case_3_0', 'case_2_0', 'case_1_0']) {
        await p.toucher(c);
      }
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
    });

    testWidgets('français : le doigt glissé le long du mot le trouve, une '
        'glissade qui sort du mot vide la sélection, aperçu révèle tout', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T38-mots-meles-fr.json'));
      // CHAT sur la ligne 0, colonnes 0 à 3, lu de gauche à droite.
      final geste = await tester.startGesture(
        tester.getCenter(p.cle('case_0_0')),
      );
      for (final c in ['case_0_1', 'case_0_2', 'case_0_3']) {
        await geste.moveTo(tester.getCenter(p.cle(c)));
        await tester.pump();
      }
      await geste.up();
      await tester.pump();
      expect(p.reponsesDonnees.last, {
        'mots': ['m1'],
      });
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      // SOL en colonne 0 depuis la ligne 1 : glisser S, O puis sortir sur
      // A (3,1) : erreur, la sélection se vide.
      final geste2 = await tester.startGesture(
        tester.getCenter(p.cle('case_1_0')),
      );
      await geste2.moveTo(tester.getCenter(p.cle('case_2_0')));
      await tester.pump();
      expect(etatCase(tester, 'case_2_0'), EtatCase.selectionnee);
      await geste2.moveTo(tester.getCenter(p.cle('case_3_1')));
      await tester.pump();
      await geste2.up();
      await tester.pump();
      expect(etatCase(tester, 'case_3_1'), EtatCase.fausse);
      expect(p.audio.audioFactice.sons.last, SonInterface.essaiFaux);
      await p.attendreVidage();
      expect(etatCase(tester, 'case_1_0'), EtatCase.repos);
      expect(p.reponsesDonnees, hasLength(1));

      await p.jouer(
        exempleJeux('T38-mots-meles-fr.json'),
        mode: ModeExercice.apercu,
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('jeux_reponse'), findsOneWidget);
      for (final id in ['m1', 'm2', 'm3']) {
        expect(
          tester.widget<Text>(p.cle('mot_$id')).style!.decoration,
          TextDecoration.lineThrough,
        );
      }
      expect(find.text('juste'), findsOneWidget);
    });
  });
}
