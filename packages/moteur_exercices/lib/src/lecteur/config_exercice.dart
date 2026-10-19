import '../forme_adresse.dart';
import '../registre/registre_types.dart';

/// Configuration donnée au lecteur par l'hôte (app, aperçu web,
/// back-office). Le lecteur ne connaît ni les profils ni la base.
class ConfigExercice {
  const ConfigExercice({
    required this.langue,
    required this.formeAdresse,
    this.mode = ModeExercice.enfant,
  });

  /// Langue de l'exercice (`ar`, `fr` ou `en`) : textes, sens, voix.
  final String langue;

  /// Accord des textes genrés et des libellés arabes.
  final FormeAdresse formeAdresse;

  final ModeExercice mode;
}
