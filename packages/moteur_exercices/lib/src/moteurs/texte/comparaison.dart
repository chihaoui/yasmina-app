/// Comparaison d'une saisie avec un texte attendu (docs/moteurs/texte.md
/// §5), en Dart pur. Les normalisations du champ `normalisation` de
/// l'exercice s'appliquent à une copie de la saisie et de la réponse, au
/// moment de comparer, jamais au texte stocké. Aucune normalisation
/// Unicode (ni NFC ni NFD) : les harakat gardent leur ordre d'écriture.
library;

/// Vrai si [saisie] et [attendu] sont égaux une fois normalisés.
bool comparerTextes(
  String saisie,
  String attendu,
  Iterable<String> normalisations,
) =>
    normaliserTexte(saisie, normalisations) ==
    normaliserTexte(attendu, normalisations);

/// Copie de [texte] après les [normalisations] demandées, dans l'ordre :
/// `espaces`, `casse`, `ponctuation`, `tatweel`, `chiffres`,
/// `harakat_ignorees`. Une normalisation inconnue est ignorée.
String normaliserTexte(String texte, Iterable<String> normalisations) {
  var t = texte;
  for (final n in normalisations) {
    t = switch (n) {
      'espaces' => t.trim().replaceAll(RegExp(r'\s+'), ' '),
      'casse' => t.toLowerCase(),
      'ponctuation' => t.replaceAll(_ponctuation, ''),
      'tatweel' => t.replaceAll('ـ', ''),
      'chiffres' => String.fromCharCodes(t.runes.map(_chiffreOccidental)),
      'harakat_ignorees' => String.fromCharCodes(
        t.runes.where((r) => !_estHaraka(r)),
      ),
      _ => t,
    };
  }
  return t;
}

/// Ponctuation latine et arabe (point, virgule, deux-points, point
/// d'interrogation et d'exclamation, guillemets, parenthèses, tirets).
final _ponctuation = RegExp('[.,:!?;؟،؛«»"\'()\\-]');

/// Chiffres arabes orientaux (٠ à ٩) et persans (۰ à ۹) vers 0 à 9.
int _chiffreOccidental(int r) {
  if (r >= 0x0660 && r <= 0x0669) return r - 0x0660 + 0x30;
  if (r >= 0x06F0 && r <= 0x06F9) return r - 0x06F0 + 0x30;
  return r;
}

/// Tanwīn, fatha, damma, kasra, shadda, sukūn et alif suscrit.
bool _estHaraka(int r) => (r >= 0x064B && r <= 0x0652) || r == 0x0670;
