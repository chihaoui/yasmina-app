import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_choix.dart';
import 'outils_choix.dart';

/// T01 QCM, T04 Trouve l'intrus, T05 Choix multiple : grille de tuiles,
/// support facultatif (texte, emoji, écoute).
void main() {
  late Partie p;

  group('T01 QCM', () {
    testWidgets('arabe : grille 2 × 2 remplie de droite à gauche, faux puis '
        'juste, événements', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T01-qcm-texte-image.json'));
      expect(p.sens, TextDirection.rtl);
      expect(find.byType(TuileChoix), findsNWidgets(4));
      // Même mélange que le moteur (graine 1) : la première tuile affichée
      // est en haut à droite.
      final ordre = ['c1', 'c2', 'c3', 'c4']..shuffle(Random(1));
      final premiere = tester.getCenter(p.cle('choix_${ordre[0]}'));
      final deuxieme = tester.getCenter(p.cle('choix_${ordre[1]}'));
      final troisieme = tester.getCenter(p.cle('choix_${ordre[2]}'));
      expect(premiere.dx, greaterThan(deuxieme.dx));
      expect(premiere.dy, closeTo(deuxieme.dy, 0.5));
      expect(troisieme.dy, greaterThan(premiere.dy));
      expect(find.text('🐟'), findsOneWidget);
      expect(p.bouton.onPressed, isNull);

      await p.toucher('choix_c2');
      expect(p.etat('choix_c2'), EtatTuile.selectionne);
      // Sélection unique : une autre tuile déplace la sélection.
      await p.toucher('choix_c3');
      expect(p.etat('choix_c2'), EtatTuile.repos);
      expect(p.etat('choix_c3'), EtatTuile.selectionne);
      await p.verifier();
      expect(p.etat('choix_c3'), EtatTuile.faux);
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      expect(p.humeur, HumeurYasmina.encourage);
      await p.attendreVidage();
      expect(p.etat('choix_c3'), EtatTuile.repos);

      await p.toucher('choix_c1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.etat('choix_c1'), EtatTuile.juste);
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.bouton.libelle, 'وَاصِلْ');
      expect(p.reponsesDonnees, [
        {
          'choix': ['c2'],
        },
        {
          'choix': ['c3'],
        },
        {
          'choix': ['c1'],
        },
      ]);
      expect(p.essais, [
        const Essai(1, juste: false),
        const Essai(2, juste: true),
      ]);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
      expect(p.audio.audioFactice.sons, [
        SonInterface.essaiFaux,
        SonInterface.juste,
      ]);
      expect(p.audio.vibrationFactice.legeres, 3);
    });

    testWidgets('arabe, scène : support texte sur deux lignes et emoji', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T01-qcm-scene.json'));
      expect(p.cle('choix_support_emoji'), findsOneWidget);
      final support = tester.widget<Text>(p.cle('choix_support_texte'));
      expect(support.data, contains('\n'));
      expect(support.style!.fontSize, StylesYasmina.contentSentence.fontSize);
      expect(p.cle('choix_ecouter'), findsNothing);
    });

    testWidgets('arabe, contraire : le mot du support en content-word', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T01-qcm-contraire.json'));
      final support = tester.widget<Text>(p.cle('choix_support_texte'));
      expect(support.data, 'كَبِيرٌ');
      expect(support.style!.fontSize, StylesYasmina.contentWord.fontSize);
    });

    testWidgets('français, orthographe : écoute du support après la consigne, '
        'bouton Écouter, tuiles en latin-prompt', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T01-qcm-orthographe.json'));
      expect(p.sens, TextDirection.ltr);
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'Écoute et touche le mot bien écrit.',
        'lapin',
      ]);
      expect(p.demandesAudio.last.origine, OrigineAudio.ecoute);
      expect(find.text('🐰'), findsOneWidget);
      await p.toucher('choix_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, 'lapin');
      expect(p.audio.audioFactice.dits, hasLength(3));
      final tuile = tester.widget<Text>(find.text('lapain')).style!;
      expect(tuile.fontSize, StylesYasmina.latinPrompt.fontSize);
      expect(tuile.fontFamily, PolicesYasmina.latin);
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });
  });

  group("T04 Trouve l'intrus", () {
    testWidgets('français : 4 tuiles, faux deux fois, réponse révélée', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T04-intrus.json'));
      expect(find.byType(TuileChoix), findsNWidgets(4));
      await p.toucher('choix_c1');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.etat('choix_c3'), EtatTuile.juste);
      expect(p.etat('choix_c2'), EtatTuile.repos);
      expect(p.tuile('choix_c3').onTap, isNull);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });

    testWidgets('arabe au féminin : consigne genrée, de droite à gauche', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t04Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      expect(
        find.text('اِخْتَارِي الْكَلِمَةَ الَّتِي لَيْسَتْ فَاكِهَةً.'),
        findsOneWidget,
      );
      // Ordre fixe : c1 en haut à droite, c2 à sa gauche.
      expect(
        tester.getCenter(p.cle('choix_c1')).dx,
        greaterThan(tester.getCenter(p.cle('choix_c2')).dx),
      );
      final tuile = tester.widget<Text>(find.text('كُرْسِيٌّ')).style!;
      expect(tuile.fontFamily, PolicesYasmina.contenuArabe);
      expect(tuile.fontSize, StylesYasmina.contentOption.fontSize);
      await p.toucher('choix_c3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتِ'), findsOneWidget);
      expect(p.bouton.libelle, 'وَاصِلِي');
    });
  });

  group('T05 Choix multiple', () {
    testWidgets('arabe : 5 tuiles sur 3 colonnes, sélection multiple, '
        'bascule, ensemble exact', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T05-choix-multiple.json'));
      expect(find.byType(TuileChoix), findsNWidgets(5));
      final ordre = ['c1', 'c2', 'c3', 'c4', 'c5']..shuffle(Random(1));
      // 3 colonnes : les 3 premières sur une ligne, la 4e en dessous.
      final y = [
        for (final id in ordre) tester.getCenter(p.cle('choix_$id')).dy,
      ];
      expect(y[0], closeTo(y[2], 0.5));
      expect(y[3], greaterThan(y[0]));
      await p.toucher('choix_c1');
      await p.toucher('choix_c3');
      await p.toucher('choix_c4');
      await p.toucher('choix_c4');
      expect(p.etat('choix_c1'), EtatTuile.selectionne);
      expect(p.etat('choix_c3'), EtatTuile.selectionne);
      expect(p.etat('choix_c4'), EtatTuile.repos);
      expect(p.reponsesDonnees.last, {
        'choix': [
          for (final id in ordre)
            if (id == 'c1' || id == 'c3') id,
        ],
      });
      // Il manque c5 : faux.
      await p.verifier();
      expect(p.etat('choix_c1'), EtatTuile.faux);
      expect(p.etat('choix_c3'), EtatTuile.faux);
      expect(p.etat('choix_c5'), EtatTuile.repos);
      await p.attendreVidage();
      for (final id in ordre) {
        expect(p.etat('choix_$id'), EtatTuile.repos);
      }
      await p.toucher('choix_c1');
      await p.toucher('choix_c3');
      await p.toucher('choix_c5');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : juste au 1er essai, aperçu avec réponse affichée', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t05Francais());
      await p.toucher('choix_c1');
      await p.toucher('choix_c3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(
        find.text('Oui : le chat et le chien sont des animaux.'),
        findsOneWidget,
      );
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));

      await p.jouer(t05Francais(), mode: ModeExercice.apercu);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.etat('choix_c1'), EtatTuile.juste);
      expect(p.etat('choix_c3'), EtatTuile.juste);
      expect(p.etat('choix_c2'), EtatTuile.repos);
      expect(find.text('bonne réponse'), findsNWidgets(2));
      expect(p.essais, isEmpty);
    });
  });
}
