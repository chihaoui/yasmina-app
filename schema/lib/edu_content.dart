/// Schéma edu-content/1.0 et son validateur, en Dart pur (VM et web).
library;

export 'src/exemples_generes.dart' show exemplesEduContent;
export 'src/probleme.dart';
export 'src/schema_genere.dart' show texteSchemaEduContent;
export 'src/validateur.dart'
    show validerEtape, validerEtapeDecodee, validerExercice;

/// Valeur attendue dans `generation.schema`.
const String versionSchemaEduContent = 'edu-content/1.0';
