import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_glisser.dart';
import 'outils_glisser.dart';

/// T06 Texte à trous : un trou (texte-trou) ou plusieurs (texte-trous, ex
/// T39), étiquettes en trop, le trou est une cible dans la phrase.
void main() {
  late Partie p;

  testWidgets('français, un trou : glisser l\'étiquette dans le trou, une '
      'autre la remplace, Vérifier', (tester) async {
    p = Partie(tester);
    await p.jouer(exemple('T06-texte-trou.json'));
    expect(p.sens, TextDirection.ltr);
    expect(find.byType(TuileGlissable), findsNWidgets(4));
    expect(find.byType(ZoneDepot), findsOneWidget);
    // Le trou est dans la phrase, entre « chien » et « dans ».
    expect(find.text('chien'), findsOneWidget);
    expect(
      tester.getCenter(p.cle('cible_t1')).dx,
      greaterThan(tester.getCenter(find.text('chien')).dx),
    );
    expect(p.bouton.onPressed, isNull);
    await p.glisser('element_e2', 'cible_t1');
    expect(p.dans('element_e2', 'cible_t1'), isTrue);
    expect(p.bouton.onPressed, isNotNull);
    // Une autre étiquette prend la place : la première revient.
    await p.glisser('element_e1', 'cible_t1');
    expect(p.dans('element_e1', 'cible_t1'), isTrue);
    expect(p.dans('element_e2', 'reserve'), isTrue);
    expect(p.reponsesDonnees.last, {
      'trous': [
        {'trou': 't1', 'etiquette': 'e1'},
      ],
    });
    await p.verifier();
    await tester.pumpAndSettle();
    expect(find.text('Bravo'), findsOneWidget);
    expect(p.etatGlissable('element_e1'), EtatGlissable.juste);
  });

  testWidgets('français, plusieurs trous (ex T39) : texte long en latin-body, '
      'les faux reviennent, étiquette en trop jamais posée', (tester) async {
    p = Partie(tester);
    await p.jouer(exemple('T06-texte-trous.json'));
    expect(find.byType(ZoneDepot), findsNWidgets(3));
    final mot = tester.widget<Text>(find.text('Sami')).style!;
    expect(mot.fontSize, StylesYasmina.latinBody.fontSize);
    await p.glisser('element_e1', 'cible_t1');
    await p.glisser('element_e3', 'cible_t2'); // faux
    expect(p.bouton.onPressed, isNull);
    await p.glisser('element_e2', 'cible_t3'); // faux
    await p.verifier();
    expect(p.etatGlissable('element_e3'), EtatGlissable.faux);
    expect(p.etatGlissable('element_e1'), EtatGlissable.pose);
    await p.attendreVidage();
    expect(p.dans('element_e1', 'cible_t1'), isTrue);
    expect(p.dans('element_e3', 'reserve'), isTrue);
    await p.toucher('element_e2');
    await p.toucherZone('cible_t2');
    await p.glisser('element_e3', 'cible_t3');
    await p.verifier();
    await tester.pumpAndSettle();
    expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    expect(p.dans('element_e4', 'reserve'), isTrue);
  });

  testWidgets('arabe : phrase de droite à gauche, le trou avant الْكِتَابَ', (
    tester,
  ) async {
    p = Partie(tester);
    await p.jouer(t06Arabe(), forme: FormeAdresse.feminin);
    expect(p.sens, TextDirection.rtl);
    final texte = tester.widget<Text>(find.text('الْوَلَدُ')).style!;
    expect(texte.fontFamily, PolicesYasmina.contenuArabe);
    expect(texte.fontSize, StylesYasmina.contentSentence.fontSize);
    // De droite à gauche : الْوَلَدُ à droite du trou, الْكِتَابَ à gauche.
    expect(
      tester.getCenter(find.text('الْوَلَدُ')).dx,
      greaterThan(tester.getCenter(p.cle('cible_t1')).dx),
    );
    expect(
      tester.getCenter(find.text('الْكِتَابَ.')).dx,
      lessThan(tester.getCenter(p.cle('cible_t1')).dx),
    );
    await p.toucher('element_e1');
    await p.toucherZone('cible_t1');
    expect(p.dans('element_e1', 'cible_t1'), isTrue);
    await p.verifier();
    await tester.pumpAndSettle();
    expect(find.text('أَحْسَنْتِ'), findsOneWidget);
  });
}
