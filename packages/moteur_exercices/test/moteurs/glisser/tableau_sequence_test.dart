import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_glisser.dart';
import 'outils_glisser.dart';

/// T12 Tableau de tri (arabe seulement), T14 Séquence d'images, T16
/// Construire un mot avec des syllabes (jamais en arabe).
void main() {
  late Partie p;

  String motConstruit(WidgetTester tester) =>
      tester.widget<Text>(p.cle('mot_construit')).data!;

  testWidgets('T12 arabe : colonnes de droite à gauche, titres sans emoji, '
      'mots seuls, tous classés', (tester) async {
    p = Partie(tester);
    await p.jouer(exemple('T12-tableau-tri.json'));
    expect(p.sens, TextDirection.rtl);
    expect(
      tester.getCenter(p.cle('cible_k1')).dx,
      greaterThan(tester.getCenter(p.cle('cible_k2')).dx),
    );
    expect(find.text('لَامٌ شَمْسِيَّةٌ'), findsOneWidget);
    expect(find.text('☀️ لَامٌ شَمْسِيَّةٌ'), findsNothing);
    for (final (e, k) in [
      ('e1', 'k1'),
      ('e2', 'k2'),
      ('e3', 'k1'),
      ('e4', 'k2'),
      ('e5', 'k1'),
      ('e6', 'k2'),
    ]) {
      await p.glisser('element_$e', 'cible_$k');
    }
    await p.verifier();
    await tester.pumpAndSettle();
    expect(find.text('أَحْسَنْتَ'), findsOneWidget);
    expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
  });

  testWidgets('T14 arabe : grandes tuiles, la ligne se remplit de droite à '
      'gauche', (tester) async {
    p = Partie(tester);
    await p.jouer(exemple('T14-sequence-images.json'));
    expect(p.sens, TextDirection.rtl);
    expect(p.glissable('element_e1').grand, isTrue);
    expect(find.text('🥚'), findsOneWidget);
    for (final e in ['e1', 'e2', 'e3', 'e4']) {
      await p.glisser('element_$e', 'ligne_fin');
    }
    expect(
      tester.getCenter(p.cle('pose_e1')).dx,
      greaterThan(tester.getCenter(p.cle('pose_e4')).dx),
    );
    await p.verifier();
    await tester.pumpAndSettle();
    expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
  });

  testWidgets('T14 français : de gauche à droite, ordre faux deux fois, '
      'réponse révélée', (tester) async {
    p = Partie(tester);
    await p.jouer(t14Francais());
    expect(p.sens, TextDirection.ltr);
    for (final e in ['e4', 'e3', 'e2', 'e1']) {
      await p.glisser('element_$e', 'ligne_fin');
    }
    expect(
      tester.getCenter(p.cle('pose_e4')).dx,
      lessThan(tester.getCenter(p.cle('pose_e1')).dx),
    );
    await p.verifier();
    await p.attendreVidage();
    // Rien de juste au début : tout est revenu.
    expect(p.cle('pose_e4'), findsNothing);
    for (final e in ['e2', 'e1', 'e3', 'e4']) {
      await p.glisser('element_$e', 'ligne_fin');
    }
    await p.verifier();
    await tester.pumpAndSettle();
    expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
    expect(p.etatGlissable('pose_e1'), EtatGlissable.juste);
    expect(
      tester.getCenter(p.cle('pose_e1')).dx,
      lessThan(tester.getCenter(p.cle('pose_e2')).dx),
    );
  });

  testWidgets('T16 français : syllabes collées, mot entendu, syllabes en '
      'trop, juste', (tester) async {
    p = Partie(tester);
    await p.jouer(exemple('T16-mot-syllabes.json'));
    expect(p.sens, TextDirection.ltr);
    expect(p.audio.audioFactice.dits.map((d) => d.texte), [
      'Écoute et construis le mot avec les syllabes.',
      'tomate',
    ]);
    expect(find.byType(TuileGlissable), findsNWidgets(5));
    await p.glisser('element_e1', 'ligne');
    await p.glisser('element_e2', 'ligne');
    expect(motConstruit(tester), 'toma');
    final style = tester.widget<Text>(p.cle('mot_construit')).style!;
    expect(style.fontFamily, PolicesYasmina.latin);
    expect(style.fontSize, StylesYasmina.contentWord.fontSize);
    await p.glisser('element_e4', 'ligne');
    expect(motConstruit(tester), 'tomapi');
    // Effacer retire la dernière syllabe (corrections du 20 oct.).
    await p.toucher('ordre_effacer');
    expect(motConstruit(tester), 'toma');
    await p.glisser('element_e3', 'ligne');
    await p.verifier();
    await tester.pumpAndSettle();
    expect(
      find.text('Oui : to, ma, te. Le mot est « tomate ».'),
      findsOneWidget,
    );
    expect(p.dans('element_e5', 'reserve'), isTrue);
  });
}
