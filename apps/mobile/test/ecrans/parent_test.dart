import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yasmina/parent/porte_parentale.dart';
import 'package:yasmina/parent/sans_harakat.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

/// L'espace parent (A3-04) : porte parentale, profils (décision 28), langue,
/// sons des effets (décision 35), progression des enfants, emplacement de
/// l'abonnement. Sans harakat (décision 27).
void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  /// Porte fixe : 6 × 7.
  final surcharges = [
    questionPorteProvider.overrideWithValue(const QuestionPorte(6, 7)),
  ];

  Future<void> ouvrirPorte(
    WidgetTester tester, {
    String depuis = 'accueil_titre',
  }) async {
    await tester.tap(cle('espace_parent_ouvrir'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'porte_question'), '6 × 7 = ?');
    await tester.enterText(cle('porte_reponse'), '42');
    await tester.tap(cle('porte_entrer'));
    await tester.pumpAndSettle();
    expect(cle('parent_titre'), findsOneWidget);
  }

  test('sansHarakat retire tanwin, fatha, damma, kasra, shadda, soukoun', () {
    expect(sansHarakat('الْإِعْدَادَاتُ'), 'الإعدادات');
    expect(sansHarakat('قَرِيبًا'), 'قريبا');
    expect(sansHarakat('Français'), 'Français');
  });

  test(
    'porte parentale : question tirée entre les bornes, réponse vérifiée',
    () {
      const q = QuestionPorte(6, 7);
      expect(q.reponse, 42);
      expect(q.verifier(' 42 '), isTrue);
      expect(q.verifier('41'), isFalse);
      expect(q.verifier('abc'), isFalse);
    },
  );

  testWidgets('mauvaise réponse : message, la porte reste fermée', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'), surcharges: surcharges);
    await tester.tap(cle('espace_parent_ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(cle('porte_reponse'), '41');
    await tester.tap(cle('porte_entrer'));
    await tester.pumpAndSettle();
    expect(find.text("Ce n'est pas la bonne réponse."), findsOneWidget);
    expect(cle('parent_titre'), findsNothing);
    // L'espace reste inaccessible par l'adresse.
    GoRouter.of(tester.element(cle('porte_titre'))).go('/parent/espace');
    await tester.pumpAndSettle();
    expect(cle('parent_titre'), findsNothing);
    expect(cle('porte_titre'), findsOneWidget);
  });

  testWidgets(
    'bonne réponse : espace parent avec les enfants, progression, langue, '
    'sons, abonnement, puis Quitter referme la porte',
    (tester) async {
      final stockage = StockageMemoire('fr');
      await lancerApp(tester, stockage, surcharges: surcharges);
      await ouvrirPorte(tester);
      expect(texteDe(tester, 'parent_titre'), 'Espace parent');
      expect(find.text('Lina'), findsWidgets);
      expect(cle('parent_ajouter'), findsOneWidget);
      expect(texteDe(tester, 'parent_1_ar'), 'Arabe : 0 / 7 étapes faites');
      expect(find.text('Maths : bientôt'), findsOneWidget);

      // Sons des effets.
      expect(stockage.lireSonsEffets(), isTrue);
      await tester.scrollUntilVisible(cle('parent_sons_effets'), 200);
      await tester.ensureVisible(cle('parent_sons_effets'));
      await tester.pumpAndSettle();
      await tester.tap(cle('parent_sons_effets'));
      await tester.pumpAndSettle();
      expect(stockage.lireSonsEffets(), isFalse);

      // Abonnement : statut simulé et offres (A3-05).
      await tester.scrollUntilVisible(cle('parent_abonnement_statut'), 200);
      expect(find.text('Essai gratuit en cours'), findsOneWidget);

      // Quitter : porte refermée, retour à « Qui joue ? ».
      await tester.tap(cle('parent_quitter'));
      await tester.pumpAndSettle();
      expect(cle('profils_titre'), findsOneWidget);
      GoRouter.of(tester.element(cle('profils_titre'))).go('/parent/espace');
      await tester.pumpAndSettle();
      expect(cle('porte_titre'), findsOneWidget);
    },
  );

  testWidgets('langue : passer en arabe bascule tout l\'écran, sans harakat', (
    tester,
  ) async {
    final stockage = StockageMemoire('fr');
    await lancerApp(tester, stockage, surcharges: surcharges);
    await ouvrirPorte(tester);
    await tester.scrollUntilVisible(cle('langue_ar'), 200);
    await tester.ensureVisible(cle('langue_ar'));
    await tester.pumpAndSettle();
    await tester.tap(cle('langue_ar'));
    await tester.pumpAndSettle();
    expect(stockage.lireLangue(), 'ar');
    expect(texteDe(tester, 'parent_titre'), 'فضاء الأولياء');
    expect(sensDe(tester, 'parent_titre'), TextDirection.rtl);
    bool haraka(int r) => (r >= 0x064B && r <= 0x0652) || r == 0x0670;
    for (final texte in tester.widgetList<Text>(find.byType(Text))) {
      final t = texte.data;
      // Les titres d'étapes (contenu) gardent leurs harakat, pas l'interface.
      if (t == null || t.startsWith('حَرْفُ') || t.startsWith('تَحَدِّي')) {
        continue;
      }
      expect(t.runes.any(haraka), isFalse, reason: t);
    }
  });

  testWidgets(
    'profils : créer, modifier le niveau, supprimer, depuis l\'espace parent',
    (tester) async {
      final depot = await lancerApp(
        tester,
        StockageMemoire('fr'),
        surcharges: surcharges,
      );
      await ouvrirPorte(tester);
      await tester.tap(cle('parent_ajouter'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'formulaire_titre'), 'Nouveau profil');
      await tester.enterText(cle('champ_prenom'), 'Yassine');
      await tester.ensureVisible(cle('forme_masculin'));
      await tester.tap(cle('forme_masculin'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(cle('niveau_2'));
      await tester.tap(cle('niveau_2'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(cle('profil_enregistrer'));
      await tester.tap(cle('profil_enregistrer'));
      await tester.pumpAndSettle();
      // Retour à l'espace parent, l'enfant est listé.
      expect(cle('parent_titre'), findsOneWidget);
      final yassine = (await depot.lister()).firstWhere(
        (p) => p.prenom == 'Yassine',
      );
      expect(yassine.niveau, 2);
      expect(cle('parent_profil_${yassine.id}'), findsOneWidget);

      // Modifier : niveau 3.
      await tester.tap(cle('parent_profil_${yassine.id}'));
      await tester.pumpAndSettle();
      expect(texteDe(tester, 'formulaire_titre'), 'Modifier le profil');
      await tester.ensureVisible(cle('niveau_3'));
      await tester.tap(cle('niveau_3'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(cle('profil_enregistrer'));
      await tester.tap(cle('profil_enregistrer'));
      await tester.pumpAndSettle();
      expect((await depot.lire(yassine.id))!.niveau, 3);
      expect(cle('parent_titre'), findsOneWidget);

      // Supprimer.
      await tester.tap(cle('parent_profil_${yassine.id}'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(cle('profil_supprimer'));
      await tester.tap(cle('profil_supprimer'));
      await tester.pumpAndSettle();
      await tester.tap(cle('dialogue_supprimer'));
      await tester.pumpAndSettle();
      expect(await depot.lire(yassine.id), isNull);
      expect(cle('parent_titre'), findsOneWidget);
      expect(cle('parent_profil_${yassine.id}'), findsNothing);
    },
  );

  testWidgets('premier lancement : bienvenue, puis le premier enfant se crée '
      'dans l\'espace parent, en arabe de droite à gauche', (tester) async {
    await lancerApp(
      tester,
      StockageMemoire('ar'),
      profils: [],
      surcharges: surcharges,
    );
    expect(cle('bienvenue_titre'), findsOneWidget);
    expect(sensDe(tester, 'bienvenue_titre'), TextDirection.rtl);
    await tester.tap(cle('bienvenue_parent'));
    await tester.pumpAndSettle();
    await tester.enterText(cle('porte_reponse'), '42');
    await tester.tap(cle('porte_entrer'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'parent_titre'), 'فضاء الأولياء');
    await tester.tap(cle('parent_ajouter'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'formulaire_titre'), 'ملف جديد');
    expect(sensDe(tester, 'formulaire_titre'), TextDirection.rtl);
    await tester.enterText(cle('champ_prenom'), 'لِينَا');
    await tester.ensureVisible(cle('forme_feminin'));
    await tester.tap(cle('forme_feminin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(cle('profil_enregistrer'));
    await tester.tap(cle('profil_enregistrer'));
    await tester.pumpAndSettle();
    expect(cle('parent_titre'), findsOneWidget);
    await tester.tap(cle('parent_quitter'));
    await tester.pumpAndSettle();
    // Un seul profil : « Qui joue ? » le propose, l'accueil suit.
    expect(cle('profils_titre'), findsOneWidget);
    await tester.tap(find.text('لِينَا'));
    await tester.pumpAndSettle();
    expect(texteDe(tester, 'accueil_bonjour'), 'مَرْحَبًا يَا لِينَا!');
  });

  testWidgets('les écrans enfant n\'ont plus ni crayon ni ajout de profil', (
    tester,
  ) async {
    await lancerApp(
      tester,
      StockageMemoire('fr'),
      profils: ['Lina', 'Yassine'],
      surcharges: surcharges,
    );
    expect(cle('profils_titre'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsNothing);
    expect(find.text('Ajouter un enfant'), findsNothing);
    expect(cle('espace_parent_ouvrir'), findsOneWidget);
  });
}
