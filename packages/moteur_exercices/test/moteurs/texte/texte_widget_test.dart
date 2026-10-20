import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_texte.dart';

/// T07 Toucher les mots et T17 Dictée au clavier (docs/moteurs/texte.md).
void main() {
  late Partie p;

  String saisie(WidgetTester tester) =>
      tester.widget<Text>(p.cle('dictee_saisie')).data!;

  group('T07 Toucher les mots', () {
    testWidgets('arabe : mots de droite à gauche, sélection unique, faux '
        'puis juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleTexte('T07-toucher-mots.json'));
      expect(p.sens, TextDirection.rtl);
      final mots = tester.widgetList<MotTouchable>(find.byType(MotTouchable));
      expect(mots.map((m) => m.texte), [
        'يَقْرَأُ',
        'الْوَلَدُ',
        'قِصَّةً',
        'جَمِيلَةً.',
      ]);
      expect(
        tester.getCenter(p.cle('mot_0')).dx,
        greaterThan(tester.getCenter(p.cle('mot_1')).dx),
      );
      expect(p.bouton.onPressed, isNull);
      await p.toucher('mot_1');
      expect(p.reponsesDonnees.last, {
        'mots': [1],
      });
      // Sélection unique : un autre mot déplace la sélection.
      await p.toucher('mot_2');
      expect(p.reponsesDonnees.last, {
        'mots': [2],
      });
      expect(tester.widget<MotTouchable>(p.cle('mot_1')).etat, EtatMot.repos);
      await p.verifier();
      expect(tester.widget<MotTouchable>(p.cle('mot_2')).etat, EtatMot.faux);
      await p.attendreVidage();
      expect(tester.widget<MotTouchable>(p.cle('mot_2')).etat, EtatMot.repos);
      await p.toucher('mot_0');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(tester.widget<MotTouchable>(p.cle('mot_0')).etat, EtatMot.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : sélection multiple, toucher retire, faux deux '
        'fois révèle les bons mots', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleTexte('T07-toucher-mots-fr.json'));
      expect(p.sens, TextDirection.ltr);
      await p.toucher('mot_1');
      await p.toucher('mot_2');
      await p.toucher('mot_1');
      expect(p.reponsesDonnees.last, {
        'mots': [2],
      });
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('mot_0');
      await p.toucher('mot_1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(tester.widget<MotTouchable>(p.cle('mot_1')).etat, EtatMot.juste);
      expect(tester.widget<MotTouchable>(p.cle('mot_5')).etat, EtatMot.juste);
      expect(tester.widget<MotTouchable>(p.cle('mot_0')).etat, EtatMot.repos);
      expect(tester.widget<MotTouchable>(p.cle('mot_0')).onTap, isNull);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T17 Dictée au clavier', () {
    testWidgets('arabe : mot dit après la consigne, clavier du moteur, '
        'Effacer, harakat ignorées, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleTexte('T17-dictee.json'));
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'اِسْتَمِعْ وَاكْتُبِ الْكَلِمَةَ.',
        'قَلَمٌ',
      ]);
      await p.toucher('dictee_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, 'قَلَمٌ');
      // Le mot n'est jamais affiché.
      expect(find.text('قَلَمٌ'), findsNothing);
      expect(p.cle('clavier'), findsOneWidget);
      expect(p.cle('clavier_harakat'), findsNothing);
      expect(p.cle('dictee_champ'), findsNothing);
      expect(p.bouton.onPressed, isNull);
      await p.toucher('touche_ق');
      await p.toucher('touche_ل');
      await p.toucher('touche_ن');
      expect(saisie(tester), 'قلن');
      expect(p.reponsesDonnees.last, {'texte': 'قلن'});
      await p.toucher('touche_effacer');
      await p.toucher('touche_م');
      expect(saisie(tester), 'قلم');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('arabe avec harakat : rangée de harakat, comparaison '
        'exacte, faux puis vidé, faux deux fois révèle le mot', (tester) async {
      p = Partie(tester);
      await p.jouer(t17Harakat(), forme: FormeAdresse.feminin);
      expect(p.cle('clavier_harakat'), findsOneWidget);
      expect(find.text('اِمْسَحِي'), findsOneWidget);
      await p.toucher('touche_ب');
      await p.toucher('touche_ا');
      await p.toucher('touche_ب');
      expect(saisie(tester), 'باب');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(saisie(tester).trim(), isEmpty);
      await p.toucher('touche_ب');
      await p.toucher('touche_َ');
      await p.toucher('touche_ا');
      await p.toucher('touche_ب');
      await p.toucher('touche_ُ');
      expect(saisie(tester), 'بَابُ');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.cle('dictee_reponse'), findsOneWidget);
      expect(saisie(tester), 'بَابٌ');
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });

    testWidgets('français : clavier système, casse ignorée, aperçu', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleTexte('T17-dictee-fr.json'));
      expect(p.cle('clavier'), findsNothing);
      expect(p.cle('dictee_champ'), findsOneWidget);
      expect(p.cle('dictee_emoji'), findsOneWidget);
      await tester.enterText(p.cle('dictee_champ'), 'Poule ');
      await tester.pump();
      expect(p.reponsesDonnees.last, {'texte': 'Poule '});
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);

      await p.jouer(
        exempleTexte('T17-dictee-fr.json'),
        mode: ModeExercice.apercu,
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('dictee_reponse'), findsOneWidget);
      expect(
        tester.widget<TextField>(p.cle('dictee_champ')).controller!.text,
        'poule',
      );
      expect(find.text('juste'), findsOneWidget);
    });
  });
}
