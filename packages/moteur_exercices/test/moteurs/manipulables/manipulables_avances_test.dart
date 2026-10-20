import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../glisser/outils_glisser.dart';
import 'fixtures_manipulables.dart';

/// T26 Monnaie, T29 Fractions et T52 Modèle en barres
/// (docs/moteurs/manipulables.md §14) : vrai geste de glisser, toucher en
/// secours, retrait par glisser ou toucher, cas arabe et cas latin,
/// déroulé complet.
void main() {
  late Partie p;

  String total(WidgetTester tester) =>
      tester.widget<Text>(p.cle('monnaie_total')).data!;

  String compte(WidgetTester tester) =>
      tester.widget<Text>(p.cle('fraction_compte')).data!;

  Set<int> coloriees(WidgetTester tester) =>
      (tester.widget<CustomPaint>(p.cle('fraction_dessin')).painter!
              as PeintreFraction)
          .coloriees;

  String inconnue(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(of: p.cle('inconnue'), matching: find.byType(Text)),
      )
      .data!;

  group('T26 Monnaie', () {
    testWidgets('arabe : pièces glissées ou touchées dans le porte-monnaie, '
        'montant en clair, retrait par glisser et au toucher, juste', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T26-monnaie.json'));
      expect(p.sens, TextDirection.rtl);
      // Réserve de la plus grande à la plus petite pièce, au début de ligne.
      expect(find.byType(Piece), findsNWidgets(5));
      expect(
        tester.getCenter(p.cle('reserve_piece_1000')).dy,
        lessThan(tester.getCenter(p.cle('reserve_piece_50')).dy),
      );
      expect(
        tester.getCenter(p.cle('reserve')).dx,
        greaterThan(tester.getCenter(p.cle('porte_monnaie')).dx),
      );
      expect(total(tester), 'الْمَجْمُوعُ: 0 م');
      expect(p.bouton.onPressed, isNull);
      await p.glisser('reserve_piece_1000', 'porte_monnaie');
      await p.glisser('reserve_piece_1000', 'porte_monnaie');
      // La réserve est inépuisable.
      expect(p.cle('reserve_piece_1000'), findsOneWidget);
      await p.glisser('reserve_piece_500', 'porte_monnaie');
      await p.toucher('reserve_piece_200');
      expect(p.reponsesDonnees.last, {'montant': 2700});
      expect(total(tester), 'الْمَجْمُوعُ: 2 د وَ700 م');
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(4));
      // Une pièce posée glissée hors du porte-monnaie est retirée, touchée
      // aussi, relâchée dedans elle reste.
      await p.glisserHors('piece_posee_3');
      expect(p.reponsesDonnees.last, {'montant': 2500});
      await p.toucher('piece_posee_2');
      expect(p.reponsesDonnees.last, {'montant': 2000});
      await p.glisser('piece_posee_0', 'porte_monnaie');
      expect(p.reponsesDonnees.last, {'montant': 2000});
      await p.toucher('reserve_piece_500');
      await p.toucher('reserve_piece_200');
      expect(total(tester), 'الْمَجْمُوعُ: 2 د وَ700 م');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('français : faux puis tout revient au départ, faux deux fois '
        'révèle la décomposition par les plus grandes pièces', (tester) async {
      p = Partie(tester);
      await p.jouer(t26Francais());
      expect(p.sens, TextDirection.ltr);
      await p.toucher('reserve_piece_500');
      await p.toucher('reserve_piece_500');
      expect(total(tester), 'Total: 1 D');
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(total(tester), 'Total: 0 m');
      expect(find.byType(Piece), findsNWidgets(5));
      await p.toucher('reserve_piece_100');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.cle('manipulables_reponse'), findsOneWidget);
      // 1 D 250 m par les plus grandes pièces : 1000, 200, 50.
      expect(total(tester), 'Total: 1 D et 250 m');
      expect(find.byType(Piece), findsNWidgets(5 + 3));
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T29 Fractions', () {
    testWidgets('arabe, disque : parts touchées et décoloriées, compte, faux '
        'puis vidé, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T29-fraction.json'));
      expect(p.sens, TextDirection.rtl);
      expect(compte(tester), '0 مِنْ 4');
      expect(p.bouton.onPressed, isNull);
      for (var i = 0; i < 4; i++) {
        final r = tester.getRect(p.cle('part_$i'));
        expect(r.width, EspacesYasmina.targetMin);
        expect(r.height, EspacesYasmina.targetMin);
      }
      await p.toucher('part_0');
      await p.toucher('part_1');
      expect(coloriees(tester), {0, 1});
      expect(compte(tester), '2 مِنْ 4');
      expect(p.reponsesDonnees.last, {'parts': 2});
      await p.toucher('part_1');
      expect(coloriees(tester), {0});
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(coloriees(tester), isEmpty);
      await p.toucher('part_3');
      await p.toucher('part_2');
      await p.toucher('part_0');
      expect(compte(tester), '3 مِنْ 4');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français, rectangle : faux deux fois révèle les premières '
        'parts, aperçu', (tester) async {
      p = Partie(tester);
      await p.jouer(t29Rectangle());
      // Bandes de gauche à droite.
      expect(
        tester.getCenter(p.cle('part_0')).dx,
        lessThan(tester.getCenter(p.cle('part_4')).dx),
      );
      await p.toucher('part_0');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('part_0');
      await p.toucher('part_1');
      await p.toucher('part_2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('manipulables_reponse'), findsOneWidget);
      expect(coloriees(tester), {0, 1});
      expect(compte(tester), '2 sur 5');
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T52 Modèle en barres', () {
    testWidgets('arabe : problème dit après la consigne, nombres glissés '
        'dans les segments, inconnue écrite au pavé, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleManipulables('T52-modele-barres.json'));
      expect(
        p.audio.audioFactice.dits.map((d) => d.texte).last,
        startsWith('مَعَ سَامِي'),
      );
      expect(p.cle('barres_texte'), findsOneWidget);
      expect(find.byType(TuileGlissable), findsNWidgets(4));
      expect(inconnue(tester), '?');
      expect(p.bouton.onPressed, isNull);
      // Les deux « 23 » sont interchangeables.
      final vingtTrois = ['e1', 'e2'];
      await p.glisser('element_${vingtTrois[1]}', 'segment_s1');
      await p.glisser('element_${vingtTrois[0]}', 'segment_s2');
      expect(p.dans('element_e2', 'segment_s1'), isTrue);
      // Toucher-toucher sur le dernier segment, avec l'intrus.
      await p.toucher('element_e4');
      await p.toucherZone('segment_s3');
      expect(p.dans('element_e4', 'segment_s3'), isTrue);
      expect(p.bouton.onPressed, isNull);
      await p.toucher('touche_3');
      await p.toucher('touche_5');
      expect(inconnue(tester), '35');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      // L'intrus revient seul, les bons placements et la valeur restent.
      expect(p.etatGlissable('element_e4'), EtatGlissable.faux);
      await p.attendreVidage();
      expect(p.dans('element_e4', 'reserve'), isTrue);
      expect(p.dans('element_e2', 'segment_s1'), isTrue);
      expect(inconnue(tester), '35');
      await p.glisser('element_e3', 'segment_s3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
      final reponse = p.reponsesDonnees.last as Map;
      expect(reponse['valeur'], 35);
      expect(
        (reponse['placements'] as List).map((pl) => (pl as Map)['segment']),
        unorderedEquals(['s1', 's2', 's3']),
      );
    });

    testWidgets('français, segment inconnu : Effacer du pavé, valeur fausse '
        'effacée après l\'indice, réponse révélée', (tester) async {
      p = Partie(tester);
      await p.jouer(t52SegmentInconnu());
      expect(p.sens, TextDirection.ltr);
      await p.glisser('element_e1', 'segment_s1');
      // Le segment inconnu ne reçoit pas d'étiquette.
      await p.glisser('element_e2', 'inconnue');
      expect(p.dans('element_e2', 'reserve'), isTrue);
      await p.toucher('touche_1');
      await p.toucher('touche_2');
      expect(inconnue(tester), '12');
      await p.toucher('touche_effacer');
      expect(inconnue(tester), '1');
      await p.toucher('touche_0');
      expect(inconnue(tester), '10');
      await p.verifier();
      await p.attendreVidage();
      expect(inconnue(tester), '?');
      expect(p.dans('element_e1', 'segment_s1'), isTrue);
      await p.toucher('touche_7');
      await p.toucher('touche_7');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('lecteur_feedback_explication'), findsOneWidget);
      expect(p.cle('manipulables_reponse'), findsOneWidget);
      expect(inconnue(tester), '7');
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });
}
