import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_mesure.dart';

/// T28 Horloge et T30 Règle (docs/moteurs/mesure-temps.md) : aiguilles
/// déplacées au doigt (vrai geste), longueur lue sur la règle et écrite au
/// pavé, cas arabe et cas latin, déroulé complet.
void main() {
  late Partie p;

  int totales(WidgetTester tester, String cle) =>
      (tester.widget<CustomPaint>(p.cle(cle)).painter! as PeintreHorloge)
          .totales;

  /// Glisse une aiguille depuis son bout jusqu'à l'angle [vers] (en
  /// minutes du cadran, 0 en haut, 15 à droite).
  Future<void> glisserAiguille(
    WidgetTester tester, {
    required Aiguille aiguille,
    required int versMinutesCadran,
  }) async {
    final rect = tester.getRect(p.cle('horloge'));
    final t = totales(tester, 'horloge');
    final part = aiguille == Aiguille.minutes
        ? PeintreHorloge.partMinutes
        : PeintreHorloge.partHeures;
    final angleDepart = aiguille == Aiguille.minutes
        ? ControleurHorloge.angleMinutes(t)
        : ControleurHorloge.angleHeures(t);
    final depart =
        rect.topLeft + PeintreHorloge.bout(rect.size, angleDepart, part);
    final angleFin = versMinutesCadran / 60 * 2 * math.pi;
    final fin = rect.topLeft + PeintreHorloge.bout(rect.size, angleFin, part);
    final geste = await tester.startGesture(depart);
    // Par étapes, pour passer par les angles intermédiaires.
    for (var k = 1; k <= 6; k++) {
      await geste.moveTo(Offset.lerp(depart, fin, k / 6)!);
      await tester.pump();
    }
    await geste.up();
    await tester.pump();
  }

  group('T28 Horloge', () {
    testWidgets('arabe : aiguille des minutes glissée au doigt (aimant au '
        'pas, l\'heure suit), aiguille des heures glissée, faux puis retour '
        'au départ, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleMesure('T28-horloge.json'));
      expect(p.sens, TextDirection.rtl);
      expect(totales(tester, 'horloge'), 0);
      expect(p.bouton.onPressed, isNull);
      // Les minutes vers 6 (30 min) : 12 h 30.
      await glisserAiguille(
        tester,
        aiguille: Aiguille.minutes,
        versMinutesCadran: 30,
      );
      expect(totales(tester, 'horloge'), 30);
      expect(p.reponsesDonnees.last, {'heure': 12, 'minutes': 30});
      expect(p.audio.audioFactice.sons, [SonInterface.depot]);
      // Les heures vers 3 : 3 h 30 (les minutes restent).
      await glisserAiguille(
        tester,
        aiguille: Aiguille.heures,
        versMinutesCadran: 15,
      );
      expect(totales(tester, 'horloge'), 3 * 60 + 30);
      expect(p.reponsesDonnees.last, {'heure': 3, 'minutes': 30});
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      // Retour au départ (12 h 00).
      expect(totales(tester, 'horloge'), 0);
      await glisserAiguille(
        tester,
        aiguille: Aiguille.minutes,
        versMinutesCadran: 30,
      );
      await glisserAiguille(
        tester,
        aiguille: Aiguille.heures,
        versMinutesCadran: 30,
      );
      expect(totales(tester, 'horloge'), 6 * 60 + 30);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français, pas de 15 minutes, départ 9 h 00 : passer 12 '
        'change d\'heure, faux deux fois révèle l\'heure', (tester) async {
      p = Partie(tester);
      await p.jouer(t28Francais());
      expect(totales(tester, 'horloge'), 9 * 60);
      // Les minutes de 12 vers 9 (45 min) en reculant : 8 h 45.
      await glisserAiguille(
        tester,
        aiguille: Aiguille.minutes,
        versMinutesCadran: 45,
      );
      expect(p.reponsesDonnees.last, {'heure': 8, 'minutes': 45});
      // Un pas de 15 : 50 min s'aimante à 45.
      await glisserAiguille(
        tester,
        aiguille: Aiguille.minutes,
        versMinutesCadran: 50,
      );
      expect(p.reponsesDonnees.last, {'heure': 8, 'minutes': 45});
      await p.verifier();
      await p.attendreVidage();
      await glisserAiguille(
        tester,
        aiguille: Aiguille.heures,
        versMinutesCadran: 5,
      );
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('saisie_reponse'), findsOneWidget);
      expect(totales(tester, 'saisie_reponse'), 10 * 60 + 15);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });

  group('T30 Règle', () {
    testWidgets('arabe : règle de gauche à droite, longueur écrite au pavé, '
        'faux puis vidé, juste', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleMesure('T30-regle.json'));
      expect(p.sens, TextDirection.rtl);
      expect(p.cle('regle'), findsOneWidget);
      expect(p.cle('pave'), findsOneWidget);
      expect(find.text('صم'), findsOneWidget);
      expect(p.bouton.onPressed, isNull);
      await p.toucher('touche_8');
      expect(find.text('8 صم'), findsOneWidget);
      expect(p.reponsesDonnees.last, {'valeur': 8});
      await p.verifier();
      expect(p.cle('lecteur_feedback_indice'), findsOneWidget);
      await p.attendreVidage();
      expect(find.text('صم'), findsOneWidget);
      await p.toucher('touche_7');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتَ'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });

    testWidgets('français, objet qui ne part pas de zéro : faux deux fois '
        'révèle la longueur', (tester) async {
      p = Partie(tester);
      await p.jouer(t30Francais());
      final peintre =
          tester.widget<CustomPaint>(p.cle('regle')).painter! as PeintreRegle;
      expect(peintre.depart, 2);
      expect(peintre.longueur, 5);
      // 7 : la lecture du bout seul est le piège.
      await p.toucher('touche_7');
      await p.verifier();
      await p.attendreVidage();
      await p.toucher('touche_6');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.cle('saisie_reponse'), findsOneWidget);
      expect(find.text('5 cm'), findsOneWidget);
      expect(p.resultat, const Resultat(IssueExercice.explique, essais: 2));
    });
  });
}
