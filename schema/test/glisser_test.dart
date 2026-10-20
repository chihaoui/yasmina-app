import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 8 types du moteur Glisser-déposer
/// (docs/moteurs/glisser-deposer.md), sur des exercices seuls construits
/// ici (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse, {
  String langue = 'fr',
  int niveau = 3,
}) {
  final arabe = langue == 'ar';
  final texte = arabe
      ? 'ضَعْ كُلَّ عُنْصُرٍ فِي مَكَانِهِ.'
      : 'Place chaque élément.';
  final code = langue == 'ar' ? 'ar' : langue;
  return {
    'id': '$code-$niveau-t1-u1-e01-x01',
    'type': type,
    'gabarit': 'essai',
    'competence': '$code-essai',
    'critere': 'C1',
    'niveau_critere': 'minimal',
    'langue': langue,
    'consigne': {'texte': texte},
    'donnees': donnees,
    'reponse': reponse,
    'feedbacks': {'reussite': texte, 'indice': texte, 'explication': texte},
    'empreinte': _empreinte,
    'statut': 'brouillon',
    'version': 1,
  };
}

List<Map<String, dynamic>> elements(
  List<String> textes, {
  String prefixe = 'e',
}) => [
  for (var i = 0; i < textes.length; i++)
    {'id': '$prefixe${i + 1}', 'texte': textes[i]},
];

final valides = <String, Map<String, dynamic> Function()>{
  'T06': () => exercice(
    'T06',
    {
      'texte': 'Le chien {t1} dans le jardin.',
      'etiquettes': elements(['court', 'courent', 'courir']),
    },
    {
      'trous': [
        {'trou': 't1', 'etiquette': 'e1'},
      ],
    },
  ),
  'T09': () => exercice(
    'T09',
    {
      'gauche': elements(['pomme', 'lune'], prefixe: 'g'),
      'droite': [
        {'id': 'd1', 'emoji': '🌙'},
        {'id': 'd2', 'emoji': '🍎'},
      ],
    },
    {
      'paires': [
        {'gauche': 'g1', 'droite': 'd2'},
        {'gauche': 'g2', 'droite': 'd1'},
      ],
    },
  ),
  'T11': () => exercice(
    'T11',
    {
      'categories': [
        {'id': 'k1', 'titre': 'Fruits', 'emoji': '🍇'},
        {'id': 'k2', 'titre': 'Légumes', 'emoji': '🥬'},
      ],
      'elements': [
        {'id': 'e1', 'texte': 'banane', 'emoji': '🍌'},
        {'id': 'e2', 'texte': 'carotte', 'emoji': '🥕'},
        {'id': 'e3', 'texte': 'poire', 'emoji': '🍐'},
      ],
    },
    {
      'classement': [
        {'element': 'e1', 'categorie': 'k1'},
        {'element': 'e2', 'categorie': 'k2'},
        {'element': 'e3', 'categorie': 'k1'},
      ],
    },
  ),
  'T12': () => exercice(
    'T12',
    {
      'categories': [
        {'id': 'k1', 'titre': 'لَامٌ شَمْسِيَّةٌ'},
        {'id': 'k2', 'titre': 'لَامٌ قَمَرِيَّةٌ'},
      ],
      'elements': elements(['الدَّفْتَرُ', 'الْجَبَلُ']),
    },
    {
      'classement': [
        {'element': 'e1', 'categorie': 'k1'},
        {'element': 'e2', 'categorie': 'k2'},
      ],
    },
    langue: 'ar',
  ),
  'T13': () => exercice(
    'T13',
    {
      'elements': elements(['Le', 'chat', 'dort.']),
    },
    {
      'ordre': ['e1', 'e2', 'e3'],
    },
  ),
  'T14': () => exercice(
    'T14',
    {
      'elements': [
        {'id': 'e1', 'emoji': '🥚', 'texte': 'œuf'},
        {'id': 'e2', 'emoji': '🐣', 'texte': 'poussin'},
        {'id': 'e3', 'emoji': '🐔', 'texte': 'poule'},
      ],
    },
    {
      'ordre': ['e1', 'e2', 'e3'],
    },
  ),
  'T15': () => exercice(
    'T15',
    {
      'elements': elements(['ق', 'م', 'ر', 'ب']),
      'ecoute': {'texte': 'قَمَرٌ'},
    },
    {
      'ordre': ['e1', 'e2', 'e3'],
    },
    langue: 'ar',
    niveau: 1,
  ),
  'T16': () => exercice(
    'T16',
    {
      'elements': elements(['to', 'ma', 'te', 'pi']),
      'ecoute': {'texte': 'tomate'},
    },
    {
      'ordre': ['e1', 'e2', 'e3'],
    },
  ),
};

Matcher probleme(String chemin, String code) => isA<ProblemeValidation>()
    .having((p) => p.chemin, 'chemin', chemin)
    .having((p) => p.code, 'code', code);

List<ProblemeValidation> erreurs(
  String type,
  void Function(Map<String, dynamic> ex) modifier,
) {
  final ex = valides[type]!();
  modifier(ex);
  return validerExercice(ex).erreurs;
}

List<ProblemeValidation> avertissements(
  String type,
  void Function(Map<String, dynamic> ex) modifier,
) {
  final ex = valides[type]!();
  modifier(ex);
  return validerExercice(ex).avertissements;
}

void main() {
  test('un exemple valide pour chacun des 8 types, sans avertissement', () {
    expect(valides.keys, hasLength(8));
    valides.forEach((type, construire) {
      final r = validerExercice(construire());
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    });
  });

  group('schéma', () {
    test('T06 : texte sans trou', () {
      final r = erreurs(
        'T06',
        (ex) => ex['donnees']['texte'] = 'Le chien dort.',
      );
      expect(r.single, probleme('/donnees/texte', 'format_incorrect'));
    });

    test('T09 : 7 éléments à gauche', () {
      final r = erreurs(
        'T09',
        (ex) => ex['donnees']['gauche'] = elements([
          'a',
          'b',
          'c',
          'd',
          'e',
          'f',
          'g',
        ], prefixe: 'g'),
      );
      expect(r, contains(probleme('/donnees/gauche', 'liste_trop_longue')));
    });

    test('T11 : 4 catégories', () {
      final r = erreurs(
        'T11',
        (ex) => ex['donnees']['categories'] = [
          for (var i = 1; i <= 4; i++) {'id': 'k$i', 'titre': 'c$i'},
        ],
      );
      expect(r, contains(probleme('/donnees/categories', 'liste_trop_longue')));
    });

    test('T13 : id d\'élément hors format', () {
      final r = erreurs(
        'T13',
        (ex) => ex['donnees']['elements'][0]['id'] = 'c1',
      );
      expect(
        r,
        contains(probleme('/donnees/elements/0/id', 'format_incorrect')),
      );
    });

    test('T15 : ordre avec un doublon', () {
      final r = erreurs('T15', (ex) => ex['reponse']['ordre'] = ['e1', 'e1']);
      expect(r, contains(probleme('/reponse/ordre', 'doublon_liste')));
    });
  });

  group('règles métier', () {
    test('T06 : trou sans réponse, réponse vers un trou absent', () {
      final r = erreurs('T06', (ex) {
        ex['donnees']['texte'] = 'Le chien {t1} dans {t2}.';
        ex['reponse'] = {
          'trous': [
            {'trou': 't3', 'etiquette': 'e1'},
          ],
        };
      });
      expect(
        r,
        unorderedEquals([
          probleme('/reponse/trous/0/trou', 'reponse_trou_inconnu'),
          probleme('/reponse/trous', 'trou_sans_reponse'),
          probleme('/reponse/trous', 'trou_sans_reponse'),
        ]),
      );
    });

    test('T06 : une étiquette pour deux trous, étiquette inconnue', () {
      final r = erreurs('T06', (ex) {
        ex['donnees']['texte'] = 'Le chien {t1} et {t2}.';
        ex['reponse'] = {
          'trous': [
            {'trou': 't1', 'etiquette': 'e1'},
            {'trou': 't2', 'etiquette': 'e1'},
          ],
        };
      });
      expect(
        r.single,
        probleme('/reponse/trous/1/etiquette', 'etiquette_reutilisee'),
      );
      expect(
        erreurs(
          'T06',
          (ex) => ex['reponse']['trous'][0]['etiquette'] = 'e9',
        ).single,
        probleme('/reponse/trous/0/etiquette', 'reponse_element_inconnu'),
      );
    });

    test('T06 : plusieurs trous sans étiquette en trop : avertissement', () {
      final a = avertissements('T06', (ex) {
        ex['donnees']['texte'] =
            'Le chien {t1}, les chiens {t2}, courir : {t3}.';
        ex['reponse'] = {
          'trous': [
            {'trou': 't1', 'etiquette': 'e1'},
            {'trou': 't2', 'etiquette': 'e2'},
            {'trou': 't3', 'etiquette': 'e3'},
          ],
        };
      });
      expect(
        a.single,
        probleme('/donnees/etiquettes', 'etiquettes_sans_intrus'),
      );
    });

    test('T09 : nombres différents, élément hors de toute paire, doublon', () {
      expect(
        erreurs(
          'T09',
          (ex) => (ex['donnees']['droite'] as List).add({
            'id': 'd3',
            'emoji': '🐟',
          }),
        ),
        contains(probleme('/donnees/droite', 'association_incomplete')),
      );
      final r = erreurs('T09', (ex) {
        ex['reponse'] = {
          'paires': [
            {'gauche': 'g1', 'droite': 'd2'},
            {'gauche': 'g1', 'droite': 'd1'},
          ],
        };
      });
      expect(
        r,
        contains(probleme('/reponse/paires/1', 'association_incomplete')),
      );
      expect(
        r,
        contains(probleme('/reponse/paires', 'association_incomplete')),
      );
    });

    test('T11 : élément non classé, catégorie vide, catégorie inconnue', () {
      final r = erreurs('T11', (ex) {
        ex['reponse'] = {
          'classement': [
            {'element': 'e1', 'categorie': 'k1'},
            {'element': 'e2', 'categorie': 'k9'},
          ],
        };
      });
      expect(
        r,
        unorderedEquals([
          probleme('/reponse/classement/1/categorie', 'format_incorrect'),
        ]),
      );
      final r2 = erreurs('T11', (ex) {
        ex['reponse'] = {
          'classement': [
            {'element': 'e1', 'categorie': 'k1'},
            {'element': 'e3', 'categorie': 'k1'},
          ],
        };
      });
      expect(
        r2,
        unorderedEquals([
          probleme('/reponse/classement', 'classement_incomplet'),
          probleme('/reponse/classement', 'categorie_vide'),
        ]),
      );
    });

    test('T12 : arabe seulement, texte obligatoire', () {
      expect(
        erreurs('T12', (ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
        }),
        contains(probleme('/langue', 'type_langue')),
      );
      final r = erreurs(
        'T12',
        (ex) => ex['donnees']['elements'][0] = {'id': 'e1', 'emoji': '☀️'},
      );
      expect(r.single, probleme('/donnees/elements/0', 'element_sans_texte'));
    });

    test('T13 : ordre incomplet ou élément inconnu', () {
      expect(
        erreurs('T13', (ex) => ex['reponse']['ordre'] = ['e1', 'e2']).single,
        probleme('/reponse/ordre', 'ordre_incomplet'),
      );
      expect(
        erreurs('T13', (ex) => ex['reponse']['ordre'] = ['e1', 'e2', 'e9']),
        contains(probleme('/reponse/ordre/2', 'reponse_element_inconnu')),
      );
    });

    test('T15 : mot construit différent du mot entendu, lettres répétées '
        'autorisées', () {
      final r = erreurs(
        'T15',
        (ex) => ex['reponse']['ordre'] = ['e1', 'e3', 'e2'],
      );
      expect(
        r.single,
        probleme('/donnees/ecoute/texte', 'mot_different_ecoute'),
      );
      expect(r.single.message, contains('قرم'));
      expect(
        erreurs('T15', (ex) {
          ex['donnees']['elements'] = elements(['ب', 'ا', 'ب', 'ن']);
          ex['donnees']['ecoute'] = {'texte': 'بَابٌ'};
          ex['reponse']['ordre'] = ['e1', 'e2', 'e3'];
        }),
        isEmpty,
      );
    });

    test('T15 en arabe seulement, T16 jamais en arabe', () {
      expect(
        erreurs('T15', (ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
        }),
        contains(probleme('/langue', 'type_langue')),
      );
      expect(
        erreurs('T16', (ex) {
          ex['langue'] = 'ar';
          ex['competence'] = 'ar-essai';
          ex['donnees']['elements'] = elements(['قَ', 'مَرٌ']);
          ex['donnees']['ecoute'] = {'texte': 'قَمَرٌ'};
          ex['reponse']['ordre'] = ['e1', 'e2'];
        }),
        contains(probleme('/langue', 'type_langue')),
      );
    });

    test('T16 : syllabes qui ne font pas le mot entendu', () {
      final r = erreurs(
        'T16',
        (ex) => ex['donnees']['ecoute'] = {'texte': 'tomates'},
      );
      expect(
        r.single,
        probleme('/donnees/ecoute/texte', 'mot_different_ecoute'),
      );
    });

    test('plus de 6 éléments en 1re ou 2e année : avertissement', () {
      final a = avertissements('T13', (ex) {
        ex['id'] = 'fr-2-t1-u1-e01-x01';
        ex['donnees']['elements'] = elements([
          'a',
          'b',
          'c',
          'd',
          'e',
          'f',
          'g',
        ]);
        ex['reponse']['ordre'] = ['e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7'];
      });
      expect(a.single, probleme('/donnees', 'elements_trop_nombreux'));
      expect(
        avertissements('T13', (ex) {
          ex['donnees']['elements'] = elements([
            'a',
            'b',
            'c',
            'd',
            'e',
            'f',
            'g',
          ]);
          ex['reponse']['ordre'] = ['e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7'];
        }),
        isEmpty,
      );
    });

    test('éléments en double (id ou texte)', () {
      final r = erreurs('T13', (ex) {
        ex['donnees']['elements'] = [
          {'id': 'e1', 'texte': 'Le'},
          {'id': 'e1', 'texte': 'chat'},
          {'id': 'e3', 'texte': 'Le'},
        ];
      });
      expect(
        r,
        unorderedEquals([
          probleme('/donnees/elements/1/id', 'element_duplique'),
          probleme('/donnees/elements/2/texte', 'element_duplique'),
          probleme('/reponse/ordre/1', 'reponse_element_inconnu'),
          probleme('/reponse/ordre', 'ordre_incomplet'),
        ]),
      );
    });
  });
}
