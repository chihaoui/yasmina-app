import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';

/// Les 5 matières, avec le niveau à partir duquel chacune est enseignée
/// (arabe, maths et éveil dès la 1re, français en 2e, anglais en 4e).
enum Matiere {
  arabe('ar', 'arabe', niveauMin: 1, icone: Icons.menu_book_rounded),
  maths('ma', 'maths', niveauMin: 1, icone: Icons.calculate_rounded),
  eveil('ev', 'eveil', niveauMin: 1, icone: Icons.eco_rounded),
  francais('fr', 'francais', niveauMin: 2, icone: Icons.translate_rounded),
  anglais('en', 'anglais', niveauMin: 4, icone: Icons.language_rounded);

  const Matiere(
    this.code,
    this.cle, {
    required this.niveauMin,
    required this.icone,
  });

  /// Code court (routes, ids de contenu : `ar-1-t1-u1-e01`).
  final String code;

  /// Valeur du champ `etape.matiere` du schéma.
  final String cle;

  /// Premier niveau (1 à 6) où la matière est proposée.
  final int niveauMin;

  /// Icône provisoire de la carte de matière.
  final IconData icone;

  /// Langue des exercices de la matière (CLAUDE.md §5 : maths et éveil en
  /// arabe).
  String get langue => switch (this) {
    arabe || maths || eveil => 'ar',
    francais => 'fr',
    anglais => 'en',
  };

  static Matiere? parCode(String code) =>
      values.where((m) => m.code == code).firstOrNull;

  /// Matières proposées à un enfant de ce niveau, dans l'ordre d'affichage.
  static List<Matiere> pourNiveau(int niveau) =>
      values.where((m) => m.niveauMin <= niveau).toList();

  /// Nom dans la langue de l'interface.
  String nom(AppLocalizations textes) => switch (this) {
    arabe => textes.matiereArabe,
    maths => textes.matiereMaths,
    eveil => textes.matiereEveil,
    francais => textes.matiereFrancais,
    anglais => textes.matiereAnglais,
  };

  /// Pastel de la carte (identique dans les deux thèmes). Français et
  /// anglais : couleur à définir (design system), tile en attendant.
  Color couleur(CouleursYasmina c) => switch (this) {
    arabe => c.subjectAr,
    maths => c.subjectMa,
    eveil => c.subjectEv,
    francais || anglais => c.tile,
  };
}
