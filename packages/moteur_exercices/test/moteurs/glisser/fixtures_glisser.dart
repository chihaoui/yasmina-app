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

/// T06 en arabe : un trou dans une phrase.
Map<String, dynamic> t06Arabe() => exerciceChoix(
  type: 'T06',
  langue: 'ar',
  gabarit: 'texte-trou',
  competence: 'nahw-fiil',
  niveau: 3,
  consigne: {
    'masculin': 'اِسْحَبِ الْكَلِمَةَ الْمُنَاسِبَةَ إِلَى الْفَرَاغِ.',
    'feminin': 'اِسْحَبِي الْكَلِمَةَ الْمُنَاسِبَةَ إِلَى الْفَرَاغِ.',
  },
  donnees: {
    'texte': 'الْوَلَدُ {t1} الْكِتَابَ.',
    'etiquettes': [
      {'id': 'e1', 'texte': 'يَقْرَأُ'},
      {'id': 'e2', 'texte': 'يَأْكُلُ'},
      {'id': 'e3', 'texte': 'يَنَامُ'},
    ],
    'melanger': false,
  },
  reponse: {
    'trous': [
      {'trou': 't1', 'etiquette': 'e1'},
    ],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: الْوَلَدُ يَقْرَأُ الْكِتَابَ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: الْوَلَدُ يَقْرَأُ الْكِتَابَ.',
  },
  indice: 'مَاذَا نَفْعَلُ بِالْكِتَابِ؟',
  explication: 'الْجُمْلَةُ هِيَ: الْوَلَدُ يَقْرَأُ الْكِتَابَ.',
);

/// T14 en français : les étapes de la journée.
Map<String, dynamic> t14Francais() => exerciceChoix(
  type: 'T14',
  langue: 'fr',
  gabarit: 'sequence-images',
  competence: 'temps-journee',
  consigne: 'Remets les moments de la journée dans l\'ordre.',
  donnees: {
    'elements': [
      {'id': 'e1', 'texte': 'le matin', 'emoji': '🌅'},
      {'id': 'e2', 'texte': 'midi', 'emoji': '☀️'},
      {'id': 'e3', 'texte': 'le soir', 'emoji': '🌇'},
      {'id': 'e4', 'texte': 'la nuit', 'emoji': '🌙'},
    ],
    'melanger': false,
  },
  reponse: {
    'ordre': ['e1', 'e2', 'e3', 'e4'],
  },
  reussite: 'Oui : le matin, midi, le soir, puis la nuit.',
  indice: 'La journée commence quand le soleil se lève.',
  explication: 'L\'ordre est : le matin, midi, le soir, la nuit.',
);

/// T62 en arabe (éveil, 2e année) : les étapes de la plante, étiquetées
/// sans date.
Map<String, dynamic> t62Arabe() => exerciceChoix(
  type: 'T62',
  langue: 'ar',
  gabarit: 'frise-etapes',
  competence: 'nabat-marahil',
  consigne: {
    'masculin': 'رَتِّبْ مَرَاحِلَ نُمُوِّ النَّبْتَةِ عَلَى الْخَطِّ.',
    'feminin': 'رَتِّبِي مَرَاحِلَ نُمُوِّ النَّبْتَةِ عَلَى الْخَطِّ.',
  },
  donnees: {
    'elements': [
      {'id': 'e1', 'texte': 'بَذْرَةٌ', 'emoji': '🌰'},
      {'id': 'e2', 'texte': 'بُرْعُمٌ', 'emoji': '🌱'},
      {'id': 'e3', 'texte': 'نَبْتَةٌ', 'emoji': '🌿'},
      {'id': 'e4', 'texte': 'زَهْرَةٌ', 'emoji': '🌸'},
    ],
    'melanger': false,
  },
  reponse: {
    'ordre': ['e1', 'e2', 'e3', 'e4'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: هَكَذَا تَنْمُو النَّبْتَةُ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: هَكَذَا تَنْمُو النَّبْتَةُ.',
  },
  indice: 'كُلُّ نَبْتَةٍ تَبْدَأُ بِبَذْرَةٍ.',
  explication: 'بَذْرَةٌ، ثُمَّ بُرْعُمٌ، ثُمَّ نَبْتَةٌ، ثُمَّ زَهْرَةٌ.',
);
