import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_scene.dart';

/// T53 Écoute et place et T54 Écoute et colorie (docs/moteurs/scene-image.md
/// §14) : consigne entendue après la consigne, un seul toucher sur
/// l'emplacement, couleur puis objet, cas anglais et cas arabe ou
/// français, déroulé complet.
void main() {
  late Partie p;

  EtatZone etatZone(WidgetTester tester, String id) =>
      tester.widget<ZoneTouchable>(p.cle('zone_$id')).etat;

  Color bordObjet(WidgetTester tester, String id) =>
      (tester.widget<Material>(p.cle('objet_$id')).shape!
              as RoundedRectangleBorder)
          .side
          .color;

  group('T53 Écoute et place', () {
    testWidgets('anglais : consigne entendue, un seul toucher pose l\'objet '
        'sur l\'emplacement, un autre le déplace, le même le retire, faux '
        'puis juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleScene('T53-ecoute-place.json'));
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'Listen, then tap the right place for the cat.',
        'Put the cat under the table.',
      ]);
      await p.toucher('place_ecouter');
      expect(
        p.audio.audioFactice.dits.last.texte,
        'Put the cat under the table.',
      );
      // La consigne entendue n'est jamais affichée.
      expect(find.text('Put the cat under the table.'), findsNothing);
      expect(p.cle('objet'), findsOneWidget);
      expect(find.byType(ZoneTouchable), findsNWidgets(3));
      expect(p.bouton.onPressed, isNull);
      await p.toucher('zone_z1');
      expect(etatZone(tester, 'z1'), EtatZone.selectionnee);
      expect(p.cle('objet_pose_z1'), findsOneWidget);
      expect(p.reponsesDonnees.last, {'zone': 'z1'});
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      // Un autre emplacement déplace l'objet.
      await p.toucher('zone_z3');
      expect(p.cle('objet_pose_z1'), findsNothing);
      expect(p.cle('objet_pose_z3'), findsOneWidget);
      // Le même emplacement le retire.
      await p.toucher('zone_z3');
      expect(p.cle('objet_pose_z3'), findsNothing);
      expect(p.bouton.onPressed, isNull);
      await p.toucher('zone_z1');
      await p.verifier();
      expect(etatZone(tester, 'z1'), EtatZone.faux);
      await p.attendreVidage();
      expect(etatZone(tester, 'z1'), EtatZone.repos);
      await p.toucher('zone_z2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Well done'), findsOneWidget);
      expect(etatZone(tester, 'z2'), EtatZone.juste);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('arabe : scène non retournée, libellés neutres, faux deux '
        'fois révèle l\'emplacement', (tester) async {
      p = Partie(tester);
      await p.jouer(t53Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      expect(
        tester.getCenter(p.cle('zone_z1')).dx,
        lessThan(tester.getCenter(p.cle('zone_z2')).dx),
      );
      expect(
        tester.widget<ZoneTouchable>(p.cle('zone_z1')).libelle,
        'صُورَةٌ 1',
      );
      await p.toucher('zone_z1');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('zone_z1');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('scene_reponse'), findsOneWidget);
      expect(etatZone(tester, 'z2'), EtatZone.juste);
      expect(p.cle('objet_pose_z2'), findsOneWidget);
      expect(find.text('وَاصِلِي'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T54 Écoute et colorie', () {
    testWidgets('anglais : couleur puis objet, grandes icônes avec le nom, '
        'seul le coloriage faux s\'efface, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleScene('T54-ecoute-colorie.json'));
      expect(p.audio.audioFactice.dits.last.texte, 'Colour the ball red.');
      expect(find.text('Colour the ball red.'), findsNothing);
      // Grandes icônes avec le nom en sous-titre.
      expect(find.text('ball'), findsOneWidget);
      expect(find.text('⚽'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('⚽')).style!.fontSize,
        StylesYasmina.letterHero.fontSize,
      );
      expect(
        tester.getSize(p.cle('objet_o1')).height,
        greaterThanOrEqualTo(60),
      );
      expect(find.text('red'), findsOneWidget);
      expect(
        tester.getSize(p.cle('couleur_red')).width,
        greaterThanOrEqualTo(48),
      );
      expect(p.bouton.onPressed, isNull);
      // Un objet touché sans couleur en main ne change pas.
      await p.toucher('objet_o1');
      expect(p.reponsesDonnees, isEmpty);
      await p.toucher('couleur_blue');
      await p.toucher('objet_o2');
      expect(p.reponsesDonnees.last, {
        'coloriages': [
          {'objet': 'o2', 'couleur': 'blue'},
        ],
      });
      expect(
        bordObjet(tester, 'o2'),
        CouleursColoriage.de('blue', inconnue: Colors.black),
      );
      await p.toucher('couleur_red');
      await p.toucher('objet_o1');
      expect(p.audio.audioFactice.sons, [
        SonInterface.depot,
        SonInterface.depot,
      ]);
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      // La voiture bleue (fausse) s'efface, le ballon rouge reste (retrait
      // fait par le lecteur : aucun reponseDonnee).
      expect(
        tester.widget<Material>(p.cle('objet_o2')).color,
        CouleursYasmina.clair.tile,
      );
      expect(
        tester.widget<Material>(p.cle('objet_o1')).color,
        isNot(CouleursYasmina.clair.tile),
      );
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Well done'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français : la couleur en main se lâche, un objet retouché '
        'sans couleur redevient blanc, aperçu révèle les coloriages', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t54Francais());
      expect(find.text('bleu'), findsOneWidget);
      await p.toucher('couleur_blue');
      await p.toucher('objet_o2');
      expect(p.reponsesDonnees.last, {
        'coloriages': [
          {'objet': 'o2', 'couleur': 'blue'},
        ],
      });
      // Lâcher la couleur, puis toucher l'objet colorié : il redevient blanc.
      await p.toucher('couleur_blue');
      await p.toucher('objet_o2');
      expect(p.reponsesDonnees.last, {'coloriages': <Object>[]});

      await p.jouer(t54Francais(), mode: ModeExercice.apercu);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('scene_reponse'), findsOneWidget);
      expect(find.text('juste'), findsOneWidget);
      expect(bordObjet(tester, 'o2'), CouleursYasmina.clair.olive);
    });
  });
}
