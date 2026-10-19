import 'dart:convert';

import 'package:edu_content/edu_content.dart';

import 'registre_types.dart';

/// Un exemple de schema/exemples/, lu et validé une fois. Il ne lève jamais
/// d'exception : toute erreur est gardée pour être affichée.
class ExempleType {
  ExempleType._({
    required this.chemin,
    required this.idType,
    required this.texte,
    this.exercice,
    this.validation,
    this.erreurLecture,
  });

  /// Lit et valide [texte]. Le type de rattachement vient du préfixe du nom
  /// de fichier (`T01-...`), pour qu'un JSON illisible reste rangé sous son
  /// type.
  factory ExempleType.lire(String chemin, String texte) {
    final nom = chemin.split('/').last;
    final idType = RegExp(r'^(T\d\d)-').firstMatch(nom)?.group(1);
    Object? decode;
    try {
      decode = jsonDecode(texte);
    } on FormatException catch (e) {
      return ExempleType._(
        chemin: chemin,
        idType: idType,
        texte: texte,
        erreurLecture: 'JSON illisible : ${e.message}',
      );
    }
    if (decode is! Map<String, dynamic>) {
      return ExempleType._(
        chemin: chemin,
        idType: idType,
        texte: texte,
        erreurLecture: 'un exercice est un objet JSON.',
      );
    }
    final validation = validerExercice(decode);
    final type = decode['type'];
    return ExempleType._(
      chemin: chemin,
      idType: idType,
      texte: texte,
      exercice: decode,
      validation: validation,
      erreurLecture: idType != null && type != idType
          ? 'le fichier annonce $idType mais l\'exercice est de type $type.'
          : null,
    );
  }

  /// Chemin relatif à schema/exemples/ (`choix/T01-qcm-scene.json`).
  final String chemin;

  /// Type annoncé par le nom du fichier, `null` sans préfixe `Txx-`.
  final String? idType;

  /// Texte exact du fichier.
  final String texte;

  /// Exercice décodé, `null` si le JSON est illisible.
  final Map<String, dynamic>? exercice;

  /// Résultat du validateur edu-content/1.0.
  final ResultatValidation? validation;

  /// Erreur de lecture ou de rattachement (hors validation).
  final String? erreurLecture;

  /// Nom du fichier seul.
  String get fichier => chemin.split('/').last;

  bool get estValide =>
      erreurLecture == null && (validation?.estValide ?? false);

  /// Erreurs à afficher, lecture comprise.
  List<String> get erreurs => [
    ?erreurLecture,
    ...?validation?.erreurs.map((e) => e.toString()),
  ];

  String? get gabarit => _texte(exercice?['gabarit']);

  String? get langue => _texte(exercice?['langue']);

  /// Consigne, au masculin si elle est genrée.
  String? get consigne {
    final consigne = exercice?['consigne'];
    final texte = consigne is Map ? consigne['texte'] : null;
    return texte is Map ? _texte(texte['masculin']) : _texte(texte);
  }

  static String? _texte(Object? valeur) => valeur is String ? valeur : null;
}

/// Les exemples de schema/exemples/, rangés par type. Par défaut, ceux
/// générés dans [exemplesEduContent]. Lus et validés au premier accès.
class CatalogueExemples {
  CatalogueExemples([Map<String, String>? sources])
    : _sources = sources ?? exemplesEduContent;

  final Map<String, String> _sources;

  late final List<ExempleType> tous = [
    for (final MapEntry(key: chemin, value: texte) in _sources.entries)
      ExempleType.lire(chemin, texte),
  ]..sort((a, b) => a.chemin.compareTo(b.chemin));

  /// Exemples rattachés au type [id].
  List<ExempleType> exemplesDuType(String id) =>
      tous.where((e) => e.idType == id).toList();

  /// Exemples sans préfixe `Txx-` ou d'un type hors du registre.
  List<ExempleType> get nonRattaches => tous
      .where((e) => e.idType == null || typeParId(e.idType!) == null)
      .toList();
}
