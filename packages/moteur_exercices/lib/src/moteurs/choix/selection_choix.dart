import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../composants/tuile_choix.dart';
import '../../lecteur/contrat_moteur.dart';

/// Une proposition touchable du moteur Choix : un choix, une preuve, une
/// forme de lettre, une haraka ou un signe. Texte, emoji ou les deux.
class Proposition {
  const Proposition({
    required this.id,
    this.texte,
    this.emoji,
    this.audio,
    this.detail,
  });

  /// Lit un élément de `donnees.choix` (ou `preuves`, ou `suite` avec un id
  /// donné par [idSuite]).
  factory Proposition.depuisJson(Map<String, dynamic> json, {String? id}) =>
      Proposition(
        id: id ?? json['id'] as String,
        texte: json['texte'] as String?,
        emoji: json['emoji'] as String?,
        audio: json['audio'] as String?,
      );

  final String id;
  final String? texte;
  final String? emoji;

  /// Fichier audio du choix (plus tard, phase B).
  final String? audio;

  /// Texte court affiché sous l'élément (date d'un élément de frise, T62).
  final String? detail;
}

/// Sélection d'une ou plusieurs propositions parmi une liste, corrigée par
/// égalité d'ensembles avec les id attendus (docs/moteurs/choix.md §5).
///
/// L'ordre des propositions est tiré une fois, à la création, avec le
/// générateur reçu (graine injectée : tests et aperçu reproductibles), et
/// ne change plus entre les essais.
class SelectionChoix {
  SelectionChoix({
    required List<Proposition> propositions,
    required Iterable<String> attendus,
    this.multiple = false,
    bool melanger = false,
    Random? aleatoire,
  }) : propositions = melanger
           ? (List.of(propositions)..shuffle(aleatoire))
           : List.unmodifiable(propositions),
       attendus = Set.unmodifiable(attendus);

  /// Propositions dans l'ordre d'affichage.
  final List<Proposition> propositions;

  /// Id des bonnes réponses.
  final Set<String> attendus;

  /// Sélection multiple (T05, T45, T61) ou unique (toucher une autre tuile
  /// déplace la sélection).
  final bool multiple;

  final _selection = <String>{};

  /// Id sélectionnés, dans l'ordre d'affichage.
  List<String> get ids => [
    for (final p in propositions)
      if (_selection.contains(p.id)) p.id,
  ];

  bool estSelectionne(String id) => _selection.contains(id);

  bool get complete => _selection.isNotEmpty;

  bool get juste => setEquals(_selection, attendus);

  /// Ajoute ou retire [id]. En sélection unique, remplace la sélection.
  void basculer(String id) {
    if (!multiple) {
      _selection
        ..clear()
        ..add(id);
      return;
    }
    if (!_selection.remove(id)) _selection.add(id);
  }

  void vider() => _selection.clear();

  /// Numéro (à partir de 1) de la proposition [id] dans l'ordre affiché,
  /// pour le libellé neutre d'une tuile sans texte.
  int numero(String id) => propositions.indexWhere((p) => p.id == id) + 1;

  /// État de la tuile [id] selon l'affichage voulu par le lecteur.
  EtatTuile etatDe(String id, AffichageReponse affichage) =>
      switch (affichage) {
        AffichageReponse.saisie =>
          estSelectionne(id) ? EtatTuile.selectionne : EtatTuile.repos,
        AffichageReponse.juste =>
          estSelectionne(id) ? EtatTuile.juste : EtatTuile.repos,
        AffichageReponse.faux =>
          estSelectionne(id) ? EtatTuile.faux : EtatTuile.repos,
        AffichageReponse.revelee =>
          attendus.contains(id) ? EtatTuile.juste : EtatTuile.repos,
      };
}
