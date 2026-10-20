import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import 'outils_choix.dart';

/// Exemple réel de schema/exemples/choix/.
Map<String, dynamic> exemple(String fichier) =>
    jsonDecode(exemplesEduContent['choix/$fichier']!) as Map<String, dynamic>;

// Exercices de test dans l'autre langue que l'exemple du type. Textes en
// brouillon, écrits selon docs/conventions-arabe.md (A, B, C), aucun contenu
// recopié des manuels.

/// T03 en arabe : écouter « قِطٌّ », toucher la bonne image.
Map<String, dynamic> t03Arabe() => exerciceChoix(
  type: 'T03',
  langue: 'ar',
  gabarit: 'ecoute-image',
  competence: 'ecoute-mots',
  consigne: {
    'masculin': 'اِسْتَمِعْ ثُمَّ الْمَسِ الصُّورَةَ الْمُنَاسِبَةَ.',
    'feminin': 'اِسْتَمِعِي ثُمَّ الْمَسِي الصُّورَةَ الْمُنَاسِبَةَ.',
  },
  donnees: {
    'ecoute': {'texte': 'قِطٌّ'},
    'choix': [
      {'id': 'c1', 'emoji': '🐶'},
      {'id': 'c2', 'emoji': '🐱'},
      {'id': 'c3', 'emoji': '🐟'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c2'],
  },
  reussite: {
    'masculin':
        'إِجَابَتُكَ صَحِيحَةٌ: سَمِعْتَ «قِطٌّ» وَلَمَسْتَ صُورَةَ الْقِطِّ.',
    'feminin':
        'إِجَابَتُكِ صَحِيحَةٌ: سَمِعْتِ «قِطٌّ» وَلَمَسْتِ صُورَةَ الْقِطِّ.',
  },
  indice: {
    'masculin': 'اِسْمَعْ مَرَّةً أُخْرَى: هَذَا الْحَيَوَانُ يَقُولُ مِيَاوْ.',
    'feminin': 'اِسْمَعِي مَرَّةً أُخْرَى: هَذَا الْحَيَوَانُ يَقُولُ مِيَاوْ.',
  },
  explication: 'الْكَلِمَةُ هِيَ «قِطٌّ»، وَهَذِهِ صُورَةُ الْقِطِّ.',
);

/// T04 en arabe : l'intrus parmi des fruits.
Map<String, dynamic> t04Arabe() => exerciceChoix(
  type: 'T04',
  langue: 'ar',
  gabarit: 'intrus-texte',
  competence: 'mufradat-tasnif',
  consigne: {
    'masculin': 'اِخْتَرِ الْكَلِمَةَ الَّتِي لَيْسَتْ فَاكِهَةً.',
    'feminin': 'اِخْتَارِي الْكَلِمَةَ الَّتِي لَيْسَتْ فَاكِهَةً.',
  },
  donnees: {
    'choix': [
      {'id': 'c1', 'texte': 'تُفَّاحَةٌ'},
      {'id': 'c2', 'texte': 'مَوْزَةٌ'},
      {'id': 'c3', 'texte': 'كُرْسِيٌّ'},
      {'id': 'c4', 'texte': 'بُرْتُقَالَةٌ'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c3'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: «كُرْسِيٌّ» لَيْسَ فَاكِهَةً.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: «كُرْسِيٌّ» لَيْسَ فَاكِهَةً.',
  },
  indice: 'ثَلَاثُ كَلِمَاتٍ فَوَاكِهُ، وَكَلِمَةٌ وَاحِدَةٌ لَا تُؤْكَلُ.',
  explication: 'الدَّخِيلُ هُوَ «كُرْسِيٌّ»: هُوَ أَثَاثٌ. أَمَّا التُّفَّاحَةُ وَالْمَوْزَةُ وَالْبُرْتُقَالَةُ فَفَوَاكِهُ.',
);

/// T05 en français : plusieurs bonnes réponses.
Map<String, dynamic> t05Francais() => exerciceChoix(
  type: 'T05',
  langue: 'fr',
  gabarit: 'choix-multiple-texte',
  competence: 'vocabulaire-animaux',
  consigne: 'Touche tous les animaux.',
  donnees: {
    'choix': [
      {'id': 'c1', 'texte': 'chat'},
      {'id': 'c2', 'texte': 'table'},
      {'id': 'c3', 'texte': 'chien'},
      {'id': 'c4', 'texte': 'vélo'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c1', 'c3'],
  },
  reussite: 'Oui : le chat et le chien sont des animaux.',
  indice: 'Un animal est vivant. Une table et un vélo ne le sont pas.',
  explication: 'Les animaux sont le chat et le chien.',
);

/// T23 en français : 7 < 12.
Map<String, dynamic> t23Francais() => exerciceChoix(
  type: 'T23',
  langue: 'fr',
  gabarit: 'comparer-nombres',
  competence: 'comparer-nombres',
  consigne: 'Compare les deux nombres.',
  donnees: {'a': 7, 'b': 12},
  reponse: {'signe': '<'},
  reussite: 'Oui : 7 est plus petit que 12.',
  indice: 'Compte le nombre de chiffres : 7 en a un, 12 en a deux.',
  explication: 'Le nombre 7 est plus petit que le nombre 12.',
);

/// T24 en français : suite pomme, banane, pomme, banane.
Map<String, dynamic> t24Francais() => exerciceChoix(
  type: 'T24',
  langue: 'fr',
  gabarit: 'suite-images',
  competence: 'suites-motifs',
  consigne: 'Quelle image vient après ?',
  donnees: {
    'suite': [
      {'emoji': '🍎'},
      {'emoji': '🍌'},
      {'emoji': '🍎'},
      {'emoji': '🍌'},
    ],
    'choix': [
      {'id': 'c1', 'emoji': '🍌'},
      {'id': 'c2', 'emoji': '🍎'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c2'],
  },
  reussite: 'Oui : après la banane revient la pomme.',
  indice: 'Regarde : les images se répètent dans le même ordre.',
  explication: 'Pomme, banane, pomme, banane. Ensuite vient la pomme.',
);

/// T45 en arabe : barrer les phrases fausses après un texte.
Map<String, dynamic> t45Arabe() => exerciceChoix(
  type: 'T45',
  langue: 'ar',
  gabarit: 'barrer-phrases',
  competence: 'fahm-maqru',
  niveau: 4,
  consigne: {
    'masculin':
        'اِقْرَأِ النَّصَّ، ثُمَّ ضَعْ خَطًّا عَلَى الْجُمَلِ الْخَاطِئَةِ.',
    'feminin':
        'اِقْرَئِي النَّصَّ، ثُمَّ ضَعِي خَطًّا عَلَى الْجُمَلِ الْخَاطِئَةِ.',
  },
  donnees: {
    'support': {
      'texte': 'تَسْقِي نُورٌ أَزْهَارَ الشُّرْفَةِ كُلَّ صَبَاحٍ. ثُمَّ تَذْهَبُ إِلَى الْمَدْرَسَةِ بِدَرَّاجَتِهَا.',
    },
    'choix': [
      {'id': 'c1', 'texte': 'تَسْقِي نُورٌ الْأَزْهَارَ فِي الْمَسَاءِ.'},
      {'id': 'c2', 'texte': 'الْأَزْهَارُ فِي الشُّرْفَةِ.'},
      {'id': 'c3', 'texte': 'تَذْهَبُ نُورٌ إِلَى الْمَدْرَسَةِ مَشْيًا.'},
      {'id': 'c4', 'texte': 'تَسْقِي نُورٌ الْأَزْهَارَ كُلَّ صَبَاحٍ.'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c1', 'c3'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: نُورٌ تَسْقِي الْأَزْهَارَ صَبَاحًا وَتَذْهَبُ بِدَرَّاجَتِهَا.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: نُورٌ تَسْقِي الْأَزْهَارَ صَبَاحًا وَتَذْهَبُ بِدَرَّاجَتِهَا.',
  },
  indice: {
    'masculin':
        'اِقْرَأِ النَّصَّ مَرَّةً أُخْرَى: مَتَى تَسْقِي نُورٌ الْأَزْهَارَ؟',
    'feminin':
        'اِقْرَئِي النَّصَّ مَرَّةً أُخْرَى: مَتَى تَسْقِي نُورٌ الْأَزْهَارَ؟',
  },
  explication: 'الْجُمْلَتَانِ الْخَاطِئَتَانِ: «تَسْقِي نُورٌ الْأَزْهَارَ فِي الْمَسَاءِ» وَ«تَذْهَبُ نُورٌ إِلَى الْمَدْرَسَةِ مَشْيًا».',
);

/// T46 en arabe : réponse puis preuve.
Map<String, dynamic> t46Arabe() => exerciceChoix(
  type: 'T46',
  langue: 'ar',
  gabarit: 'reponse-justification',
  competence: 'fahm-tabrir',
  niveau: 5,
  consigne: {
    'masculin': 'أَجِبْ عَنِ السُّؤَالِ، ثُمَّ حَدِّدِ الْجُمْلَةَ الَّتِي تُثْبِتُ ذَلِكَ.',
    'feminin': 'أَجِيبِي عَنِ السُّؤَالِ، ثُمَّ حَدِّدِي الْجُمْلَةَ الَّتِي تُثْبِتُ ذَلِكَ.',
  },
  donnees: {
    'texte': 'فِي الصَّبَاحِ نَسِيَ آدَمُ مِظَلَّتَهُ. فِي الظُّهْرِ نَزَلَ الْمَطَرُ بِغَزَارَةٍ. عَادَ إِلَى الْبَيْتِ وَثِيَابُهُ مُبَلَّلَةٌ.',
    'question': 'هَلْ بَقِيَ آدَمُ جَافًّا؟',
    'choix': [
      {'id': 'c1', 'texte': 'نَعَمْ'},
      {'id': 'c2', 'texte': 'لَا'},
    ],
    'preuves': [
      {'id': 'p1', 'texte': 'فِي الصَّبَاحِ نَسِيَ آدَمُ مِظَلَّتَهُ.'},
      {'id': 'p2', 'texte': 'فِي الظُّهْرِ نَزَلَ الْمَطَرُ بِغَزَارَةٍ.'},
      {'id': 'p3', 'texte': 'عَادَ إِلَى الْبَيْتِ وَثِيَابُهُ مُبَلَّلَةٌ.'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c2'],
    'preuves': ['p3'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: عَادَ آدَمُ وَثِيَابُهُ مُبَلَّلَةٌ، فَهُوَ لَمْ يَبْقَ جَافًّا.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: عَادَ آدَمُ وَثِيَابُهُ مُبَلَّلَةٌ، فَهُوَ لَمْ يَبْقَ جَافًّا.',
  },
  indice: {
    'masculin':
        'اِبْحَثْ فِي النَّصِّ: كَيْفَ كَانَتْ ثِيَابُ آدَمَ عِنْدَمَا عَادَ؟',
    'feminin':
        'اِبْحَثِي فِي النَّصِّ: كَيْفَ كَانَتْ ثِيَابُ آدَمَ عِنْدَمَا عَادَ؟',
  },
  explication: 'لَمْ يَبْقَ آدَمُ جَافًّا. الدَّلِيلُ: «عَادَ إِلَى الْبَيْتِ وَثِيَابُهُ مُبَلَّلَةٌ.»',
);

/// T55 en arabe : سَيْفٌ ou صَيْفٌ.
Map<String, dynamic> t55Arabe() => exerciceChoix(
  type: 'T55',
  langue: 'ar',
  gabarit: 'paire-minimale',
  competence: 'aswat-sin-sad',
  consigne: {
    'masculin':
        'اِسْتَمِعْ جَيِّدًا وَحَدِّدِ الْكَلِمَةَ الَّتِي تَسْمَعُهَا.',
    'feminin':
        'اِسْتَمِعِي جَيِّدًا وَحَدِّدِي الْكَلِمَةَ الَّتِي تَسْمَعِينَهَا.',
  },
  donnees: {
    'ecoute': {'texte': 'صَيْفٌ'},
    'choix': [
      {'id': 'c1', 'texte': 'سَيْفٌ', 'emoji': '🗡️'},
      {'id': 'c2', 'texte': 'صَيْفٌ', 'emoji': '☀️'},
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c2'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: سَمِعْتَ «صَيْفٌ» بِحَرْفِ الصَّادِ.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: سَمِعْتِ «صَيْفٌ» بِحَرْفِ الصَّادِ.',
  },
  indice: {
    'masculin': 'اِسْمَعِ الصَّوْتَ الْأَوَّلَ: سِينٌ أَمْ صَادٌ؟',
    'feminin': 'اِسْمَعِي الصَّوْتَ الْأَوَّلَ: سِينٌ أَمْ صَادٌ؟',
  },
  explication: 'الْكَلِمَةُ هِيَ «صَيْفٌ» بِحَرْفِ الصَّادِ. أَمَّا «سَيْفٌ» فَبِحَرْفِ السِّينِ.',
);

/// T61 en arabe : les trois phrases qui résument l'histoire.
Map<String, dynamic> t61Arabe() => exerciceChoix(
  type: 'T61',
  langue: 'ar',
  gabarit: 'resume-selection',
  competence: 'fahm-talkhis',
  niveau: 5,
  consigne: {
    'masculin': 'اِخْتَرِ الْجُمَلَ الثَّلَاثَ الَّتِي تُلَخِّصُ الْقِصَّةَ.',
    'feminin': 'اِخْتَارِي الْجُمَلَ الثَّلَاثَ الَّتِي تُلَخِّصُ الْقِصَّةَ.',
  },
  donnees: {
    'texte': 'وَجَدَتْ إِينَاسُ عُصْفُورًا صَغِيرًا سَقَطَ مِنْ عُشِّهِ فِي السَّاحَةِ. وَضَعَتْهُ بِرِفْقٍ فِي عُلْبَةٍ فِيهَا قُطْنٌ. سَاعَدَهَا جَدُّهَا عَلَى إِعَادَةِ الْعُصْفُورِ إِلَى عُشِّهِ. فِي الْمَسَاءِ سَمِعَتْ إِينَاسُ الْعُصْفُورَ يُغَرِّدُ قُرْبَ النَّافِذَةِ.',
    'choix': [
      {
        'id': 'c1',
        'texte': 'وَجَدَتْ إِينَاسُ عُصْفُورًا سَقَطَ مِنْ عُشِّهِ.',
      },
      {'id': 'c2', 'texte': 'فِي الْعُلْبَةِ قُطْنٌ.'},
      {
        'id': 'c3',
        'texte': 'أَعَادَتْ مَعَ جَدِّهَا الْعُصْفُورَ إِلَى عُشِّهِ.',
      },
      {'id': 'c4', 'texte': 'الْعُصْفُورُ صَغِيرٌ.'},
      {
        'id': 'c5',
        'texte': 'فِي الْمَسَاءِ غَرَّدَ الْعُصْفُورُ قُرْبَ النَّافِذَةِ.',
      },
    ],
    'melanger': false,
  },
  reponse: {
    'choix': ['c1', 'c3', 'c5'],
  },
  reussite: {
    'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: هَذِهِ الْجُمَلُ الثَّلَاثُ تَرْوِي بِدَايَةَ الْقِصَّةِ وَوَسَطَهَا وَنِهَايَتَهَا.',
    'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: هَذِهِ الْجُمَلُ الثَّلَاثُ تَرْوِي بِدَايَةَ الْقِصَّةِ وَوَسَطَهَا وَنِهَايَتَهَا.',
  },
  indice: 'الْمُلَخَّصُ يَحْتَفِظُ بِالْأَحْدَاثِ الْمُهِمَّةِ، لَا بِالتَّفَاصِيلِ الصَّغِيرَةِ.',
  explication: 'الْمُلَخَّصُ: وَجَدَتْ إِينَاسُ عُصْفُورًا سَقَطَ مِنْ عُشِّهِ. أَعَادَتْ مَعَ جَدِّهَا الْعُصْفُورَ إِلَى عُشِّهِ. فِي الْمَسَاءِ غَرَّدَ الْعُصْفُورُ قُرْبَ النَّافِذَةِ.',
);
