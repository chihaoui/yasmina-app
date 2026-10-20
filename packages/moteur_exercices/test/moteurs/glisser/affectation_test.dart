import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_glisser.dart';
import 'outils_glisser.dart';

/// T09 Association et T11 Tri en catégories : vrai glisser, toucher-toucher,
/// dépôt hors cible, seuls les éléments faux reviennent, réponse révélée.
void main() {
  late Partie p;

  group('T09 Association', () {
    testWidgets('français : glisser réel sur la bonne image, son et '
        'vibration, dépôt hors cible annulé, juste au 1er essai', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T09-association.json'));
      expect(p.sens, TextDirection.ltr);
      expect(find.byType(TuileGlissable), findsNWidgets(4));
      expect(find.byType(ZoneDepot), findsNWidgets(4));
      // La réserve (gauche) est à gauche des cibles.
      expect(
        tester.getCenter(p.cle('element_g1')).dx,
        lessThan(tester.getCenter(p.cle('cible_d1')).dx),
      );
      expect(p.bouton.onPressed, isNull);

      await p.glisser('element_g1', 'cible_d3');
      expect(p.dans('element_g1', 'cible_d3'), isTrue);
      expect(p.etatGlissable('element_g1'), EtatGlissable.pose);
      expect(p.sons, [SonInterface.depot]);
      expect(p.audio.vibrationFactice.legeres, 1);
      expect(p.reponsesDonnees.last, {
        'paires': [
          {'droite': 'd3', 'gauche': 'g1'},
        ],
      });

      // Hors cible : l'élément revient dans la réserve.
      await p.glisserHors('element_g2');
      expect(p.etatGlissable('element_g2'), EtatGlissable.repos);
      expect(p.dans('element_g2', 'reserve'), isTrue);
      expect(p.sons, hasLength(1));

      await p.glisser('element_g2', 'cible_d1');
      await p.glisser('element_g3', 'cible_d4');
      expect(p.bouton.onPressed, isNull);
      await p.glisser('element_g4', 'cible_d2');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
      expect(p.etatGlissable('element_g1'), EtatGlissable.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(p.sons.last, SonInterface.juste);
    });

    testWidgets('arabe au féminin : réserve à droite, toucher-toucher, '
        'seul l\'élément faux revient, puis juste', (tester) async {
      p = Partie(tester);
      await p.jouer(t09Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      expect(
        find.text('اِسْحَبِي كُلَّ كَلِمَةٍ إِلَى صُورَتِهَا.'),
        findsOneWidget,
      );
      // Début de ligne à droite : la réserve est à droite des cibles.
      expect(
        tester.getCenter(p.cle('element_g1')).dx,
        greaterThan(tester.getCenter(p.cle('cible_d1')).dx),
      );
      // Toucher-toucher : l'élément passe en attente, puis se pose.
      await p.toucher('element_g1');
      expect(p.etatGlissable('element_g1'), EtatGlissable.attente);
      await p.toucherZone('cible_d1'); // faux : قِطٌّ sur le livre
      expect(p.dans('element_g1', 'cible_d1'), isTrue);
      expect(p.etatGlissable('element_g1'), EtatGlissable.pose);
      await p.toucher('element_g2');
      await p.toucherZone('cible_d3');
      await p.toucher('element_g3');
      // Un toucher sur l'élément en attente l'en sort.
      await p.toucher('element_g3');
      expect(p.etatGlissable('element_g3'), EtatGlissable.repos);
      await p.glisser('element_g3', 'cible_d2'); // faux aussi
      await p.verifier();
      expect(p.etatGlissable('element_g1'), EtatGlissable.faux);
      expect(p.etatGlissable('element_g3'), EtatGlissable.faux);
      expect(p.etatGlissable('element_g2'), EtatGlissable.pose);
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      // Les faux reviennent, le juste reste.
      expect(p.etatGlissable('element_g1'), EtatGlissable.repos);
      expect(p.dans('element_g2', 'cible_d3'), isTrue);
      await p.glisser('element_g1', 'cible_d2');
      await p.glisser('element_g3', 'cible_d1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتِ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('faux deux fois : la bonne réponse est révélée', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T09-association.json'));
      for (final (g, d) in [
        ('g1', 'd1'),
        ('g2', 'd2'),
        ('g3', 'd3'),
        ('g4', 'd4'),
      ]) {
        await p.glisser('element_$g', 'cible_$d');
      }
      await p.verifier();
      await p.attendreVidage();
      for (final (g, d) in [
        ('g1', 'd1'),
        ('g2', 'd2'),
        ('g3', 'd3'),
        ('g4', 'd4'),
      ]) {
        await p.glisser('element_$g', 'cible_$d');
      }
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.dans('element_g1', 'cible_d3'), isTrue);
      expect(p.etatGlissable('element_g1'), EtatGlissable.juste);
      expect(p.glissable('element_g1').onToucher, isNull);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T11 Tri en catégories', () {
    testWidgets('arabe : bacs de droite à gauche, 6 éléments, tous classés', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T11-tri-categories.json'));
      expect(p.sens, TextDirection.rtl);
      expect(find.byType(TuileGlissable), findsNWidgets(6));
      expect(
        tester.getCenter(p.cle('cible_k1')).dx,
        greaterThan(tester.getCenter(p.cle('cible_k2')).dx),
      );
      expect(find.text('🍇 فَوَاكِهُ'), findsOneWidget);
      for (final (e, k) in [
        ('e1', 'k1'),
        ('e2', 'k2'),
        ('e3', 'k1'),
        ('e4', 'k2'),
        ('e5', 'k1'),
      ]) {
        await p.glisser('element_$e', 'cible_$k');
      }
      expect(p.bouton.onPressed, isNull);
      await p.toucher('element_e6');
      await p.toucherZone('cible_k2');
      expect(p.dans('element_e6', 'cible_k2'), isTrue);
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(6));
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(p.etatGlissable('element_e4'), EtatGlissable.juste);
    });

    testWidgets('français : un élément posé se retire au toucher, '
        'déplacement vers l\'autre bac', (tester) async {
      p = Partie(tester);
      await p.jouer(t11Francais());
      expect(p.sens, TextDirection.ltr);
      await p.glisser('element_e1', 'cible_k2');
      expect(p.dans('element_e1', 'cible_k2'), isTrue);
      // Posé : se déplace encore vers l'autre bac.
      await p.glisser('element_e1', 'cible_k1');
      expect(p.dans('element_e1', 'cible_k1'), isTrue);
      expect(p.dans('element_e1', 'cible_k2'), isFalse);
      // Le toucher d'un élément posé le renvoie dans la réserve.
      await p.toucher('element_e1');
      expect(p.dans('element_e1', 'reserve'), isTrue);
      expect(p.etatGlissable('element_e1'), EtatGlissable.repos);
      for (final (e, k) in [
        ('e1', 'k1'),
        ('e2', 'k2'),
        ('e3', 'k1'),
        ('e4', 'k2'),
      ]) {
        await p.glisser('element_$e', 'cible_$k');
      }
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
    });
  });
}
