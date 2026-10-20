import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_recit.dart';

/// T35 Histoire à choix (docs/moteurs/recit.md) : les étapes s'enchaînent
/// dans la zone, un mauvais choix explique puis laisse choisir à nouveau,
/// sans note, cas français et cas arabe.
void main() {
  late Partie p;

  String texteDe(WidgetTester tester, String cle) =>
      tester.widget<Text>(p.cle(cle)).data!;

  group('T35 Histoire à choix', () {
    testWidgets('français : étapes enchaînées, mauvais choix expliqué puis '
        'repris, Écouter dit le texte de l\'étape, fin et Continuer sans '
        'note', (tester) async {
      p = Partie(tester);
      await p.jouer(exempleRecit('T35-histoire-choix.json'));
      expect(texteDe(tester, 'recit_compteur'), 'Étape 1 / 3');
      expect(texteDe(tester, 'recit_texte'), startsWith('Nour doit traverser'));
      expect(p.cle('recit_scene'), findsOneWidget);
      expect(p.bouton.libelle, 'Continuer');
      expect(p.bouton.onPressed, isNull);
      await p.toucher('recit_ecouter');
      expect(
        p.audio.audioFactice.dits.last.texte,
        startsWith('Nour doit traverser'),
      );
      // Mauvais choix : explication, le choix barré, « Compris ».
      await p.toucher('choix_c1');
      expect(p.audio.audioFactice.sons.last, SonInterface.essaiFaux);
      expect(p.cle('recit_pourquoi'), findsOneWidget);
      expect(tester.widget<TuileChoix>(p.cle('choix_c1')).barre, isTrue);
      expect(p.cle('choix_c2'), findsNothing);
      expect(p.reponsesDonnees.last, {
        'choix': [
          {'etape': 'e1', 'choix': 'c1'},
        ],
        'erreurs': 1,
      });
      await p.toucher('recit_compris');
      expect(p.cle('recit_pourquoi'), findsNothing);
      expect(p.cle('choix_c2'), findsOneWidget);
      // Bon choix : l'histoire avance, le premier choix de l'étape reste
      // dans la réponse.
      await p.toucher('choix_c2');
      expect(p.audio.audioFactice.sons.last, SonInterface.depot);
      expect(texteDe(tester, 'recit_compteur'), 'Étape 2 / 3');
      expect((p.reponsesDonnees.last as Map)['choix'], [
        {'etape': 'e1', 'choix': 'c1'},
      ]);
      await p.toucher('choix_c3');
      expect(texteDe(tester, 'recit_compteur'), 'Étape 3 / 3');
      expect(p.bouton.onPressed, isNull);
      await p.toucher('choix_c6');
      // Fin : texte de fin, Continuer actif, aucun bandeau.
      expect(p.cle('recit_fin'), findsOneWidget);
      expect(texteDe(tester, 'recit_texte'), startsWith('Nour arrive'));
      expect(p.bouton.onPressed, isNotNull);
      await p.verifier();
      await tester.pumpAndSettle();
      expect(p.resultat, const Resultat(IssueExercice.termine, essais: 0));
      expect(find.byType(BandeauFeedback), findsNothing);
    });

    testWidgets('arabe : de droite à gauche, trois choix, sans texte de fin, '
        'aperçu révèle la dernière étape', (tester) async {
      p = Partie(tester);
      await p.jouer(t35Arabe(), forme: FormeAdresse.feminin);
      expect(p.sens, TextDirection.rtl);
      expect(find.byType(TuileChoix), findsNWidgets(3));
      await p.toucher('choix_c2');
      expect(texteDe(tester, 'recit_compteur'), 'الْمَرْحَلَةُ 2 / 2');
      await p.toucher('choix_c5');
      expect(p.cle('recit_fin'), findsOneWidget);
      expect(find.text('وَاصِلِي'), findsOneWidget);

      await p.jouer(t35Arabe(), mode: ModeExercice.apercu);
      await tester.tap(p.cle('lecteur_afficher_reponse'));
      await tester.pump();
      expect(p.cle('recit_reponse'), findsOneWidget);
      expect(texteDe(tester, 'recit_compteur'), 'الْمَرْحَلَةُ 2 / 2');
      expect(find.text('juste'), findsOneWidget);
    });
  });
}
