import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 3 types du moteur Révision et jeux
/// (docs/moteurs/revision-jeux.md), sur des exercices seuls construits ici
/// (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse, {
  String langue = 'ar',
}) => {
  'id': '$langue-2-t1-u1-e01-x01',
  'type': type,
  'gabarit': 'essai',
  'competence': '$langue-essai',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': langue,
  'consigne': {'texte': langue == 'ar' ? 'اِلْعَبْ.' : 'Joue.'},
  'donnees': donnees,
  'reponse': reponse,
  'feedbacks': {
    'reussite': langue == 'ar' ? 'أَحْسَنْتَ.' : 'Oui.',
    'indice': langue == 'ar' ? 'حَاوِلْ.' : 'Essaie.',
    'explication': langue == 'ar' ? 'هَكَذَا.' : 'Voilà.',
  },
  'empreinte': _empreinte,
  'statut': 'brouillon',
  'version': 1,
};

final valides = <String, Map<String, dynamic> Function()>{
  'T36': () => exercice(
    'T36',
    {
      'cartes': [
        {
          'id': 'c1',
          'recto': {'emoji': '🐱'},
          'verso': {'texte': 'قِطٌّ'},
        },
        {
          'id': 'c2',
          'recto': {'emoji': '🐶'},
          'verso': {'texte': 'كَلْبٌ'},
        },
      ],
    },
    {
      'cartes': ['c1', 'c2'],
    },
  ),
  'T37': () => exercice(
    'T37',
    {
      'paires': [
        {
          'id': 'p1',
          'a': {'texte': 'قِطٌّ'},
          'b': {'emoji': '🐱'},
        },
        {
          'id': 'p2',
          'a': {'texte': 'كَلْبٌ'},
          'b': {'emoji': '🐶'},
        },
      ],
    },
    {
      'paires': ['p1', 'p2'],
    },
  ),
  // قلم de droite à gauche sur la ligne 0 à partir de la colonne 3, كتب
  // de haut en bas dans la colonne 0.
  'T38': () => exercice(
    'T38',
    {
      'grille': ['كملقب', 'تسردا', 'بحدمر', 'اينزك'],
      'mots': [
        {
          'id': 'm1',
          'texte': 'قَلَمٌ',
          'ligne': 0,
          'colonne': 3,
          'direction': 'ligne',
        },
        {
          'id': 'm2',
          'texte': 'كتب',
          'ligne': 0,
          'colonne': 0,
          'direction': 'colonne',
        },
      ],
    },
    {
      'mots': ['m1', 'm2'],
    },
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

void main() {
  test('un exemple valide pour chacun des 3 types, sans avertissement', () {
    valides.forEach((type, construire) {
      final r = validerExercice(construire());
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    });
  });

  group('schéma', () {
    test('face sans texte ni emoji, 9 cartes, essais_max nul', () {
      expect(
        erreurs('T36', (ex) => ex['donnees']['cartes'][0]['recto'] = {}),
        contains(probleme('/donnees/cartes/0/recto', 'forme_incorrecte')),
      );
      expect(
        erreurs(
          'T36',
          (ex) => ex['donnees']['cartes'] = [
            for (var i = 1; i <= 9; i++)
              {
                'id': 'c${i % 8 + 1}',
                'recto': {'texte': 'a$i'},
                'verso': {'texte': 'b$i'},
              },
          ],
        ),
        contains(probleme('/donnees/cartes', 'liste_trop_longue')),
      );
      expect(
        erreurs('T37', (ex) => ex['donnees']['essais_max'] = 0),
        contains(probleme('/donnees/essais_max', 'valeur_trop_petite')),
      );
    });

    test('grille de 3 lignes, direction inconnue', () {
      expect(
        erreurs(
          'T38',
          (ex) => ex['donnees']['grille'] = ['كملق', 'تسرد', 'بحدم'],
        ),
        contains(probleme('/donnees/grille', 'liste_trop_courte')),
      );
      expect(
        erreurs(
          'T38',
          (ex) => ex['donnees']['mots'][0]['direction'] = 'diagonale',
        ),
        contains(probleme('/donnees/mots/0/direction', 'valeur_non_autorisee')),
      );
    });
  });

  group('règles métier', () {
    test('T36 : carte inconnue, id en double', () {
      expect(
        erreurs(
          'T36',
          (ex) => ex['reponse'] = {
            'cartes': ['c1', 'c7'],
          },
        ).single,
        probleme('/reponse/cartes/1', 'reponse_element_inconnu'),
      );
      expect(
        erreurs('T36', (ex) => ex['donnees']['cartes'][1]['id'] = 'c1'),
        contains(probleme('/donnees/cartes/1/id', 'element_duplique')),
      );
    });

    test('T37 : toutes les paires, paire inconnue', () {
      expect(
        erreurs(
          'T37',
          (ex) => ex['reponse'] = {
            'paires': ['p1', 'p1'],
          },
        ),
        contains(probleme('/reponse/paires', 'doublon_liste')),
      );
      expect(
        erreurs(
          'T37',
          (ex) => ex['reponse'] = {
            'paires': ['p1', 'p6'],
          },
        ),
        unorderedEquals([
          probleme('/reponse/paires/1', 'reponse_element_inconnu'),
          probleme('/reponse/paires', 'paires_incompletes'),
        ]),
      );
    });

    test('T38 : grille irrégulière, lettre vocalisée ou espace en arabe', () {
      expect(
        erreurs('T38', (ex) => ex['donnees']['grille'][1] = 'تسرداب'),
        contains(probleme('/donnees/grille/1', 'grille_irreguliere')),
      );
      // Une haraka compte comme une rune : la ligne garde sa longueur.
      expect(
        erreurs('T38', (ex) => ex['donnees']['grille'][1] = 'تَسرد').single,
        probleme('/donnees/grille/1', 'lettre_invalide'),
      );
    });

    test('T38 : mot qui ne se lit pas à sa position, dans le sens déclaré', () {
      expect(
        erreurs('T38', (ex) => ex['donnees']['mots'][0]['colonne'] = 2).single,
        probleme('/donnees/mots/0', 'mot_hors_grille'),
      );
      // De gauche à droite, قلم ne se lit plus.
      expect(
        erreurs('T38', (ex) => ex['donnees']['sens'] = 'gauche-droite').single,
        probleme('/donnees/mots/0', 'mot_hors_grille'),
      );
      // En colonne, hors de la grille.
      expect(
        erreurs('T38', (ex) => ex['donnees']['mots'][1]['ligne'] = 2).single,
        probleme('/donnees/mots/1', 'mot_hors_grille'),
      );
    });

    test('T38 : français de gauche à droite par défaut, tous les mots', () {
      expect(
        erreurs('T38', (ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
          ex['donnees'] = {
            'grille': ['CHAT', 'SOLE', 'OUIE', 'LAME'],
            'mots': [
              {
                'id': 'm1',
                'texte': 'CHAT',
                'ligne': 0,
                'colonne': 0,
                'direction': 'ligne',
              },
              {
                'id': 'm2',
                'texte': 'SOL',
                'ligne': 1,
                'colonne': 0,
                'direction': 'colonne',
              },
            ],
          };
        }),
        isEmpty,
      );
      expect(
        erreurs(
          'T38',
          (ex) => ex['reponse'] = {
            'mots': ['m1', 'm1'],
          },
        ),
        contains(probleme('/reponse/mots', 'doublon_liste')),
      );
      expect(
        erreurs(
          'T38',
          (ex) => ex['reponse'] = {
            'mots': ['m1', 'm5'],
          },
        ),
        unorderedEquals([
          probleme('/reponse/mots/1', 'reponse_element_inconnu'),
          probleme('/reponse/mots', 'ordre_incomplet'),
        ]),
      );
    });
  });
}
