import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_choix.dart';
import 'outils_choix.dart';

/// T46 Réponse puis justification : partie A (réponse), partie B (preuve),
/// Vérifier seulement quand les deux sont choisies.
void main() {
  late Partie p;

  testWidgets('français : texte en latin-body, question en latin-prompt, '
      'les deux parties, preuves en pleine largeur et dans l\'ordre du texte', (
    tester,
  ) async {
    p = Partie(tester);
    await p.jouer(exemple('T46-justification.json'));
    expect(p.sens, TextDirection.ltr);
    final texte = tester.widget<Text>(p.cle('justification_texte'));
    expect(texte.style!.fontSize, StylesYasmina.latinBody.fontSize);
    final question = tester.widget<Text>(p.cle('justification_question'));
    expect(question.style!.fontSize, StylesYasmina.latinPrompt.fontSize);
    expect(find.byType(TuileChoix), findsNWidgets(5));
    // Preuves pleine largeur, dans l'ordre du texte.
    final y = [
      for (var i = 1; i <= 3; i++) tester.getTopLeft(p.cle('preuve_p$i')).dy,
    ];
    expect(y[0], lessThan(y[1]));
    expect(y[1], lessThan(y[2]));
    expect(
      tester.getSize(p.cle('preuve_p1')).width,
      greaterThan(tester.getSize(p.cle('choix_c1')).width),
    );

    expect(p.bouton.onPressed, isNull);
    await p.toucher('choix_c2');
    expect(p.bouton.onPressed, isNull);
    await p.toucher('preuve_p1');
    expect(p.bouton.onPressed, isNotNull);
    expect(p.reponsesDonnees.last, {
      'choix': ['c2'],
      'preuves': ['p1'],
    });
    // Bonne réponse, mauvaise preuve : faux, les deux parties vidées.
    await p.verifier();
    expect(p.etat('choix_c2'), EtatTuile.faux);
    expect(p.etat('preuve_p1'), EtatTuile.faux);
    await p.attendreVidage();
    expect(p.etat('choix_c2'), EtatTuile.repos);
    expect(p.etat('preuve_p1'), EtatTuile.repos);
    await p.toucher('choix_c2');
    await p.toucher('preuve_p3');
    await p.verifier();
    await tester.pumpAndSettle();
    expect(p.etat('choix_c2'), EtatTuile.juste);
    expect(p.etat('preuve_p3'), EtatTuile.juste);
    expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
  });

  testWidgets(
    'arabe au féminin : de droite à gauche, texte en content-sentence, '
    'explication révèle réponse et preuve',
    (tester) async {
      p = Partie(tester);
      await p.jouer(t46Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      final texte = tester.widget<Text>(p.cle('justification_texte'));
      expect(texte.style!.fontSize, StylesYasmina.contentSentence.fontSize);
      expect(texte.style!.fontFamily, PolicesYasmina.contenuArabe);
      expect(find.text('هَلْ بَقِيَ آدَمُ جَافًّا؟'), findsOneWidget);
      // Partie A : نَعَمْ (c1) à droite de لَا (c2).
      expect(
        tester.getCenter(p.cle('choix_c1')).dx,
        greaterThan(tester.getCenter(p.cle('choix_c2')).dx),
      );
      await p.toucher('choix_c1');
      await p.toucher('preuve_p3');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('choix_c1');
      await p.toucher('preuve_p2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.etat('choix_c2'), EtatTuile.juste);
      expect(p.etat('preuve_p3'), EtatTuile.juste);
      expect(p.etat('choix_c1'), EtatTuile.repos);
      expect(p.bouton.libelle, 'وَاصِلِي');
    },
  );
}
