import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

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

  group('premier lancement sans profil : création directe', () {
    testWidgets('en arabe, de droite à gauche', (tester) async {
      await lancerApp(tester, StockageMemoire('ar'), profils: []);
      expect(texteDe(tester, 'formulaire_titre'), 'مَلَفٌّ جَدِيدٌ');
      expect(sensDe(tester, 'formulaire_titre'), TextDirection.rtl);
      expect(find.byType(BackButton), findsNothing);

      await remplir(tester, prenom: 'لِينَا');
      await enregistrer(tester);
      expect(texteDe(tester, 'accueil_bonjour'), 'مَرْحَبًا يَا لِينَا!');
    });

    testWidgets('en français, de gauche à droite', (tester) async {
      final depot = await lancerApp(tester, StockageMemoire('fr'), profils: []);
      expect(texteDe(tester, 'formulaire_titre'), 'Nouveau profil');
      expect(sensDe(tester, 'formulaire_titre'), TextDirection.ltr);

      await remplir(tester, prenom: 'Yassine', forme: 'masculin');
      await tester.tap(cle('niveau_2'));
      await enregistrer(tester);
      expect(texteDe(tester, 'accueil_bonjour'), 'Bonjour Yassine !');
      final profil = (await depot.lister()).single;
      expect(profil.niveau, 2);
    });

    testWidgets("Enregistrer reste inactif sans forme d'adresse", (
      tester,
    ) async {
      await lancerApp(tester, StockageMemoire('fr'), profils: []);
      await tester.enterText(cle('champ_prenom'), 'Lina');
      await tester.pump();
      final bouton = tester.widget<BoutonYasmina>(cle('profil_enregistrer'));
      expect(bouton.onPressed, isNull);
    });
  });

  testWidgets("un seul profil : accueil direct, « Changer d'enfant » visible", (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'));
    expect(texteDe(tester, 'accueil_bonjour'), 'Bonjour Lina !');
    await tester.tap(cle('profil_changer'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'profils_titre'), 'Qui joue ?');
    expect(cle('profils_ajouter'), findsOneWidget);
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

  testWidgets('5 profils : plus de bouton Ajouter, message de limite', (
    tester,
  ) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['A', 'B', 'C', 'D', 'E'],
    );
    expect(cle('profils_ajouter'), findsNothing);
    expect(
      texteDe(tester, 'profils_limite'),
      '5 profils au maximum sur cet appareil',
    );
  });

  testWidgets('prénom déjà utilisé : message sous le champ', (tester) async {
    await lancerApp(tester, StockageMemoire('fr'), profils: ['Lina', 'Sami']);
    await tester.tap(cle('profils_ajouter'));
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
    );
    final lina = (await depot.lister()).first;
    await tester.tap(cle('profil_modifier_${lina.id}'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'formulaire_titre'), 'Modifier le profil');

    await tester.tap(cle('niveau_3'));
    await enregistrer(tester);
    expect(texteDe(tester, 'profils_titre'), 'Qui joue ?');
    expect((await depot.lire(lina.id))!.niveau, 3);
    expect(await depot.historiqueNiveaux(lina.id), hasLength(2));
  });

  testWidgets('supprimer demande confirmation', (tester) async {
    final depot = await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Yassine'],
    );
    final lina = (await depot.lister()).first;
    Future<void> ouvrirSuppression() async {
      await tester.tap(cle('profil_modifier_${lina.id}'));
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
    expect(find.text('Lina'), findsNothing);
    expect(find.text('Yassine'), findsOneWidget);
  });
}
