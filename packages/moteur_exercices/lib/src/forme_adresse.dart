/// Forme d'adresse de l'enfant, pour accorder les textes genrés (consigne et
/// feedbacks en `{ "masculin", "feminin" }` dans le JSON edu-content/1.0).
///
/// Le moteur la reçoit dans sa configuration. Il ne connaît pas les profils.
enum FormeAdresse {
  masculin,
  feminin;

  /// Choisit la variante d'un texte genré du JSON : un texte simple est
  /// renvoyé tel quel, un objet `{masculin, feminin}` selon la forme.
  String accorder(Object texte) => switch (texte) {
    String() => texte,
    Map() => texte[name] as String,
    _ => throw ArgumentError.value(texte, 'texte', 'texte genré invalide'),
  };
}
