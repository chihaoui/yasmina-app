import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/revision-jeux/.
Map<String, dynamic> exempleJeux(String fichier) =>
    jsonDecode(exemplesEduContent['revision-jeux/$fichier']!)
        as Map<String, dynamic>;

/// T37 à deux paires avec un seuil d'essais strict (2).
Map<String, dynamic> t37EssaisMax() => exerciceChoix(
  type: 'T37',
  langue: 'ar',
  gabarit: 'memory-mot-image',
  competence: 'vocabulaire',
  consigne: {
    'masculin': 'اِبْحَثْ عَنِ الْأَزْوَاجِ.',
    'feminin': 'اِبْحَثِي عَنِ الْأَزْوَاجِ.',
  },
  donnees: {
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
    'essais_max': 2,
    'melanger': false,
  },
  reponse: {
    'paires': ['p1', 'p2'],
  },
  reussite: {
    'masculin': 'وَجَدْتَ كُلَّ الْأَزْوَاجِ.',
    'feminin': 'وَجَدْتِ كُلَّ الْأَزْوَاجِ.',
  },
  indice: 'تَذَكَّرْ مَكَانَ الْبِطَاقَاتِ.',
  explication: 'وُجِدَتْ كُلُّ الْأَزْوَاجِ، بِمُحَاوَلَاتٍ كَثِيرَةٍ.',
);
