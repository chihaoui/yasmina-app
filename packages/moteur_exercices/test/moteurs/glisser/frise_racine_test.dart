import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_glisser.dart';
import 'outils_glisser.dart';

/// T62 Frise chronologique (variante de T13 sur une ligne du temps à cases
/// fixes) et T56 Racine et schème (lettres nues dans des emplacements,
/// isolées pour la racine, liées avec leurs harakat pour le schème).
void main() {
  late Partie p;

  String motConstruit(WidgetTester tester) =>
      tester.widget<Text>(p.cle('mot_construit')).data!;

  group('T62 Frise chronologique', () {
    testWidgets('français : cases de gauche à droite, dates sous les '
        'éléments, insertion, retrait du dernier, toucher-toucher', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T62-frise.json'));
      expect(p.sens, TextDirection.ltr);
      expect(p.cle('frise'), findsOneWidget);
      expect(find.byType(TuileGlissable), findsNWidgets(5));
      // Une case par élément : la première reçoit, les autres attendent.
      expect(p.cle('ligne_fin'), findsOneWidget);
      expect(p.cle('frise_case_1'), findsOneWidget);
      expect(p.cle('frise_case_4'), findsOneWidget);
      // La date de la réserve est lue avec le texte.
      expect(find.text('7 h'), findsOneWidget);
      expect(p.glissable('element_e1').detail, '7 h');
      await p.glisser('element_e1', 'ligne_fin');
      await p.glisser('element_e3', 'ligne_fin');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e3'],
      });
      // Sur la frise : l'emoji et la date, sans le texte (case étroite),
      // le texte reste le libellé lu.
      expect(p.dans('pose_e1', 'frise'), isTrue);
      expect(p.glissable('pose_e1').texte, isNull);
      expect(p.glissable('pose_e1').emoji, '⏰');
      expect(p.glissable('pose_e1').detail, '7 h');
      expect(p.glissable('pose_e1').libelleAccessibilite, 'Le réveil');
      expect(
        tester.getCenter(p.cle('pose_e1')).dx,
        lessThan(tester.getCenter(p.cle('pose_e3')).dx),
      );
      // Insertion avant le déjeuner (e3).
      await p.glisser('element_e2', 'avant_e3');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3'],
      });
      // Les cases vides restent à la suite, la 4e reçoit.
      expect(p.cle('ligne_fin'), findsOneWidget);
      expect(p.cle('frise_case_4'), findsOneWidget);
      expect(p.cle('frise_case_3'), findsNothing);
      await p.glisser('element_e5', 'ligne_fin');
      // Seul le dernier élément se retire au toucher.
      await p.toucher('pose_e1');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3', 'e5'],
      });
      await p.toucher('pose_e5');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3'],
      });
      expect(p.bouton.onPressed, isNull);
      await p.toucher('element_e4');
      await p.toucher('ligne_fin');
      await p.glisser('element_e5', 'ligne_fin');
      // Frise pleine : plus de case qui reçoit.
      expect(p.cle('ligne_fin'), findsNothing);
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(6));
    });

    testWidgets('arabe : cases de droite à gauche, début juste gardé après '
        'le 1er essai faux, réponse révélée', (tester) async {
      p = Partie(tester);
      await p.jouer(t62Arabe());
      expect(p.sens, TextDirection.rtl);
      // Sans date : la tuile n'a pas de détail.
      expect(p.glissable('element_e1').detail, isNull);
      await p.glisser('element_e1', 'ligne_fin');
      await p.glisser('element_e3', 'ligne_fin');
      expect(
        tester.getCenter(p.cle('pose_e1')).dx,
        greaterThan(tester.getCenter(p.cle('pose_e3')).dx),
      );
      await p.glisser('element_e2', 'ligne_fin');
      await p.glisser('element_e4', 'ligne_fin');
      await p.verifier();
      expect(p.etatGlissable('pose_e1'), EtatGlissable.pose);
      expect(p.etatGlissable('pose_e3'), EtatGlissable.faux);
      await p.attendreVidage();
      expect(p.cle('pose_e1'), findsOneWidget);
      expect(p.cle('pose_e3'), findsNothing);
      expect(p.dans('element_e3', 'reserve'), isTrue);
      await p.glisser('element_e4', 'ligne_fin');
      await p.glisser('element_e3', 'ligne_fin');
      await p.glisser('element_e2', 'ligne_fin');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(
        tester.getCenter(p.cle('pose_e2')).dx,
        greaterThan(tester.getCenter(p.cle('pose_e3')).dx),
      );
      expect(p.etatGlissable('pose_e2'), EtatGlissable.juste);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T56 Racine et schème, arabe seulement', () {
    testWidgets('racine : mot entendu après la consigne, lettres isolées '
        'dans les emplacements, ligne pleine, retrait du dernier', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T56-racine.json'));
      expect(p.sens, TextDirection.rtl);
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'اِسْحَبْ حُرُوفَ جَذْرِ الْكَلِمَةِ إِلَى أَمَاكِنِهَا.',
        'مَكْتَبٌ',
      ]);
      expect(tester.widget<Text>(p.cle('racine_mot')).data, 'مَكْتَبٌ');
      await p.toucher('ordre_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, 'مَكْتَبٌ');
      expect(find.byType(TuileGlissable), findsNWidgets(5));
      expect(p.glissable('element_e1').grand, isTrue);
      // Trois emplacements vides, rien de construit.
      expect(p.cle('mot_construit'), findsNothing);
      for (final i in [0, 1, 2]) {
        expect(p.cle('emplacement_$i'), findsOneWidget);
      }
      // Dépôt sur le premier emplacement, puis sur la ligne.
      await p.glisser('element_e1', 'emplacement_0');
      expect(motConstruit(tester), 'ك');
      expect(p.cle('emplacement_0'), findsNothing);
      await p.glisser('element_e2', 'ligne');
      // Lettres isolées, séparées par une espace : jamais liées.
      expect(motConstruit(tester), 'ك ت');
      final style = tester.widget<Text>(p.cle('mot_construit')).style!;
      expect(style.fontFamily, PolicesYasmina.contenuArabe);
      // Effacer retire la dernière lettre (le toucher de la ligne ne retire
      // plus rien, corrections du 20 oct.).
      await p.toucher('ordre_effacer');
      expect(motConstruit(tester), 'ك');
      expect(p.dans('element_e2', 'reserve'), isTrue);
      expect(p.bouton.onPressed, isNull);
      // Toucher-toucher vers l'emplacement suivant, puis glisser.
      await p.toucher('element_e2');
      await p.toucher('emplacement_1');
      await p.glisser('element_e3', 'emplacement_2');
      expect(motConstruit(tester), 'ك ت ب');
      expect(p.reponsesDonnees.last, {
        'ordre': ['e1', 'e2', 'e3'],
      });
      // Ligne pleine : une 4e lettre est refusée et reste dans la réserve.
      expect(p.cle('emplacement_2'), findsNothing);
      await p.glisser('element_e4', 'ligne');
      expect(motConstruit(tester), 'ك ت ب');
      expect(p.dans('element_e4', 'reserve'), isTrue);
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(4));
    });

    testWidgets('schème : les lettres se lient avec la haraka de leur '
        'emplacement, faux puis révélé', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T56-scheme.json'));
      expect(tester.widget<Text>(p.cle('racine_mot')).data, 'كَاتِبٌ');
      expect(find.byType(TuileGlissable), findsNWidgets(6));
      for (final i in [0, 1, 2, 3]) {
        expect(p.cle('emplacement_$i'), findsOneWidget);
      }
      await p.glisser('element_e1', 'ligne');
      expect(motConstruit(tester), 'فَ');
      await p.glisser('element_e4', 'ligne');
      expect(motConstruit(tester), 'فَا');
      await p.glisser('element_e2', 'ligne');
      expect(motConstruit(tester), 'فَاعِ');
      // Une lettre fausse à la 4e place.
      await p.glisser('element_e5', 'emplacement_3');
      expect(motConstruit(tester), 'فَاعِمٌ');
      expect(p.cle('emplacement_3'), findsNothing);
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      expect(
        tester.widget<Text>(p.cle('mot_construit')).style!.color,
        isNot(tester.widget<Text>(p.cle('racine_mot')).style!.color),
      );
      await p.attendreVidage();
      // Le début juste reste, م revient dans la réserve.
      expect(motConstruit(tester), 'فَاعِ');
      expect(p.dans('element_e5', 'reserve'), isTrue);
      await p.glisser('element_e6', 'ligne');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(motConstruit(tester), 'فَاعِلٌ');
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });

    testWidgets('schème juste au 1er essai, réponse affichée en aperçu', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T56-scheme.json'));
      for (final id in ['e1', 'e4', 'e2', 'e3']) {
        await p.glisser('element_$id', 'ligne');
      }
      expect(motConstruit(tester), 'فَاعِلٌ');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));

      await p.jouer(exemple('T56-scheme.json'), mode: ModeExercice.apercu);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(motConstruit(tester), 'فَاعِلٌ');
      expect(p.cle('emplacement_0'), findsNothing);
    });
  });
}
