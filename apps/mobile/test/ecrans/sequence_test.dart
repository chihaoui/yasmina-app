import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';
import 'package:yasmina/sequences/sequence_test.dart';

import '../outils.dart';

/// Séquence de test du tour 1 (A1-22) : séries depuis l'accueil, exercices
/// enchaînés dans le lecteur, bilan de Yasmina, retour à l'accueil.
void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  /// Deux fois le même exercice (T02 en anglais, réponse « faux »), un
  /// chemin absent du catalogue (sauté), et une série sans rien à jouer.
  const sequence = SequenceTest(
    id: 'essai',
    series: [
      SerieTest(
        id: 'choix',
        titre: TitreBilingue(ar: 'أَخْتَارُ', fr: 'Choisir'),
        exemples: [
          'choix/T02-vrai-faux.json',
          'choix/inconnu.json',
          'choix/T02-vrai-faux.json',
        ],
      ),
      SerieTest(
        id: 'vide',
        titre: TitreBilingue(ar: 'فَارِغَةٌ', fr: 'Vide'),
        exemples: ['choix/inconnu.json'],
      ),
    ],
  );
  final surcharges = [
    sequenceTestProvider.overrideWith((ref) async => sequence),
  ];

  /// Répond juste à T02 (« faux »), Vérifier, puis Continuer.
  Future<void> repondreJuste(WidgetTester tester) async {
    await tester.ensureVisible(cle('vrai_faux_false'));
    await tester.tap(cle('vrai_faux_false'));
    await tester.pump();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pumpAndSettle();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'depuis l\'accueil : séries et leur nombre, deux exercices enchaînés '
    'en mode enfant avec la forme du profil, bilan, retour à l\'accueil',
    (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), surcharges: surcharges);
      await tester.tap(cle('accueil_jouer'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'sequence_titre'), 'Mes exercices');
      expect(texteDe(tester, 'serie_titre_choix'), 'Choisir');
      expect(find.text('2 exercices'), findsOneWidget);
      expect(find.text('Aucun exercice'), findsOneWidget);

      await tester.tap(cle('serie_choix'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'serie_titre'), 'Choisir');
      expect(texteDe(tester, 'serie_progression'), 'Exercice 1 sur 2');
      final config = tester
          .widget<LecteurExercice>(find.byType(LecteurExercice))
          .config;
      expect(config.mode, ModeExercice.enfant);
      expect(config.langue, 'en');
      // Lina est créée au féminin par lancerApp.
      expect(config.formeAdresse, FormeAdresse.feminin);

      await repondreJuste(tester);
      expect(texteDe(tester, 'serie_progression'), 'Exercice 2 sur 2');
      await repondreJuste(tester);
      expect(
        texteDe(tester, 'serie_fin'),
        'C\'est fini ! Tous les exercices sont faits.',
      );
      expect(find.text('2 réussis sur 2'), findsOneWidget);
      expect(find.byType(LecteurExercice), findsNothing);

      await tester.tap(cle('serie_retour'));
      await tester.pumpAndSettle();
      expect(cle('accueil_titre'), findsOneWidget);
    },
  );

  testWidgets(
    'interface en arabe : titres arabes de droite à gauche, la série vide '
    'ne s\'ouvre pas, progression en arabe',
    (tester) async {
      await lancerApp(tester, StockageMemoire('ar'), surcharges: surcharges);
      await tester.tap(cle('accueil_jouer'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'sequence_titre'), 'تَمَارِينِي');
      expect(sensDe(tester, 'sequence_titre'), TextDirection.rtl);
      expect(texteDe(tester, 'serie_titre_choix'), 'أَخْتَارُ');
      expect(find.text('تَمْرِينَانِ'), findsOneWidget);

      await tester.tap(cle('serie_vide'));
      await tester.pumpAndSettle();
      expect(cle('sequence_titre'), findsOneWidget);

      await tester.tap(cle('serie_choix'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'serie_progression'), 'التَّمْرِينُ 1 مِنْ 2');
      // L'exercice garde sa langue (anglais) dans une interface arabe.
      expect(sensDe(tester, 'lecteur_consigne'), TextDirection.ltr);
    },
  );

  testWidgets('sans profil choisi, /sequence renvoie à « Qui joue ? »', (
    tester,
  ) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Yassine'],
      surcharges: surcharges,
    );
    GoRouter.of(tester.element(cle('profils_titre'))).go('/sequence');
    await tester.pumpAndSettle();
    expect(cle('sequence_titre'), findsNothing);
    expect(cle('profils_titre'), findsOneWidget);
  });
}
