// Fichier généré par tool/generer_exemples.dart. Ne pas modifier à la main.
// Source de vérité : schema/exemples/**/*.json

/// Texte exact de chaque exemple, par chemin relatif à schema/exemples/
/// (par exemple `choix/T01-qcm-scene.json`).
const Map<String, String> exemplesEduContent = {
  'choix/T01-qcm-contraire.json': r'''
{
  "id": "ar-2-t1-u4-e01-x01",
  "type": "T01",
  "gabarit": "qcm-contraire",
  "competence": "ar-vocabulaire-contraires",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "مَا عَكْسُ كَلِمَةِ «كَبِيرٌ»؟"
  },
  "donnees": {
    "support": {
      "texte": "كَبِيرٌ"
    },
    "choix": [
      {
        "id": "c1",
        "texte": "صَغِيرٌ"
      },
      {
        "id": "c2",
        "texte": "طَوِيلٌ"
      },
      {
        "id": "c3",
        "texte": "جَمِيلٌ"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: عَكْسُ «كَبِيرٌ» هُوَ «صَغِيرٌ».",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: عَكْسُ «كَبِيرٌ» هُوَ «صَغِيرٌ»."
    },
    "indice": {
      "masculin": "تَخَيَّلْ فِيلًا وَنَمْلَةً: الْفِيلُ كَبِيرٌ، وَالنَّمْلَةُ...؟",
      "feminin": "تَخَيَّلِي فِيلًا وَنَمْلَةً: الْفِيلُ كَبِيرٌ، وَالنَّمْلَةُ...؟"
    },
    "explication": "عَكْسُ «كَبِيرٌ» هُوَ «صَغِيرٌ»: الْفِيلُ كَبِيرٌ، وَالنَّمْلَةُ صَغِيرَةٌ."
  },
  "empreinte": "sha256:59c554ab236ea9f998d108b224592da297c67ed3bcc248ef2ad1fe4aa1debf8c",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T01-qcm-orthographe.json': r'''
{
  "id": "fr-3-t1-u3-e02-x01",
  "type": "T01",
  "gabarit": "qcm-orthographe",
  "competence": "fr-orthographe-sons",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Écoute et touche le mot bien écrit."
  },
  "donnees": {
    "support": {
      "emoji": "🐰",
      "ecoute": {
        "texte": "lapin"
      }
    },
    "choix": [
      {
        "id": "c1",
        "texte": "lapain"
      },
      {
        "id": "c2",
        "texte": "lapin"
      },
      {
        "id": "c3",
        "texte": "lapun"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c2"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : « lapin » s'écrit avec « in » à la fin.",
    "indice": "Écoute la fin du mot : on entend « in », comme dans « sapin ».",
    "explication": "Le mot bien écrit est « lapin », avec « in » à la fin, comme « sapin »."
  },
  "empreinte": "sha256:f510c3bc8f7f378c956407b5b85b5b6eceab5a910c970138e43500930f2fb0f1",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T01-qcm-scene.json': r'''
{
  "id": "ev-2-t1-u1-e02-x01",
  "type": "T01",
  "gabarit": "qcm-scene",
  "competence": "ev-meteo",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "مَاذَا تَأْخُذُ سَلْمَى مَعَهَا؟"
  },
  "donnees": {
    "support": {
      "texte": "السَّمَاءُ مُمْطِرَةٌ.\nتَخْرُجُ سَلْمَى إِلَى الْمَدْرَسَةِ.",
      "emoji": "🌧️"
    },
    "choix": [
      {
        "id": "c1",
        "texte": "مِظَلَّةً",
        "emoji": "🌂"
      },
      {
        "id": "c2",
        "texte": "نَظَّارَةً شَمْسِيَّةً",
        "emoji": "🕶️"
      },
      {
        "id": "c3",
        "texte": "كُرَةً",
        "emoji": "⚽"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: الْمِظَلَّةُ تَحْمِي سَلْمَى مِنَ الْمَطَرِ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: الْمِظَلَّةُ تَحْمِي سَلْمَى مِنَ الْمَطَرِ."
    },
    "indice": {
      "masculin": "فَكِّرْ: مَاذَا يَحْمِينَا مِنَ الْمَطَرِ؟",
      "feminin": "فَكِّرِي: مَاذَا يَحْمِينَا مِنَ الْمَطَرِ؟"
    },
    "explication": "عِنْدَمَا تُمْطِرُ السَّمَاءُ، نَأْخُذُ مِظَلَّةً حَتَّى لَا نَبْتَلَّ."
  },
  "empreinte": "sha256:a962009b00de0c8080ba1bd9404a52a3417fe10cd7201f1c642b7e772e48ba52",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T01-qcm-texte-image.json': r'''
{
  "id": "ev-3-t1-u2-e01-x01",
  "type": "T01",
  "gabarit": "qcm-texte-image",
  "competence": "ev-milieux-de-vie",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "أَيُّ حَيَوَانٍ يَعِيشُ فِي الْمَاءِ؟"
  },
  "donnees": {
    "choix": [
      {
        "id": "c1",
        "texte": "السَّمَكَةُ",
        "emoji": "🐟"
      },
      {
        "id": "c2",
        "texte": "الْقِطُّ",
        "emoji": "🐱"
      },
      {
        "id": "c3",
        "texte": "الْحِصَانُ",
        "emoji": "🐴"
      },
      {
        "id": "c4",
        "texte": "الدِّيكُ",
        "emoji": "🐓"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: السَّمَكَةُ تَعِيشُ فِي الْمَاءِ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: السَّمَكَةُ تَعِيشُ فِي الْمَاءِ."
    },
    "indice": {
      "masculin": "فَكِّرْ فِي حَيَوَانٍ يَسْبَحُ وَلَا يَخْرُجُ مِنَ الْمَاءِ.",
      "feminin": "فَكِّرِي فِي حَيَوَانٍ يَسْبَحُ وَلَا يَخْرُجُ مِنَ الْمَاءِ."
    },
    "explication": "السَّمَكَةُ تَعِيشُ فِي الْمَاءِ وَتَتَنَفَّسُ بِخَيَاشِيمِهَا. أَمَّا الْقِطُّ وَالْحِصَانُ وَالدِّيكُ فَتَعِيشُ عَلَى الْيَابِسَةِ."
  },
  "empreinte": "sha256:134aa35235d9ae7376399c8dea6366e1a40f3bb69005ec73792aa77c89c78349",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T02-vrai-faux.json': r'''
{
  "id": "en-4-t1-u1-e01-x01",
  "type": "T02",
  "gabarit": "vrai-faux-texte",
  "competence": "en-vocabulary-animals",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "en",
  "consigne": {
    "texte": "True or false?"
  },
  "donnees": {
    "affirmation": "An elephant is a small animal.",
    "emoji": "🐘"
  },
  "reponse": {
    "valeur": false
  },
  "feedbacks": {
    "reussite": "Right: the sentence is false. An elephant is a very big animal.",
    "indice": "Think about the size of an elephant next to a cat.",
    "explication": "False. An elephant is one of the biggest animals on land."
  },
  "empreinte": "sha256:bdab343a46404f4795a7c86fba02c30d46672988ef3413a29982004e1557a844",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T03-ecoute-et-choisis.json': r'''
{
  "id": "en-4-t1-u1-e02-x01",
  "type": "T03",
  "gabarit": "ecoute-image",
  "competence": "en-listening-words",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "en",
  "consigne": {
    "texte": "Listen and tap the right picture."
  },
  "donnees": {
    "ecoute": {
      "texte": "cat"
    },
    "choix": [
      {
        "id": "c1",
        "emoji": "🐶"
      },
      {
        "id": "c2",
        "emoji": "🐱"
      },
      {
        "id": "c3",
        "emoji": "🐦"
      },
      {
        "id": "c4",
        "emoji": "🐟"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c2"
    ]
  },
  "feedbacks": {
    "reussite": "Right: you heard \"cat\" and you tapped the cat.",
    "indice": "Listen again. This animal says meow.",
    "explication": "The word is \"cat\". This is the picture of the cat."
  },
  "empreinte": "sha256:b5486acf50ba7a36b39ddd8d91bff030bfb72fea5c2ce023aba46dc1ce472446",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T04-intrus.json': r'''
{
  "id": "fr-3-t1-u1-e01-x01",
  "type": "T04",
  "gabarit": "intrus-texte",
  "competence": "fr-vocabulaire-categories",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Touche le mot qui n'est pas un fruit."
  },
  "donnees": {
    "choix": [
      {
        "id": "c1",
        "texte": "pomme"
      },
      {
        "id": "c2",
        "texte": "poire"
      },
      {
        "id": "c3",
        "texte": "chaise"
      },
      {
        "id": "c4",
        "texte": "banane"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c3"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : « chaise » n'est pas un fruit, c'est un meuble.",
    "indice": "Trois mots sont des fruits. Lequel ne se mange pas ?",
    "explication": "L'intrus est « chaise » : c'est un meuble. Pomme, poire et banane sont des fruits."
  },
  "empreinte": "sha256:854e52a5097c9ca7086a0ef0598d75fd111fea4dff2e49e6f2bd644eacdf0fc2",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T05-choix-multiple.json': r'''
{
  "id": "ma-2-t1-u3-e02-x01",
  "type": "T05",
  "gabarit": "choix-multiple-texte",
  "competence": "ma-nombres-pairs",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "اِخْتَرْ كُلَّ الْأَعْدَادِ الزَّوْجِيَّةِ."
  },
  "donnees": {
    "choix": [
      {
        "id": "c1",
        "texte": "4"
      },
      {
        "id": "c2",
        "texte": "7"
      },
      {
        "id": "c3",
        "texte": "10"
      },
      {
        "id": "c4",
        "texte": "3"
      },
      {
        "id": "c5",
        "texte": "8"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1",
      "c3",
      "c5"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 4 وَ 10 وَ 8 أَعْدَادٌ زَوْجِيَّةٌ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 4 وَ 10 وَ 8 أَعْدَادٌ زَوْجِيَّةٌ."
    },
    "indice": "الْعَدَدُ الزَّوْجِيُّ نَقْسِمُهُ عَلَى 2 فَلَا يَبْقَى شَيْءٌ.",
    "explication": "الْأَعْدَادُ الزَّوْجِيَّةُ هِيَ 4 وَ 8 وَ 10. أَمَّا 3 وَ 7 فَأَعْدَادٌ فَرْدِيَّةٌ."
  },
  "empreinte": "sha256:fa1ba22795289a9e42011bf149e0ed9312f564a355d11595d912a3f3c36504af",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T18-forme-lettre.json': r'''
{
  "id": "ar-1-t1-u3-e02-x01",
  "type": "T18",
  "gabarit": "forme-lettre",
  "competence": "ar-ecriture-formes-lettre",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "اِخْتَرْ شَكْلَ حَرْفِ الْجِيمِ فِي وَسَطِ كَلِمَةِ «نَجْمَةٌ»."
  },
  "donnees": {
    "lettre": "ج",
    "position": "milieu",
    "mot": "نَجْمَةٌ",
    "choix": [
      {
        "id": "c1",
        "texte": "ج"
      },
      {
        "id": "c2",
        "texte": "جـ"
      },
      {
        "id": "c3",
        "texte": "ـجـ"
      },
      {
        "id": "c4",
        "texte": "ـج"
      }
    ],
    "melanger": false
  },
  "reponse": {
    "choix": [
      "c3"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: فِي وَسَطِ الْكَلِمَةِ نَكْتُبُ الْجِيمَ هَكَذَا: ـجـ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: فِي وَسَطِ الْكَلِمَةِ نَكْتُبُ الْجِيمَ هَكَذَا: ـجـ."
    },
    "indice": "فِي وَسَطِ الْكَلِمَةِ، يَتَّصِلُ الْحَرْفُ بِمَا قَبْلَهُ وَبِمَا بَعْدَهُ.",
    "explication": "فِي كَلِمَةِ «نَجْمَةٌ» يَأْتِي الْجِيمُ فِي الْوَسَطِ، فَنَكْتُبُهُ هَكَذَا: ـجـ."
  },
  "empreinte": "sha256:8ba1b05f5529b000429243f69cd4ce4130a4ecccaf0a52211fd07d2e10d69901",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T19-haraka.json': r'''
{
  "id": "ar-2-t1-u2-e03-x01",
  "type": "T19",
  "gabarit": "haraka",
  "competence": "ar-lecture-harakat",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "اِخْتَرِ الْحَرَكَةَ الْمُنَاسِبَةَ لِحَرْفِ التَّاءِ."
  },
  "donnees": {
    "avant": "كُ",
    "lettre": "ت",
    "apres": "بٌ",
    "harakat": [
      "fatha",
      "damma",
      "kasra",
      "soukoun"
    ],
    "ecoute": {
      "texte": "كُتُبٌ"
    }
  },
  "reponse": {
    "haraka": "damma"
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: نَقُولُ «كُتُبٌ»، وَعَلَى التَّاءِ ضَمَّةٌ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: نَقُولُ «كُتُبٌ»، وَعَلَى التَّاءِ ضَمَّةٌ."
    },
    "indice": {
      "masculin": "اِسْمَعِ الْكَلِمَةَ مَرَّةً أُخْرَى: «كُتُبٌ».",
      "feminin": "اِسْمَعِي الْكَلِمَةَ مَرَّةً أُخْرَى: «كُتُبٌ»."
    },
    "explication": "نَقُولُ «كُتُبٌ»: عَلَى التَّاءِ ضَمَّةٌ."
  },
  "empreinte": "sha256:d80d5370a1f5e3722d0e32d2cab716b9a6c0fcb618adad731f09c56f8174acd9",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T19-lettre-vocalisee.json': r'''
{
  "id": "ar-1-t1-u2-e01-x01",
  "type": "T19",
  "gabarit": "lettre-vocalisee",
  "competence": "ar-lecture-harakat",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "أَيُّ حَرْفٍ عَلَيْهِ فَتْحَةٌ؟"
  },
  "donnees": {
    "haraka": "fatha",
    "choix": [
      {
        "id": "c1",
        "texte": "بَ"
      },
      {
        "id": "c2",
        "texte": "بُ"
      },
      {
        "id": "c3",
        "texte": "بِ"
      },
      {
        "id": "c4",
        "texte": "بْ"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: عَلَى «بَ» فَتْحَةٌ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: عَلَى «بَ» فَتْحَةٌ."
    },
    "indice": "الْفَتْحَةُ خَطٌّ صَغِيرٌ فَوْقَ الْحَرْفِ.",
    "explication": "الْحَرْفُ «بَ» عَلَيْهِ فَتْحَةٌ، فَنَقْرَأُ: بَ."
  },
  "empreinte": "sha256:e04b136865d58abb513cda23602f9be97103af19c19d07db2af08206b9a727cd",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T23-comparer.json': r'''
{
  "id": "ma-1-t1-u4-e01-x01",
  "type": "T23",
  "gabarit": "comparer-nombres",
  "competence": "ma-comparer-nombres",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "قَارِنْ بَيْنَ الْعَدَدَيْنِ."
  },
  "donnees": {
    "a": 14,
    "b": 9
  },
  "reponse": {
    "signe": ">"
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 14 أَكْبَرُ مِنْ 9.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 14 أَكْبَرُ مِنْ 9."
    },
    "indice": {
      "masculin": "قَارِنْ أَوَّلًا عَدَدَ الْأَرْقَامِ: فِي 14 رَقْمَانِ، وَفِي 9 رَقْمٌ وَاحِدٌ.",
      "feminin": "قَارِنِي أَوَّلًا عَدَدَ الْأَرْقَامِ: فِي 14 رَقْمَانِ، وَفِي 9 رَقْمٌ وَاحِدٌ."
    },
    "explication": "الْعَدَدُ 14 أَكْبَرُ مِنَ الْعَدَدِ 9."
  },
  "empreinte": "sha256:ae04521bd52e6d14585306db076125b5dc4a539b3d7ef47a0e1d27e49eb7d2fc",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T24-suite.json': r'''
{
  "id": "ma-1-t1-u5-e02-x01",
  "type": "T24",
  "gabarit": "suite-images",
  "competence": "ma-suites-motifs",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": "مَا الشَّكْلُ الَّذِي يَأْتِي فِي الْمَكَانِ الْفَارِغِ؟"
  },
  "donnees": {
    "suite": [
      {
        "emoji": "🔺"
      },
      {
        "emoji": "🔵"
      },
      {
        "emoji": "🟩"
      },
      {
        "emoji": "🔺"
      },
      {
        "emoji": "🔵"
      },
      {
        "emoji": "🟩"
      }
    ],
    "choix": [
      {
        "id": "c1",
        "emoji": "🔵"
      },
      {
        "id": "c2",
        "emoji": "🔺"
      },
      {
        "id": "c3",
        "emoji": "🟩"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c2"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: بَعْدَ الْمُرَبَّعِ يَعُودُ الْمُثَلَّثُ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: بَعْدَ الْمُرَبَّعِ يَعُودُ الْمُثَلَّثُ."
    },
    "indice": {
      "masculin": "لَاحِظْ: الْأَشْكَالُ تَتَكَرَّرُ بِالتَّرْتِيبِ نَفْسِهِ.",
      "feminin": "لَاحِظِي: الْأَشْكَالُ تَتَكَرَّرُ بِالتَّرْتِيبِ نَفْسِهِ."
    },
    "explication": "الْمُثَلَّثُ ثُمَّ الدَّائِرَةُ ثُمَّ الْمُرَبَّعُ، ثُمَّ نُعِيدُ مِنَ الْبِدَايَةِ. يَأْتِي الْآنَ الْمُثَلَّثُ."
  },
  "empreinte": "sha256:67c4b3667f0d625f19729db004fa6cd4c035814188ce72a4bca5be321797adf8",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T45-barrer.json': r'''
{
  "id": "fr-4-t1-u2-e01-x01",
  "type": "T45",
  "gabarit": "barrer-phrases",
  "competence": "fr-comprehension-ecrit",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Lis le texte, puis barre les phrases fausses."
  },
  "donnees": {
    "support": {
      "texte": "Nour arrose les fleurs du balcon chaque matin. Ensuite, elle prend son vélo pour aller à l'école."
    },
    "choix": [
      {
        "id": "c1",
        "texte": "Nour arrose les fleurs le soir."
      },
      {
        "id": "c2",
        "texte": "Les fleurs sont sur le balcon."
      },
      {
        "id": "c3",
        "texte": "Nour va à l'école à pied."
      },
      {
        "id": "c4",
        "texte": "Nour arrose les fleurs chaque matin."
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1",
      "c3"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : Nour arrose les fleurs le matin et elle va à l'école à vélo.",
    "indice": "Relis le texte : à quel moment Nour arrose-t-elle les fleurs ? Comment va-t-elle à l'école ?",
    "explication": "Les phrases fausses sont « Nour arrose les fleurs le soir » et « Nour va à l'école à pied ». Dans le texte, elle arrose les fleurs le matin et elle prend son vélo."
  },
  "empreinte": "sha256:b2c71fc9853615f65d5e29be6a98fb63f293a388afe12bbc26199fdad58543e6",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T46-justification.json': r'''
{
  "id": "fr-5-t1-u1-e03-x01",
  "type": "T46",
  "gabarit": "reponse-justification",
  "competence": "fr-comprehension-justifier",
  "critere": "C3",
  "niveau_critere": "perfectionnement",
  "langue": "fr",
  "consigne": {
    "texte": "Réponds à la question, puis touche la phrase du texte qui le prouve."
  },
  "donnees": {
    "texte": "Ce matin, Adam a oublié son parapluie. À midi, la pluie tombe très fort. Il rentre à la maison les vêtements trempés.",
    "question": "Adam est-il resté au sec ?",
    "choix": [
      {
        "id": "c1",
        "texte": "Oui"
      },
      {
        "id": "c2",
        "texte": "Non"
      }
    ],
    "preuves": [
      {
        "id": "p1",
        "texte": "Ce matin, Adam a oublié son parapluie."
      },
      {
        "id": "p2",
        "texte": "À midi, la pluie tombe très fort."
      },
      {
        "id": "p3",
        "texte": "Il rentre à la maison les vêtements trempés."
      }
    ],
    "melanger": false
  },
  "reponse": {
    "choix": [
      "c2"
    ],
    "preuves": [
      "p3"
    ]
  },
  "feedbacks": {
    "reussite": "Bonne réponse et bonne preuve : Adam rentre les vêtements trempés, il n'est donc pas resté au sec.",
    "indice": "Cherche dans le texte comment sont les vêtements d'Adam quand il rentre.",
    "explication": "Adam n'est pas resté au sec. La preuve : « Il rentre à la maison les vêtements trempés. »"
  },
  "empreinte": "sha256:d0e8ac78962e60c6abaadb324a78a6e46c149d010c565fb033317f5a3c7477e1",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T55-paire-minimale.json': r'''
{
  "id": "fr-3-t1-u2-e02-x01",
  "type": "T55",
  "gabarit": "paire-minimale",
  "competence": "fr-phonologie-p-b",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Écoute bien et touche le mot que tu entends."
  },
  "donnees": {
    "ecoute": {
      "texte": "bain"
    },
    "choix": [
      {
        "id": "c1",
        "texte": "pain",
        "emoji": "🥖"
      },
      {
        "id": "c2",
        "texte": "bain",
        "emoji": "🛁"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c2"
    ]
  },
  "feedbacks": {
    "reussite": "Oui, on entend « bain » : le mot commence par le son « b ».",
    "indice": "Écoute le premier son : « p » ou « b » ?",
    "explication": "On entend « bain », avec « b ». « Pain » commence par « p »."
  },
  "empreinte": "sha256:8824d549e4ab40fc09d08efe9b82418654ab40f52c288cf4e8c7a09e089768f6",
  "statut": "brouillon",
  "version": 1
}
''',
  'choix/T61-resume.json': r'''
{
  "id": "fr-5-t1-u3-e01-x01",
  "type": "T61",
  "gabarit": "resume-selection",
  "competence": "fr-comprehension-resumer",
  "critere": "C3",
  "niveau_critere": "perfectionnement",
  "langue": "fr",
  "consigne": {
    "texte": "Choisis les trois phrases qui résument le mieux l'histoire."
  },
  "donnees": {
    "texte": "Inès trouve un petit oiseau tombé du nid dans la cour. Elle le pose doucement dans une boîte avec du coton. Son grand-père l'aide à remettre l'oiseau dans son nid. Le soir, Inès entend l'oiseau chanter près de la fenêtre.",
    "choix": [
      {
        "id": "c1",
        "texte": "Inès trouve un oiseau tombé du nid."
      },
      {
        "id": "c2",
        "texte": "La boîte contient du coton."
      },
      {
        "id": "c3",
        "texte": "Avec son grand-père, elle remet l'oiseau dans son nid."
      },
      {
        "id": "c4",
        "texte": "L'oiseau est petit."
      },
      {
        "id": "c5",
        "texte": "Le soir, l'oiseau chante près de la fenêtre."
      }
    ],
    "melanger": true
  },
  "reponse": {
    "choix": [
      "c1",
      "c3",
      "c5"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : ces trois phrases racontent le début, le milieu et la fin de l'histoire.",
    "indice": "Un résumé garde les moments importants. Les petits détails ne comptent pas.",
    "explication": "Le résumé : Inès trouve un oiseau tombé du nid. Avec son grand-père, elle remet l'oiseau dans son nid. Le soir, l'oiseau chante près de la fenêtre."
  },
  "empreinte": "sha256:c40bc07cc445726e510c370257ef094795300f664ec5e178454560d6f2f7f553",
  "statut": "brouillon",
  "version": 1
}
''',
};
