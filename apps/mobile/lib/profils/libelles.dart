import '../l10n/app_localizations.dart';

/// Libellé d'un niveau (1 à 6) dans la langue de l'interface.
String libelleNiveau(AppLocalizations textes, int niveau) => switch (niveau) {
  1 => textes.niveau1,
  2 => textes.niveau2,
  3 => textes.niveau3,
  4 => textes.niveau4,
  5 => textes.niveau5,
  _ => textes.niveau6,
};
