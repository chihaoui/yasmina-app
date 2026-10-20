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

/// T26 en français (usage futur hors maths) : 1 dinar et 250 millimes avec
/// des pièces de 1000, 500, 200, 100 et 50.
Map<String, dynamic> t26Francais() => exerciceChoix(
  type: 'T26',
  langue: 'fr',
  gabarit: 'monnaie-porte-monnaie',
  competence: 'mesure-monnaie',
  niveau: 3,
  consigne: 'Forme 1 dinar et 250 millimes avec les pièces.',
  donnees: {
    'pieces': [1000, 500, 200, 100, 50],
    'cible': 1250,
  },
  reponse: {'montant': 1250},
  reussite: 'Oui : 1 dinar et 250 millimes.',
  indice: 'Commence par le dinar, puis 200 et 50 millimes.',
  explication:
      '1 dinar, 200 millimes et 50 millimes font 1 dinar et 250 millimes.',
);

/// T29 en français, rectangle en cinq bandes, 2/5.
Map<String, dynamic> t29Rectangle() => exerciceChoix(
  type: 'T29',
  langue: 'fr',
  gabarit: 'fraction-rectangle',
  competence: 'fractions-representer',
  niveau: 5,
  consigne: 'Colorie 2/5 du rectangle.',
  donnees: {'forme': 'rectangle', 'parts': 5, 'numerateur': 2},
  reponse: {'parts': 2},
  reussite: 'Oui : 2 bandes sur 5.',
  indice: 'Le rectangle a 5 bandes : colorie 2 bandes.',
  explication: 'Le dénominateur 5 est le nombre de bandes, le numérateur 2 les bandes coloriées.',
);

/// T52 en français : un segment inconnu (une barre partie-tout, 19 = 12 + ?).
Map<String, dynamic> t52SegmentInconnu() => exerciceChoix(
  type: 'T52',
  langue: 'fr',
  gabarit: 'barres-partie-tout',
  competence: 'problemes-modele-barres',
  niveau: 3,
  consigne: 'Place les nombres dans le schéma, puis écris la partie inconnue.',
  donnees: {
    'texte': 'Lina a 19 billes. 12 sont rouges, les autres sont bleues. Combien de billes bleues ?',
    'barres': [
      {
        'id': 'b1',
        'libelle': 'billes',
        'segments': [
          {'id': 's1', 'valeur': 12},
          {'id': 's2', 'valeur': 7},
        ],
      },
    ],
    'inconnue': {'segment': 's2'},
    'etiquettes': [
      {'id': 'e1', 'texte': '12'},
      {'id': 'e2', 'texte': '19'},
    ],
    'melanger': false,
  },
  reponse: {'valeur': 7},
  reussite: 'Oui : 19 moins 12, il reste 7 billes bleues.',
  indice: 'La barre entière fait 19, la partie rouge 12.',
  explication: '19 moins 12 égale 7 billes bleues.',
);
