import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Titre d'une série en arabe et en français : la langue de l'interface
/// choisit (les séries sont nommées dans le JSON, pas dans les ARB).
class TitreBilingue {
  const TitreBilingue({required this.ar, required this.fr});

  factory TitreBilingue.depuisJson(Map<String, dynamic> json) =>
      TitreBilingue(ar: json['ar'] as String, fr: json['fr'] as String);

  final String ar;
  final String fr;

  String pour(String langue) => langue == 'ar' ? ar : fr;
}

/// Une série : des exemples du catalogue (schema/exemples) joués à la suite.
class SerieTest {
  const SerieTest({
    required this.id,
    required this.titre,
    required this.exemples,
  });

  factory SerieTest.depuisJson(Map<String, dynamic> json) => SerieTest(
    id: json['id'] as String,
    titre: TitreBilingue.depuisJson(json['titre'] as Map<String, dynamic>),
    exemples: (json['exemples'] as List).cast<String>(),
  );

  final String id;
  final TitreBilingue titre;

  /// Chemins des exemples dans le catalogue (`choix/T01-qcm-scene.json`),
  /// dans l'ordre de passage.
  final List<String> exemples;

  /// Les exemples jouables de la série, dans l'ordre : présents dans le
  /// catalogue, valides, d'un type jouable. Les autres sont sautés, sans
  /// erreur : un exemple retiré du catalogue ne bloque pas la séquence.
  List<ExempleType> jouables(CatalogueExemples catalogue) => [
    for (final chemin in exemples)
      for (final e in catalogue.tous)
        if (e.chemin == chemin &&
            e.estValide &&
            e.idType != null &&
            typeParId(e.idType!)?.etat == EtatType.jouable)
          e,
  ];
}

/// Séquence de test du tour 1 des familles (A1-22) : des séries d'exercices
/// enchaînés, sans carte du trimestre (le parcours vient en A3). Décrite
/// dans [cheminSequenceTest], qui se modifie sans toucher au code (ordre,
/// contenu, titres).
class SequenceTest {
  const SequenceTest({required this.id, required this.series});

  factory SequenceTest.depuisJson(Map<String, dynamic> json) => SequenceTest(
    id: json['id'] as String,
    series: [
      for (final s in (json['series'] as List).cast<Map<String, dynamic>>())
        SerieTest.depuisJson(s),
    ],
  );

  static SequenceTest depuisTexte(String json) =>
      SequenceTest.depuisJson(jsonDecode(json) as Map<String, dynamic>);

  final String id;
  final List<SerieTest> series;

  SerieTest? serie(String id) => series.where((s) => s.id == id).firstOrNull;
}

/// Asset de la séquence embarquée (déclaré dans pubspec.yaml).
const cheminSequenceTest = 'assets/sequences/tour-1.json';

/// La séquence embarquée, lue une fois. Surchargée dans les tests.
final sequenceTestProvider = FutureProvider<SequenceTest>(
  (ref) async =>
      SequenceTest.depuisTexte(await rootBundle.loadString(cheminSequenceTest)),
);
