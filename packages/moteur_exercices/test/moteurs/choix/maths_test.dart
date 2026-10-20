import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_choix.dart';
import 'outils_choix.dart';

/// T23 Comparer et T24 Suites et motifs.
void main() {
  late Partie p;

  group('T23 Comparer', () {
    String expression(WidgetTester tester) => tester
        .widget<Text>(p.cle('comparer_expression'))
        .textSpan!
        .toPlainText();

    testWidgets('arabe : expression et signes toujours de gauche à droite, '
        'le signe choisi remplace « ? »', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T23-comparer.json'));
      expect(p.sens, TextDirection.rtl);
      expect(expression(tester), '14 ? 9');
      expect(
        Directionality.of(tester.element(p.cle('comparer_expression'))),
        TextDirection.ltr,
      );
      // < à gauche, > à droite, même en arabe.
      expect(
        tester.getCenter(p.cle('signe_<')).dx,
        lessThan(tester.getCenter(p.cle('signe_=')).dx),
      );
      expect(
        tester.getCenter(p.cle('signe_=')).dx,
        lessThan(tester.getCenter(p.cle('signe_>')).dx),
      );
      expect(p.tuile('signe_>').grand, isTrue);
      await p.toucher('signe_<');
      expect(expression(tester), '14 < 9');
      expect(p.reponsesDonnees.last, {'signe': '<'});
      await p.verifier();
      expect(p.etat('signe_<'), EtatTuile.faux);
      await p.attendreVidage();
      expect(expression(tester), '14 ? 9');
      await p.toucher('signe_>');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(
        find.text('إِجَابَتُكَ صَحِيحَةٌ: 14 أَكْبَرُ مِنْ 9.'),
        findsOneWidget,
      );
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : 7 < 12 au 1er essai', (tester) async {
      p = Partie(tester);
      await p.jouer(t23Francais());
      expect(p.sens, TextDirection.ltr);
      expect(expression(tester), '7 ? 12');
      await p.toucher('signe_<');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Oui : 7 est plus petit que 12.'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });
  });

  group('T24 Suites et motifs', () {
    String inconnue(WidgetTester tester) => tester
        .widget<Text>(
          find.descendant(
            of: p.cle('choix_suite_inconnue'),
            matching: find.byType(Text),
          ),
        )
        .data!;

    testWidgets('arabe : la suite de droite à gauche, la case « ? » montre '
        'le choix, images avec libellé neutre', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T24-suite.json'));
      expect(p.sens, TextDirection.rtl);
      expect(inconnue(tester), '?');
      // Le premier élément de la suite est à droite de la case « ? ».
      final suite = tester.getTopRight(p.cle('choix_suite'));
      final caseInconnue = tester.getCenter(p.cle('choix_suite_inconnue'));
      expect(caseInconnue.dx, lessThan(suite.dx));
      expect(find.byType(TuileChoix), findsNWidgets(3));
      expect(p.tuile('choix_c2').libelleAccessibilite, startsWith('صُورَةٌ '));
      await p.toucher('choix_c1');
      expect(inconnue(tester), '🔵');
      await p.verifier();
      await p.attendreVidage();
      expect(inconnue(tester), '?');
      await p.toucher('choix_c2');
      expect(inconnue(tester), '🔺');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : pomme après banane', (tester) async {
      p = Partie(tester);
      await p.jouer(t24Francais());
      expect(p.sens, TextDirection.ltr);
      final suite = tester.getTopLeft(p.cle('choix_suite'));
      expect(
        tester.getCenter(p.cle('choix_suite_inconnue')).dx,
        greaterThan(suite.dx),
      );
      await p.toucher('choix_c2');
      expect(inconnue(tester), '🍎');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(
        find.text('Oui : après la banane revient la pomme.'),
        findsOneWidget,
      );
    });
  });
}
