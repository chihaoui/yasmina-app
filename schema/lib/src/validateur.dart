import 'dart:convert';

import 'package:json_schema/json_schema.dart';

import 'messages.dart';
import 'pointeur.dart';
import 'probleme.dart';
import 'regles_metier.dart';
import 'schema_genere.dart';

/// Valide une étape complète à partir de son texte JSON.
ResultatValidation validerEtape(String texteJson) {
  final Object? donnees;
  try {
    donnees = jsonDecode(texteJson);
  } on FormatException catch (e) {
    return ResultatValidation([
      ProblemeValidation(
        chemin: '/',
        code: 'json_illisible',
        message: 'JSON illisible : ${e.message} (position ${e.offset}).',
      ),
    ]);
  }
  return validerEtapeDecodee(donnees);
}

/// Valide une étape complète déjà décodée. Les données ne sont pas modifiées.
ResultatValidation validerEtapeDecodee(Object? donnees) {
  final erreurs = _validateur.erreursSchema(_validateur.schemaEtape, donnees);
  if (erreurs.isNotEmpty) return ResultatValidation(erreurs);
  return ResultatValidation(reglesEtape(donnees as Map<String, dynamic>));
}

/// Valide un exercice seul, hors de son étape (aperçu web du back-office).
/// Les règles propres à l'étape (séquences, langue de l'étape) sont sautées.
ResultatValidation validerExercice(Object? exercice) {
  final erreurs = _validateur.erreursSchema(
    _validateur.sousSchema('exercice'),
    exercice,
  );
  if (erreurs.isNotEmpty) return ResultatValidation(erreurs);
  return ResultatValidation(
    reglesExercice(exercice as Map<String, dynamic>, '', seul: true),
  );
}

final _validateur = _Validateur();

class _Validateur {
  _Validateur()
    : racine = jsonDecode(texteSchemaEduContent) as Map<String, dynamic> {
    schemaEtape = JsonSchema.create(racine);
  }

  final Map<String, dynamic> racine;
  late final JsonSchema schemaEtape;
  final _sousSchemas = <String, JsonSchema>{};

  /// Schéma réduit à une définition de `$defs` (mêmes chemins d'erreur que
  /// le schéma complet).
  JsonSchema sousSchema(String definition) => _sousSchemas.putIfAbsent(
    definition,
    () => JsonSchema.create({
      r'$schema': racine[r'$schema'],
      r'$defs': racine[r'$defs'],
      r'$ref': '#/\$defs/$definition',
    }),
  );

  List<ProblemeValidation> erreursSchema(
    JsonSchema schema,
    Object? donnees, {
    String prefixe = '',
  }) {
    final problemes = <ProblemeValidation>[];
    for (final e in schema.validate(donnees).errors) {
      // json_schema signale un champ manquant deux fois : sur l'objet et sur
      // le champ. On garde l'erreur sur l'objet.
      if (e.message.startsWith('required prop missing: ')) {
        final nom = e.message.substring(23).split(' from ').first;
        if (e.instancePath.endsWith('/$nom')) continue;
      }
      // Les erreurs dans allOf, if et then sont résumées par json_schema. On
      // revalide donnees et reponse contre la définition du type pour obtenir
      // un chemin précis.
      if (e.schemaPath.endsWith('/allOf') || e.schemaPath.endsWith('/then')) {
        problemes.addAll(_detaillerParType(donnees, e.instancePath, prefixe));
        continue;
      }
      problemes.add(
        traduireErreurSchema(
          e,
          schema: racine,
          donnees: donnees,
          prefixe: prefixe,
        ),
      );
    }
    return problemes;
  }

  List<ProblemeValidation> _detaillerParType(
    Object? donnees,
    String cheminExercice,
    String prefixe,
  ) {
    final exercice = lireChemin(donnees, cheminExercice);
    final type = exercice is Map ? exercice['type'] : null;
    final problemes = <ProblemeValidation>[];
    for (final (champ, definition) in _definitionsDuType(type)) {
      problemes.addAll(
        erreursSchema(
          sousSchema(definition),
          (exercice as Map)[champ],
          prefixe: '$prefixe$cheminExercice/$champ',
        ),
      );
    }
    if (problemes.isEmpty) {
      problemes.add(
        ProblemeValidation(
          chemin: afficherChemin('$prefixe$cheminExercice'),
          code: 'donnees_type',
          message: 'donnees ou reponse incompatibles avec le type $type.',
        ),
      );
    }
    return problemes;
  }

  /// Lit dans `$defs/exercice/allOf` les définitions imposées au type :
  /// par exemple `(donnees, donneesChoix)` et `(reponse, reponseChoix)`.
  List<(String, String)> _definitionsDuType(Object? type) {
    final resultat = <(String, String)>[];
    final allOf = racine[r'$defs']['exercice']['allOf'] as List;
    for (final branche in allOf.cast<Map<String, dynamic>>()) {
      final condition = branche['if']['properties']['type'] as Map;
      final types = condition['enum'] ?? [condition['const']];
      if (!(types as List).contains(type)) continue;
      final champs = branche['then']['properties'] as Map<String, dynamic>;
      for (final MapEntry(:key, :value) in champs.entries) {
        final ref = (value as Map)[r'$ref'] as String;
        resultat.add((key, ref.split('/').last));
      }
    }
    return resultat;
  }
}
