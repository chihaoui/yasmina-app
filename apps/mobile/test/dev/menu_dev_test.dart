import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yasmina/dev/menu_dev.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  Future<void> ouvrirMenu(WidgetTester tester, String titre) async {
    await tester.longPress(cle(titre));
    await tester.pumpAndSettle();
  }

  group('release (menu indisponible)', () {
    final release = [menuDevDisponibleProvider.overrideWithValue(false)];

    testWidgets("l'appui long sur le titre n'ouvre rien", (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), surcharges: release);
      await ouvrirMenu(tester, 'accueil_titre');
      expect(cle('menu_dev_titre'), findsNothing);
      expect(cle('accueil_titre'), findsOneWidget);
    });

    testWidgets('/dev redirige vers « Qui joue ? »', (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), surcharges: release);
      GoRouter.of(tester.element(cle('accueil_titre'))).go('/dev');
      await tester.pumpAndSettle();
      expect(cle('menu_dev_titre'), findsNothing);
      expect(cle('profils_titre'), findsOneWidget);
    });
  });

  group('debug (menu disponible)', () {
    testWidgets(
      'appui long sur le titre : menu en français et de gauche à droite, '
      'même avec une interface en arabe',
      (tester) async {
        await lancerApp(tester, StockageMemoire('ar'));
        await ouvrirMenu(tester, 'accueil_titre');
        expect(texteDe(tester, 'menu_dev_titre'), 'Menu développeur');
        expect(sensDe(tester, 'menu_dev_titre'), TextDirection.ltr);
      },
    );

    testWidgets('accessible dès le premier lancement (écran de bienvenue)', (
      tester,
    ) async {
      await lancerApp(tester, StockageMemoire('fr'), profils: []);
      await ouvrirMenu(tester, 'bienvenue_titre');
      expect(cle('menu_dev_titre'), findsOneWidget);
    });

    testWidgets('profils de test créés une seule fois', (tester) async {
      final depot = await lancerApp(tester, StockageMemoire('fr'), profils: []);
      await ouvrirMenu(tester, 'bienvenue_titre');
      await tester.tap(cle('dev_profils_test'));
      await tester.pumpAndSettle();
      expect(find.text('2 profils créés.'), findsOneWidget);

      await tester.tap(cle('dev_profils_test'));
      await tester.pumpAndSettle();
      expect(
        find.text('Aucun profil créé. Lina existe déjà. Yassine existe déjà.'),
        findsOneWidget,
      );
      final profils = await depot.lister();
      expect(
        profils.map((p) => p.prenom),
        unorderedEquals(['Lina', 'Yassine']),
      );
    });

    testWidgets('Lina reçoit une progression d\'exemple (première étape faite, '
        'deuxième en cours), Yassine reste vierge', (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), profils: []);
      await ouvrirMenu(tester, 'bienvenue_titre');
      await tester.tap(cle('dev_profils_test'));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(cle('menu_dev_titre'))).go('/');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lina'));
      await tester.pumpAndSettle();
      expect(find.text('1 sur 7'), findsOneWidget);
      await tester.tap(cle('matiere_ar'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e01'), 'Faite');
      expect(texteDe(tester, 'etape_etat_ar-1-t1-u1-e02'), 'À faire');
      await tester.tap(cle('etape_ar-1-t1-u1-e02'));
      await tester.pumpAndSettle();
      expect(find.text('Reprendre'), findsOneWidget);

      GoRouter.of(tester.element(cle('intro_titre'))).go('/');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yassine'));
      await tester.pumpAndSettle();
      expect(find.text('0 sur 7'), findsOneWidget);
    });

    testWidgets('réinitialiser : tout est effacé, retour à la création', (
      tester,
    ) async {
      final stockage = StockageMemoire('fr');
      final depot = await lancerApp(
        tester,
        stockage,
        profils: ['Lina', 'Sami'],
      );
      await ouvrirMenu(tester, 'profils_titre');
      await tester.tap(cle('dev_abonnement_abonne'));
      await tester.pumpAndSettle();

      await tester.tap(cle('dev_reinitialiser'));
      await tester.pumpAndSettle();
      await tester.tap(cle('dev_annuler'));
      await tester.pumpAndSettle();
      expect(await depot.lister(), hasLength(2));

      await tester.tap(cle('dev_reinitialiser'));
      await tester.pumpAndSettle();
      await tester.tap(cle('dev_confirmer'));
      await tester.pumpAndSettle();
      expect(await depot.lister(), isEmpty);
      expect(stockage.lireAbonnementSimule(), isNull);
      expect(stockage.lireLangue(), 'fr');
      expect(cle('bienvenue_titre'), findsOneWidget);
    });

    testWidgets(
      'abonnement simulé et « tout débloquer » enregistrés (les sons des '
      'effets sont dans l\'espace parent, décision 35)',
      (tester) async {
        final stockage = StockageMemoire('fr');
        await lancerApp(tester, stockage);
        await ouvrirMenu(tester, 'accueil_titre');
        expect(stockage.lireAbonnementSimule(), isNull);

        await tester.tap(cle('dev_abonnement_essaiTermine'));
        await tester.pumpAndSettle();
        expect(stockage.lireAbonnementSimule(), 'essaiTermine');

        await tester.scrollUntilVisible(cle('dev_tout_debloquer'), 100);
        await tester.tap(cle('dev_tout_debloquer'));
        await tester.pumpAndSettle();
        expect(stockage.lireToutDebloque(), isTrue);
      },
    );
  });
}
