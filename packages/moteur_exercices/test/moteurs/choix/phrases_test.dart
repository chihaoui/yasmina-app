import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_choix.dart';
import 'outils_choix.dart';

/// T45 Barrer l'élément faux et T61 Résumé par sélection : phrases en
/// tuiles pleine largeur, sélection multiple, texte long au-dessus.
void main() {
  late Partie p;

  group("T45 Barrer l'élément faux", () {
    testWidgets('français : support en latin-body, phrases pleine largeur, '
        'barrées au toucher, les deux fausses', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T45-barrer.json'));
      expect(p.sens, TextDirection.ltr);
      final support = tester.widget<Text>(p.cle('choix_support_texte'));
      expect(support.style!.fontSize, StylesYasmina.latinBody.fontSize);
      expect(support.style!.fontFamily, PolicesYasmina.latin);
      // Pleine largeur : les 4 tuiles ont la même abscisse et se suivent.
      final x = [
        for (var i = 1; i <= 4; i++) tester.getTopLeft(p.cle('choix_c$i')).dx,
      ];
      expect(x.toSet(), hasLength(1));
      final largeur = tester.getSize(p.cle('choix_c1')).width;
      expect(
        largeur,
        greaterThan(tester.getSize(find.byType(GrilleChoix)).width * 0.9),
      );

      await p.toucher('choix_c1');
      expect(p.tuile('choix_c1').barre, isTrue);
      expect(p.tuile('choix_c2').barre, isFalse);
      final style = tester
          .widget<Text>(find.text('Nour arrose les fleurs le soir.'))
          .style!;
      expect(style.decoration, TextDecoration.lineThrough);
      await p.toucher('choix_c3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.etat('choix_c1'), EtatTuile.juste);
      expect(p.etat('choix_c3'), EtatTuile.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('arabe : de droite à gauche, support en content-sentence, '
        'faux puis explication barrée révélée', (tester) async {
      p = Partie(tester);
      await p.jouer(t45Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      final support = tester.widget<Text>(p.cle('choix_support_texte'));
      expect(support.style!.fontSize, StylesYasmina.contentSentence.fontSize);
      expect(support.style!.fontFamily, PolicesYasmina.contenuArabe);
      expect(
        find.text(
          'اِقْرَئِي النَّصَّ، ثُمَّ ضَعِي خَطًّا عَلَى الْجُمَلِ الْخَاطِئَةِ.',
        ),
        findsOneWidget,
      );
      await p.toucher('choix_c1');
      await p.verifier();
      await p.attendreVidage();
      expect(p.tuile('choix_c1').barre, isFalse);
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.etat('choix_c1'), EtatTuile.juste);
      expect(p.etat('choix_c3'), EtatTuile.juste);
      expect(p.etat('choix_c2'), EtatTuile.repos);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T61 Résumé par sélection', () {
    testWidgets(
      'français : texte en latin-body, 5 phrases, les trois du résumé',
      (tester) async {
        p = Partie(tester);
        await p.jouer(exemple('T61-resume.json'));
        final texte = tester.widget<Text>(p.cle('choix_support_texte'));
        expect(texte.style!.fontSize, StylesYasmina.latinBody.fontSize);
        expect(find.byType(TuileChoix), findsNWidgets(5));
        await p.toucher('choix_c1');
        await p.toucher('choix_c3');
        await p.toucher('choix_c5');
        expect(p.tuile('choix_c1').barre, isFalse);
        await p.verifier();
        await tester.pumpAndSettle();
        expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
        expect(p.reponsesDonnees.last, {
          'choix': unorderedEquals(['c1', 'c3', 'c5']),
        });
      },
    );

    testWidgets('arabe : de droite à gauche, deux phrases seulement : faux', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t61Arabe());
      expect(p.sens, TextDirection.rtl);
      final texte = tester.widget<Text>(p.cle('choix_support_texte'));
      expect(texte.style!.fontFamily, PolicesYasmina.contenuArabe);
      expect(
        find.text(
          'اِخْتَرِ الْجُمَلَ الثَّلَاثَ الَّتِي تُلَخِّصُ الْقِصَّةَ.',
        ),
        findsOneWidget,
      );
      await p.toucher('choix_c1');
      await p.toucher('choix_c3');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      expect(p.audio.audioFactice.sons, [SonInterface.essaiFaux]);
    });
  });
}
