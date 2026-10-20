import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import '../choix/outils_choix.dart';

/// Exemple réel de schema/exemples/grille-graphiques/.
Map<String, dynamic> exempleGrille(String fichier) =>
    jsonDecode(exemplesEduContent['grille-graphiques/$fichier']!)
        as Map<String, dynamic>;

/// T31 en français : la plus petite valeur.
Map<String, dynamic> t31Moins() => exerciceChoix(
  type: 'T31',
  langue: 'fr',
  gabarit: 'graphique-barres-lecture',
  competence: 'donnees-lire-graphique',
  niveau: 4,
  consigne: 'Touche le sport le moins choisi.',
  donnees: {
    'series': [
      {'id': 's1', 'texte': 'foot', 'valeur': 8},
      {'id': 's2', 'texte': 'nage', 'valeur': 3},
      {'id': 's3', 'texte': 'vélo', 'valeur': 5},
    ],
    'maximum': 10,
    'question': 'moins',
  },
  reponse: {'serie': 's2'},
  reussite: 'Oui : la natation, 3 élèves, est la barre la plus basse.',
  indice: 'Cherche la barre la plus basse.',
  explication: 'La natation : 3 élèves, la barre la plus basse.',
);

/// T32 en français : deux barres.
Map<String, dynamic> t32Francais() => exerciceChoix(
  type: 'T32',
  langue: 'fr',
  gabarit: 'graphique-barres-construction',
  competence: 'donnees-construire-graphique',
  niveau: 4,
  consigne: 'Dessine les barres du tableau.',
  donnees: {
    'series': [
      {'id': 's1', 'texte': 'chats', 'valeur': 4},
      {'id': 's2', 'texte': 'chiens', 'valeur': 2},
    ],
    'maximum': 5,
  },
  reponse: {
    'valeurs': [
      {'serie': 's1', 'valeur': 4},
      {'serie': 's2', 'valeur': 2},
    ],
  },
  reussite: 'Oui : 4 chats et 2 chiens.',
  indice: 'Chaque carreau vaut un animal.',
  explication: 'Chats 4, chiens 2.',
);

/// T33 en français : quadrillage 3 × 4, deux cases données.
Map<String, dynamic> t33Francais() => exerciceChoix(
  type: 'T33',
  langue: 'fr',
  gabarit: 'symetrie-quadrillage',
  competence: 'geometrie-symetrie',
  niveau: 4,
  consigne: 'Complète la figure par symétrie.',
  donnees: {
    'lignes': 3,
    'colonnes': 4,
    'cases': [
      [0, 0],
      [1, 1],
    ],
  },
  reponse: {
    'cases': [
      [0, 3],
      [1, 2],
    ],
  },
  reussite: 'Oui : la figure est symétrique.',
  indice: 'Chaque case a sa jumelle de l\'autre côté de l\'axe.',
  explication: 'Le symétrique est l\'image dans le miroir.',
);

/// T60 en français : grille 3 × 3 sans obstacle, du coin haut gauche au
/// milieu droit (plusieurs chemins justes).
Map<String, dynamic> t60Francais() => exerciceChoix(
  type: 'T60',
  langue: 'fr',
  gabarit: 'codage-chemin',
  competence: 'espace-codage',
  niveau: 3,
  consigne: 'Mène la fleur au puits avec les flèches, puis joue le programme.',
  donnees: {
    'lignes': 3,
    'colonnes': 3,
    'depart': {'ligne': 0, 'colonne': 0},
    'but': {'ligne': 1, 'colonne': 2},
  },
  reponse: {
    'chemin': ['bas', 'droite', 'droite'],
  },
  reussite: 'Oui : la fleur est arrivée au puits.',
  indice: 'Le puits est à droite, une ligne plus bas.',
  explication: 'Bas, droite, droite : la fleur arrive au puits.',
);
