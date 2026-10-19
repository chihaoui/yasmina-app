import 'dart:convert';

import 'package:edu_content/edu_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// T02 anglais : exemple réel (réponse : faux).
Map<String, dynamic> t02Anglais() =>
    jsonDecode(exemplesEduContent['choix/T02-vrai-faux.json']!)
        as Map<String, dynamic>;

/// T02 arabe : textes relus de la fixture du schéma (réponse : vrai).
Map<String, dynamic> t02Arabe() => {
  'id': 'ar-1-t1-u1-e01-x02',
  'type': 'T02',
  'gabarit': 'vrai-faux-texte',
  'langue': 'ar',
  'consigne': {'texte': 'هَلْ هَذِهِ الْجُمْلَةُ صَحِيحَةٌ؟'},
  'donnees': {'affirmation': 'كَلِمَةُ «بَطَّةٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ.'},
  'reponse': {'valeur': true},
  'feedbacks': {
    'reussite': {
      'masculin':
          'إِجَابَتُكَ صَحِيحَةٌ: «بَطَّةٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ.',
      'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: «بَطَّةٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ.',
    },
    'indice': {
      'masculin': 'رَدِّدِ الْكَلِمَةَ بِبُطْءٍ.',
      'feminin': 'رَدِّدِي الْكَلِمَةَ بِبُطْءٍ.',
    },
    'explication':
        'الْجُمْلَةُ صَحِيحَةٌ: «بَطَّةٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ.',
  },
};

void main() {
  late List<EvenementExercice> evenements;
  late ServicesFactices services;

  setUp(() {
    evenements = [];
    services = ServicesFactices();
  });

  Future<void> jouer(
    WidgetTester tester,
    Map<String, dynamic> exercice, {
    FormeAdresse forme = FormeAdresse.masculin,
    ModeExercice mode = ModeExercice.enfant,
  }) async {
    final langue = exercice['langue'] as String;
    await tester.pumpWidget(
      MaterialApp(
        // Interface en français : le lecteur suit la langue de l'exercice.
        locale: const Locale('fr'),
        supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeYasmina.theme(langue: 'fr', luminosite: Brightness.light),
        home: Scaffold(
          body: LecteurExercice(
            exercice: exercice,
            config: ConfigExercice(
              langue: langue,
              formeAdresse: forme,
              mode: mode,
            ),
            services: services,
            onEvenement: evenements.add,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  EtatTuile etat(WidgetTester tester, bool valeur) =>
      tester.widget<TuileChoix>(cle('vrai_faux_$valeur')).etat;

  HumeurYasmina humeur(WidgetTester tester) =>
      tester.widget<Yasmina>(find.byType(Yasmina)).humeur;

  String libelleBouton(WidgetTester tester) =>
      tester.widget<BoutonYasmina>(cle('lecteur_bouton')).libelle;

  Future<void> choisirEtVerifier(WidgetTester tester, bool valeur) async {
    await tester.tap(cle('vrai_faux_$valeur'));
    await tester.pump();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pump();
  }

  testWidgets(
    'anglais : faux au 1er essai (indice, sélection vidée), juste au 2e',
    (tester) async {
      await jouer(tester, t02Anglais());
      expect(services.audioFactice.dits.single.texte, 'True or false?');
      expect(find.text('🐘'), findsOneWidget);
      expect(find.text('An elephant is a small animal.'), findsOneWidget);
      // De gauche à droite : True à gauche de False.
      expect(
        tester.getCenter(cle('vrai_faux_true')).dx,
        lessThan(tester.getCenter(cle('vrai_faux_false')).dx),
      );
      expect(libelleBouton(tester), 'Check');
      expect(
        tester.widget<BoutonYasmina>(cle('lecteur_bouton')).onPressed,
        isNull,
      );

      await choisirEtVerifier(tester, true);
      expect(etat(tester, true), EtatTuile.faux);
      expect(cle('lecteur_feedback_indice'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(
        find.text('Think about the size of an elephant next to a cat.'),
        findsOneWidget,
      );
      expect(humeur(tester), HumeurYasmina.encourage);

      await tester.pump(MouvementsYasmina.dureeFaux);
      expect(etat(tester, true), EtatTuile.repos);
      expect(
        tester.widget<BoutonYasmina>(cle('lecteur_bouton')).onPressed,
        isNull,
      );
      expect(cle('lecteur_feedback_indice'), findsOneWidget);

      await choisirEtVerifier(tester, false);
      await tester.pumpAndSettle();
      expect(etat(tester, false), EtatTuile.juste);
      expect(find.text('Well done'), findsOneWidget);
      expect(humeur(tester), HumeurYasmina.bravo);
      expect(libelleBouton(tester), 'Continue');
      expect(evenements.whereType<Essai>(), [
        const Essai(1, juste: false),
        const Essai(2, juste: true),
      ]);
      expect(
        evenements.whereType<Resultat>().single,
        const Resultat(IssueExercice.reussi, essais: 2),
      );
      expect(evenements.whereType<ReponseDonnee>().map((e) => e.reponse), [
        true,
        false,
      ]);
      expect(services.audioFactice.sons, [
        SonInterface.essaiFaux,
        SonInterface.juste,
      ]);
    },
  );

  testWidgets(
    'arabe au féminin : libellés genrés, de droite à gauche, explication',
    (tester) async {
      await jouer(tester, t02Arabe(), forme: FormeAdresse.feminin);
      final consigne = tester.element(cle('lecteur_consigne'));
      expect(Directionality.of(consigne), TextDirection.rtl);
      expect(libelleBouton(tester), 'تَحَقَّقِي');
      // صَحِيحٌ (vrai) au début de ligne, donc à droite.
      expect(find.text('صَحِيحٌ'), findsOneWidget);
      expect(
        tester.getCenter(cle('vrai_faux_true')).dx,
        greaterThan(tester.getCenter(cle('vrai_faux_false')).dx),
      );

      await choisirEtVerifier(tester, false);
      expect(find.text('رَدِّدِي الْكَلِمَةَ بِبُطْءٍ.'), findsOneWidget);
      await tester.pump(MouvementsYasmina.dureeFaux);
      await choisirEtVerifier(tester, false);
      await tester.pumpAndSettle();
      expect(cle('lecteur_feedback_explication'), findsOneWidget);
      expect(find.text('لِنَتَعَلَّمْ'), findsOneWidget);
      // Bonne réponse révélée, zone verrouillée.
      expect(etat(tester, true), EtatTuile.juste);
      expect(etat(tester, false), EtatTuile.repos);
      expect(tester.widget<TuileChoix>(cle('vrai_faux_true')).onTap, isNull);
      expect(libelleBouton(tester), 'وَاصِلِي');
      expect(services.audioFactice.sons, [
        SonInterface.essaiFaux,
        SonInterface.revelee,
      ]);
      expect(
        evenements.whereType<Resultat>().single,
        const Resultat(IssueExercice.explique, essais: 2),
      );
    },
  );

  testWidgets('arabe au masculin : juste au 1er essai', (tester) async {
    await jouer(tester, t02Arabe());
    expect(libelleBouton(tester), 'تَحَقَّقْ');
    await choisirEtVerifier(tester, true);
    await tester.pumpAndSettle();
    expect(find.text('أَحْسَنْتَ'), findsOneWidget);
    expect(
      find.text('إِجَابَتُكَ صَحِيحَةٌ: «بَطَّةٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ.'),
      findsOneWidget,
    );
    expect(libelleBouton(tester), 'وَاصِلْ');
    expect(services.vibrationFactice.legeres, 1);
  });

  testWidgets('aperçu : afficher la réponse, Rejouer, aucune progression', (
    tester,
  ) async {
    await jouer(tester, t02Anglais(), mode: ModeExercice.apercu);
    await tester.tap(cle('lecteur_afficher_reponse'));
    await tester.pump();
    expect(etat(tester, false), EtatTuile.juste);
    expect(find.text('bonne réponse'), findsOneWidget);
    await tester.tap(cle('lecteur_afficher_reponse'));
    await tester.pump();
    expect(etat(tester, false), EtatTuile.repos);

    await choisirEtVerifier(tester, false);
    await tester.pumpAndSettle();
    expect(cle('lecteur_feedback_validation'), findsOneWidget);
    await tester.tap(cle('lecteur_rejouer'));
    await tester.pumpAndSettle();
    expect(find.byType(BandeauFeedback), findsNothing);
    expect(etat(tester, false), EtatTuile.repos);
    expect(libelleBouton(tester), 'Check');
    expect(evenements.whereType<Essai>(), isEmpty);
    expect(evenements.whereType<Resultat>(), isEmpty);
  });

  testWidgets("sans voix pour la langue : l'exercice reste jouable", (
    tester,
  ) async {
    services = ServicesFactices(voix: {'fr'});
    await jouer(tester, t02Arabe());
    await choisirEtVerifier(tester, true);
    await tester.pumpAndSettle();
    expect(cle('lecteur_feedback_validation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('anglais : affirmation et tuiles en latin-prompt', (
    tester,
  ) async {
    await jouer(tester, t02Anglais());
    for (final texte in ['An elephant is a small animal.', 'True', 'False']) {
      final style = tester.widget<Text>(find.text(texte)).style!;
      expect(style.fontSize, StylesYasmina.latinPrompt.fontSize, reason: texte);
      expect(style.fontFamily, PolicesYasmina.latin, reason: texte);
    }
  });
}
