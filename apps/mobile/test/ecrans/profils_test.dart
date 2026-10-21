import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/parent/porte_parentale.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// Profils : choix de l'enfant sur l'écran enfant, création et modification
/// dans l'espace parent (décision 28, porte fixe 6 × 7 dans les tests).
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
    expect(cle('parent_titre'), findsOneWidget);
  }

  Future<void> remplir(
    WidgetTester tester, {
    required String prenom,
    String forme = 'feminin',
  }) async {
    await tester.enterText(cle('champ_prenom'), prenom);
    await tester.ensureVisible(cle('forme_$forme'));
    await tester.tap(cle('forme_$forme'));
    await tester.pumpAndSettle();
  }

  Future<void> enregistrer(WidgetTester tester) async {
    await tester.ensureVisible(cle('profil_enregistrer'));
    await tester.tap(cle('profil_enregistrer'));
    await tester.pumpAndSettle();
  }

  group('premier lancement sans profil : bienvenue', () {
    testWidgets('en arabe, de droite à gauche', (tester) async {
      await lancerApp(tester, StockageMemoire('ar'), profils: []);
      expect(
        texteDe(tester, 'bienvenue_bulle'),
        'مَرْحَبًا! يُضِيفُ الْوَلِيُّ الطِّفْلَ الْأَوَّلَ مِنْ فَضَاءِ الْأَوْلِيَاءِ.',
      );
      expect(sensDe(tester, 'bienvenue_titre'), TextDirection.rtl);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('en français, de gauche à droite', (tester) async {
      await lancerApp(tester, StockageMemoire('fr'), profils: []);
      expect(
        texteDe(tester, 'bienvenue_bulle'),
        "Bienvenue ! Un parent ajoute le premier enfant depuis l'espace parent.",
      );
      expect(sensDe(tester, 'bienvenue_titre'), TextDirection.ltr);
      expect(cle('bienvenue_parent'), findsOneWidget);
    });
  });

  testWidgets("Enregistrer reste inactif sans forme d'adresse", (tester) async {
    await lancerApp(tester, StockageMemoire('fr'), surcharges: surcharges);
    await ouvrirParent(tester);
    await tester.tap(cle('parent_ajouter'));
    await tester.pumpAndSettle();
    await tester.enterText(cle('champ_prenom'), 'Sami');
    await tester.pump();
    final bouton = tester.widget<BoutonYasmina>(cle('profil_enregistrer'));
    expect(bouton.onPressed, isNull);
  });

  testWidgets("un seul profil : accueil direct, « Changer d'enfant » visible", (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'));
    expect(texteDe(tester, 'accueil_bonjour'), 'Bonjour Lina !');
    // Sous les matières : hors de l'écran de test, la liste défile.
    await tester.ensureVisible(cle('profil_changer'));
    await tester.pumpAndSettle();
    await tester.tap(cle('profil_changer'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'profils_titre'), 'Qui joue ?');
    expect(find.text('Lina'), findsOneWidget);
  });

  group('deux profils ou plus : choix à chaque ouverture', () {
    testWidgets('en français : choisir Yassine ouvre son accueil', (
      tester,
    ) async {
      await lancerApp(
        tester,
        StockageMemoire('fr'),
        profils: ['Lina', 'Yassine'],
      );
      expect(texteDe(tester, 'profils_titre'), 'Qui joue ?');
      expect(sensDe(tester, 'profils_titre'), TextDirection.ltr);
      await tester.tap(find.text('Yassine'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'accueil_bonjour'), 'Bonjour Yassine !');
    });

    testWidgets('en arabe : titre et sens de droite à gauche', (tester) async {
      await lancerApp(
        tester,
        StockageMemoire('ar'),
        profils: ['Lina', 'Yassine'],
      );
      expect(texteDe(tester, 'profils_titre'), 'مَنْ يَلْعَبُ؟');
      expect(sensDe(tester, 'profils_titre'), TextDirection.rtl);
    });
  });

  testWidgets('5 profils : plus d\'ajout dans l\'espace parent, message de '
      'limite', (tester) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['A', 'B', 'C', 'D', 'E'],
      surcharges: surcharges,
    );
    await ouvrirParent(tester);
    expect(cle('parent_ajouter'), findsNothing);
    expect(
      texteDe(tester, 'parent_limite'),
      '5 profils au maximum sur cet appareil',
    );
  });

  testWidgets('prénom déjà utilisé : message sous le champ', (tester) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Sami'],
      surcharges: surcharges,
    );
    await ouvrirParent(tester);
    await tester.tap(cle('parent_ajouter'));
    await tester.pumpAndSettle();
    await remplir(tester, prenom: 'lina');
    await enregistrer(tester);
    expect(
      find.text('Ce prénom est déjà utilisé sur cet appareil.'),
      findsOneWidget,
    );
  });

  testWidgets("modifier le niveau garde l'historique", (tester) async {
    final depot = await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Yassine'],
      surcharges: surcharges,
    );
    final lina = (await depot.lister()).first;
    await ouvrirParent(tester);
    await tester.tap(cle('parent_profil_${lina.id}'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'formulaire_titre'), 'Modifier le profil');

    await tester.ensureVisible(cle('niveau_3'));
    await tester.tap(cle('niveau_3'));
    await enregistrer(tester);
    expect(cle('parent_titre'), findsOneWidget);
    expect((await depot.lire(lina.id))!.niveau, 3);
    expect(await depot.historiqueNiveaux(lina.id), hasLength(2));
  });

  testWidgets('supprimer demande confirmation', (tester) async {
    final depot = await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Yassine'],
      surcharges: surcharges,
    );
    final lina = (await depot.lister()).first;
    await ouvrirParent(tester);
    Future<void> ouvrirSuppression() async {
      await tester.tap(cle('parent_profil_${lina.id}'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(cle('profil_supprimer'));
      await tester.tap(cle('profil_supprimer'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Supprimer définitivement le profil de Lina ? '
          'Toutes ses données seront effacées.',
        ),
        findsOneWidget,
      );
    }

    await ouvrirSuppression();
    await tester.tap(cle('dialogue_annuler'));
    await tester.pumpAndSettle();
    expect(await depot.lire(lina.id), isNotNull);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await ouvrirSuppression();
    await tester.tap(cle('dialogue_supprimer'));
    await tester.pumpAndSettle();
    expect(await depot.lire(lina.id), isNull);
    expect(cle('parent_profil_${lina.id}'), findsNothing);
    expect(find.text('Yassine'), findsWidgets);
  });
}
