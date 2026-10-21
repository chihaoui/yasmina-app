import 'dart:convert';

import 'package:flutter/services.dart'
    show AssetBundle, AssetManifest, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Une séquence d'une étape : son titre (dans la langue de la matière) et
/// ses exercices dans l'ordre de passage.
class SequenceEtape {
  const SequenceEtape({
    required this.id,
    required this.titre,
    required this.exercices,
  });

  final String id;
  final String titre;
  final List<String> exercices;
}

/// Une étape edu-content/1.0 embarquée (une lettre, un défi), telle que la
/// joue le parcours : les séquences et les exercices par id.
class Etape {
  const Etape({
    required this.id,
    required this.matiere,
    required this.niveau,
    required this.trimestre,
    required this.unite,
    required this.ordre,
    required this.langue,
    required this.titre,
    required this.sequences,
    required this.exercices,
  });

  factory Etape.depuisJson(Map<String, dynamic> json) {
    final etape = json['etape'] as Map<String, dynamic>;
    return Etape(
      id: etape['id'] as String,
      matiere: etape['matiere'] as String,
      niveau: etape['niveau'] as int,
      trimestre: etape['trimestre'] as int,
      unite: etape['unite'] as int,
      ordre: etape['ordre'] as int,
      langue: etape['langue'] as String,
      titre: etape['titre'] as String,
      sequences: [
        for (final s
            in (etape['sequences'] as List).cast<Map<String, dynamic>>())
          SequenceEtape(
            id: s['id'] as String,
            titre: s['titre'] as String,
            exercices: (s['exercices'] as List).cast<String>(),
          ),
      ],
      exercices: {
        for (final x
            in (json['exercices'] as List).cast<Map<String, dynamic>>())
          x['id'] as String: x,
      },
    );
  }

  final String id;
  final String matiere;
  final int niveau;
  final int trimestre;
  final int unite;
  final int ordre;
  final String langue;
  final String titre;
  final List<SequenceEtape> sequences;
  final Map<String, Map<String, dynamic>> exercices;

  /// Mot qui ouvre le titre d'un défi d'unité (« تَحَدِّي الْوَحْدَةِ... »).
  static const prefixeDefi = 'تَحَدِّي';

  /// Défi de l'unité : une seule série, glyphe 🏆 sur la carte. Lu dans le
  /// titre, en attendant un champ du schéma (question A3-01).
  bool get estDefi => titre.startsWith(prefixeDefi);

  /// Lettre de l'étape, affichée sur la carte et dans l'intro : celle du
  /// premier T18 (forme de la lettre), sinon la première lettre du nom de la
  /// lettre dans le titre (« حَرْفُ الْبَاءِ » donne ب), sinon le titre.
  String get lettre {
    for (final x in exercices.values) {
      if (x['type'] == 'T18') {
        final lettre = (x['donnees'] as Map)['lettre'];
        if (lettre is String && lettre.isNotEmpty) return lettre;
      }
    }
    final nom = titre.split(' ').last.replaceAll(_harakat, '');
    final sansArticle = nom.startsWith('ال') ? nom.substring(2) : nom;
    return sansArticle.isEmpty ? titre : sansArticle.substring(0, 1);
  }

  /// Formes de la lettre proposées par le premier T18 (ب بـ ـبـ ـب), pour
  /// l'intro. Vide sans T18.
  List<String> get formes {
    for (final x in exercices.values) {
      if (x['type'] == 'T18') {
        return [
          for (final c in ((x['donnees'] as Map)['choix'] as List).cast<Map>())
            c['texte'] as String,
        ];
      }
    }
    return const [];
  }

  /// Les exercices à jouer, dans l'ordre des séquences, chacun avec l'index
  /// de sa séquence (couleur de la barre de progression).
  List<ExerciceAJouer> get deroule => [
    for (var s = 0; s < sequences.length; s++)
      for (final id in sequences[s].exercices)
        if (exercices[id] case final exercice?)
          ExerciceAJouer(sequence: s, id: id, exercice: exercice),
  ];

  int get nombreExercices => deroule.length;
}

/// Un exercice du déroulé d'une étape.
class ExerciceAJouer {
  const ExerciceAJouer({
    required this.sequence,
    required this.id,
    required this.exercice,
  });

  /// Index de la séquence dans l'étape (0 à 3, ou 0 pour un défi).
  final int sequence;
  final String id;
  final Map<String, dynamic> exercice;
}

/// Le parcours d'une matière, d'un niveau et d'un trimestre : ses étapes
/// dans l'ordre de la carte (unité, puis ordre dans l'unité).
class Parcours {
  Parcours({
    required this.matiere,
    required this.niveau,
    required this.trimestre,
    required List<Etape> etapes,
  }) : etapes = List.unmodifiable(
         [...etapes]..sort(
           (a, b) => a.unite != b.unite
               ? a.unite.compareTo(b.unite)
               : a.ordre.compareTo(b.ordre),
         ),
       );

  /// Valeur du champ `etape.matiere` (`arabe`, `maths`...).
  final String matiere;
  final int niveau;
  final int trimestre;
  final List<Etape> etapes;

  /// Étapes groupées par unité, dans l'ordre.
  Map<int, List<Etape>> get parUnite {
    final unites = <int, List<Etape>>{};
    for (final e in etapes) {
      unites.putIfAbsent(e.unite, () => []).add(e);
    }
    return unites;
  }

  Etape? etape(String id) => etapes.where((e) => e.id == id).firstOrNull;

  int indexDe(String id) => etapes.indexWhere((e) => e.id == id);

  /// Étape qui suit [id] sur la carte, `null` pour la dernière.
  Etape? suivante(String id) {
    final i = indexDe(id);
    return i >= 0 && i + 1 < etapes.length ? etapes[i + 1] : null;
  }

  /// Étape qui précède [id], `null` pour la première.
  Etape? precedente(String id) {
    final i = indexDe(id);
    return i > 0 ? etapes[i - 1] : null;
  }
}

/// Tous les parcours embarqués (apps/mobile/assets/content/), lus par
/// matière, niveau et trimestre.
class CatalogueParcours {
  const CatalogueParcours(this.parcours);

  final List<Parcours> parcours;

  /// Parcours d'une matière (`arabe`...), d'un niveau et d'un trimestre,
  /// `null` quand aucune étape n'est embarquée.
  Parcours? pour({
    required String matiere,
    required int niveau,
    int trimestre = 1,
  }) => parcours
      .where(
        (p) =>
            p.matiere == matiere &&
            p.niveau == niveau &&
            p.trimestre == trimestre,
      )
      .firstOrNull;

  /// Préfixe des étapes embarquées dans le bundle.
  static const prefixeAssets = 'assets/content/';

  /// Lit toutes les étapes du bundle (fichiers JSON sous [prefixeAssets],
  /// listés par le manifeste des assets).
  static Future<CatalogueParcours> charger(AssetBundle bundle) async {
    final manifeste = await AssetManifest.loadFromAssetBundle(bundle);
    final chemins =
        manifeste
            .listAssets()
            .where((c) => c.startsWith(prefixeAssets) && c.endsWith('.json'))
            .toList()
          ..sort();
    final etapes = <Etape>[];
    for (final chemin in chemins) {
      final json =
          jsonDecode(await bundle.loadString(chemin)) as Map<String, dynamic>;
      etapes.add(Etape.depuisJson(json));
    }
    return CatalogueParcours.depuisEtapes(etapes);
  }

  /// Groupe des étapes en parcours (matière, niveau, trimestre).
  factory CatalogueParcours.depuisEtapes(Iterable<Etape> etapes) {
    final groupes = <(String, int, int), List<Etape>>{};
    for (final e in etapes) {
      groupes.putIfAbsent((e.matiere, e.niveau, e.trimestre), () => []).add(e);
    }
    return CatalogueParcours([
      for (final MapEntry(key: (matiere, niveau, trimestre), value: liste)
          in groupes.entries)
        Parcours(
          matiere: matiere,
          niveau: niveau,
          trimestre: trimestre,
          etapes: liste,
        ),
    ]);
  }
}

/// Harakat (tanwīn, fatha, damma, kasra, shadda, sukūn).
final _harakat = RegExp('[ً-ْ]');

/// Les parcours embarqués, lus une fois. Surchargé dans les tests.
final catalogueParcoursProvider = FutureProvider<CatalogueParcours>(
  (ref) => CatalogueParcours.charger(rootBundle),
);
