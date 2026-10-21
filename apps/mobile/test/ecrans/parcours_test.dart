import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';
import '../parcours/fixtures_parcours.dart';

/// Le parcours (A3-01, A3-02) : matières selon le niveau, carte du
/// trimestre, intro d'étape, exercices enchaînés, résultat et déblocage de
/// l'étape suivante, sur un catalogue de test (ب puis le défi).
void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  final catalogue = catalogueTest();

  /// Répond juste au T02 (« vrai »), Vérifier, puis Continuer.
  Future<void> repondreJuste(WidgetTester tester) async {
    await tester.ensureVisible(cle('vrai_faux_true'));
    await tester.tap(cle('vrai_faux_true'));
    await tester.pump();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pumpAndSettle();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'accueil en 1re : arabe ouvrable avec son avancement, maths et éveil '
    '« bientôt » sans plantage, Jouer et Changer d\'enfant toujours là',
    (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), catalogue: catalogue);
      expect(find.text('Arabe'), findsOneWidget);
      expect(find.text('0 sur 2'), findsOneWidget);
      expect(cle('matiere_ar'), findsOneWidget);
      expect(cle('matiere_ma'), findsOneWidget);
      expect(cle('matiere_ev'), findsOneWidget);
      expect(cle('matiere_fr'), findsNothing);
      expect(cle('matiere_en'), findsNothing);
      expect(find.text('Bientôt'), findsNWidgets(2));
      expect(cle('accueil_jouer'), findsOneWidget);
      expect(cle('profil_changer'), findsOneWidget);

      await tester.tap(cle('matiere_ma'));
      await tester.pumpAndSettle();
      expect(cle('accueil_titre'), findsOneWidget);
      expect(cle('carte_titre'), findsNothing);
    },
  );

  testWidgets('français dès la 2e année, anglais dès la 4e', (tester) async {
    final depot = await lancerApp(
      tester,
      StockageMemoire('fr'),
      catalogue: catalogue,
    );
    final lina = (await depot.lister()).single;
    await depot.changerNiveau(lina.id, 2);
    await tester.pumpAndSettle();
    expect(cle('matiere_fr'), findsOneWidget);
    expect(cle('matiere_en'), findsNothing);
    await depot.changerNiveau(lina.id, 4);
    await tester.pumpAndSettle();
    expect(cle('matiere_fr'), findsOneWidget);
    expect(cle('matiere_en'), findsOneWidget);
    // Pas de parcours d'arabe en 4e : la carte le dit.
    await tester.tap(cle('matiere_ar'));
    await tester.pumpAndSettle();
    expect(cle('accueil_titre'), findsOneWidget);
    GoRouter.of(tester.element(cle('accueil_titre'))).push('/matiere/ar');
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'carte_bientot'), 'Cette matière arrive bientôt.');
  });

  testWidgets(
    'carte, intro, étape jouée en mode enfant, résultat, étape suivante '
    'débloquée, retour à la carte, rejouer',
    (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), catalogue: catalogue);
      await tester.tap(cle('matiere_ar'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'carte_titre'), 'Arabe');
      expect(texteDe(tester, 'carte_trimestre'), 'Trimestre 1');
      expect(texteDe(tester, 'carte_unite_1'), 'Unité 1');
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e01'), 'À faire');
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e02'), 'Verrouillée');
      // Le titre de l'étape est en arabe, même dans une interface française.
      expect(
        tester.widget<Text>(cle('etape_titre_ar-1-t1-u1-e01')).textDirection,
        TextDirection.rtl,
      );

      // Étape verrouillée : message, on reste sur la carte.
      await tester.tap(cle('etape_ar-1-t1-u1-e02'));
      await tester.pumpAndSettle();
      expect(find.text("Termine d'abord l'étape précédente."), findsOneWidget);
      expect(cle('intro_titre'), findsNothing);
      // Le bandeau disparaît de lui-même (il recouvrirait le bas de l'écran
      // de test).
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text("Termine d'abord l'étape précédente."), findsNothing);

      // Intro de l'étape ouverte.
      await tester.tap(cle('etape_ar-1-t1-u1-e01'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'intro_titre'), 'حَرْفُ الْبَاءِ');
      expect(texteDe(tester, 'intro_bulle'), "C'est parti !");
      expect(texteDe(tester, 'intro_lettre'), 'ب');
      expect(cle('intro_sequence_0'), findsOneWidget);
      expect(find.text('2 exercices'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);

      // Les exercices s'enchaînent dans le lecteur.
      await tester.tap(cle('intro_commencer'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'jeu_compteur'), 'Exercice 1 sur 2');
      expect(texteDe(tester, 'jeu_sequence'), 'أَكْتَشِفُ 1');
      final config = tester
          .widget<LecteurExercice>(find.byType(LecteurExercice))
          .config;
      expect(config.mode, ModeExercice.enfant);
      expect(config.langue, 'ar');
      expect(config.formeAdresse, FormeAdresse.feminin);
      expect(sensDe(tester, 'lecteur_consigne'), TextDirection.rtl);

      await repondreJuste(tester);
      expect(texteDe(tester, 'jeu_compteur'), 'Exercice 2 sur 2');
      await repondreJuste(tester);
      expect(texteDe(tester, 'etape_resultat'), 'Étape terminée !');
      expect(find.text('2 réussis sur 2'), findsOneWidget);
      expect(texteDe(tester, 'etape_suivante'), 'Étape suivante débloquée !');
      expect(find.byType(LecteurExercice), findsNothing);

      // Retour à la carte : faite, et la suivante est ouverte.
      await tester.tap(cle('etape_retour_carte'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'carte_titre'), 'Arabe');
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e01'), 'Faite');
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e02'), 'À faire');
      expect(texteDe(tester, 'carte_avancement'), '1 sur 2');

      // Une étape faite se rejoue.
      await tester.tap(cle('etape_ar-1-t1-u1-e01'));
      await tester.pumpAndSettle();
      expect(find.text('Rejouer'), findsOneWidget);

      // Le défi : 🏆, une séquence, rien à débloquer après.
      GoRouter.of(tester.element(cle('intro_titre'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(cle('etape_ar-1-t1-u1-e02'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'intro_lettre'), '🏆');
      await tester.tap(cle('intro_commencer'));
      await tester.pumpAndSettle();
      await repondreJuste(tester);
      expect(cle('etape_suivante'), findsNothing);
      await tester.tap(cle('etape_retour_carte'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'carte_avancement'), '2 sur 2');
    },
  );

  testWidgets('interface en arabe : carte de droite à gauche, états en arabe', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('ar'), catalogue: catalogue);
    expect(find.text('الْعَرَبِيَّةُ'), findsOneWidget);
    expect(find.text('قَرِيبًا'), findsNWidgets(2));
    await tester.tap(cle('matiere_ar'));
    await tester.pumpAndSettle();
    expect(sensDe(tester, 'carte_titre'), TextDirection.rtl);
    expect(texteDe(tester, 'carte_trimestre'), 'الثُّلَاثِيُّ 1');
    expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e01'), 'جَاهِزَةٌ');
    expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e02'), 'مُغْلَقَةٌ');
    await tester.tap(cle('etape_ar-1-t1-u1-e01'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'intro_bulle'), 'هَيَّا بِنَا!');
    expect(find.text('هَيَّا نَبْدَأُ'), findsOneWidget);
  });

  testWidgets(
    '« tout débloquer » du menu développeur ouvre toutes les étapes',
    (tester) async {
      final stockage = StockageMemoire('fr');
      await stockage.ecrireToutDebloque(true);
      await lancerApp(tester, stockage, catalogue: catalogue);
      await tester.tap(cle('matiere_ar'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e02'), 'À faire');
      expect(stockage.lireToutDebloque(), isTrue);
    },
  );

  testWidgets(
    'matière inconnue ou sans parcours : « bientôt », sans plantage',
    (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), catalogue: catalogue);
      final routeur = GoRouter.of(tester.element(cle('accueil_titre')));
      routeur.push('/matiere/zz');
      await tester.pumpAndSettle();
      expect(cle('carte_bientot'), findsOneWidget);
      routeur.go('/matiere/ev');
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'carte_titre'), 'Éveil scientifique');
      expect(cle('carte_bientot'), findsOneWidget);
      // Étape inconnue : écran d'attente (indicateur animé : pas de
      // pumpAndSettle).
      routeur.go('/matiere/ar/etape/inconnue');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('sans profil choisi, /matiere/ar renvoie à « Qui joue ? »', (
    tester,
  ) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Yassine'],
      catalogue: catalogue,
    );
    GoRouter.of(tester.element(cle('profils_titre'))).go('/matiere/ar');
    await tester.pumpAndSettle();
    expect(cle('carte_titre'), findsNothing);
    expect(cle('profils_titre'), findsOneWidget);
  });
}
