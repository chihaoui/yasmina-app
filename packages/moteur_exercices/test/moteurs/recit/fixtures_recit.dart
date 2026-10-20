import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/recit/.
Map<String, dynamic> exempleRecit(String fichier) =>
    jsonDecode(exemplesEduContent['recit/$fichier']!) as Map<String, dynamic>;

/// T35 en arabe : deux étapes, trois choix, sans texte de fin.
Map<String, dynamic> t35Arabe() => exerciceChoix(
  type: 'T35',
  langue: 'ar',
  gabarit: 'histoire-choix',
  competence: 'comprehension-recit',
  niveau: 2,
  consigne: {
    'masculin': 'سَاعِدْ سَامِي عَلَى الْعَوْدَةِ إِلَى الْبَيْتِ.',
    'feminin': 'سَاعِدِي سَامِي عَلَى الْعَوْدَةِ إِلَى الْبَيْتِ.',
  },
  donnees: {
    'etapes': [
      {
        'id': 'e1',
        'scene': '🌧️ ☂️',
        'texte': 'بَدَأَ الْمَطَرُ يَنْزِلُ. مَاذَا يَفْعَلُ سَامِي؟',
        'choix': [
          {
            'id': 'c1',
            'texte': 'يَلْعَبُ تَحْتَ الْمَطَرِ.',
            'pourquoi': 'سَيَبْتَلُّ وَيَمْرَضُ.',
          },
          {'id': 'c2', 'texte': 'يَفْتَحُ الْمِظَلَّةَ.', 'juste': true},
          {
            'id': 'c3',
            'texte': 'يَجْلِسُ عَلَى الْأَرْضِ.',
            'pourquoi': 'الْأَرْضُ مُبَلَّلَةٌ.',
          },
        ],
      },
      {
        'id': 'e2',
        'scene': '🏠',
        'texte': 'وَصَلَ سَامِي إِلَى الْبَيْتِ. مَاذَا يَفْعَلُ؟',
        'choix': [
          {
            'id': 'c4',
            'texte': 'يَدْخُلُ بِحِذَائِهِ الْمُبَلَّلِ.',
            'pourquoi': 'سَيُوَسِّخُ الْبَيْتَ.',
          },
          {
            'id': 'c5',
            'texte': 'يَخْلَعُ حِذَاءَهُ ثُمَّ يَدْخُلُ.',
            'juste': true,
          },
        ],
      },
    ],
  },
  reponse: {
    'etapes': ['e1', 'e2'],
  },
  reussite: {
    'masculin': 'أَحْسَنْتَ: عَادَ سَامِي إِلَى الْبَيْتِ بِأَمَانٍ.',
    'feminin': 'أَحْسَنْتِ: عَادَ سَامِي إِلَى الْبَيْتِ بِأَمَانٍ.',
  },
  indice: 'فَكِّرْ فِي الْأَكْثَرِ أَمَانًا.',
  explication: 'الْمِظَلَّةُ تَحْمِي مِنَ الْمَطَرِ.',
)..['competence'] = 'ar-comprehension-recit';
