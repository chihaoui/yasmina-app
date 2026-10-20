import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/texte/.
Map<String, dynamic> exempleTexte(String fichier) =>
    jsonDecode(exemplesEduContent['texte/$fichier']!) as Map<String, dynamic>;

/// T17 en arabe avec la rangée de harakat et une comparaison exacte.
Map<String, dynamic> t17Harakat() => exerciceChoix(
  type: 'T17',
  langue: 'ar',
  gabarit: 'dictee-mot',
  competence: 'ecriture-dictee',
  niveau: 2,
  consigne: {
    'masculin': 'اِسْتَمِعْ وَاكْتُبِ الْكَلِمَةَ بِحَرَكَاتِهَا.',
    'feminin': 'اِسْتَمِعِي وَاكْتُبِي الْكَلِمَةَ بِحَرَكَاتِهَا.',
  },
  donnees: {
    'ecoute': {'texte': 'بَابٌ'},
    'harakat': true,
  },
  reponse: {'texte': 'بَابٌ'},
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: بَابٌ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: بَابٌ.',
  },
  indice: 'لَا تَنْسَ الْحَرَكَاتِ.',
  explication:
      'بَابٌ: بَاءٌ مَفْتُوحَةٌ، أَلِفٌ، بَاءٌ مُنَوَّنَةٌ بِالضَّمِّ.',
);
