import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_choix.dart';
import 'outils_choix.dart';

/// T18 Forme de la lettre et T19 Choisir la haraka (deux formes) : types
/// propres à l'écriture arabe, donc en arabe seulement (le validateur
/// refuse une autre langue : pas de cas latin).
void main() {
  late Partie p;

  group('T18 Forme de la lettre', () {
    testWidgets('mot en content-word, 4 formes grandes en ordre fixe de '
        'droite à gauche, forme du milieu juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T18-forme-lettre.json'));
      expect(p.sens, TextDirection.rtl);
      final mot = tester.widget<Text>(p.cle('choix_mot'));
      expect(mot.data, 'نَجْمَةٌ');
      expect(mot.style!.fontSize, StylesYasmina.contentWord.fontSize);
      expect(find.byType(TuileChoix), findsNWidgets(4));
      for (final id in ['c1', 'c2', 'c3', 'c4']) {
        expect(p.tuile('choix_$id').grand, isTrue);
      }
      // melanger: false : isolée, début, milieu, fin, de droite à gauche
      // (2 × 2 : c1 en haut à droite, c2 à sa gauche, c3 en dessous).
      final c1 = tester.getCenter(p.cle('choix_c1'));
      final c2 = tester.getCenter(p.cle('choix_c2'));
      final c3 = tester.getCenter(p.cle('choix_c3'));
      expect(c1.dx, greaterThan(c2.dx));
      expect(c3.dy, greaterThan(c1.dy));
      expect(c3.dx, closeTo(c1.dx, 0.5));
      final forme = tester.widget<Text>(find.text('ـجـ')).style!;
      expect(forme.fontSize, StylesYasmina.contentWord.fontSize);
      expect(forme.fontFamily, PolicesYasmina.contenuArabe);

      await p.toucher('choix_c4');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      await p.toucher('choix_c3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.etat('choix_c3'), EtatTuile.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('au féminin : libellés genrés du lecteur', (tester) async {
      p = Partie(tester);
      await p.jouer(
        exemple('T18-forme-lettre.json'),
        forme: FormeAdresse.feminin,
      );
      expect(p.bouton.libelle, 'تَحَقَّقِي');
      await p.toucher('choix_c3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتِ'), findsOneWidget);
      expect(p.bouton.libelle, 'وَاصِلِي');
    });
  });

  group('T19 Choisir la haraka, forme mot', () {
    String mot(WidgetTester tester) =>
        tester.widget<Text>(p.cle('haraka_mot')).textSpan!.toPlainText();

    testWidgets('le mot sans la haraka, puis avec celle choisie, écoute du '
        'mot après la consigne, fatha fausse puis damma juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T19-haraka.json'));
      expect(p.sens, TextDirection.rtl);
      expect(mot(tester), 'كُتبٌ');
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'اِخْتَرِ الْحَرَكَةَ الْمُنَاسِبَةَ لِحَرْفِ التَّاءِ.',
        'كُتُبٌ',
      ]);
      await p.toucher('haraka_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, 'كُتُبٌ');
      // 4 tuiles : ◌ avec la haraka en grand, le nom en dessous.
      expect(find.byType(TuileChoix), findsNWidgets(4));
      expect(find.text('فَتْحَةٌ'), findsOneWidget);
      expect(find.text('$porteurHarakaُ'), findsOneWidget);
      // La lettre cible est en blue.
      final spans =
          (tester.widget<Text>(p.cle('haraka_mot')).textSpan! as TextSpan)
              .children!
              .cast<TextSpan>();
      expect(spans[1].text, 'ت');
      expect(spans[1].style!.color, CouleursYasmina.clair.blue);

      await p.toucher('haraka_fatha');
      expect(mot(tester), 'كُتَبٌ');
      expect(p.reponsesDonnees.last, {'haraka': 'fatha'});
      await p.verifier();
      expect(p.etat('haraka_fatha'), EtatTuile.faux);
      await p.attendreVidage();
      expect(mot(tester), 'كُتبٌ');
      await p.toucher('haraka_damma');
      expect(mot(tester), 'كُتُبٌ');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.etat('haraka_damma'), EtatTuile.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('faux deux fois : la bonne haraka est révélée sur la lettre', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exemple('T19-haraka.json'));
      await p.toucher('haraka_kasra');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('haraka_soukoun');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(mot(tester), 'كُتُبٌ');
      expect(p.etat('haraka_damma'), EtatTuile.juste);
      expect(p.etat('haraka_soukoun'), EtatTuile.repos);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T19 Choisir la haraka, lettre vocalisée', () {
    testWidgets('4 lettres vocalisées en grand, بَ juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T19-lettre-vocalisee.json'));
      expect(p.sens, TextDirection.rtl);
      expect(p.cle('haraka_mot'), findsNothing);
      expect(find.byType(TuileChoix), findsNWidgets(4));
      expect(p.tuile('choix_c1').grand, isTrue);
      expect(find.text('بَ'), findsOneWidget);
      await p.toucher('choix_c2');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('choix_c1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.etat('choix_c1'), EtatTuile.juste);
      expect(p.reponsesDonnees.last, {
        'choix': ['c1'],
      });
    });
  });
}
