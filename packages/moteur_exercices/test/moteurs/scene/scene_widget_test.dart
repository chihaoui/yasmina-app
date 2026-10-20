import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../glisser/outils_glisser.dart';
import 'fixtures_scene.dart';

/// T08 Hot spot sur image et T47 Étiqueter un schéma
/// (docs/moteurs/scene-image.md).
void main() {
  late Partie p;

  EtatZone etatZone(WidgetTester tester, String id) =>
      tester.widget<ZoneTouchable>(p.cle('zone_$id')).etat;

  group('T08 Hot spot sur image', () {
    testWidgets('arabe : scène dessinée, zones d\'au moins 48 dp, sélection '
        'unique, faux puis juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleScene('T08-hot-spot.json'));
      expect(p.sens, TextDirection.rtl);
      expect(p.cle('scene_formes'), findsOneWidget);
      expect(p.cle('scene_emoji_0'), findsOneWidget);
      expect(find.byType(ZoneTouchable), findsNWidgets(4));
      // La scène ne se retourne pas : z1 (x 0,05) reste à gauche de z2.
      expect(
        tester.getCenter(p.cle('zone_z1')).dx,
        lessThan(tester.getCenter(p.cle('zone_z2')).dx),
      );
      expect(tester.getSize(p.cle('zone_z1')).height, greaterThanOrEqualTo(48));
      // Libellé neutre.
      expect(
        tester.widget<ZoneTouchable>(p.cle('zone_z1')).libelle,
        'صُورَةٌ 1',
      );
      expect(p.bouton.onPressed, isNull);
      await p.toucher('zone_z2');
      expect(p.reponsesDonnees.last, {
        'zones': ['z2'],
      });
      await p.toucher('zone_z3');
      expect(p.reponsesDonnees.last, {
        'zones': ['z3'],
      });
      expect(etatZone(tester, 'z2'), EtatZone.repos);
      await p.verifier();
      expect(etatZone(tester, 'z3'), EtatZone.faux);
      await p.attendreVidage();
      expect(etatZone(tester, 'z3'), EtatZone.repos);
      await p.toucher('zone_z1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(etatZone(tester, 'z1'), EtatZone.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : sélection multiple, petite zone élargie, faux '
        'deux fois révèle les zones', (tester) async {
      p = Partie(tester);
      await p.jouer(t08Plusieurs());
      expect(tester.getSize(p.cle('zone_z3')).width, 48);
      expect(tester.getSize(p.cle('zone_z3')).height, 48);
      await p.toucher('zone_z1');
      await p.toucher('zone_z2');
      await p.toucher('zone_z1');
      expect(p.reponsesDonnees.last, {
        'zones': ['z2'],
      });
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('zone_z2');
      await p.toucher('zone_z3');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('scene_reponse'), findsOneWidget);
      expect(etatZone(tester, 'z1'), EtatZone.juste);
      expect(etatZone(tester, 'z2'), EtatZone.juste);
      expect(etatZone(tester, 'z3'), EtatZone.repos);
      expect(tester.widget<ZoneTouchable>(p.cle('zone_z1')).onTap, isNull);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T47 Étiqueter un schéma', () {
    testWidgets('français : vrai geste sur une zone de la scène, '
        'remplacement, retrait au toucher, seules les fausses reviennent', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(exempleScene('T47-etiqueter-schema.json'));
      expect(find.byType(TuileGlissable), findsNWidgets(5));
      expect(find.byType(ZoneDepot), findsNWidgets(4));
      await p.glisser('element_e1', 'cible_z1');
      expect(p.dans('element_e1', 'cible_z1'), isTrue);
      expect(p.reponsesDonnees.last, {
        'placements': [
          {'zone': 'z1', 'etiquette': 'e1'},
        ],
      });
      // Une autre étiquette remplace la première.
      await p.glisser('element_e5', 'cible_z1');
      expect(p.dans('element_e5', 'cible_z1'), isTrue);
      expect(p.dans('element_e1', 'reserve'), isTrue);
      // Toucher-toucher vers z2, retrait au toucher.
      await p.toucher('element_e2');
      await p.toucherZone('cible_z2');
      expect(p.dans('element_e2', 'cible_z2'), isTrue);
      await p.toucher('element_e2');
      expect(p.dans('element_e2', 'reserve'), isTrue);
      await p.glisser('element_e2', 'cible_z2');
      await p.glisser('element_e3', 'cible_z3');
      expect(p.bouton.onPressed, isNull);
      await p.glisser('element_e4', 'cible_z4');
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      expect(p.etatGlissable('element_e5'), EtatGlissable.faux);
      expect(p.etatGlissable('element_e2'), EtatGlissable.pose);
      await p.attendreVidage();
      expect(p.dans('element_e5', 'reserve'), isTrue);
      expect(p.dans('element_e2', 'cible_z2'), isTrue);
      await p.glisser('element_e1', 'cible_z1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
      // 6 dépôts (glisser et toucher-toucher), puis 1 après le vidage.
      expect(p.sons.where((s) => s == SonInterface.depot), hasLength(7));
    });

    testWidgets('arabe : réserve de droite à gauche, réponse révélée', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t47Arabe(), mode: ModeExercice.apercu);
      expect(p.sens, TextDirection.rtl);
      expect(
        tester.getCenter(p.cle('element_e1')).dx,
        greaterThan(tester.getCenter(p.cle('element_e2')).dx),
      );
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('scene_reponse'), findsOneWidget);
      expect(p.dans('element_e1', 'cible_z1'), isTrue);
      expect(p.dans('element_e2', 'cible_z2'), isTrue);
      expect(p.etatGlissable('element_e1'), EtatGlissable.juste);
      // Réponse révélée : chaque étiquette est en juste, même celle en trop.
      expect(find.text('juste'), findsNWidgets(3));
    });
  });
}
