/// Lecture d'une valeur JSON à partir d'un chemin JSON Pointer (RFC 6901).
///
/// Renvoie `null` si le chemin n'existe pas.
Object? lireChemin(Object? racine, String chemin) {
  Object? courant = racine;
  for (final brut in chemin.split('/').skip(1)) {
    final cle = brut.replaceAll('~1', '/').replaceAll('~0', '~');
    if (courant is Map) {
      courant = courant[cle];
    } else if (courant is List) {
      final i = int.tryParse(cle);
      if (i == null || i < 0 || i >= courant.length) return null;
      courant = courant[i];
    } else {
      return null;
    }
  }
  return courant;
}

/// Chemin affiché dans les messages : `/` pour la racine.
String afficherChemin(String chemin) => chemin.isEmpty ? '/' : chemin;
