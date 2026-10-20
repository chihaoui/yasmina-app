import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/mesure-temps/.
Map<String, dynamic> exempleMesure(String fichier) =>
    jsonDecode(exemplesEduContent['mesure-temps/$fichier']!)
        as Map<String, dynamic>;

/// T28 en français, pas de 15 minutes, départ 9 h 00, cible 10 h 15.
Map<String, dynamic> t28Francais() => exerciceChoix(
  type: 'T28',
  langue: 'fr',
  gabarit: 'horloge-aiguilles',
  competence: 'mesure-heure',
  niveau: 2,
  consigne: 'Règle l\'horloge sur 10 h 15.',
  donnees: {
    'pas': 15,
    'depart': {'heure': 9, 'minutes': 0},
  },
  reponse: {'heure': 10, 'minutes': 15},
  reussite: 'Oui : il est 10 h 15.',
  indice: 'La petite aiguille montre les heures, la grande les minutes.',
  explication: 'À 10 h 15, la grande aiguille est sur le 3 et la petite juste après le 10.',
);

/// T30 en français : un objet de 5 cm qui part de 2 cm.
Map<String, dynamic> t30Francais() => exerciceChoix(
  type: 'T30',
  langue: 'fr',
  gabarit: 'regle-objet',
  competence: 'mesure-longueur',
  niveau: 3,
  consigne: 'Quelle est la longueur du trombone en cm ?',
  donnees: {
    'longueur_regle': 10,
    'objet': {'emoji': '📎', 'longueur': 5, 'depart': 2},
    'unite': 'cm',
  },
  reponse: {'valeur': 5},
  reussite: 'Oui : de 2 à 7, le trombone mesure 5 cm.',
  indice: 'Le trombone ne part pas de zéro : compte de 2 à 7.',
  explication: '7 moins 2 égale 5 : le trombone mesure 5 cm.',
);
