import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_glisser.dart';
import 'outils_glisser.dart';

/// T13 Remise en ordre et T15 Construire un mot : ligne de réponse qui se
/// remplit dans le sens d'écriture, insertion, retrait du dernier, mot lié.
void main() {
  late Partie p;

  String motConstruit(WidgetTester tester) =>
      tester.widget<Text>(p.cle('mot_construit')).data!;

  group('T13 Remise en ordre', () {
    testWidgets('anglais : les mots se rangent dans la ligne de gauche à '
        'droite, insertion avant un mot, retrait du dernier', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T13-remise-en-ordre.json'));
      expect(p.sens, TextDirection.ltr);
      expect(find.byType(TuileGlissable), findsNWidgets(5));
      await p.glisserEnFin('element_e1', 'ligne');
      await p.glisserEnFin('element_e3', 'ligne');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e3'],
      });
      expect(p.dans('pose_e1', 'ligne'), isTrue);
      expect(
        tester.getCenter(p.cle('pose_e1')).dx,
        lessThan(tester.getCenter(p.cle('pose_e3')).dx),
      );
      // Insertion avant « football » (e3).
      await p.glisser('element_e2', 'avant_e3');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3'],
      });
      await p.glisserEnFin('element_e5', 'ligne');
      // Le toucher du dernier mot le retire, pas celui d'un autre.
      await p.toucher('pose_e1');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3', 'e5'],
      });
      await p.toucher('pose_e5');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3'],
      });
      expect(p.bouton.onPressed, isNull);
      // Toucher-toucher vers la ligne.
      await p.toucher('element_e4');
      await p.toucherZone('ligne');
      await p.glisserEnFin('element_e5', 'ligne');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Well done'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      // 4 glisser, 1 toucher-toucher, 1 glisser après le retrait de e5.
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(6));
    });

    testWidgets('arabe : la ligne se remplit de droite à gauche, début juste '
        'gardé après le 1er essai faux, réponse révélée', (tester) async {
      p = Partie(tester);
      await p.jouer(t13Arabe());
      expect(p.sens, TextDirection.rtl);
      await p.glisserEnFin('element_e1', 'ligne');
      await p.glisserEnFin('element_e3', 'ligne');
      // Premier mot à droite du deuxième.
      expect(
        tester.getCenter(p.cle('pose_e1')).dx,
        greaterThan(tester.getCenter(p.cle('pose_e3')).dx),
      );
      await p.glisserEnFin('element_e2', 'ligne');
      await p.glisserEnFin('element_e4', 'ligne');
      await p.verifier();
      expect(p.etatGlissable('pose_e1'), EtatGlissable.pose);
      expect(p.etatGlissable('pose_e3'), EtatGlissable.faux);
      await p.attendreVidage();
      // Seul يَلْعَبُ (début juste) reste dans la ligne, les autres sont
      // revenus dans la réserve (retrait fait par le lecteur : aucun
      // reponseDonnee).
      expect(p.cle('pose_e1'), findsOneWidget);
      expect(p.cle('pose_e3'), findsNothing);
      expect(p.dans('element_e3', 'reserve'), isTrue);
      expect(p.dans('element_e2', 'reserve'), isTrue);
      await p.glisserEnFin('element_e4', 'ligne');
      await p.glisserEnFin('element_e3', 'ligne');
      await p.glisserEnFin('element_e2', 'ligne');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      // Bonne réponse révélée : e1 e2 e3 e4 dans la ligne, en juste.
      expect(
        tester.getCenter(p.cle('pose_e2')).dx,
        greaterThan(tester.getCenter(p.cle('pose_e3')).dx),
      );
      expect(p.etatGlissable('pose_e2'), EtatGlissable.juste);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T15 Construire un mot (lettres), arabe seulement', () {
    testWidgets('mot entendu après la consigne, lettres liées, le toucher '
        'de la zone retire la dernière, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T15-mot-lettres.json'));
      expect(p.sens, TextDirection.rtl);
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'اِسْتَمِعْ وَرَكِّبِ الْكَلِمَةَ بِالْحُرُوفِ.',
        'قَمَرٌ',
      ]);
      await p.toucher('ordre_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, 'قَمَرٌ');
      expect(find.byType(TuileGlissable), findsNWidgets(5));
      expect(p.glissable('element_e1').grand, isTrue);
      expect(motConstruit(tester).trim(), isEmpty);
      await p.glisserEnFin('element_e1', 'ligne');
      await p.glisserEnFin('element_e3', 'ligne');
      // Une seule chaîne : les lettres se lient (قر).
      expect(motConstruit(tester), 'قر');
      final style = tester.widget<Text>(p.cle('mot_construit')).style!;
      expect(style.fontSize, StylesYasmina.contentWord.fontSize);
      expect(style.fontFamily, PolicesYasmina.contenuArabe);
      // Le toucher de la zone retire la dernière lettre.
      await p.toucher('ligne');
      expect(motConstruit(tester), 'ق');
      expect(p.dans('element_e3', 'reserve'), isTrue);
      await p.toucher('element_e2');
      await p.toucher('ligne');
      await p.glisserEnFin('element_e3', 'ligne');
      expect(motConstruit(tester), 'قمر');
      // Vérifier actif avec des lettres en trop dans la réserve.
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('mot faux : les lettres reviennent sauf le début juste, '
        'puis la bonne réponse est révélée', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T15-mot-lettres.json'));
      await p.glisserEnFin('element_e1', 'ligne');
      await p.glisserEnFin('element_e4', 'ligne');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(motConstruit(tester), 'ق');
      await p.glisserEnFin('element_e5', 'ligne');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(motConstruit(tester), 'قمر');
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
    });
  });
}
