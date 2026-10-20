import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/simulateur/.
Map<String, dynamic> exempleSimulateur(String fichier) =>
    jsonDecode(exemplesEduContent['simulateur/$fichier']!)
        as Map<String, dynamic>;

/// T57 en français, sans décor : un aimant attire ou non.
Map<String, dynamic> t57Francais() => exerciceChoix(
  type: 'T57',
  langue: 'fr',
  gabarit: 'simulateur-aimant',
  competence: 'aimant',
  niveau: 3,
  consigne: 'Prédis : l\'aimant attire ou non ? Puis observe.',
  donnees: {
    'decor': 'aucun',
    'issues': {
      'a': {'libelle': 'attiré'},
      'b': {'libelle': 'fond'},
    },
    'objets': [
      {'id': 'o1', 'emoji': '📎', 'libelle': 'trombone'},
      {'id': 'o2', 'emoji': '🧽', 'libelle': 'éponge'},
    ],
  },
  reponse: {
    'resultats': [
      {'objet': 'o1', 'issue': 'a'},
      {'objet': 'o2', 'issue': 'b'},
    ],
  },
  reussite: 'Oui : le trombone est attiré, pas l\'éponge.',
  indice: 'L\'aimant attire le fer.',
  explication:
      'Le trombone est en fer : il est attiré. L\'éponge reste au fond.',
);
