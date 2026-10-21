import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/dev/reglages_dev.dart';
import 'package:yasmina/parent/porte_parentale.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// Simulation d'essai et d'abonnement (A3-05, décision 13) : le parcours
/// respecte le statut simulé, les offres de l'espace parent le basculent,
/// sans paiement ni réseau.
void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  final surcharges = [
    questionPorteProvider.overrideWithValue(const QuestionPorte(6, 7)),
  ];

  Future<void> ouvrirParent(WidgetTester tester) async {
    await tester.tap(cle('espace_parent_ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(cle('porte_reponse'), '42');
    await tester.tap(cle('porte_entrer'));
    await tester.pumpAndSettle();
  }

  test('le parcours est ouvert en essai et abonné, fermé après l\'essai', () {
    expect(AbonnementSimule.essai.parcoursOuvert, isTrue);
    expect(AbonnementSimule.abonne.parcoursOuvert, isTrue);
    expect(AbonnementSimule.essaiTermine.parcoursOuvert, isFalse);
  });

  testWidgets('essai : la carte s\'ouvre avec la pastille « Essai gratuit »', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'), surcharges: surcharges);
    await tester.tap(cle('matiere_ar'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'carte_abonnement'), 'Essai gratuit');
    expect(cle('etape_ar-1-t1-u1-e01'), findsOneWidget);
  });

  testWidgets(
    'essai terminé : la carte explique et renvoie vers la porte parentale',
    (tester) async {
      final stockage = StockageMemoire('fr');
      await stockage.ecrireAbonnementSimule('essaiTermine');
      await lancerApp(tester, stockage, surcharges: surcharges);
      await tester.tap(cle('matiere_ar'));
      await tester.pumpAndSettle();
      expect(
        texteDe(tester, 'carte_essai_termine'),
        "L'essai gratuit est terminé.",
      );
      expect(cle('etape_ar-1-t1-u1-e01'), findsNothing);
      await tester.tap(cle('carte_espace_parent'));
      await tester.pumpAndSettle();
      expect(cle('porte_titre'), findsOneWidget);
    },
  );

  testWidgets('abonné : tout est ouvert, pastille « Abonné »', (tester) async {
    final stockage = StockageMemoire('ar');
    await stockage.ecrireAbonnementSimule('abonne');
    await lancerApp(tester, stockage, surcharges: surcharges);
    await tester.tap(cle('matiere_ar'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'carte_abonnement'), 'مُشْتَرِكٌ');
    expect(cle('etape_ar-1-t1-u1-e01'), findsOneWidget);
  });

  testWidgets(
    'espace parent : trois offres, S\'abonner bascule sur abonné sans '
    'réseau, la simulation revient à l\'essai',
    (tester) async {
      final stockage = StockageMemoire('fr');
      await stockage.ecrireAbonnementSimule('essaiTermine');
      await lancerApp(tester, stockage, surcharges: surcharges);
      await ouvrirParent(tester);
      await tester.scrollUntilVisible(cle('parent_sabonner_annee'), 200);
      expect(find.text('Essai terminé'), findsOneWidget);
      expect(find.text('10 DT par mois'), findsOneWidget);
      expect(find.text('20 DT pour 3 mois'), findsOneWidget);
      expect(find.text('50 DT pour 12 mois'), findsOneWidget);

      await tester.ensureVisible(cle('parent_sabonner_annee'));
      await tester.pumpAndSettle();
      await tester.tap(cle('parent_sabonner_annee'));
      await tester.pumpAndSettle();
      expect(stockage.lireAbonnementSimule(), 'abonne');
      expect(find.text('Abonnement actif'), findsOneWidget);
      expect(cle('parent_sabonner_annee'), findsNothing);

      await tester.ensureVisible(cle('parent_abonnement_retour'));
      await tester.pumpAndSettle();
      await tester.tap(cle('parent_abonnement_retour'));
      await tester.pumpAndSettle();
      expect(stockage.lireAbonnementSimule(), 'essai');
      expect(find.text('Essai gratuit en cours'), findsOneWidget);

      // Le parcours suit : la carte est de nouveau ouverte.
      await tester.tap(cle('parent_quitter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lina'));
      await tester.pumpAndSettle();
      await tester.tap(cle('matiere_ar'));
      await tester.pumpAndSettle();
      expect(cle('etape_ar-1-t1-u1-e01'), findsOneWidget);
    },
  );
}
