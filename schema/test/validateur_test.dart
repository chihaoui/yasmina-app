import 'dart:convert';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/etape_exemple.dart';

Map<String, dynamic> exemple() =>
    jsonDecode(etapeExemple) as Map<String, dynamic>;

/// Valide une copie de l'exemple après [modifier].
ResultatValidation valider(void Function(dynamic d) modifier) {
  final d = exemple();
  modifier(d);
  return validerEtapeDecodee(d);
}

Matcher probleme(String chemin, String code) => isA<ProblemeValidation>()
    .having((p) => p.chemin, 'chemin', chemin)
    .having((p) => p.code, 'code', code);

void main() {
  group('JSON valide', () {
    test("l'exemple passe, avec le seul avertissement sur les 4 séquences", () {
      final r = validerEtape(etapeExemple);
      expect(r.erreurs, isEmpty, reason: '$r');
      expect(r.estValide, isTrue);
      expect(r.avertissements, [
        probleme('/etape/sequences', 'sequences_nombre'),
      ]);
    });

    test('une consigne genrée est acceptée', () {
      final r = valider((d) {
        d['exercices'][0]['consigne']['texte'] = {
          'masculin': 'اِخْتَرِ الْكَلِمَةَ الصَّحِيحَةَ.',
          'feminin': 'اِخْتَارِي الْكَلِمَةَ الصَّحِيحَةَ.',
        };
      });
      expect(r.erreurs, isEmpty, reason: '$r');
    });

    test('un T05 accepte plusieurs bonnes réponses', () {
      final r = valider((d) {
        d['exercices'][0]['type'] = 'T05';
        d['exercices'][0]['reponse'] = {
          'choix': ['c1', 'c2'],
        };
      });
      expect(r.erreurs, isEmpty, reason: '$r');
    });

    test('un exercice orphelin donne un avertissement, pas une erreur', () {
      final r = valider((d) {
        final copie = jsonDecode(jsonEncode(d['exercices'][1]));
        copie['id'] = 'ar-1-t1-u1-e01-x03';
        (d['exercices'] as List).add(copie);
      });
      expect(r.estValide, isTrue, reason: '$r');
      expect(
        r.avertissements,
        contains(probleme('/exercices/2/id', 'exercice_orphelin')),
      );
    });

    test('la validation ne modifie pas les données (harakat comprises)', () {
      final d = exemple();
      final avant = jsonEncode(d);
      final affirmation = d['exercices'][1]['donnees']['affirmation'] as String;
      final runes = affirmation.runes.toList();
      validerEtapeDecodee(d);
      expect(jsonEncode(d), avant);
      expect(
        (d['exercices'][1]['donnees']['affirmation'] as String).runes,
        orderedEquals(runes),
      );
    });
  });

  group('JSON invalides : schéma', () {
    test('JSON mal formé', () {
      final r = validerEtape('{"generation": ');
      expect(r.erreurs.single, probleme('/', 'json_illisible'));
    });

    test('bloc exercices absent', () {
      final r = valider((d) => d.remove('exercices'));
      expect(r.erreurs.single, probleme('/', 'obligatoire'));
      expect(r.erreurs.single.message, contains('exercices'));
    });

    test('mauvaise version de schéma', () {
      final r = valider((d) => d['generation']['schema'] = 'edu-content/2.0');
      expect(
        r.erreurs.single,
        probleme('/generation/schema', 'valeur_attendue'),
      );
      expect(r.erreurs.single.message, contains('edu-content/1.0'));
    });

    test('type hors catalogue', () {
      final r = valider((d) => d['exercices'][0]['type'] = 'T64');
      expect(
        r.erreurs.single,
        probleme('/exercices/0/type', 'format_incorrect'),
      );
      expect(r.erreurs.single.message, contains('T01 à T63'));
    });

    test('feedback avec masculin sans feminin', () {
      final r = valider(
        (d) => d['exercices'][0]['feedbacks']['reussite'] = {'masculin': 'x'},
      );
      expect(
        r.erreurs.single,
        probleme('/exercices/0/feedbacks/reussite', 'forme_incorrecte'),
      );
      expect(r.erreurs.single.message, contains('masculin et feminin'));
    });

    test('texte de choix vide : chemin précis malgré if/then', () {
      final r = valider(
        (d) => d['exercices'][0]['donnees']['choix'][1]['texte'] = '',
      );
      expect(
        r.erreurs.single,
        probleme('/exercices/0/donnees/choix/1/texte', 'texte_trop_court'),
      );
    });

    test('propriété inconnue et niveau hors limites', () {
      final r = valider((d) {
        d['etape']['niveau'] = 7;
        d['etape']['bonus'] = true;
      });
      expect(
        r.erreurs,
        unorderedEquals([
          probleme('/etape/niveau', 'valeur_trop_grande'),
          probleme('/etape', 'propriete_inconnue'),
        ]),
      );
    });
  });

  group('JSON invalides : règles métier', () {
    test("langue d'un exercice différente de celle de l'étape", () {
      final r = valider((d) => d['exercices'][1]['langue'] = 'fr');
      expect(
        r.erreurs.single.toString(),
        "/exercices/1/langue [langue_incoherente] : la langue de l'exercice "
        "(fr) doit être celle de l'étape (ar).",
      );
    });

    test('étape de maths en français', () {
      final r = valider((d) {
        d['etape']['matiere'] = 'maths';
        d['etape']['langue'] = 'fr';
      });
      expect(r.erreurs, contains(probleme('/etape/langue', 'langue_matiere')));
      expect(
        r.erreurs.firstWhere((e) => e.code == 'langue_matiere').message,
        'une étape de maths doit être en arabe (ar), pas en français (fr).',
      );
    });

    test("séquence qui cite un exercice inexistant", () {
      final r = valider(
        (d) =>
            d['etape']['sequences'][0]['exercices'][1] = 'ar-1-t1-u1-e01-x09',
      );
      expect(
        r.erreurs.single,
        probleme('/etape/sequences/0/exercices/1', 'id_inconnu'),
      );
      expect(
        r.avertissements,
        contains(probleme('/exercices/1/id', 'exercice_orphelin')),
      );
    });

    test('id en double', () {
      final r = valider((d) => d['exercices'][1]['id'] = 'ar-1-t1-u1-e01-x01');
      expect(r.erreurs, contains(probleme('/exercices/1/id', 'id_duplique')));
    });

    test('réponse T01 vers un choix absent', () {
      final r = valider(
        (d) => d['exercices'][0]['reponse'] = {
          'choix': ['c9'],
        },
      );
      expect(
        r.erreurs.single,
        probleme('/exercices/0/reponse/choix/0', 'reponse_choix_inconnu'),
      );
    });

    test('T01 avec deux bonnes réponses', () {
      final r = valider(
        (d) => d['exercices'][0]['reponse'] = {
          'choix': ['c1', 'c2'],
        },
      );
      expect(
        r.erreurs.single,
        probleme('/exercices/0/reponse/choix', 'reponse_t01_unique'),
      );
    });

    test('date qui n’existe pas', () {
      final r = valider((d) => d['generation']['date'] = '2026-02-30');
      expect(
        r.erreurs,
        contains(probleme('/generation/date', 'date_invalide')),
      );
    });

    test("id de l'étape incohérent avec ses champs", () {
      final r = valider((d) => d['etape']['ordre'] = 2);
      expect(r.erreurs.single, probleme('/etape/id', 'id_incoherent'));
      expect(r.erreurs.single.message, contains('ar-1-t1-u1-e02'));
    });

    test("compétence d'une autre matière", () {
      final r = valider(
        (d) => d['exercices'][0]['competence'] = 'fr-lecture-son-initial',
      );
      expect(
        r.erreurs.single,
        probleme('/exercices/0/competence', 'competence_matiere'),
      );
    });

    test('texte arabe sans harakat en 1re année : avertissement', () {
      final r = valider(
        (d) => d['exercices'][0]['donnees']['choix'][0]['texte'] = 'باب',
      );
      expect(r.estValide, isTrue);
      expect(
        r.avertissements,
        contains(
          probleme('/exercices/0/donnees/choix/0/texte', 'harakat_manquantes'),
        ),
      );
    });
  });

  group('conventions d\'écriture de l\'arabe', () {
    test('alif suscrit (U+0670) : avertissement avec le chemin exact', () {
      final r = valider(
        (d) => d['exercices'][1]['consigne']['texte'] =
            'هَلْ هٰذِهِ الْجُمْلَةُ صَحِيحَةٌ؟',
      );
      expect(r.estValide, isTrue);
      final alif = r.avertissements.where((a) => a.code == 'alif_suscrit');
      expect(
        alif.single,
        probleme('/exercices/1/consigne/texte', 'alif_suscrit'),
      );
      expect(alif.single.message, contains('convention B'));
      expect(alif.single.message, contains('هَذِهِ'));
    });

    test('alif suscrit dans une variante genrée et dans un exercice seul', () {
      final ex = exemple()['exercices'][0];
      ex['feedbacks']['indice']['feminin'] =
          'اِسْتَمِعِي إِلَى هٰذِهِ الْكَلِمَةِ.';
      final r = validerExercice(ex);
      expect(r.estValide, isTrue);
      expect(
        r.avertissements.single,
        probleme('/feedbacks/indice/feminin', 'alif_suscrit'),
      );
    });

    test("l'exemple validé ne contient aucun U+0670", () {
      expect(etapeExemple.runes, isNot(contains(0x0670)));
    });
  });

  group('exercice seul (aperçu web)', () {
    test("un exercice de l'exemple est valide seul", () {
      final r = validerExercice(exemple()['exercices'][0]);
      expect(r.erreurs, isEmpty, reason: '$r');
    });

    test('la langue doit suivre le code matière de la compétence', () {
      final ex = exemple()['exercices'][1];
      ex['langue'] = 'fr';
      final r = validerExercice(ex);
      expect(r.erreurs.single, probleme('/langue', 'langue_competence'));
    });

    test('erreur de schéma dans un exercice seul', () {
      final ex = exemple()['exercices'][1];
      ex['reponse'] = {'valeur': 'oui'};
      final r = validerExercice(ex);
      expect(r.erreurs.single, probleme('/reponse/valeur', 'type_incorrect'));
      expect(r.erreurs.single.message, 'type incorrect : attendu un booléen.');
    });
  });
}
