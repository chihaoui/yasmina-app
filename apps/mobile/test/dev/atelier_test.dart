import 'dart:convert';

import 'package:edu_content/edu_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/dev/atelier_ecran.dart';
import 'package:yasmina/dev/menu_dev.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

import '../outils.dart';

void main() {
  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  /// Types du moteur Choix déjà jouables (ils entrent un par un).
  final jouablesChoix = typesDuMoteur(Moteur.choix)
      .where((t) => t.etat == EtatType.jouable)
      .length;

  Future<void> aller(WidgetTester tester, String chemin) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(chemin);
    await tester.pumpAndSettle();
  }

  test('contenu : moteurs dans l\'ordre de développement, 53 types', () {
    final lignes = contenuAtelier(CatalogueExemples());
    final moteurs = lignes.whereType<EnTeteMoteur>().map((e) => e.moteur);
    expect(moteurs, Moteur.values);
    expect(lignes.whereType<LigneType>(), hasLength(53));
    final choix = lignes.whereType<EnTeteMoteur>().first;
    expect((choix.jouables, choix.total), (jouablesChoix, 13));
    // Chaque type suit l'en-tête de son moteur.
    Moteur? courant;
    for (final ligne in lignes) {
      if (ligne is EnTeteMoteur) courant = ligne.moteur;
      if (ligne is LigneType) expect(ligne.type.moteur, courant);
    }
  });

  testWidgets('ouvert depuis le menu : groupé par moteur, Choix en premier', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('ar'));
    await tester.longPress(cle('accueil_titre'));
    await tester.pumpAndSettle();
    await tester.tap(cle('dev_atelier'));
    await tester.pumpAndSettle();

    expect(texteDe(tester, 'atelier_titre'), 'Atelier');
    expect(sensDe(tester, 'atelier_titre'), TextDirection.ltr);
    expect(
      texteDe(tester, 'atelier_moteur_choix'),
      'Choix · $jouablesChoix / 13 jouables',
    );
    expect(find.text('T01  QCM'), findsOneWidget);
    expect(find.text('Lot 1 · 4 exemples'), findsOneWidget);
    expect(find.text('Jouable'), findsWidgets);

    // Le dernier moteur (Récit, lot 2) est atteint en défilant.
    await tester.scrollUntilVisible(cle('atelier_type_T35'), 300);
    expect(texteDe(tester, 'atelier_moteur_recit'), 'Récit · 0 / 1 jouables');
    expect(find.text('À venir'), findsWidgets);
  });

  testWidgets('T01 : 4 exemples valides, consigne arabe de droite à gauche', (
    tester,
  ) async {
    await lancerApp(tester, StockageMemoire('fr'));
    await aller(tester, '/dev/atelier/T01');
    expect(texteDe(tester, 'atelier_type_titre'), 'T01  QCM');
    expect(find.byType(Card), findsNWidgets(4));
    expect(texteDe(tester, 'statut_T01-qcm-contraire.json'), 'Valide');
    expect(
      sensDe(tester, 'consigne_T01-qcm-contraire.json'),
      TextDirection.rtl,
    );
    expect(
      sensDe(tester, 'consigne_T01-qcm-orthographe.json'),
      TextDirection.ltr,
    );
  });

  testWidgets('type sans exemple : ouvrable, avec un message', (tester) async {
    await lancerApp(tester, StockageMemoire('fr'));
    await aller(tester, '/dev/atelier/T20');
    expect(
      texteDe(tester, 'atelier_type_titre'),
      'T20  Tracé de lettre (non noté)',
    );
    expect(cle('atelier_aucun_exemple'), findsOneWidget);
  });

  testWidgets('exemple ouvert : mode, zone du lecteur à venir et JSON', (
    tester,
  ) async {
    // Un type à venir (T20, moteur Tracé) avec un exemple valide rangé
    // sous lui : tous les exemples réels sont jouables, le catalogue est
    // surchargé.
    final t20 =
        jsonDecode(
            exemplesEduContent['glisser-deposer/T14-sequence-images.json']!,
          ) as Map<String, dynamic>
          ..['type'] = 'T20'
          ..['gabarit'] = 'trace-lettre'
          ..['donnees'] = {'lettre': 'ب'}
          ..['reponse'] = <String, dynamic>{};
    final surcharge = catalogueExemplesProvider.overrideWithValue(
      CatalogueExemples({'trace/T20-essai.json': jsonEncode(t20)}),
    );
    await lancerApp(tester, StockageMemoire('fr'), surcharges: [surcharge]);
    await aller(tester, '/dev/atelier/T20/T20-essai.json');
    expect(texteDe(tester, 'zone_lecteur_message'), startsWith('Type à venir'));
    await tester.tap(find.text('Aperçu'));
    await tester.pumpAndSettle();
    final json = tester.widget<SelectableText>(cle('atelier_json')).data!;
    expect(json, contains('"gabarit": "trace-lettre"'));
    // Les harakat restent telles qu'écrites.
    expect(json, contains('رَتِّبْ مَرَاحِلَ نُمُوِّ الدَّجَاجَةِ.'));
  });

  group('exemples en erreur', () {
    final valide = exemplesEduContent['choix/T04-intrus.json']!;
    final invalide = (jsonDecode(valide) as Map<String, dynamic>)
      ..['reponse'] = {
        'choix': ['c9'],
      };
    final surcharges = [
      catalogueExemplesProvider.overrideWithValue(
        CatalogueExemples({
          'choix/T04-intrus.json': valide,
          'choix/T04-illisible.json': '{"type": ',
          'choix/T04-invalide.json': jsonEncode(invalide),
          'choix/sans-prefixe.json': valide,
        }),
      ),
    ];

    testWidgets('signalés dans la liste et dans le type, sans plantage', (
      tester,
    ) async {
      await lancerApp(tester, StockageMemoire('fr'), surcharges: surcharges);
      await aller(tester, '/dev/atelier');
      await tester.scrollUntilVisible(cle('atelier_type_T04'), 200);
      expect(
        find.textContaining('3 exemples · 2 en erreur', findRichText: true),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(cle('atelier_non_rattaches'), 300);
      expect(find.text('choix/sans-prefixe.json'), findsOneWidget);

      await aller(tester, '/dev/atelier/T04');
      expect(texteDe(tester, 'statut_T04-intrus.json'), 'Valide');
      expect(
        texteDe(tester, 'statut_T04-illisible.json'),
        startsWith('En erreur :\nJSON illisible'),
      );
      expect(
        texteDe(tester, 'statut_T04-invalide.json'),
        contains('reponse_choix_inconnu'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('un exemple illisible s\'ouvre, JSON brut et lecteur bloqué', (
      tester,
    ) async {
      await lancerApp(tester, StockageMemoire('fr'), surcharges: surcharges);
      await aller(tester, '/dev/atelier/T04/T04-illisible.json');
      expect(
        tester.widget<SelectableText>(cle('atelier_json')).data,
        '{"type": ',
      );
      expect(
        texteDe(tester, 'zone_lecteur_message'),
        startsWith('Exemple invalide'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('T02 jouable dans l\'atelier', () {
    const chemin = '/dev/atelier/T02/T02-vrai-faux.json';

    String journal(WidgetTester tester) =>
        tester.widget<Text>(cle('atelier_journal')).data!;

    testWidgets('le lecteur joue l\'exemple, le journal suit les événements', (
      tester,
    ) async {
      await lancerApp(tester, StockageMemoire('fr'));
      await aller(tester, chemin);
      expect(find.byType(LecteurExercice), findsOneWidget);
      expect(cle('atelier_voix_absente'), findsNothing);
      expect(journal(tester), 'demandeAudio (consigne, en) : True or false?');

      await tester.ensureVisible(cle('vrai_faux_false'));
      await tester.pumpAndSettle();
      await tester.tap(cle('vrai_faux_false'));
      await tester.pump();
      await tester.tap(cle('lecteur_bouton'));
      await tester.pumpAndSettle();
      expect(journal(tester).split('\n').take(3), [
        'resultat : reussi (1 essai(s))',
        'essai 1 : juste',
        'reponseDonnee : false',
      ]);

      // Continuer relance une partie du même exemple.
      await tester.tap(cle('lecteur_bouton'));
      await tester.pumpAndSettle();
      expect(journal(tester), contains('continuer : nouvelle partie'));
      expect(
        tester.widget<TuileChoix>(cle('vrai_faux_false')).etat,
        EtatTuile.repos,
      );
    });

    testWidgets('mode aperçu et forme féminine transmis au lecteur', (
      tester,
    ) async {
      await lancerApp(tester, StockageMemoire('fr'));
      await aller(tester, chemin);
      await tester.tap(find.text('Aperçu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Féminin'));
      await tester.pumpAndSettle();
      final config = tester
          .widget<LecteurExercice>(find.byType(LecteurExercice))
          .config;
      expect(config.mode, ModeExercice.apercu);
      expect(config.formeAdresse, FormeAdresse.feminin);
      expect(cle('lecteur_afficher_reponse'), findsOneWidget);
    });

    testWidgets('sans voix pour la langue : avertissement, lecteur jouable', (
      tester,
    ) async {
      await lancerApp(
        tester,
        StockageMemoire('fr'),
        services: ServicesFactices(voix: {'fr'}),
      );
      await aller(tester, chemin);
      expect(
        texteDe(tester, 'atelier_voix_absente'),
        startsWith('Aucune voix anglaise sur cet appareil'),
      );
      expect(find.byType(LecteurExercice), findsOneWidget);
    });
  });
}
