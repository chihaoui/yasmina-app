/// Événements émis par le lecteur vers l'hôte (journal de l'atelier,
/// progression locale, analytics).
sealed class EvenementExercice {
  const EvenementExercice();

  List<Object?> get _cle;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is EvenementExercice &&
      _egales(other._cle, _cle);

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(_cle));

  static bool _egales(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// La réponse de l'enfant a changé (valeur sérialisable en JSON).
final class ReponseDonnee extends EvenementExercice {
  const ReponseDonnee(this.reponse);

  final Object? reponse;

  @override
  List<Object?> get _cle => ['$reponse'];

  @override
  String toString() => 'reponseDonnee : $reponse';
}

/// Un essai corrigé (mode enfant seulement).
final class Essai extends EvenementExercice {
  const Essai(this.numero, {required this.juste});

  final int numero;
  final bool juste;

  @override
  List<Object?> get _cle => [numero, juste];

  @override
  String toString() => 'essai $numero : ${juste ? 'juste' : 'faux'}';
}

/// Issue d'un exercice.
enum IssueExercice {
  /// Juste au 1er ou au 2e essai (ou fin automatique juste).
  reussi,

  /// Faux deux fois (ou fin automatique fausse) : explication donnée.
  explique,

  /// Type non noté (T36 Flashcards).
  termine,
}

/// Fin de l'exercice (mode enfant seulement).
final class Resultat extends EvenementExercice {
  const Resultat(this.issue, {required this.essais});

  final IssueExercice issue;
  final int essais;

  @override
  List<Object?> get _cle => [issue, essais];

  @override
  String toString() => 'resultat : ${issue.name} ($essais essai(s))';
}

/// Ce qui demande de l'audio.
enum OrigineAudio { consigne, ecoute, choix }

/// Le lecteur ou une zone fait dire un texte par le service audio.
final class DemandeAudio extends EvenementExercice {
  const DemandeAudio(this.texte, {required this.langue, required this.origine});

  final String texte;
  final String langue;
  final OrigineAudio origine;

  @override
  List<Object?> get _cle => [texte, langue, origine];

  @override
  String toString() => 'demandeAudio (${origine.name}, $langue) : $texte';
}
