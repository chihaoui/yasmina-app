import 'package:json_schema/json_schema.dart';

import 'pointeur.dart';
import 'probleme.dart';

const _nomsTypes = {
  'string': 'un texte',
  'integer': 'un entier',
  'number': 'un nombre',
  'boolean': 'un booléen',
  'object': 'un objet',
  'array': 'une liste',
  'null': 'null',
};

/// Traduit une erreur de `json_schema` (en anglais) en problème en français.
///
/// [schema] est le schéma décodé (pour lire `enum`, `const`, `pattern`,
/// `description`...), [donnees] l'instance validée et [prefixe] le chemin à
/// ajouter devant celui de l'erreur quand l'instance est un sous-objet.
ProblemeValidation traduireErreurSchema(
  ValidationError erreur, {
  required Map<String, dynamic> schema,
  required Object? donnees,
  String prefixe = '',
}) {
  final chemin = afficherChemin('$prefixe${erreur.instancePath}');
  final valeur = lireChemin(donnees, erreur.instancePath);
  final noeud = lireChemin(schema, erreur.schemaPath);
  final parent = lireChemin(schema, _sansDernierSegment(erreur.schemaPath));
  final m = erreur.message;

  ProblemeValidation probleme(String code, String message) =>
      ProblemeValidation(chemin: chemin, code: code, message: message);

  String? champ(Object? n, String cle) => n is Map ? '${n[cle]}' : null;

  if (m.startsWith('required prop missing: ')) {
    final nom = m.substring(23).split(' from ').first;
    return probleme(
      'obligatoire',
      'propriété obligatoire manquante : « $nom ».',
    );
  }
  if (m.startsWith('unallowed additional property ')) {
    final nom = m.substring(30);
    return probleme(
      'propriete_inconnue',
      'propriété non prévue par le schéma : « $nom ».',
    );
  }
  if (m.startsWith('type: wanted')) {
    final types = noeud is Map ? noeud['type'] : null;
    final attendu = (types is List ? types : [types])
        .map((t) => _nomsTypes[t] ?? '$t')
        .join(' ou ');
    return probleme('type_incorrect', 'type incorrect : attendu $attendu.');
  }
  if (m.startsWith('const violated')) {
    return probleme(
      'valeur_attendue',
      'valeur « $valeur » au lieu de « ${champ(noeud, 'const')} ».',
    );
  }
  if (m.startsWith('enum violated')) {
    final possibles = noeud is Map && noeud['enum'] is List
        ? (noeud['enum'] as List).join(', ')
        : '?';
    return probleme(
      'valeur_non_autorisee',
      'valeur « $valeur » non autorisée. Valeurs possibles : $possibles.',
    );
  }
  if (m.startsWith('pattern violated')) {
    final aide = noeud is Map && noeud['description'] is String
        ? ' ${noeud['description']}'
        : ' Motif attendu : ${champ(noeud, 'pattern')}';
    return probleme('format_incorrect', 'format incorrect : « $valeur ».$aide');
  }
  if (m.startsWith('minLength violated')) {
    final min = noeud is Map ? noeud['minLength'] : null;
    return probleme(
      'texte_trop_court',
      min == 1 ? 'texte vide.' : 'texte trop court (minimum $min caractères).',
    );
  }
  if (m.startsWith('minItems violated')) {
    return probleme(
      'liste_trop_courte',
      'liste trop courte : ${_taille(valeur)} élément(s), '
          'minimum ${champ(noeud, 'minItems')}.',
    );
  }
  if (m.startsWith('maxItems exceeded')) {
    return probleme(
      'liste_trop_longue',
      'liste trop longue : ${_taille(valeur)} éléments, '
          'maximum ${champ(noeud, 'maxItems')}.',
    );
  }
  if (m.startsWith('uniqueItems violated')) {
    return probleme('doublon_liste', 'la liste contient des doublons.');
  }
  if (m.startsWith('minimum violated')) {
    return probleme(
      'valeur_trop_petite',
      'valeur $valeur trop petite (minimum ${champ(noeud, 'minimum')}).',
    );
  }
  if (m.startsWith('maximum exceeded')) {
    return probleme(
      'valeur_trop_grande',
      'valeur $valeur trop grande (maximum ${champ(noeud, 'maximum')}).',
    );
  }
  if (erreur.schemaPath.endsWith('/oneOf') ||
      erreur.schemaPath.endsWith('/anyOf')) {
    final aide = parent is Map && parent['description'] is String
        ? ' ${parent['description']}'
        : '';
    return probleme('forme_incorrecte', 'forme incorrecte.$aide');
  }
  if (m.endsWith('not violated')) {
    return probleme('valeur_interdite', 'valeur « $valeur » interdite.');
  }
  return probleme('schema', 'non conforme au schéma ($m).');
}

String _sansDernierSegment(String chemin) {
  final i = chemin.lastIndexOf('/');
  return i <= 0 ? '' : chemin.substring(0, i);
}

String _taille(Object? valeur) => valeur is List ? '${valeur.length}' : '?';
