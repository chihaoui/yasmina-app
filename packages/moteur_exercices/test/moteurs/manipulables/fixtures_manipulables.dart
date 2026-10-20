import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/manipulables/.
Map<String, dynamic> exempleManipulables(String fichier) =>
    jsonDecode(exemplesEduContent['manipulables/$fichier']!)
        as Map<String, dynamic>;

/// T25 en arabe, droite de droite à gauche (0 à droite), cible 4.
Map<String, dynamic> t25DroiteGauche() => exerciceChoix(
  type: 'T25',
  langue: 'ar',
  gabarit: 'droite-0-10',
  competence: 'nombres-droite',
  niveau: 1,
  consigne: {
    'masculin': 'ضَعِ الْعَلَامَةَ عَلَى الْعَدَدِ 4.',
    'feminin': 'ضَعِي الْعَلَامَةَ عَلَى الْعَدَدِ 4.',
  },
  donnees: {'min': 0, 'max': 10, 'cible': 4, 'sens': 'droite-gauche'},
  reponse: {'valeur': 4},
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: الْعَدَدُ 4 يَبْعُدُ 4 خُطُوَاتٍ عَنِ الصِّفْرِ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: الْعَدَدُ 4 يَبْعُدُ 4 خُطُوَاتٍ عَنِ الصِّفْرِ.',
  },
  indice: 'عُدَّ الْخُطُوَاتِ مِنَ الصِّفْرِ.',
  explication: 'الْعَدَدُ 4 يَأْتِي قَبْلَ 5 بِخُطْوَةٍ.',
)..['competence'] = 'ma-nombres-droite';

/// T25 en français (usage futur hors maths), droite de 0 à 20 par 2.
Map<String, dynamic> t25Francais() => exerciceChoix(
  type: 'T25',
  langue: 'fr',
  gabarit: 'droite-0-20',
  competence: 'nombres-droite',
  niveau: 3,
  consigne: 'Place le repère sur le nombre 16.',
  donnees: {'min': 0, 'max': 20, 'pas': 2, 'reperes': 10, 'cible': 16},
  reponse: {'valeur': 16},
  reussite: 'Oui : 16 est à 8 pas de 0.',
  indice: 'Compte de 2 en 2 à partir de 10.',
  explication: '16 vient après 10 : 12, 14, 16.',
);

/// T27 en mode libre : toute somme qui fait 34.
Map<String, dynamic> t27Libre() => exerciceChoix(
  type: 'T27',
  langue: 'ar',
  gabarit: 'blocs-dizaines-unites',
  competence: 'numeration',
  consigne: {
    'masculin': 'مَثِّلِ الْعَدَدَ 34 كَمَا تُرِيدُ.',
    'feminin': 'مَثِّلِي الْعَدَدَ 34 كَمَا تُرِيدِينَ.',
  },
  donnees: {'cible': 34, 'canonique': false},
  reponse: {'dizaines': 3, 'unites': 4},
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: الْمَجْمُوعُ 34.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: الْمَجْمُوعُ 34.',
  },
  indice: 'كُلُّ قَضِيبٍ يُسَاوِي 10.',
  explication: '34 هُوَ 3 عَشَرَاتٍ وَ4 وَحَدَاتٍ.',
)..['competence'] = 'ma-numeration';
