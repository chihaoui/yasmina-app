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

/// T49 en français, fraction exacte exigée : 1/4 + 2/4 = 3/4.
Map<String, dynamic> t49Exacte() => exerciceChoix(
  type: 'T49',
  langue: 'fr',
  gabarit: 'fraction-somme',
  competence: 'fractions-addition',
  niveau: 5,
  consigne: 'Calcule et écris la fraction (sans simplifier ni agrandir).',
  donnees: {
    'termes': [
      {'numerateur': 1, 'denominateur': 4},
      {'numerateur': 2, 'denominateur': 4},
    ],
    'operation': 'addition',
    'equivalentes': false,
  },
  reponse: {'numerateur': 3, 'denominateur': 4},
  reussite: 'Oui : 1/4 + 2/4 = 3/4.',
  indice: 'Même dénominateur : additionne seulement les numérateurs.',
  explication: '1 + 2 = 3, le dénominateur reste 4 : 3/4.',
);

/// T50 en français : trois additions jusqu'à 10, sans chronomètre.
Map<String, dynamic> t50SansChrono() => exerciceChoix(
  type: 'T50',
  langue: 'fr',
  gabarit: 'fluidite-additions',
  competence: 'calcul-additions',
  niveau: 1,
  consigne: 'Réponds aux additions.',
  donnees: {'exercice': 'addition', 'max': 10, 'chrono': false, 'questions': 3},
  reponse: {'questions_min': 1},
  reussite: 'Bravo pour l\'entraînement.',
  indice: 'Compte sur tes doigts.',
  explication: 'Chaque addition a une seule bonne réponse.',
);

/// T63 en français, le sac à droite : 8 à gauche, 3 et 3 à droite, sac 2.
Map<String, dynamic> t63SacADroite() => exerciceChoix(
  type: 'T63',
  langue: 'fr',
  gabarit: 'balance-sac',
  competence: 'egalite-balance',
  niveau: 4,
  consigne: 'Quelle est la masse du sac pour équilibrer la balance ?',
  donnees: {
    'gauche': [8],
    'droite': [3, 3],
    'sac': 'droite',
  },
  reponse: {'valeur': 2},
  reussite: 'Oui : le sac pèse 2.',
  indice: 'À gauche 8, à droite 3 + 3 = 6 et le sac.',
  explication: '8 moins 6 égale 2 : le sac pèse 2.',
);
