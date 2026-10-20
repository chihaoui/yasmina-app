import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/glisser-deposer/.
Map<String, dynamic> exemple(String fichier) =>
    jsonDecode(exemplesEduContent['glisser-deposer/$fichier']!)
        as Map<String, dynamic>;

// Exercices de test dans l'autre langue que l'exemple du type. Textes en
// brouillon (docs/conventions-arabe.md), aucun contenu recopié des manuels.

/// T09 en arabe : mot et image.
Map<String, dynamic> t09Arabe() => exerciceChoix(
  type: 'T09',
  langue: 'ar',
  gabarit: 'association-mot-image',
  competence: 'qiraa-kalimat-suwar',
  consigne: {
    'masculin': 'اِسْحَبْ كُلَّ كَلِمَةٍ إِلَى صُورَتِهَا.',
    'feminin': 'اِسْحَبِي كُلَّ كَلِمَةٍ إِلَى صُورَتِهَا.',
  },
  donnees: {
    'gauche': [
      {'id': 'g1', 'texte': 'قِطٌّ'},
      {'id': 'g2', 'texte': 'شَمْسٌ'},
      {'id': 'g3', 'texte': 'كِتَابٌ'},
    ],
    'droite': [
      {'id': 'd1', 'emoji': '📖'},
      {'id': 'd2', 'emoji': '🐱'},
      {'id': 'd3', 'emoji': '☀️'},
    ],
    'melanger': false,
  },
  reponse: {
    'paires': [
      {'gauche': 'g1', 'droite': 'd2'},
      {'gauche': 'g2', 'droite': 'd3'},
      {'gauche': 'g3', 'droite': 'd1'},
    ],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: كُلُّ كَلِمَةٍ عَلَى صُورَتِهَا.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: كُلُّ كَلِمَةٍ عَلَى صُورَتِهَا.',
  },
  indice: {
    'masculin': 'اِقْرَأْ كُلَّ كَلِمَةٍ بِصَوْتٍ عَالٍ، ثُمَّ اِبْحَثْ عَنْ صُورَتِهَا.',
    'feminin': 'اِقْرَئِي كُلَّ كَلِمَةٍ بِصَوْتٍ عَالٍ، ثُمَّ اِبْحَثِي عَنْ صُورَتِهَا.',
  },
  explication: 'قِطٌّ وَصُورَةُ الْقِطِّ، شَمْسٌ وَصُورَةُ الشَّمْسِ، كِتَابٌ وَصُورَةُ الْكِتَابِ.',
);

/// T11 en français : fruits et légumes.
Map<String, dynamic> t11Francais() => exerciceChoix(
  type: 'T11',
  langue: 'fr',
  gabarit: 'tri-bacs',
  competence: 'vocabulaire-aliments',
  consigne: 'Glisse chaque aliment dans le bon panier.',
  donnees: {
    'categories': [
      {'id': 'k1', 'titre': 'Fruits', 'emoji': '🍇'},
      {'id': 'k2', 'titre': 'Légumes', 'emoji': '🥬'},
    ],
    'elements': [
      {'id': 'e1', 'texte': 'banane', 'emoji': '🍌'},
      {'id': 'e2', 'texte': 'carotte', 'emoji': '🥕'},
      {'id': 'e3', 'texte': 'poire', 'emoji': '🍐'},
      {'id': 'e4', 'texte': 'oignon', 'emoji': '🧅'},
    ],
    'melanger': false,
  },
  reponse: {
    'classement': [
      {'element': 'e1', 'categorie': 'k1'},
      {'element': 'e2', 'categorie': 'k2'},
      {'element': 'e3', 'categorie': 'k1'},
      {'element': 'e4', 'categorie': 'k2'},
    ],
  },
  reussite: 'Oui : la banane et la poire sont des fruits, la carotte et l\'oignon des légumes.',
  indice: 'Un fruit est sucré. Un légume se cuisine ou se mange en salade.',
  explication: 'Fruits : banane, poire. Légumes : carotte, oignon.',
);

/// T13 en arabe : remettre les mots d'une phrase dans l'ordre.
Map<String, dynamic> t13Arabe() => exerciceChoix(
  type: 'T13',
  langue: 'ar',
  gabarit: 'ordre-mots',
  competence: 'tarkib-jumla',
  niveau: 3,
  consigne: {
    'masculin': 'رَتِّبِ الْكَلِمَاتِ لِتُكَوِّنَ جُمْلَةً.',
    'feminin': 'رَتِّبِي الْكَلِمَاتِ لِتُكَوِّنِي جُمْلَةً.',
  },
  donnees: {
    'elements': [
      {'id': 'e1', 'texte': 'يَلْعَبُ'},
      {'id': 'e2', 'texte': 'سَامِي'},
      {'id': 'e3', 'texte': 'فِي'},
      {'id': 'e4', 'texte': 'الْحَدِيقَةِ.'},
    ],
    'melanger': false,
  },
  reponse: {
    'ordre': ['e1', 'e2', 'e3', 'e4'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: يَلْعَبُ سَامِي فِي الْحَدِيقَةِ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: يَلْعَبُ سَامِي فِي الْحَدِيقَةِ.',
  },
  indice: 'الْجُمْلَةُ تَبْدَأُ بِالْفِعْلِ: يَلْعَبُ.',
  explication: 'الْجُمْلَةُ هِيَ: يَلْعَبُ سَامِي فِي الْحَدِيقَةِ.',
);
