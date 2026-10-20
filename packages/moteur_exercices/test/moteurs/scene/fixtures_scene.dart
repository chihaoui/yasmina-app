import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/scene-image/.
Map<String, dynamic> exempleScene(String fichier) =>
    jsonDecode(exemplesEduContent['scene-image/$fichier']!)
        as Map<String, dynamic>;

/// T08 en français, plusieurs zones, dont une plus petite que 48 dp.
Map<String, dynamic> t08Plusieurs() => exerciceChoix(
  type: 'T08',
  langue: 'fr',
  gabarit: 'hot-spot-emoji',
  competence: 'sciences-animaux',
  niveau: 2,
  consigne: 'Touche les deux animaux qui volent.',
  donnees: {
    'scene': {
      'elements': [
        {'emoji': '🐦', 'x': 0.2, 'y': 0.25, 'h': 0.25},
        {'emoji': '🦋', 'x': 0.7, 'y': 0.25, 'h': 0.25},
        {'emoji': '🐟', 'x': 0.5, 'y': 0.75, 'h': 0.25},
      ],
    },
    'zones': [
      {'id': 'z1', 'x': 0.05, 'y': 0.05, 'l': 0.3, 'h': 0.4},
      {'id': 'z2', 'x': 0.55, 'y': 0.05, 'l': 0.3, 'h': 0.4},
      {'id': 'z3', 'x': 0.48, 'y': 0.72, 'l': 0.04, 'h': 0.04},
    ],
    'plusieurs': true,
  },
  reponse: {
    'zones': ['z1', 'z2'],
  },
  reussite: 'Oui : l\'oiseau et le papillon volent.',
  indice: 'Le poisson nage, il ne vole pas.',
  explication: 'L\'oiseau et le papillon volent. Le poisson nage.',
);

/// T47 en arabe : deux parties d'une maison dessinée en formes.
Map<String, dynamic> t47Arabe() => exerciceChoix(
  type: 'T47',
  langue: 'ar',
  gabarit: 'schema-formes',
  competence: 'bayt-ajzaa',
  consigne: {
    'masculin':
        'ضَعْ كُلَّ بِطَاقَةٍ عَلَى الْجُزْءِ الْمُنَاسِبِ مِنَ الْبَيْتِ.',
    'feminin':
        'ضَعِي كُلَّ بِطَاقَةٍ عَلَى الْجُزْءِ الْمُنَاسِبِ مِنَ الْبَيْتِ.',
  },
  donnees: {
    'scene': {
      'elements': [
        {
          'forme': 'triangle',
          'couleur': 'coral',
          'x': 0.25,
          'y': 0.1,
          'l': 0.5,
          'h': 0.3,
        },
        {
          'forme': 'rectangle',
          'couleur': 'sun',
          'x': 0.3,
          'y': 0.4,
          'l': 0.4,
          'h': 0.5,
        },
      ],
    },
    'zones': [
      {
        'id': 'z1',
        'x': 0.25,
        'y': 0.1,
        'l': 0.5,
        'h': 0.3,
        'libelle': 'الْجُزْءُ الْأَعْلَى',
      },
      {
        'id': 'z2',
        'x': 0.3,
        'y': 0.45,
        'l': 0.4,
        'h': 0.4,
        'libelle': 'الْجُزْءُ الْأَسْفَلُ',
      },
    ],
    'etiquettes': [
      {'id': 'e1', 'texte': 'السَّقْفُ'},
      {'id': 'e2', 'texte': 'الْجِدَارُ'},
      {'id': 'e3', 'texte': 'الشَّجَرَةُ'},
    ],
    'melanger': false,
  },
  reponse: {
    'placements': [
      {'zone': 'z1', 'etiquette': 'e1'},
      {'zone': 'z2', 'etiquette': 'e2'},
    ],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: السَّقْفُ فَوْقَ الْجِدَارِ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: السَّقْفُ فَوْقَ الْجِدَارِ.',
  },
  indice: 'السَّقْفُ فِي الْأَعْلَى.',
  explication: 'السَّقْفُ فِي الْأَعْلَى، وَالْجِدَارُ تَحْتَهُ. لَا شَجَرَةَ فِي الرَّسْمِ.',
)..['competence'] = 'ev-bayt-ajzaa';

/// T53 en arabe (éveil, 1re) : placer le soleil au-dessus de la maison.
Map<String, dynamic> t53Arabe() => exerciceChoix(
  type: 'T53',
  langue: 'ar',
  gabarit: 'ecoute-place-scene',
  competence: 'eveil-positions',
  niveau: 1,
  consigne: {
    'masculin': 'اِسْتَمِعْ ثُمَّ الْمِسِ الْمَكَانَ الْمُنَاسِبَ.',
    'feminin': 'اِسْتَمِعِي ثُمَّ الْمِسِي الْمَكَانَ الْمُنَاسِبَ.',
  },
  donnees: {
    'scene': {
      'elements': [
        {'emoji': '🏠', 'x': 0.5, 'y': 0.7, 'h': 0.4},
      ],
    },
    'objet': {'emoji': '☀️', 'libelle': 'الشَّمْسُ'},
    'zones': [
      {'id': 'z1', 'x': 0.05, 'y': 0.55, 'l': 0.25, 'h': 0.35},
      {'id': 'z2', 'x': 0.35, 'y': 0.05, 'l': 0.3, 'h': 0.3},
      {'id': 'z3', 'x': 0.7, 'y': 0.55, 'l': 0.25, 'h': 0.35},
    ],
    'ecoute': {'texte': 'ضَعِ الشَّمْسَ فَوْقَ الْبَيْتِ.'},
  },
  reponse: {'zone': 'z2'},
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: الشَّمْسُ فَوْقَ الْبَيْتِ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: الشَّمْسُ فَوْقَ الْبَيْتِ.',
  },
  indice: 'اِسْتَمِعْ مَرَّةً أُخْرَى: فَوْقَ يَعْنِي فِي الْأَعْلَى.',
  explication: 'الشَّمْسُ فِي السَّمَاءِ، فَوْقَ الْبَيْتِ.',
)..['competence'] = 'ev-positions';

/// T54 en français : colorier la voiture en bleu.
Map<String, dynamic> t54Francais() => exerciceChoix(
  type: 'T54',
  langue: 'fr',
  gabarit: 'ecoute-colorie-objets',
  competence: 'couleurs-objets',
  niveau: 2,
  consigne: 'Écoute. Touche une couleur, puis l\'objet.',
  donnees: {
    'objets': [
      {'id': 'o1', 'emoji': '⚽', 'libelle': 'le ballon'},
      {'id': 'o2', 'emoji': '🚗', 'libelle': 'la voiture'},
    ],
    'couleurs': ['red', 'blue', 'yellow'],
    'ecoute': {'texte': 'Colorie la voiture en bleu.'},
  },
  reponse: {
    'coloriages': [
      {'objet': 'o2', 'couleur': 'blue'},
    ],
  },
  reussite: 'Oui : la voiture est bleue.',
  indice: 'Écoute encore : quel objet, quelle couleur ?',
  explication: 'La voiture doit être bleue, et seulement la voiture.',
);
