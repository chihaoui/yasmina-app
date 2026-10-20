import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_jeux.dart';

/// T36 Flashcards (sans note), T37 Memory et T38 Mots mêlés (automatiques)
/// (docs/moteurs/revision-jeux.md).
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
    testWidgets('français : paire fausse refermée, paire juste gardée avec '
        'son, fin automatique juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T37-memory.json'));
      expect(find.byType(CarteRevision), findsNWidgets(8));
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
      for (final id in ['p2', 'p3', 'p4']) {
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
        hasLength(4),
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
      await p.toucher('carte_p1a');
      await p.toucher('carte_p1b');
      await p.toucher('carte_p2a');
      await p.toucher('carte_p2b');
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 1));
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
    });
  });

  group('T38 Mots mêlés', () {
    testWidgets('arabe : lettres isolées, mot lu de droite à gauche, '
        'sélection fausse effacée, colonne, fin automatique', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T38-mots-meles.json'));
      expect(p.cle('grille'), findsOneWidget);
      // Les cases suivent l'index de colonne, de gauche à droite.
      expect(
        tester.getCenter(p.cle('case_0_0')).dx,
        lessThan(tester.getCenter(p.cle('case_0_4')).dx),
      );
      // قلم : de la colonne 3 à la colonne 1 sur la ligne 0.
      await p.toucher('case_0_3');
      await p.toucher('case_0_1');
      expect(p.reponsesDonnees.last, {
        'mots': ['m1'],
      });
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      final barre = tester.widget<Text>(p.cle('mot_m1')).style!.decoration;
      expect(barre, TextDecoration.lineThrough);
      // Sélection fausse.
      await p.toucher('case_2_2');
      await p.toucher('case_2_4');
      expect(p.reponsesDonnees, hasLength(1));
      await p.attendreVidage();
      // درس sur la ligne 1, puis كتاب en colonne 0 (dernière lettre d'abord).
      await p.toucher('case_1_3');
      await p.toucher('case_1_1');
      await p.toucher('case_4_0');
      await p.toucher('case_1_0');
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
    });

    testWidgets('français : de gauche à droite, aperçu révèle tous les mots', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleJeux('T38-mots-meles-fr.json'));
      await p.toucher('case_0_0');
      await p.toucher('case_0_3');
      expect(p.reponsesDonnees.last, {
        'mots': ['m1'],
      });

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
