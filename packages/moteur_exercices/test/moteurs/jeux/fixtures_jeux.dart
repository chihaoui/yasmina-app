import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/revision-jeux/.
Map<String, dynamic> exempleJeux(String fichier) =>
    jsonDecode(exemplesEduContent['revision-jeux/$fichier']!)
        as Map<String, dynamic>;

/// Paires du memory : un mot et son emoji, dans l'ordre.
const _pairesMemory = [
  ('قِطٌّ', '🐱'),
  ('كَلْبٌ', '🐶'),
  ('أَرْنَبٌ', '🐰'),
  ('حِصَانٌ', '🐴'),
  ('بَقَرَةٌ', '🐮'),
  ('دَجَاجَةٌ', '🐔'),
  ('سَمَكَةٌ', '🐟'),
  ('طَائِرٌ', '🐦'),
  ('فِيلٌ', '🐘'),
  ('أَسَدٌ', '🦁'),
  ('قِرْدٌ', '🐵'),
  ('ضِفْدَعٌ', '🐸'),
];

/// T37 en 1re (3 paires) avec un seuil d'essais strict (2).
Map<String, dynamic> t37EssaisMax() => t37Niveau(1, paires: 3, essaisMax: 2);

/// T37 du niveau [niveau] avec [paires] paires (3, 6, 9 ou 12 : grille de 3
/// colonnes pleine), sans mélange.
Map<String, dynamic> t37Niveau(
  int niveau, {
  required int paires,
  int? essaisMax,
}) => exerciceChoix(
  type: 'T37',
  langue: 'ar',
  gabarit: 'memory-mot-image',
  competence: 'vocabulaire',
  niveau: niveau,
  consigne: {
    'masculin': 'اِبْحَثْ عَنِ الْأَزْوَاجِ.',
    'feminin': 'اِبْحَثِي عَنِ الْأَزْوَاجِ.',
  },
  donnees: {
    'paires': [
      for (final (i, (mot, emoji)) in _pairesMemory.take(paires).indexed)
        {
          'id': 'p${i + 1}',
          'a': {'texte': mot},
          'b': {'emoji': emoji},
        },
    ],
    'essais_max': ?essaisMax,
    'melanger': false,
  },
  reponse: {
    'paires': [for (var i = 1; i <= paires; i++) 'p$i'],
  },
  reussite: {
    'masculin': 'وَجَدْتَ كُلَّ الْأَزْوَاجِ.',
    'feminin': 'وَجَدْتِ كُلَّ الْأَزْوَاجِ.',
  },
  indice: 'تَذَكَّرْ مَكَانَ الْبِطَاقَاتِ.',
  explication: 'وُجِدَتْ كُلُّ الْأَزْوَاجِ، بِمُحَاوَلَاتٍ كَثِيرَةٍ.',
);
