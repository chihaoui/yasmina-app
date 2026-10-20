import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'fixtures_choix.dart';
import 'outils_choix.dart';

/// T03 Écoute et choisis et T55 Paires minimales sonores : grand bouton
/// Écouter, mot dit après la consigne puis à chaque toucher, jamais affiché.
void main() {
  late Partie p;

  group('T03 Écoute et choisis', () {
    testWidgets('anglais : Listen, mot dit après la consigne, images avec '
        'libellé neutre', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T03-ecoute-et-choisis.json'));
      final poignee = tester.ensureSemantics();
      expect(p.sens, TextDirection.ltr);
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'Listen and tap the right picture.',
        'cat',
      ]);
      // Le mot entendu n'est jamais affiché.
      expect(find.text('cat'), findsNothing);
      expect(find.text('Listen'), findsOneWidget);
      await p.toucher('choix_ecouter');
      expect(p.audio.audioFactice.dits.last.texte, 'cat');
      expect(p.demandesAudio.last.origine, OrigineAudio.ecoute);
      // 4 emoji en 2 × 2, libellés neutres numérotés dans l'ordre affiché.
      expect(find.byType(TuileChoix), findsNWidgets(4));
      final libelles = [
        for (final t in tester.widgetList<TuileChoix>(find.byType(TuileChoix)))
          t.libelleAccessibilite,
      ];
      expect(libelles, ['picture 1', 'picture 2', 'picture 3', 'picture 4']);
      poignee.dispose();
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 1));
    });

    testWidgets('arabe au féminin : اِسْمَعِي, de droite à gauche, faux puis '
        'juste', (tester) async {
      p = Partie(tester);
      await p.jouer(t03Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      expect(find.text('اِسْمَعِي'), findsOneWidget);
      expect(p.audio.audioFactice.dits.last.texte, 'قِطٌّ');
      final libelles = [
        for (final t in tester.widgetList<TuileChoix>(find.byType(TuileChoix)))
          t.libelleAccessibilite,
      ];
      expect(libelles, ['صُورَةٌ 1', 'صُورَةٌ 2', 'صُورَةٌ 3']);
      // Ordre fixe : c1 à droite de c2.
      expect(
        tester.getCenter(p.cle('choix_c1')).dx,
        greaterThan(tester.getCenter(p.cle('choix_c2')).dx),
      );
      await p.toucher('choix_c1');
      await p.verifier();
      expect(
        find.text(
          'اِسْمَعِي مَرَّةً أُخْرَى: هَذَا الْحَيَوَانُ يَقُولُ مِيَاوْ.',
        ),
        findsOneWidget,
      );
      await p.attendreVidage();
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('أَحْسَنْتِ'), findsOneWidget);
    });
  });

  group('T55 Paires minimales sonores', () {
    testWidgets('français : deux tuiles texte et emoji, bain', (tester) async {
      p = Partie(tester);
      await p.jouer(exemple('T55-paire-minimale.json'));
      expect(p.audio.audioFactice.dits.map((d) => d.texte), [
        'Écoute bien et touche le mot que tu entends.',
        'bain',
      ]);
      expect(find.text('🥖'), findsOneWidget);
      expect(find.text('pain'), findsOneWidget);
      expect(find.byType(TuileChoix), findsNWidgets(2));
      // Tuile avec texte : libellé par défaut (le texte).
      expect(p.tuile('choix_c2').libelleAccessibilite, isNull);
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(find.text('Bravo'), findsOneWidget);
    });

    testWidgets('arabe : صَيْفٌ, de droite à gauche, bouton اِسْمَعْ', (
      tester,
    ) async {
      p = Partie(tester);
      await p.jouer(t55Arabe());
      expect(p.sens, TextDirection.rtl);
      expect(find.text('اِسْمَعْ'), findsOneWidget);
      expect(p.audio.audioFactice.dits.last.texte, 'صَيْفٌ');
      await p.toucher('choix_ecouter');
      expect(p.audio.audioFactice.dits, hasLength(3));
      await p.toucher('choix_c1');
      await p.verifier();
      expect(p.etat('choix_c1'), EtatTuile.faux);
      await p.attendreVidage();
      await p.toucher('choix_c2');
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.reussi, essais: 2));
    });
  });
}
