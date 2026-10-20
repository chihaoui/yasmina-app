import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'gabarit_factice.dart';

/// Le lecteur avec un gabarit factice : le contrat, indépendamment des
/// moteurs réels.
void main() {
  late List<EvenementExercice> evenements;
  late ServicesFactices services;
  late int continues;

  setUp(() {
    evenements = [];
    services = ServicesFactices();
    continues = 0;
  });

  Future<void> jouer(
    WidgetTester tester, {
    GabaritReponse? gabarit,
    ModeExercice mode = ModeExercice.enfant,
    FormeAdresse forme = FormeAdresse.masculin,
    Map<String, dynamic>? exercice,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeYasmina.theme(langue: 'fr', luminosite: Brightness.light),
        home: Scaffold(
          body: LecteurExercice(
            exercice: exercice ?? exerciceFactice(),
            config: ConfigExercice(
              langue: 'fr',
              formeAdresse: forme,
              mode: mode,
            ),
            services: services,
            gabarit: gabarit ?? GabaritFactice(),
            onEvenement: evenements.add,
            onContinuer: () => continues++,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  BoutonYasmina bouton(WidgetTester tester) =>
      tester.widget<BoutonYasmina>(cle('lecteur_bouton'));

  testWidgets('consigne genrée, lue une fois à l\'ouverture, réécoute', (
    tester,
  ) async {
    await jouer(tester, forme: FormeAdresse.feminin);
    expect(find.text('Choisis A (féminin).'), findsOneWidget);
    expect(services.audioFactice.dits, [
      (texte: 'Choisis A (féminin).', langue: 'fr'),
    ]);
    expect(
      evenements.single,
      const DemandeAudio(
        'Choisis A (féminin).',
        langue: 'fr',
        origine: OrigineAudio.consigne,
      ),
    );
    await tester.tap(cle('lecteur_reecoute'));
    expect(services.audioFactice.dits, hasLength(2));
  });

  testWidgets('mot à écouter : après la consigne à l\'ouverture, puis au '
      'toucher, dit par le lecteur et émis', (tester) async {
    await jouer(
      tester,
      gabarit: GabaritFactice(ModeValidation.verifier, 'chat'),
    );
    expect(services.audioFactice.dits.map((d) => d.texte), [
      'Choisis A.',
      'chat',
    ]);
    expect(evenements, [
      const DemandeAudio(
        'Choisis A.',
        langue: 'fr',
        origine: OrigineAudio.consigne,
      ),
      const DemandeAudio('chat', langue: 'fr', origine: OrigineAudio.ecoute),
    ]);
    await tester.tap(cle('factice_mot'));
    await tester.pump();
    expect(services.audioFactice.dits, hasLength(3));
    expect(services.audioFactice.dits.last.texte, 'chat');
    expect(evenements.whereType<DemandeAudio>(), hasLength(3));
    // La réécoute de la consigne ne redit pas le mot.
    await tester.tap(cle('lecteur_reecoute'));
    await tester.pump();
    expect(services.audioFactice.dits.last.texte, 'Choisis A.');
  });

  testWidgets('mode vérifier : faux, faux, explication et Continuer', (
    tester,
  ) async {
    await jouer(tester);
    expect(bouton(tester).onPressed, isNull);
    await tester.tap(cle('factice_B'));
    await tester.pump();
    expect(bouton(tester).onPressed, isNotNull);
    await tester.tap(cle('lecteur_bouton'));
    await tester.pump();
    expect(cle('lecteur_feedback_indice'), findsOneWidget);
    await tester.pump(MouvementsYasmina.dureeFaux);
    await tester.tap(cle('factice_B'));
    await tester.pump();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pumpAndSettle();
    expect(cle('lecteur_feedback_explication'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    await tester.tap(cle('lecteur_bouton'));
    expect(continues, 1);
    expect(
      evenements.whereType<Resultat>().single,
      const Resultat(IssueExercice.explique, essais: 2),
    );
  });

  group('mode automatique', () {
    for (final (juste, temps, issue) in [
      (true, 'validation', IssueExercice.reussi),
      (false, 'explication', IssueExercice.explique),
    ]) {
      testWidgets('fin ${juste ? 'juste' : 'fausse'} : $temps puis Continuer', (
        tester,
      ) async {
        await jouer(
          tester,
          gabarit: GabaritFactice(ModeValidation.automatique),
        );
        // Pas de bouton Vérifier tant que la zone n'a pas fini.
        expect(cle('lecteur_bouton'), findsNothing);
        await tester.tap(cle('factice_A'));
        await tester.pump();
        expect(cle('lecteur_bouton'), findsNothing);

        await tester.tap(cle('factice_fin_$juste'));
        await tester.pumpAndSettle();
        expect(cle('lecteur_feedback_$temps'), findsOneWidget);
        expect(find.text('Continuer'), findsOneWidget);
        expect(evenements.whereType<Resultat>().single.issue, issue);
        expect(services.audioFactice.sons, [
          juste ? SonInterface.juste : SonInterface.revelee,
        ]);
        expect(evenements.whereType<Essai>().single.juste, juste);

        await tester.tap(cle('lecteur_bouton'));
        expect(continues, 1);
      });
    }

    testWidgets('en aperçu : feedback, sans événement de progression', (
      tester,
    ) async {
      await jouer(
        tester,
        gabarit: GabaritFactice(ModeValidation.automatique),
        mode: ModeExercice.apercu,
      );
      await tester.tap(cle('factice_fin_true'));
      await tester.pumpAndSettle();
      expect(cle('lecteur_feedback_validation'), findsOneWidget);
      expect(evenements.whereType<Resultat>(), isEmpty);
    });
  });

  testWidgets('mode sans note : Continuer dès que la réponse est complète', (
    tester,
  ) async {
    await jouer(tester, gabarit: GabaritFactice(ModeValidation.sansNote));
    expect(find.text('Continuer'), findsOneWidget);
    expect(bouton(tester).onPressed, isNull);
    await tester.tap(cle('factice_B'));
    await tester.pump();
    await tester.tap(cle('lecteur_bouton'));
    await tester.pump();
    expect(continues, 1);
    expect(find.byType(BandeauFeedback), findsNothing);
    expect(
      evenements.whereType<Resultat>().single,
      const Resultat(IssueExercice.termine, essais: 0),
    );
    // Type non noté : aucun son de feedback.
    expect(services.audioFactice.sons, isEmpty);
  });

  testWidgets('type sans gabarit : message, aucune exception', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LecteurExercice(
            exercice: exerciceFactice(),
            config: const ConfigExercice(
              langue: 'fr',
              formeAdresse: FormeAdresse.masculin,
            ),
            services: services,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Type T99 pas encore jouable.'), findsOneWidget);
    expect(services.audioFactice.dits, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('édition : l\'exercice se recharge quand le JSON change', (
    tester,
  ) async {
    await jouer(tester, mode: ModeExercice.edition);
    await tester.tap(cle('factice_B'));
    await tester.pump();
    final modifie = exerciceFactice()
      ..['consigne'] = {'texte': 'Nouvelle consigne.'};
    await jouer(tester, mode: ModeExercice.edition, exercice: modifie);
    expect(find.text('Nouvelle consigne.'), findsOneWidget);
    expect(services.audioFactice.dits.last.texte, 'Nouvelle consigne.');
    // Réponse vidée : nouveau contrôleur.
    expect(bouton(tester).onPressed, isNull);
  });
}
