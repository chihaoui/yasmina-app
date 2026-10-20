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
  'glisser-deposer/T06-texte-trou.json': r'''
{
  "id": "fr-4-t1-u2-e02-x01",
  "type": "T06",
  "gabarit": "texte-trou",
  "competence": "fr-conjugaison-present",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Glisse le bon mot dans la phrase."
  },
  "donnees": {
    "texte": "Le chien {t1} dans le jardin.",
    "etiquettes": [
      {
        "id": "e1",
        "texte": "court"
      },
      {
        "id": "e2",
        "texte": "courent"
      },
      {
        "id": "e3",
        "texte": "courons"
      },
      {
        "id": "e4",
        "texte": "courir"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "trous": [
      {
        "trou": "t1",
        "etiquette": "e1"
      }
    ]
  },
  "feedbacks": {
    "reussite": "Oui : le chien court. Avec « le chien », le verbe se termine par « t ».",
    "indice": "Le sujet est « le chien », comme « il ». Que fait-il ?",
    "explication": "La phrase est « Le chien court dans le jardin. » Avec il, elle ou le chien, on écrit « court »."
  },
  "empreinte": "sha256:b97aa7b4e00ace8c7adf88145e9e25987bc2f4a6ea7b711c2b817ca7ca79070b",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T06-texte-trous.json': r'''
{
  "id": "fr-5-t1-u1-e02-x01",
  "type": "T06",
  "gabarit": "texte-trous",
  "competence": "fr-comprehension-texte-trous",
  "critere": "C2",
  "niveau_critere": "perfectionnement",
  "langue": "fr",
  "consigne": {
    "texte": "Glisse chaque mot dans le bon trou du texte."
  },
  "donnees": {
    "texte": "Le matin, Sami {t1} son cartable. Il {t2} à l'école à pied. Le soir, il {t3} ses devoirs.",
    "etiquettes": [
      {
        "id": "e1",
        "texte": "prend"
      },
      {
        "id": "e2",
        "texte": "va"
      },
      {
        "id": "e3",
        "texte": "fait"
      },
      {
        "id": "e4",
        "texte": "dort"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "trous": [
      {
        "trou": "t1",
        "etiquette": "e1"
      },
      {
        "trou": "t2",
        "etiquette": "e2"
      },
      {
        "trou": "t3",
        "etiquette": "e3"
      }
    ]
  },
  "feedbacks": {
    "reussite": "Oui : Sami prend son cartable, va à l'école et fait ses devoirs.",
    "indice": "Lis chaque phrase en entier avant de choisir : le mot « dort » ne va dans aucun trou.",
    "explication": "Le texte est : « Le matin, Sami prend son cartable. Il va à l'école à pied. Le soir, il fait ses devoirs. »"
  },
  "empreinte": "sha256:1f499a69cfe27cea85610ce0d0abdf3c7f6aaca596c12183c86d5bbe0fa6eab1",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T09-association.json': r'''
{
  "id": "fr-3-t1-u2-e01-x01",
  "type": "T09",
  "gabarit": "association-mot-image",
  "competence": "fr-lecture-mots-images",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Glisse chaque mot sur son image."
  },
  "donnees": {
    "gauche": [
      {
        "id": "g1",
        "texte": "pomme"
      },
      {
        "id": "g2",
        "texte": "vélo"
      },
      {
        "id": "g3",
        "texte": "lune"
      },
      {
        "id": "g4",
        "texte": "poisson"
      }
    ],
    "droite": [
      {
        "id": "d1",
        "emoji": "🚲"
      },
      {
        "id": "d2",
        "emoji": "🐟"
      },
      {
        "id": "d3",
        "emoji": "🍎"
      },
      {
        "id": "d4",
        "emoji": "🌙"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "paires": [
      {
        "gauche": "g1",
        "droite": "d3"
      },
      {
        "gauche": "g2",
        "droite": "d1"
      },
      {
        "gauche": "g3",
        "droite": "d4"
      },
      {
        "gauche": "g4",
        "droite": "d2"
      }
    ]
  },
  "feedbacks": {
    "reussite": "Oui : chaque mot est sur son image.",
    "indice": "Lis chaque mot à voix haute, puis cherche son image.",
    "explication": "pomme et la pomme, vélo et le vélo, lune et la lune, poisson et le poisson."
  },
  "empreinte": "sha256:a051af5dc730705be1667c04bebf9ed016b5edcc852fa5262d81949e66802988",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T11-tri-categories.json': r'''
{
  "id": "ev-2-t1-u2-e01-x01",
  "type": "T11",
  "gabarit": "tri-bacs",
  "competence": "ev-aliments-fruits-legumes",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "صَنِّفِ الْأَطْعِمَةَ: فَوَاكِهُ أَمْ خُضَرٌ؟",
      "feminin": "صَنِّفِي الْأَطْعِمَةَ: فَوَاكِهُ أَمْ خُضَرٌ؟"
    }
  },
  "donnees": {
    "categories": [
      {
        "id": "k1",
        "titre": "فَوَاكِهُ",
        "emoji": "🍇"
      },
      {
        "id": "k2",
        "titre": "خُضَرٌ",
        "emoji": "🥬"
      }
    ],
    "elements": [
      {
        "id": "e1",
        "texte": "مَوْزَةٌ",
        "emoji": "🍌"
      },
      {
        "id": "e2",
        "texte": "جَزَرَةٌ",
        "emoji": "🥕"
      },
      {
        "id": "e3",
        "texte": "بُرْتُقَالَةٌ",
        "emoji": "🍊"
      },
      {
        "id": "e4",
        "texte": "خِيَارَةٌ",
        "emoji": "🥒"
      },
      {
        "id": "e5",
        "texte": "فَرَاوْلَةٌ",
        "emoji": "🍓"
      },
      {
        "id": "e6",
        "texte": "بَصَلَةٌ",
        "emoji": "🧅"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "classement": [
      {
        "element": "e1",
        "categorie": "k1"
      },
      {
        "element": "e2",
        "categorie": "k2"
      },
      {
        "element": "e3",
        "categorie": "k1"
      },
      {
        "element": "e4",
        "categorie": "k2"
      },
      {
        "element": "e5",
        "categorie": "k1"
      },
      {
        "element": "e6",
        "categorie": "k2"
      }
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: كُلُّ طَعَامٍ فِي مَكَانِهِ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: كُلُّ طَعَامٍ فِي مَكَانِهِ."
    },
    "indice": "الْفَوَاكِهُ حُلْوَةٌ وَتَنْمُو عَلَى الْأَشْجَارِ غَالِبًا. الْخُضَرُ نَطْبُخُهَا أَوْ نَأْكُلُهَا فِي السَّلَطَةِ.",
    "explication": "الْفَوَاكِهُ: الْمَوْزَةُ وَالْبُرْتُقَالَةُ وَالْفَرَاوْلَةُ. الْخُضَرُ: الْجَزَرَةُ وَالْخِيَارَةُ وَالْبَصَلَةُ."
  },
  "empreinte": "sha256:7e2046b16d83bc6621df454182c08ed09e96c8adbf46ec99d58ddfd516564b09",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T12-tableau-tri.json': r'''
{
  "id": "ar-3-t1-u3-e01-x01",
  "type": "T12",
  "gabarit": "tableau-tri",
  "competence": "ar-lam-shamsiya-qamariya",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "صَنِّفِ الْكَلِمَاتِ: لَامٌ شَمْسِيَّةٌ أَمْ لَامٌ قَمَرِيَّةٌ؟",
      "feminin": "صَنِّفِي الْكَلِمَاتِ: لَامٌ شَمْسِيَّةٌ أَمْ لَامٌ قَمَرِيَّةٌ؟"
    }
  },
  "donnees": {
    "categories": [
      {
        "id": "k1",
        "titre": "لَامٌ شَمْسِيَّةٌ",
        "emoji": "☀️"
      },
      {
        "id": "k2",
        "titre": "لَامٌ قَمَرِيَّةٌ",
        "emoji": "🌙"
      }
    ],
    "elements": [
      {
        "id": "e1",
        "texte": "الدَّفْتَرُ"
      },
      {
        "id": "e2",
        "texte": "الْجَبَلُ"
      },
      {
        "id": "e3",
        "texte": "الطَّرِيقُ"
      },
      {
        "id": "e4",
        "texte": "الْكُرْسِيُّ"
      },
      {
        "id": "e5",
        "texte": "السَّيَّارَةُ"
      },
      {
        "id": "e6",
        "texte": "الْمَدْرَسَةُ"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "classement": [
      {
        "element": "e1",
        "categorie": "k1"
      },
      {
        "element": "e2",
        "categorie": "k2"
      },
      {
        "element": "e3",
        "categorie": "k1"
      },
      {
        "element": "e4",
        "categorie": "k2"
      },
      {
        "element": "e5",
        "categorie": "k1"
      },
      {
        "element": "e6",
        "categorie": "k2"
      }
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: كُلُّ كَلِمَةٍ فِي عَمُودِهَا.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: كُلُّ كَلِمَةٍ فِي عَمُودِهَا."
    },
    "indice": "اللَّامُ الشَّمْسِيَّةُ لَا تُنْطَقُ، وَبَعْدَهَا حَرْفٌ عَلَيْهِ شَدَّةٌ. اللَّامُ الْقَمَرِيَّةُ تُنْطَقُ وَعَلَيْهَا سُكُونٌ.",
    "explication": "شَمْسِيَّةٌ: الدَّفْتَرُ وَالطَّرِيقُ وَالسَّيَّارَةُ. قَمَرِيَّةٌ: الْجَبَلُ وَالْكُرْسِيُّ وَالْمَدْرَسَةُ."
  },
  "empreinte": "sha256:095c495c6afb7c4fae037bc8c074d8433dd9ff7a38c73a9437373adfd9e898c2",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T13-remise-en-ordre.json': r'''
{
  "id": "en-5-t1-u2-e01-x01",
  "type": "T13",
  "gabarit": "ordre-mots",
  "competence": "en-sentence-order",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "en",
  "consigne": {
    "texte": "Drag the words to make a sentence."
  },
  "donnees": {
    "elements": [
      {
        "id": "e1",
        "texte": "We"
      },
      {
        "id": "e2",
        "texte": "play"
      },
      {
        "id": "e3",
        "texte": "football"
      },
      {
        "id": "e4",
        "texte": "on"
      },
      {
        "id": "e5",
        "texte": "Sunday."
      }
    ],
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e2",
      "e3",
      "e4",
      "e5"
    ]
  },
  "feedbacks": {
    "reussite": "Right: We play football on Sunday.",
    "indice": "A sentence starts with a capital letter. Here it is \"We\".",
    "explication": "The sentence is \"We play football on Sunday.\""
  },
  "empreinte": "sha256:7381729d70991cdbfcbca37ab4f32e7250e1f56bcdc565e1346a5b7a5fc0637f",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T14-sequence-images.json': r'''
{
  "id": "ev-2-t1-u3-e01-x01",
  "type": "T14",
  "gabarit": "sequence-images",
  "competence": "ev-cycle-de-vie",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "رَتِّبْ مَرَاحِلَ نُمُوِّ الدَّجَاجَةِ.",
      "feminin": "رَتِّبِي مَرَاحِلَ نُمُوِّ الدَّجَاجَةِ."
    }
  },
  "donnees": {
    "elements": [
      {
        "id": "e1",
        "texte": "بَيْضَةٌ",
        "emoji": "🥚"
      },
      {
        "id": "e2",
        "texte": "كَتْكُوتٌ",
        "emoji": "🐣"
      },
      {
        "id": "e3",
        "texte": "فَرْخٌ",
        "emoji": "🐥"
      },
      {
        "id": "e4",
        "texte": "دَجَاجَةٌ",
        "emoji": "🐔"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e2",
      "e3",
      "e4"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: هَكَذَا تَنْمُو الدَّجَاجَةُ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: هَكَذَا تَنْمُو الدَّجَاجَةُ."
    },
    "indice": "كُلُّ دَجَاجَةٍ تَبْدَأُ بِبَيْضَةٍ.",
    "explication": "بَيْضَةٌ، ثُمَّ كَتْكُوتٌ، ثُمَّ فَرْخٌ، ثُمَّ دَجَاجَةٌ."
  },
  "empreinte": "sha256:7a1f4db92026eb92cee47cbe0ffcaf2b109163aa6aa059cb57633cea4dae8427",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T15-mot-lettres.json': r'''
{
  "id": "ar-1-t1-u4-e02-x01",
  "type": "T15",
  "gabarit": "mot-lettres",
  "competence": "ar-ecriture-construire-mot",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِسْتَمِعْ وَرَكِّبِ الْكَلِمَةَ بِالْحُرُوفِ.",
      "feminin": "اِسْتَمِعِي وَرَكِّبِي الْكَلِمَةَ بِالْحُرُوفِ."
    }
  },
  "donnees": {
    "elements": [
      {
        "id": "e1",
        "texte": "ق"
      },
      {
        "id": "e2",
        "texte": "م"
      },
      {
        "id": "e3",
        "texte": "ر"
      },
      {
        "id": "e4",
        "texte": "ب"
      },
      {
        "id": "e5",
        "texte": "ن"
      }
    ],
    "ecoute": {
      "texte": "قَمَرٌ"
    },
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e2",
      "e3"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: قَمَرٌ تُكْتَبُ ق ثُمَّ م ثُمَّ ر.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: قَمَرٌ تُكْتَبُ ق ثُمَّ م ثُمَّ ر."
    },
    "indice": "الْكَلِمَةُ تَبْدَأُ بِحَرْفِ الْقَافِ.",
    "explication": "قَمَرٌ: ق ثُمَّ م ثُمَّ ر. الْحَرْفَانِ ب وَن لَيْسَا فِي الْكَلِمَةِ."
  },
  "empreinte": "sha256:cfc452d674e7548dfa3e7955041ddfd599b9e75093a345da70d595bcce909305",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T16-mot-syllabes.json': r'''
{
  "id": "fr-2-t1-u3-e01-x01",
  "type": "T16",
  "gabarit": "mot-syllabes",
  "competence": "fr-lecture-syllabes",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Écoute et construis le mot avec les syllabes."
  },
  "donnees": {
    "elements": [
      {
        "id": "e1",
        "texte": "to"
      },
      {
        "id": "e2",
        "texte": "ma"
      },
      {
        "id": "e3",
        "texte": "te"
      },
      {
        "id": "e4",
        "texte": "pi"
      },
      {
        "id": "e5",
        "texte": "lu"
      }
    ],
    "ecoute": {
      "texte": "tomate"
    },
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e2",
      "e3"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : to, ma, te. Le mot est « tomate ».",
    "indice": "Le mot commence par « to ».",
    "explication": "to + ma + te = tomate. Les syllabes « pi » et « lu » ne sont pas dans le mot."
  },
  "empreinte": "sha256:6ac4ef585315c90bf76fa032b4899199af19e8247fcf9f483007514eb807a25a",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T56-racine.json': r'''
{
  "id": "ar-4-t1-u3-e01-x01",
  "type": "T56",
  "gabarit": "racine-lettres",
  "competence": "ar-sarf-jadhr",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِسْحَبْ حُرُوفَ جَذْرِ الْكَلِمَةِ إِلَى أَمَاكِنِهَا.",
      "feminin": "اِسْحَبِي حُرُوفَ جَذْرِ الْكَلِمَةِ إِلَى أَمَاكِنِهَا."
    }
  },
  "donnees": {
    "mot": "مَكْتَبٌ",
    "forme": "racine",
    "emplacements": [
      {},
      {},
      {}
    ],
    "lettres": [
      {
        "id": "e1",
        "texte": "ك"
      },
      {
        "id": "e2",
        "texte": "ت"
      },
      {
        "id": "e3",
        "texte": "ب"
      },
      {
        "id": "e4",
        "texte": "م"
      },
      {
        "id": "e5",
        "texte": "ن"
      }
    ],
    "ecoute": {
      "texte": "مَكْتَبٌ"
    },
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e2",
      "e3"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: الْجَذْرُ هُوَ ك ت ب.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: الْجَذْرُ هُوَ ك ت ب."
    },
    "indice": "الْحُرُوفُ الْأَصْلِيَّةُ ثَلَاثَةٌ: اِبْحَثْ عَنْهَا فِي الْكَلِمَةِ.",
    "explication": "مَكْتَبٌ مِنَ الْجَذْرِ ك ت ب: كَتَبَ، كَاتِبٌ، كِتَابٌ."
  },
  "empreinte": "sha256:b149d952f7df34ae93cd04d3f00502153c33e842646f2bb41ff168c24f5a563e",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T56-scheme.json': r'''
{
  "id": "ar-4-t1-u3-e01-x02",
  "type": "T56",
  "gabarit": "scheme-lettres",
  "competence": "ar-sarf-wazn",
  "critere": "C2",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِسْحَبِ الْحُرُوفَ لِتُكَوِّنَ وَزْنَ الْكَلِمَةِ.",
      "feminin": "اِسْحَبِي الْحُرُوفَ لِتُكَوِّنِي وَزْنَ الْكَلِمَةِ."
    }
  },
  "donnees": {
    "mot": "كَاتِبٌ",
    "forme": "scheme",
    "emplacements": [
      {
        "haraka": "fatha"
      },
      {},
      {
        "haraka": "kasra"
      },
      {
        "haraka": "dammatan"
      }
    ],
    "lettres": [
      {
        "id": "e1",
        "texte": "ف"
      },
      {
        "id": "e2",
        "texte": "ع"
      },
      {
        "id": "e3",
        "texte": "ل"
      },
      {
        "id": "e4",
        "texte": "ا"
      },
      {
        "id": "e5",
        "texte": "م"
      },
      {
        "id": "e6",
        "texte": "ت"
      }
    ],
    "ecoute": {
      "texte": "كَاتِبٌ"
    },
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e4",
      "e2",
      "e3"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: كَاتِبٌ عَلَى وَزْنِ فَاعِلٌ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: كَاتِبٌ عَلَى وَزْنِ فَاعِلٌ."
    },
    "indice": "ضَعِ الْفَاءَ مَكَانَ الْحَرْفِ الْأَوَّلِ، وَالْعَيْنَ مَكَانَ الثَّانِي، وَاللَّامَ مَكَانَ الثَّالِثِ.",
    "explication": "كَاتِبٌ: ك فِي مَكَانِ ف، ا تَبْقَى، ت فِي مَكَانِ ع، ب فِي مَكَانِ ل. الْوَزْنُ هُوَ فَاعِلٌ."
  },
  "empreinte": "sha256:e82c62055a8077d5ed4b9279d8b3460ef5afab8230d80c0324bc1c68914b2705",
  "statut": "brouillon",
  "version": 1
}
''',
  'glisser-deposer/T62-frise.json': r'''
{
  "id": "fr-3-t1-u4-e01-x01",
  "type": "T62",
  "gabarit": "frise-journee",
  "competence": "fr-temps-journee",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Glisse chaque moment de la journée à sa place sur la frise."
  },
  "donnees": {
    "elements": [
      {
        "id": "e1",
        "texte": "Le réveil",
        "emoji": "⏰",
        "date": "7 h"
      },
      {
        "id": "e2",
        "texte": "L'école",
        "emoji": "🏫",
        "date": "8 h"
      },
      {
        "id": "e3",
        "texte": "Le déjeuner",
        "emoji": "🍽️",
        "date": "12 h"
      },
      {
        "id": "e4",
        "texte": "Le goûter",
        "emoji": "🍎",
        "date": "16 h"
      },
      {
        "id": "e5",
        "texte": "Le coucher",
        "emoji": "🌙",
        "date": "20 h"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "ordre": [
      "e1",
      "e2",
      "e3",
      "e4",
      "e5"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : le réveil, l'école, le déjeuner, le goûter, puis le coucher.",
    "indice": "Lis les heures : la journée commence à 7 h.",
    "explication": "L'ordre est : 7 h le réveil, 8 h l'école, 12 h le déjeuner, 16 h le goûter, 20 h le coucher."
  },
  "empreinte": "sha256:d0e0bc1b8a17f3b8bd27f8602b2a1a1c6c023cbe0f16ae6a1f9aeca9e84c0eae",
  "statut": "brouillon",
  "version": 1
}
''',
  'manipulables/T25-droite-numerique.json': r'''
{
  "id": "ma-1-t1-u2-e01-x01",
  "type": "T25",
  "gabarit": "droite-0-10",
  "competence": "ma-nombres-droite",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "ضَعِ الْعَلَامَةَ عَلَى الْعَدَدِ 7.",
      "feminin": "ضَعِي الْعَلَامَةَ عَلَى الْعَدَدِ 7."
    }
  },
  "donnees": {
    "min": 0,
    "max": 10,
    "pas": 1,
    "reperes": 5,
    "cible": 7,
    "sens": "gauche-droite"
  },
  "reponse": {
    "valeur": 7
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: الْعَدَدُ 7 يَبْعُدُ 7 خُطُوَاتٍ عَنِ الصِّفْرِ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: الْعَدَدُ 7 يَبْعُدُ 7 خُطُوَاتٍ عَنِ الصِّفْرِ."
    },
    "indice": "عُدَّ الْخُطُوَاتِ مِنَ الصِّفْرِ: 1، 2، 3، ثُمَّ وَاصِلْ.",
    "explication": "الْعَدَدُ 7 يَأْتِي بَعْدَ 5 بِخُطْوَتَيْنِ."
  },
  "empreinte": "sha256:14d3af162388ada80dad91e2334e11674a78940a8ac5a9c934dd8659f627976d",
  "statut": "brouillon",
  "version": 1
}
''',
  'manipulables/T27-blocs-base-10.json': r'''
{
  "id": "ma-2-t1-u1-e01-x01",
  "type": "T27",
  "gabarit": "blocs-dizaines-unites",
  "competence": "ma-numeration-dizaines-unites",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "مَثِّلِ الْعَدَدَ 34 بِالْعَشَرَاتِ وَالْوَحَدَاتِ.",
      "feminin": "مَثِّلِي الْعَدَدَ 34 بِالْعَشَرَاتِ وَالْوَحَدَاتِ."
    }
  },
  "donnees": {
    "cible": 34,
    "canonique": true
  },
  "reponse": {
    "dizaines": 3,
    "unites": 4
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 34 هُوَ 3 عَشَرَاتٍ وَ4 وَحَدَاتٍ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 34 هُوَ 3 عَشَرَاتٍ وَ4 وَحَدَاتٍ."
    },
    "indice": "رَقْمُ الْعَشَرَاتِ هُوَ 3: ضَعْ 3 قِطَعٍ مِنَ الْعَشَرَاتِ أَوَّلًا.",
    "explication": "34 هُوَ 3 عَشَرَاتٍ وَ4 وَحَدَاتٍ: ثَلَاثَةُ قُضْبَانٍ وَأَرْبَعُ مُكَعَّبَاتٍ."
  },
  "empreinte": "sha256:530dff7dbfa8785ebe6c0d6f2a217a87b43d5a7b280299534be75774fc5e1a64",
  "statut": "brouillon",
  "version": 1
}
''',
  'manipulables/T51-cadre-de-10.json': r'''
{
  "id": "ma-1-t1-u1-e01-x02",
  "type": "T51",
  "gabarit": "cadre-dix",
  "competence": "ma-nombres-cadre-dix",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "ضَعْ 7 قِطَعٍ فِي إِطَارِ الْعَشَرَةِ.",
      "feminin": "ضَعِي 7 قِطَعٍ فِي إِطَارِ الْعَشَرَةِ."
    }
  },
  "donnees": {
    "cible": 7
  },
  "reponse": {
    "jetons": 7
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 7 قِطَعٍ، وَتَبْقَى 3 خَانَاتٍ فَارِغَةٍ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 7 قِطَعٍ، وَتَبْقَى 3 خَانَاتٍ فَارِغَةٍ."
    },
    "indice": "اِمْلَأِ الصَّفَّ الْأَوَّلَ، ثُمَّ أَضِفْ قِطْعَتَيْنِ.",
    "explication": "7 = 5 + 2: صَفٌّ كَامِلٌ وَقِطْعَتَانِ."
  },
  "empreinte": "sha256:65d16edc516e73f489c260b7263bf54f3d4f895fb424037dd8913876a34b744c",
  "statut": "brouillon",
  "version": 1
}
''',
  'revision-jeux/T36-flashcards.json': r'''
{
  "id": "ar-1-t1-u2-e02-x01",
  "type": "T36",
  "gabarit": "flashcards-mots",
  "competence": "ar-vocabulaire-animaux",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِقْلِبِ الْبِطَاقَةَ وَقُلِ الْكَلِمَةَ.",
      "feminin": "اِقْلِبِي الْبِطَاقَةَ وَقُولِي الْكَلِمَةَ."
    }
  },
  "donnees": {
    "cartes": [
      {
        "id": "c1",
        "recto": {
          "emoji": "🐱"
        },
        "verso": {
          "texte": "قِطٌّ"
        },
        "ecoute": {
          "texte": "قِطٌّ"
        }
      },
      {
        "id": "c2",
        "recto": {
          "emoji": "🐶"
        },
        "verso": {
          "texte": "كَلْبٌ"
        },
        "ecoute": {
          "texte": "كَلْبٌ"
        }
      },
      {
        "id": "c3",
        "recto": {
          "emoji": "🐟"
        },
        "verso": {
          "texte": "سَمَكَةٌ"
        },
        "ecoute": {
          "texte": "سَمَكَةٌ"
        }
      },
      {
        "id": "c4",
        "recto": {
          "emoji": "🐦"
        },
        "verso": {
          "texte": "عُصْفُورٌ"
        },
        "ecoute": {
          "texte": "عُصْفُورٌ"
        }
      }
    ],
    "melanger": true
  },
  "reponse": {
    "cartes": [
      "c1",
      "c2",
      "c3",
      "c4"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "رَاجَعْتَ كُلَّ الْبِطَاقَاتِ.",
      "feminin": "رَاجَعْتِ كُلَّ الْبِطَاقَاتِ."
    },
    "indice": "اِقْلِبِ الْبِطَاقَةَ لِتَرَى الْكَلِمَةَ.",
    "explication": "قِطٌّ، كَلْبٌ، سَمَكَةٌ، عُصْفُورٌ."
  },
  "empreinte": "sha256:50c56a6f94acaad2afec1a450db05679af5b648952f94f000c0805f75d2a21a8",
  "statut": "brouillon",
  "version": 1
}
''',
  'revision-jeux/T37-memory.json': r'''
{
  "id": "fr-2-t1-u2-e01-x01",
  "type": "T37",
  "gabarit": "memory-mot-image",
  "competence": "fr-vocabulaire-fruits",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Retrouve chaque mot et son image."
  },
  "donnees": {
    "paires": [
      {
        "id": "p1",
        "a": {
          "texte": "pomme"
        },
        "b": {
          "emoji": "🍎"
        }
      },
      {
        "id": "p2",
        "a": {
          "texte": "banane"
        },
        "b": {
          "emoji": "🍌"
        }
      },
      {
        "id": "p3",
        "a": {
          "texte": "fraise"
        },
        "b": {
          "emoji": "🍓"
        }
      },
      {
        "id": "p4",
        "a": {
          "texte": "poire"
        },
        "b": {
          "emoji": "🍐"
        }
      },
      {
        "id": "p5",
        "a": {
          "texte": "orange"
        },
        "b": {
          "emoji": "🍊"
        }
      },
      {
        "id": "p6",
        "a": {
          "texte": "cerise"
        },
        "b": {
          "emoji": "🍒"
        }
      }
    ],
    "essais_max": 15,
    "melanger": true
  },
  "reponse": {
    "paires": [
      "p1",
      "p2",
      "p3",
      "p4",
      "p5",
      "p6"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : toutes les paires sont trouvées.",
    "indice": "Retiens la place des cartes que tu retournes.",
    "explication": "Toutes les paires sont trouvées, avec beaucoup d'essais : pomme, banane, fraise, poire, orange, cerise."
  },
  "empreinte": "sha256:6614e95f2e93fc8b4a6d0befbd8e39439db0ce8a667a84d05840c296cdec01cf",
  "statut": "brouillon",
  "version": 1
}
''',
  'revision-jeux/T38-mots-meles-fr.json': r'''
{
  "id": "fr-3-t1-u1-e02-x01",
  "type": "T38",
  "gabarit": "mots-meles-carre",
  "competence": "fr-lecture-mots",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Trouve les trois mots cachés dans la grille."
  },
  "donnees": {
    "grille": [
      "CHATE",
      "SIBOR",
      "OLUNE",
      "LAMIP",
      "ETRAN"
    ],
    "mots": [
      {
        "id": "m1",
        "texte": "CHAT",
        "ligne": 0,
        "colonne": 0,
        "direction": "ligne"
      },
      {
        "id": "m2",
        "texte": "LUNE",
        "ligne": 2,
        "colonne": 1,
        "direction": "ligne"
      },
      {
        "id": "m3",
        "texte": "SOL",
        "ligne": 1,
        "colonne": 0,
        "direction": "colonne"
      }
    ]
  },
  "reponse": {
    "mots": [
      "m1",
      "m2",
      "m3"
    ]
  },
  "feedbacks": {
    "reussite": "Oui : chat, lune et sol sont trouvés.",
    "indice": "Lis les lignes de gauche à droite et les colonnes de haut en bas.",
    "explication": "CHAT sur la première ligne, LUNE sur la troisième, SOL dans la première colonne."
  },
  "empreinte": "sha256:9cf9ae842f1480da40ed9769a3e090a2daf753ec38aa9006521709c2c1e0ea94",
  "statut": "brouillon",
  "version": 1
}
''',
  'revision-jeux/T38-mots-meles.json': r'''
{
  "id": "ar-3-t1-u1-e02-x01",
  "type": "T38",
  "gabarit": "mots-meles-carre",
  "competence": "ar-lecture-mots",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِبْحَثْ عَنِ الْكَلِمَاتِ الثَّلَاثِ فِي الشَّبَكَةِ.",
      "feminin": "اِبْحَثِي عَنِ الْكَلِمَاتِ الثَّلَاثِ فِي الشَّبَكَةِ."
    }
  },
  "donnees": {
    "grille": [
      "تملقب",
      "كسردا",
      "تبحدم",
      "ايرزك",
      "بسعلن"
    ],
    "mots": [
      {
        "id": "m1",
        "texte": "قَلَمٌ",
        "ligne": 0,
        "colonne": 3,
        "direction": "ligne"
      },
      {
        "id": "m2",
        "texte": "دَرْسٌ",
        "ligne": 1,
        "colonne": 3,
        "direction": "ligne"
      },
      {
        "id": "m3",
        "texte": "كِتَابٌ",
        "ligne": 1,
        "colonne": 0,
        "direction": "colonne"
      }
    ],
    "sens": "droite-gauche"
  },
  "reponse": {
    "mots": [
      "m1",
      "m2",
      "m3"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "وَجَدْتَ الْكَلِمَاتِ الثَّلَاثَ.",
      "feminin": "وَجَدْتِ الْكَلِمَاتِ الثَّلَاثَ."
    },
    "indice": "اِقْرَأِ السُّطُورَ مِنَ الْيَمِينِ إِلَى الْيَسَارِ.",
    "explication": "قَلَمٌ فِي السَّطْرِ الْأَوَّلِ، دَرْسٌ فِي الثَّانِي، كِتَابٌ فِي الْعَمُودِ الْأَوَّلِ."
  },
  "empreinte": "sha256:ee876f04fc5c9d600676b3cd7cb18e51f2087b43089a575c74ce8463a122d907",
  "statut": "brouillon",
  "version": 1
}
''',
  'saisie-numerique/T22-probleme.json': r'''
{
  "id": "ma-2-t1-u2-e01-x01",
  "type": "T22",
  "gabarit": "probleme-court",
  "competence": "ma-problemes-addition",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِقْرَأْ وَاكْتُبِ الْجَوَابَ.",
      "feminin": "اِقْرَئِي وَاكْتُبِي الْجَوَابَ."
    }
  },
  "donnees": {
    "texte": "فِي السَّلَّةِ 12 تُفَّاحَةً وَ15 بُرْتُقَالَةً. كَمْ ثَمَرَةً فِي السَّلَّةِ؟",
    "emoji": "🧺",
    "chiffres_max": 3
  },
  "reponse": {
    "valeur": 27
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 12 زَائِدُ 15 يُسَاوِي 27.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 12 زَائِدُ 15 يُسَاوِي 27."
    },
    "indice": "اِجْمَعْ عَدَدَ التُّفَّاحِ وَعَدَدَ الْبُرْتُقَالِ.",
    "explication": "فِي السَّلَّةِ 27 ثَمَرَةً: 12 زَائِدُ 15 يُسَاوِي 27."
  },
  "empreinte": "sha256:6e7a01bce0dc1b9668e483123df725baafdcc4ba9cd397c141e46bb2366ac250",
  "statut": "brouillon",
  "version": 1
}
''',
  'saisie-numerique/T48-addition-posee.json': r'''
{
  "id": "ma-2-t1-u3-e01-x01",
  "type": "T48",
  "gabarit": "addition-posee",
  "competence": "ma-calcul-addition-posee",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "أَنْجِزِ الْعَمَلِيَّةَ.",
      "feminin": "أَنْجِزِي الْعَمَلِيَّةَ."
    }
  },
  "donnees": {
    "a": 34,
    "b": 25,
    "operation": "addition"
  },
  "reponse": {
    "valeur": 59
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 34 زَائِدُ 25 يُسَاوِي 59.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 34 زَائِدُ 25 يُسَاوِي 59."
    },
    "indice": "اِبْدَأْ بِالْوَحَدَاتِ: 4 زَائِدُ 5.",
    "explication": "الْوَحَدَاتُ: 4 زَائِدُ 5 يُسَاوِي 9. الْعَشَرَاتُ: 3 زَائِدُ 2 يُسَاوِي 5. النَّتِيجَةُ 59."
  },
  "empreinte": "sha256:0d888b0a99945fd171c142d51278651fd7108f0bfcb69b40f7b32fa95cb944a8",
  "statut": "brouillon",
  "version": 1
}
''',
  'saisie-numerique/T48-addition-retenue.json': r'''
{
  "id": "ma-2-t1-u3-e02-x01",
  "type": "T48",
  "gabarit": "addition-posee",
  "competence": "ma-calcul-addition-posee",
  "critere": "C2",
  "niveau_critere": "perfectionnement",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "أَنْجِزِ الْعَمَلِيَّةَ مَعَ الْحَمْلِ.",
      "feminin": "أَنْجِزِي الْعَمَلِيَّةَ مَعَ الْحَمْلِ."
    }
  },
  "donnees": {
    "a": 47,
    "b": 36,
    "operation": "addition",
    "retenues": true
  },
  "reponse": {
    "valeur": 83
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 47 زَائِدُ 36 يُسَاوِي 83.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 47 زَائِدُ 36 يُسَاوِي 83."
    },
    "indice": "7 زَائِدُ 6 يُسَاوِي 13: نَكْتُبُ 3 وَنَحْمِلُ 1 إِلَى الْعَشَرَاتِ.",
    "explication": "الْوَحَدَاتُ: 7 زَائِدُ 6 يُسَاوِي 13، نَكْتُبُ 3 وَنَحْمِلُ 1. الْعَشَرَاتُ: 4 زَائِدُ 3 زَائِدُ 1 يُسَاوِي 8. النَّتِيجَةُ 83."
  },
  "empreinte": "sha256:103e46c4bb4ebf18d3213b79b2df3d9e5afa7a024bc7184fdbde4d61bd0358b1",
  "statut": "brouillon",
  "version": 1
}
''',
  'saisie-numerique/T48-soustraction-emprunt.json': r'''
{
  "id": "ma-2-t1-u3-e02-x02",
  "type": "T48",
  "gabarit": "soustraction-posee",
  "competence": "ma-calcul-soustraction-posee",
  "critere": "C2",
  "niveau_critere": "perfectionnement",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "أَنْجِزِ الْعَمَلِيَّةَ مَعَ الِاسْتِعَارَةِ.",
      "feminin": "أَنْجِزِي الْعَمَلِيَّةَ مَعَ الِاسْتِعَارَةِ."
    }
  },
  "donnees": {
    "a": 62,
    "b": 28,
    "operation": "soustraction",
    "retenues": true
  },
  "reponse": {
    "valeur": 34
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 62 نَاقِصُ 28 يُسَاوِي 34.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 62 نَاقِصُ 28 يُسَاوِي 34."
    },
    "indice": "2 أَصْغَرُ مِنْ 8: نَسْتَعِيرُ عَشَرَةً مِنَ الْعَشَرَاتِ.",
    "explication": "الْوَحَدَاتُ: 12 نَاقِصُ 8 يُسَاوِي 4 بَعْدَ الِاسْتِعَارَةِ. الْعَشَرَاتُ: 5 نَاقِصُ 2 يُسَاوِي 3. النَّتِيجَةُ 34."
  },
  "empreinte": "sha256:f2626d74e16b22b62ccab801a79a82ac47dcbcd322d87b18c216f956f135ea40",
  "statut": "brouillon",
  "version": 1
}
''',
  'saisie-numerique/T48-soustraction-posee.json': r'''
{
  "id": "ma-2-t1-u3-e01-x02",
  "type": "T48",
  "gabarit": "soustraction-posee",
  "competence": "ma-calcul-soustraction-posee",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "أَنْجِزِ الْعَمَلِيَّةَ.",
      "feminin": "أَنْجِزِي الْعَمَلِيَّةَ."
    }
  },
  "donnees": {
    "a": 57,
    "b": 23,
    "operation": "soustraction",
    "retenues": false
  },
  "reponse": {
    "valeur": 34
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: 57 نَاقِصُ 23 يُسَاوِي 34.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: 57 نَاقِصُ 23 يُسَاوِي 34."
    },
    "indice": "اِبْدَأْ بِالْوَحَدَاتِ: 7 نَاقِصُ 3.",
    "explication": "الْوَحَدَاتُ: 7 نَاقِصُ 3 يُسَاوِي 4. الْعَشَرَاتُ: 5 نَاقِصُ 2 يُسَاوِي 3. النَّتِيجَةُ 34."
  },
  "empreinte": "sha256:6a613897f8010d9b7b517f80440961c47e3754448e37dd7d821240f6679de5bb",
  "statut": "brouillon",
  "version": 1
}
''',
  'scene-image/T08-hot-spot.json': r'''
{
  "id": "ev-1-t1-u1-e01-x01",
  "type": "T08",
  "gabarit": "hot-spot-emoji",
  "competence": "ev-ciel-soleil",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِلْمِسِ الشَّمْسَ فِي الصُّورَةِ.",
      "feminin": "اِلْمِسِي الشَّمْسَ فِي الصُّورَةِ."
    }
  },
  "donnees": {
    "scene": {
      "elements": [
        {
          "emoji": "☀️",
          "x": 0.2,
          "y": 0.22,
          "h": 0.25
        },
        {
          "emoji": "☁️",
          "x": 0.65,
          "y": 0.2,
          "h": 0.22
        },
        {
          "emoji": "🌳",
          "x": 0.25,
          "y": 0.7,
          "h": 0.3
        },
        {
          "emoji": "🏠",
          "x": 0.7,
          "y": 0.7,
          "h": 0.3
        }
      ]
    },
    "zones": [
      {
        "id": "z1",
        "x": 0.05,
        "y": 0.05,
        "l": 0.3,
        "h": 0.35
      },
      {
        "id": "z2",
        "x": 0.5,
        "y": 0.05,
        "l": 0.3,
        "h": 0.3
      },
      {
        "id": "z3",
        "x": 0.05,
        "y": 0.5,
        "l": 0.4,
        "h": 0.45
      },
      {
        "id": "z4",
        "x": 0.5,
        "y": 0.5,
        "l": 0.4,
        "h": 0.45
      }
    ],
    "plusieurs": false
  },
  "reponse": {
    "zones": [
      "z1"
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: هَذِهِ هِيَ الشَّمْسُ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: هَذِهِ هِيَ الشَّمْسُ."
    },
    "indice": "الشَّمْسُ فِي السَّمَاءِ، وَهِيَ صَفْرَاءُ وَمُضِيئَةٌ.",
    "explication": "الشَّمْسُ فِي أَعْلَى الصُّورَةِ، بِجَانِبِ الْغَيْمَةِ."
  },
  "empreinte": "sha256:1e24f1c3aa368df3083b0f867f8b5cf95c1641b5466e6c610e5440e28546c047",
  "statut": "brouillon",
  "version": 1
}
''',
  'scene-image/T47-etiqueter-schema.json': r'''
{
  "id": "fr-3-t1-u3-e01-x01",
  "type": "T47",
  "gabarit": "schema-formes",
  "competence": "fr-sciences-plante",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Place chaque étiquette sur la bonne partie de la plante."
  },
  "donnees": {
    "scene": {
      "elements": [
        {
          "forme": "rectangle",
          "couleur": "amber",
          "x": 0.47,
          "y": 0.35,
          "l": 0.06,
          "h": 0.45
        },
        {
          "forme": "cercle",
          "couleur": "coral",
          "x": 0.4,
          "y": 0.12,
          "l": 0.2,
          "h": 0.25
        },
        {
          "forme": "triangle",
          "couleur": "olive",
          "x": 0.25,
          "y": 0.45,
          "l": 0.22,
          "h": 0.14
        },
        {
          "forme": "triangle",
          "couleur": "olive",
          "x": 0.53,
          "y": 0.55,
          "l": 0.22,
          "h": 0.14
        },
        {
          "forme": "rectangle",
          "couleur": "line",
          "x": 0.35,
          "y": 0.8,
          "l": 0.3,
          "h": 0.15
        }
      ]
    },
    "zones": [
      {
        "id": "z1",
        "x": 0.36,
        "y": 0.08,
        "l": 0.28,
        "h": 0.3,
        "libelle": "le haut de la plante"
      },
      {
        "id": "z2",
        "x": 0.22,
        "y": 0.42,
        "l": 0.26,
        "h": 0.2,
        "libelle": "la partie verte à gauche"
      },
      {
        "id": "z3",
        "x": 0.4,
        "y": 0.6,
        "l": 0.2,
        "h": 0.18,
        "libelle": "la partie fine au milieu"
      },
      {
        "id": "z4",
        "x": 0.33,
        "y": 0.8,
        "l": 0.34,
        "h": 0.17,
        "libelle": "la partie sous la terre"
      }
    ],
    "etiquettes": [
      {
        "id": "e1",
        "texte": "la fleur"
      },
      {
        "id": "e2",
        "texte": "la feuille"
      },
      {
        "id": "e3",
        "texte": "la tige"
      },
      {
        "id": "e4",
        "texte": "la racine"
      },
      {
        "id": "e5",
        "texte": "le fruit"
      }
    ],
    "melanger": true
  },
  "reponse": {
    "placements": [
      {
        "zone": "z1",
        "etiquette": "e1"
      },
      {
        "zone": "z2",
        "etiquette": "e2"
      },
      {
        "zone": "z3",
        "etiquette": "e3"
      },
      {
        "zone": "z4",
        "etiquette": "e4"
      }
    ]
  },
  "feedbacks": {
    "reussite": "Oui : la fleur en haut, la feuille, la tige au milieu et la racine sous la terre.",
    "indice": "La racine est sous la terre, la fleur tout en haut.",
    "explication": "De haut en bas : la fleur, la feuille sur le côté, la tige au milieu, la racine sous la terre. Il n'y a pas de fruit."
  },
  "empreinte": "sha256:29056a47d873bb2aaefbb4419d1602526401604f69aebc3386bf5e7cc1561c18",
  "statut": "brouillon",
  "version": 1
}
''',
  'texte/T07-toucher-mots-fr.json': r'''
{
  "id": "fr-3-t1-u2-e02-x01",
  "type": "T07",
  "gabarit": "toucher-mots",
  "competence": "fr-grammaire-noms",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Touche les deux noms de la phrase."
  },
  "donnees": {
    "texte": "Le chat dort sur le canapé.",
    "plusieurs": true
  },
  "reponse": {
    "mots": [
      1,
      5
    ]
  },
  "feedbacks": {
    "reussite": "Oui : chat et canapé sont des noms.",
    "indice": "Un nom est souvent précédé de le, la, un ou une.",
    "explication": "Les noms sont chat et canapé. Le verbe est dort."
  },
  "empreinte": "sha256:1de8038c0e600f8df1dc5927eeceea1c132d2192da1eb44137eeced68b58e719",
  "statut": "brouillon",
  "version": 1
}
''',
  'texte/T07-toucher-mots.json': r'''
{
  "id": "ar-3-t1-u2-e01-x01",
  "type": "T07",
  "gabarit": "toucher-mots",
  "competence": "ar-nahw-fiil",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِلْمِسِ الْفِعْلَ فِي الْجُمْلَةِ.",
      "feminin": "اِلْمِسِي الْفِعْلَ فِي الْجُمْلَةِ."
    }
  },
  "donnees": {
    "texte": "يَقْرَأُ الْوَلَدُ قِصَّةً جَمِيلَةً.",
    "plusieurs": false
  },
  "reponse": {
    "mots": [
      0
    ]
  },
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: الْفِعْلُ هُوَ يَقْرَأُ.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: الْفِعْلُ هُوَ يَقْرَأُ."
    },
    "indice": "الْفِعْلُ يَدُلُّ عَلَى عَمَلٍ: مَاذَا يَفْعَلُ الْوَلَدُ؟",
    "explication": "يَقْرَأُ فِعْلٌ، وَالْوَلَدُ اِسْمٌ."
  },
  "empreinte": "sha256:36c1b261e0a81efe069a8d2e462502fd6766d728c594e327c1844b6b5401db56",
  "statut": "brouillon",
  "version": 1
}
''',
  'texte/T17-dictee-fr.json': r'''
{
  "id": "fr-2-t1-u1-e01-x01",
  "type": "T17",
  "gabarit": "dictee-mot",
  "competence": "fr-orthographe-dictee",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "fr",
  "consigne": {
    "texte": "Écoute et écris le mot."
  },
  "donnees": {
    "ecoute": {
      "texte": "poule"
    },
    "emoji": "🐔",
    "casse": "minuscules"
  },
  "reponse": {
    "texte": "poule"
  },
  "normalisation": [
    "casse",
    "espaces"
  ],
  "feedbacks": {
    "reussite": "Oui : poule s'écrit p, o, u, l, e.",
    "indice": "Le mot commence par la lettre p.",
    "explication": "Le mot est poule."
  },
  "empreinte": "sha256:0ea65c28a1486fc9e851b3bdc4bd903fbcc477b1f47bc3e4853d00eb1b37ca6f",
  "statut": "brouillon",
  "version": 1
}
''',
  'texte/T17-dictee.json': r'''
{
  "id": "ar-1-t1-u3-e01-x01",
  "type": "T17",
  "gabarit": "dictee-mot",
  "competence": "ar-ecriture-dictee",
  "critere": "C1",
  "niveau_critere": "minimal",
  "langue": "ar",
  "consigne": {
    "texte": {
      "masculin": "اِسْتَمِعْ وَاكْتُبِ الْكَلِمَةَ.",
      "feminin": "اِسْتَمِعِي وَاكْتُبِي الْكَلِمَةَ."
    }
  },
  "donnees": {
    "ecoute": {
      "texte": "قَلَمٌ"
    },
    "emoji": "✏️",
    "harakat": false,
    "clavier": "reduit",
    "lettres": "قلمبنترد"
  },
  "reponse": {
    "texte": "قَلَمٌ"
  },
  "normalisation": [
    "harakat_ignorees"
  ],
  "feedbacks": {
    "reussite": {
      "masculin": "إِجَابَتُكَ صَحِيحَةٌ: قَلَمٌ تُكْتَبُ ق ثُمَّ ل ثُمَّ م.",
      "feminin": "إِجَابَتُكِ صَحِيحَةٌ: قَلَمٌ تُكْتَبُ ق ثُمَّ ل ثُمَّ م."
    },
    "indice": "الْكَلِمَةُ تَبْدَأُ بِحَرْفِ الْقَافِ.",
    "explication": "قَلَمٌ: ق ثُمَّ ل ثُمَّ م."
  },
  "empreinte": "sha256:ec08cf6a5ffa0a51dc89da09eb9389bdf5124f34175b43c6dbdce1fd29f034df",
  "statut": "brouillon",
  "version": 1
}
''',
};
