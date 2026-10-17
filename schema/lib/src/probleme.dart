/// Gravité d'un problème : une erreur rend le JSON invalide, un avertissement
/// signale un point à relire sans bloquer.
enum Gravite { erreur, avertissement }

/// Un problème trouvé dans un JSON edu-content/1.0.
class ProblemeValidation {
  const ProblemeValidation({
    required this.chemin,
    required this.code,
    required this.message,
    this.gravite = Gravite.erreur,
  });

  /// Emplacement au format JSON Pointer (`/exercices/1/langue`), `/` pour la
  /// racine.
  final String chemin;

  /// Code stable, utilisable par les tests et le back-office.
  final String code;

  /// Explication en français.
  final String message;

  final Gravite gravite;

  @override
  String toString() => '$chemin [$code] : $message';
}

/// Résultat d'une validation.
class ResultatValidation {
  ResultatValidation(List<ProblemeValidation> problemes)
    : erreurs = List.unmodifiable(
        problemes.where((p) => p.gravite == Gravite.erreur),
      ),
      avertissements = List.unmodifiable(
        problemes.where((p) => p.gravite == Gravite.avertissement),
      );

  final List<ProblemeValidation> erreurs;
  final List<ProblemeValidation> avertissements;

  bool get estValide => erreurs.isEmpty;

  @override
  String toString() {
    if (erreurs.isEmpty && avertissements.isEmpty) return 'JSON valide.';
    return [
      for (final e in erreurs) 'Erreur $e',
      for (final a in avertissements) 'Avertissement $a',
    ].join('\n');
  }
}
