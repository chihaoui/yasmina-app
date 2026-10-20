import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 2 types du moteur Texte (docs/moteurs/texte.md), sur des
/// exercices seuls construits ici (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse, {
  String langue = 'ar',
  List<String>? normalisation,
}) => {
  'id': '$langue-2-t1-u1-e01-x01',
  'type': type,
  'gabarit': 'essai',
  'competence': '$langue-essai',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': langue,
  'consigne': {'texte': langue == 'ar' ? 'اِلْمِسِ الْكَلِمَةَ.' : 'Touche.'},
  'donnees': donnees,
  'reponse': reponse,
  'normalisation': ?normalisation,
  'feedbacks': {
    'reussite': langue == 'ar' ? 'إِجَابَتُكَ صَحِيحَةٌ.' : 'Oui.',
    'indice': langue == 'ar' ? 'اِنْظُرْ جَيِّدًا.' : 'Regarde.',
    'explication': langue == 'ar' ? 'هَذَا هُوَ الْجَوَابُ.' : 'Voilà.',
  },
  'empreinte': _empreinte,
  'statut': 'brouillon',
  'version': 1,
};

final valides = <String, Map<String, dynamic> Function()>{
  'T07': () => exercice(
    'T07',
    {'texte': 'يَقْرَأُ الْوَلَدُ قِصَّةً.'},
    {
      'mots': [0],
    },
  ),
  'T17': () => exercice(
    'T17',
    {
      'ecoute': {'texte': 'قَلَمٌ'},
    },
    {'texte': 'قَلَمٌ'},
    normalisation: ['harakat_ignorees'],
  ),
};

Matcher probleme(String chemin, String code) => isA<ProblemeValidation>()
    .having((p) => p.chemin, 'chemin', chemin)
    .having((p) => p.code, 'code', code);

List<ProblemeValidation> erreurs(
  String type,
  void Function(Map<String, dynamic> ex) f,
) {
  final ex = valides[type]!();
  f(ex);
  return validerExercice(ex).erreurs;
}

List<ProblemeValidation> avertissements(
  String type,
  void Function(Map<String, dynamic> ex) f,
) {
  final ex = valides[type]!();
  f(ex);
  return validerExercice(ex).avertissements;
}

void main() {
  test('un exemple valide pour chacun des 2 types, sans avertissement', () {
    valides.forEach((type, construire) {
      final r = validerExercice(construire());
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    });
  });

  group('T07', () {
    test('schéma : 7 mots attendus, index négatif', () {
      expect(
        erreurs(
          'T07',
          (ex) => ex['reponse'] = {
            'mots': [0, 1, 2, 3, 4, 5, 6],
          },
        ),
        contains(probleme('/reponse/mots', 'liste_trop_longue')),
      );
      expect(
        erreurs(
          'T07',
          (ex) => ex['reponse'] = {
            'mots': [-1],
          },
        ),
        contains(probleme('/reponse/mots/0', 'valeur_trop_petite')),
      );
    });

    test('phrase d\'un seul mot, index hors de la phrase', () {
      expect(
        erreurs('T07', (ex) => ex['donnees']['texte'] = 'يَقْرَأُ').single,
        probleme('/donnees/texte', 'phrase_invalide'),
      );
      expect(
        erreurs(
          'T07',
          (ex) => ex['reponse'] = {
            'mots': [3],
          },
        ).single,
        probleme('/reponse/mots/0', 'mot_inconnu'),
      );
    });

    test('plusieurs mots seulement avec plusieurs', () {
      expect(
        erreurs(
          'T07',
          (ex) => ex['reponse'] = {
            'mots': [0, 2],
          },
        ).single,
        probleme('/reponse/mots', 'reponse_unique'),
      );
      expect(
        erreurs('T07', (ex) {
          ex['donnees']['plusieurs'] = true;
          ex['reponse'] = {
            'mots': [0, 2],
          };
        }),
        isEmpty,
      );
    });

    test('français : la ponctuation reste collée au mot', () {
      expect(
        erreurs('T07', (ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
          ex['donnees']['texte'] = 'Le chat dort.';
          ex['reponse'] = {
            'mots': [2],
          };
        }),
        isEmpty,
      );
    });
  });

  group('T17', () {
    test('le texte attendu est le mot entendu', () {
      expect(
        erreurs('T17', (ex) => ex['reponse']['texte'] = 'قَمَرٌ').single,
        probleme('/reponse/texte', 'ecoute_differente_reponse'),
      );
    });

    test('mot vocalisé sans rangée de harakat ni harakat_ignorees : '
        'impossible à écrire', () {
      expect(
        erreurs('T17', (ex) => ex.remove('normalisation')).single,
        probleme('/reponse/texte', 'harakat_impossibles'),
      );
      expect(
        erreurs('T17', (ex) {
          ex.remove('normalisation');
          ex['donnees']['harakat'] = true;
        }),
        isEmpty,
      );
      // Mot sans harakat : rien à signaler.
      expect(
        erreurs('T17', (ex) {
          ex.remove('normalisation');
          ex['donnees']['ecoute'] = {'texte': 'قلم'};
          ex['reponse']['texte'] = 'قلم';
        }),
        isEmpty,
      );
    });

    test('rangée de harakat proposée pour un mot nu : avertissement', () {
      final a = avertissements('T17', (ex) {
        ex['donnees']['harakat'] = true;
        ex['donnees']['ecoute'] = {'texte': 'قلم'};
        ex['reponse']['texte'] = 'قلم';
      });
      expect(
        a.single,
        probleme('/reponse/texte', 'harakat_manquantes_reponse'),
      );
    });

    test('harakat hors arabe, casse inconnue', () {
      expect(
        erreurs('T17', (ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
          ex['donnees'] = {
            'ecoute': {'texte': 'poule'},
            'harakat': true,
          };
          ex['reponse']['texte'] = 'poule';
          ex.remove('normalisation');
        }).single,
        probleme('/donnees/harakat', 'harakat_hors_arabe'),
      );
      expect(
        erreurs('T17', (ex) => ex['donnees']['casse'] = 'majuscules'),
        contains(probleme('/donnees/casse', 'valeur_non_autorisee')),
      );
    });
  });
}
