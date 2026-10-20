import 'package:edu_content/edu_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Partie d'un exercice du moteur Choix dans le lecteur, avec des services
/// factices et le journal des événements.
class Partie {
  Partie(this.tester, {this.services, this.evenements});

  final WidgetTester tester;
  ServicesFactices? services;
  List<EvenementExercice>? evenements;

  ServicesFactices get audio => services!;

  var _parties = 0;

  /// Affiche [exercice] (déjà valide) dans le lecteur. Interface en
  /// français : le lecteur suit la langue de l'exercice.
  Future<void> jouer(
    Map<String, dynamic> exercice, {
    FormeAdresse forme = FormeAdresse.masculin,
    ModeExercice mode = ModeExercice.enfant,
    int? graine = 1,
    Set<String>? voix,
  }) async {
    final validation = validerExercice(exercice);
    expect(validation.erreurs, isEmpty, reason: '$validation');
    services = ServicesFactices(voix: voix);
    evenements = [];
    final langue = exercice['langue'] as String;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeYasmina.theme(langue: 'fr', luminosite: Brightness.light),
        home: Scaffold(
          body: LecteurExercice(
            // Une nouvelle partie à chaque appel (jamais l'état précédent).
            key: ValueKey('partie_${_parties++}'),
            exercice: exercice,
            config: ConfigExercice(
              langue: langue,
              formeAdresse: forme,
              mode: mode,
              graine: graine,
            ),
            services: services!,
            onEvenement: evenements!.add,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder cle(String valeur) => find.byKey(ValueKey(valeur));

  /// État de la tuile qui porte la clé [valeur].
  EtatTuile etat(String valeur) => tester.widget<TuileChoix>(cle(valeur)).etat;

  TuileChoix tuile(String valeur) => tester.widget<TuileChoix>(cle(valeur));

  BoutonYasmina get bouton =>
      tester.widget<BoutonYasmina>(cle('lecteur_bouton'));

  HumeurYasmina get humeur =>
      tester.widget<Yasmina>(find.byType(Yasmina)).humeur;

  TextDirection get sens =>
      Directionality.of(tester.element(cle('lecteur_consigne')));

  Future<void> toucher(String valeur) async {
    await tester.ensureVisible(cle(valeur));
    await tester.tap(cle(valeur));
    await tester.pump();
  }

  /// Appuie sur Vérifier (ou Continuer).
  Future<void> verifier() async {
    await tester.ensureVisible(cle('lecteur_bouton'));
    await tester.tap(cle('lecteur_bouton'));
    await tester.pump();
  }

  /// Attend la fin du marquage « faux » du 1er essai.
  Future<void> attendreVidage() => tester.pump(MouvementsYasmina.dureeFaux);

  List<Object?> get reponsesDonnees =>
      evenements!.whereType<ReponseDonnee>().map((e) => e.reponse).toList();

  List<Essai> get essais => evenements!.whereType<Essai>().toList();

  Resultat get resultat => evenements!.whereType<Resultat>().single;

  List<DemandeAudio> get demandesAudio =>
      evenements!.whereType<DemandeAudio>().toList();
}

/// Exercice seul minimal du moteur Choix (brouillon, empreinte de test).
Map<String, dynamic> exerciceChoix({
  required String type,
  required String langue,
  required String gabarit,
  required Object consigne,
  required Map<String, dynamic> donnees,
  required Map<String, dynamic> reponse,
  required Object reussite,
  required Object indice,
  required Object explication,
  String competence = 'essai',
  int niveau = 2,
}) {
  final code = langue;
  return {
    'id': '$code-$niveau-t1-u1-e01-x01',
    'type': type,
    'gabarit': gabarit,
    'competence': '$code-$competence',
    'critere': 'C1',
    'niveau_critere': 'minimal',
    'langue': langue,
    'consigne': {'texte': consigne},
    'donnees': donnees,
    'reponse': reponse,
    'feedbacks': {
      'reussite': reussite,
      'indice': indice,
      'explication': explication,
    },
    'empreinte': 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
    'statut': 'brouillon',
    'version': 1,
  };
}
