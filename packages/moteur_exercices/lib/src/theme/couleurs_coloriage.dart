import 'package:flutter/material.dart';

/// Couleurs de coloriage de T54 Écoute et colorie (docs/moteurs/scene-image.md
/// §14) : des vraies couleurs, parce que « rouge » doit être rouge. Elles
/// vivent dans le thème (seul endroit autorisé pour une couleur en dur,
/// CLAUDE.md §8), avec leur nom dans les trois langues des exercices.
abstract final class CouleursColoriage {
  /// Identifiants acceptés par le schéma (`donnees.couleurs`).
  static const ids = [
    'red',
    'blue',
    'green',
    'yellow',
    'orange',
    'purple',
    'brown',
    'black',
    'white',
    'pink',
  ];

  static const _couleurs = <String, Color>{
    'red': Color(0xFFE5484D),
    'blue': Color(0xFF3B82F6),
    'green': Color(0xFF22A35A),
    'yellow': Color(0xFFF5C518),
    'orange': Color(0xFFF0883E),
    'purple': Color(0xFF8B5CF6),
    'brown': Color(0xFF8D5A3C),
    'black': Color(0xFF222222),
    'white': Color(0xFFFFFFFF),
    'pink': Color(0xFFEC6AA7),
  };

  static const _noms = <String, (String, String, String)>{
    // (anglais, français, arabe en brouillon, harakat à relire).
    'red': ('red', 'rouge', 'أَحْمَرُ'),
    'blue': ('blue', 'bleu', 'أَزْرَقُ'),
    'green': ('green', 'vert', 'أَخْضَرُ'),
    'yellow': ('yellow', 'jaune', 'أَصْفَرُ'),
    'orange': ('orange', 'orange', 'بُرْتُقَالِيٌّ'),
    'purple': ('purple', 'violet', 'بَنَفْسَجِيٌّ'),
    'brown': ('brown', 'marron', 'بُنِّيٌّ'),
    'black': ('black', 'noir', 'أَسْوَدُ'),
    'white': ('white', 'blanc', 'أَبْيَضُ'),
    'pink': ('pink', 'rose', 'وَرْدِيٌّ'),
  };

  /// La couleur de [id] (`line` du thème si l'id est inconnu).
  static Color de(String id, {required Color inconnue}) =>
      _couleurs[id] ?? inconnue;

  /// Le nom de la couleur [id] dans [langue].
  static String nom(String id, String langue) {
    final noms = _noms[id];
    if (noms == null) return id;
    return switch (langue) {
      'ar' => noms.$3,
      'fr' => noms.$2,
      _ => noms.$1,
    };
  }

  /// Tous les noms arabes (test des conventions d'écriture).
  static List<String> get nomsArabes => [for (final n in _noms.values) n.$3];
}
