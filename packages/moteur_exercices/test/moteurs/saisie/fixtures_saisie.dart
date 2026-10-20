import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/saisie-numerique/.
Map<String, dynamic> exempleSaisie(String fichier) =>
    jsonDecode(exemplesEduContent['saisie-numerique/$fichier']!)
        as Map<String, dynamic>;

/// T22 en chiffres orientaux, avec une unité et une tolérance de 1.
Map<String, dynamic> t22Orientaux() =>
    exerciceChoix(
        type: 'T22',
        langue: 'ar',
        gabarit: 'probleme-court',
        competence: 'problemes',
        consigne: {
          'masculin': 'كَمْ دِينَارًا بَقِيَ مَعَ سَامِي؟',
          'feminin': 'كَمْ دِينَارًا بَقِيَ مَعَ سَامِي؟',
        },
        donnees: {'unite': 'د', 'chiffres': 'orientaux', 'chiffres_max': 2},
        reponse: {'valeur': 12},
        reussite: {
          'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: بَقِيَ 12 دِينَارًا.',
          'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: بَقِيَ 12 دِينَارًا.',
        },
        indice: 'اِطْرَحِ الثَّمَنَ مِنَ الْمَبْلَغِ.',
        explication: 'بَقِيَ 12 دِينَارًا.',
      )
      ..['competence'] = 'ma-problemes'
      ..['tolerance'] = 1;

/// T48 addition à trois chiffres, unités à gauche, chiffres orientaux,
/// retenues : 78 + 46 = 124.
Map<String, dynamic> t48GaucheDroite() => exerciceChoix(
  type: 'T48',
  langue: 'ar',
  gabarit: 'addition-posee',
  competence: 'calcul',
  consigne: {
    'masculin': 'أَنْجِزِ الْعَمَلِيَّةَ.',
    'feminin': 'أَنْجِزِي الْعَمَلِيَّةَ.',
  },
  donnees: {
    'a': 78,
    'b': 46,
    'operation': 'addition',
    'sens': 'gauche-droite',
    'chiffres': 'orientaux',
    'retenues': true,
  },
  reponse: {'valeur': 124},
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: 78 زَائِدُ 46 يُسَاوِي 124.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: 78 زَائِدُ 46 يُسَاوِي 124.',
  },
  indice: 'لَا تَنْسَ الْمَحْمُولَ.',
  explication: '78 زَائِدُ 46 يُسَاوِي 124.',
)..['competence'] = 'ma-calcul';
