/// Harakat (tanwīn, fatha, damma, kasra, shadda, sukūn) et alif suscrit.
final _harakat = RegExp('[ً-ْٰ]');

/// Le texte sans ses harakat : l'espace parent s'écrit sans harakat
/// (décision 27), les textes de l'interface enfant les portent toutes.
/// Jamais appliqué à un texte stocké ni à un texte d'exercice.
String sansHarakat(String texte) => texte.replaceAll(_harakat, '');
