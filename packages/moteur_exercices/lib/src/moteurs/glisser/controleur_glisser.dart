import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../choix/selection_choix.dart';

/// État visuel d'un élément à glisser (docs/moteurs/glisser-deposer.md §11).
enum EtatGlissable {
  /// Dans la réserve.
  repos,

  /// En attente (toucher-toucher) : se pose au toucher d'une cible.
  attente,

  /// Posé sur une cible, encore déplaçable.
  pose,

  /// Bien placé (validation, réponse révélée).
  juste,

  /// Mal placé (1er essai faux, un instant).
  faux,
}

/// Base des contrôleurs du moteur Glisser-déposer : la réserve (ordre tiré
/// une fois avec la graine), l'élément en attente, le retrait des seuls
/// éléments faux après le 1er essai.
abstract class ControleurGlisser extends ControleurReponse {
  ControleurGlisser({
    required this.config,
    required List<Proposition> elements,
    bool melanger = true,
  }) : elements = melanger
           ? (List.of(elements)
               ..shuffle(config.graine == null ? null : Random(config.graine)))
           : List.unmodifiable(elements);

  final ConfigExercice config;

  /// Éléments de la réserve, dans l'ordre d'affichage.
  final List<Proposition> elements;

  String? _enAttente;

  /// Élément en attente (toucher-toucher), `null` sinon.
  String? get enAttente => _enAttente;

  Proposition element(String id) => elements.firstWhere((e) => e.id == id);

  /// Numéro (à partir de 1) de l'élément dans la réserve, pour le libellé
  /// neutre d'une tuile sans texte.
  int numero(String id) => elements.indexWhere((e) => e.id == id) + 1;

  /// Met [id] en attente, ou l'en sort s'il l'était déjà.
  void basculerAttente(String id) {
    if (!modifiable) return;
    _enAttente = _enAttente == id ? null : id;
    notifyListeners();
  }

  /// L'élément en attente se pose sur [cible] (toucher d'une cible).
  void poserAttente(String cible) {
    final id = _enAttente;
    if (id == null) return;
    _enAttente = null;
    poser(id, cible);
  }

  /// Pose [id] sur [cible] (dépôt). [cible] est un id de cible ou, pour
  /// une ligne, une position.
  void poser(String id, String cible);

  /// Renvoie [id] dans la réserve.
  void retirer(String id);

  /// L'élément [id] est posé quelque part.
  bool estPose(String id);

  /// L'élément [id] est posé au bon endroit.
  bool estJuste(String id);

  /// Après le 1er essai faux : seuls les éléments mal placés reviennent
  /// dans la réserve (glisser-deposer.md §6).
  @override
  void retirerFaux();

  /// État de l'élément [id] selon l'affichage voulu par le lecteur.
  EtatGlissable etatDe(String id) => switch (affichage) {
    AffichageReponse.saisie =>
      _enAttente == id
          ? EtatGlissable.attente
          : estPose(id)
          ? EtatGlissable.pose
          : EtatGlissable.repos,
    AffichageReponse.juste =>
      estPose(id) ? EtatGlissable.juste : EtatGlissable.repos,
    AffichageReponse.faux =>
      !estPose(id)
          ? EtatGlissable.repos
          : estJuste(id)
          ? EtatGlissable.pose
          : EtatGlissable.faux,
    // Réponse révélée : chaque élément à sa place, juste.
    AffichageReponse.revelee => EtatGlissable.juste,
  };

  @override
  void vider() {
    _enAttente = null;
    reponseModifiee();
  }

  void _changer() {
    _enAttente = null;
    reponseModifiee();
  }
}

/// Forme de la réponse d'une affectation : trou → étiquette (T06), gauche →
/// droite (T09), élément → catégorie (T11, T12).
enum FormeAffectation {
  trous('trous', 'trou', 'etiquette'),
  paires('paires', 'droite', 'gauche'),
  bacs('classement', 'categorie', 'element'),

  /// Zones d'un schéma (T47, moteur Scène image) : une étiquette par zone.
  zones('placements', 'zone', 'etiquette');

  const FormeAffectation(this.champ, this.cleCible, this.cleElement);

  /// Nom du tableau dans `reponse`.
  final String champ;

  /// Clé de la cible et clé de l'élément dans chaque entrée.
  final String cleCible;
  final String cleElement;

  /// Une cible reçoit un seul élément (trous, paires) ou plusieurs (bacs).
  bool get cibleUnique => this != bacs;
}

/// Chaque élément va sur une cible : trous (T06), paires (T09), bacs (T11,
/// T12). Juste si l'affectation est exactement celle attendue.
class ControleurAffectation extends ControleurGlisser {
  ControleurAffectation({
    required super.config,
    required super.elements,
    required this.cibles,
    required this.attendu,
    required this.forme,
    super.melanger,
  });

  /// Cibles dans l'ordre d'affichage (trous du texte, droite, catégories).
  final List<Proposition> cibles;

  /// Élément → cible attendue.
  final Map<String, String> attendu;

  final FormeAffectation forme;

  final _placements = <String, String>{};

  /// Élément → cible, tel que posé par l'enfant (ou la bonne réponse quand
  /// elle est révélée).
  Map<String, String> get placements =>
      affichage == AffichageReponse.revelee ? attendu : _placements;

  /// Éléments posés sur [cible], dans l'ordre de la réserve.
  List<Proposition> elementsSur(String cible) => [
    for (final e in elements)
      if (placements[e.id] == cible) e,
  ];

  @override
  void poser(String id, String cible) {
    if (!modifiable) return;
    if (forme.cibleUnique) {
      // Un seul élément par cible : l'occupant revient dans la réserve.
      _placements.removeWhere((e, c) => c == cible && e != id);
    }
    _placements[id] = cible;
    _changer();
  }

  @override
  void retirer(String id) {
    if (!modifiable) return;
    _placements.remove(id);
    _changer();
  }

  @override
  bool estPose(String id) => placements.containsKey(id);

  @override
  bool estJuste(String id) => placements[id] == attendu[id];

  @override
  void retirerFaux() {
    _placements.removeWhere((e, c) => attendu[e] != c);
    _changer();
  }

  /// Complète quand chaque élément attendu est posé (bacs, paires) ou
  /// chaque cible remplie (trous, zones : les étiquettes en trop restent).
  @override
  bool get complete =>
      forme == FormeAffectation.trous || forme == FormeAffectation.zones
      ? cibles.every((c) => _placements.containsValue(c.id))
      : attendu.keys.every(_placements.containsKey);

  @override
  Object? get reponse => {
    forme.champ: [
      for (final e in elements)
        if (_placements[e.id] case final cible?)
          {forme.cleCible: cible, forme.cleElement: e.id},
    ],
  };

  @override
  bool corriger() => mapEquals(_placements, attendu);

  @override
  void vider() {
    _placements.clear();
    super.vider();
  }
}

/// Les éléments se rangent dans une ligne, dans l'ordre : mots (T13),
/// images (T14), lettres ou syllabes d'un mot (T15, T16), éléments d'une
/// frise (T62), lettres d'une racine ou d'un schème (T56).
class ControleurOrdre extends ControleurGlisser {
  ControleurOrdre({
    required super.config,
    required super.elements,
    required this.attendu,
    this.exigeTous = true,
    this.capacite,
    this.ecoute,
    super.melanger,
  });

  /// Ids dans l'ordre attendu.
  final List<String> attendu;

  /// Vérifier exige tous les éléments (T13, T14) ou au moins un (T15, T16,
  /// où des lettres de la réserve peuvent être en trop).
  final bool exigeTous;

  /// Nombre de places dans la ligne (emplacements de T56), `null` sans
  /// limite. Une ligne pleine ne reçoit plus d'élément de la réserve.
  final int? capacite;

  /// La ligne est pleine.
  bool get pleine => capacite != null && _ordre.length >= capacite!;

  /// Mot entendu (T15, T16), dit après la consigne et au toucher.
  final String? ecoute;

  final _ordre = <String>[];

  /// Ligne de réponse (ou la bonne réponse quand elle est révélée).
  List<String> get ordre =>
      affichage == AffichageReponse.revelee ? attendu : _ordre;

  /// Texte des éléments de la ligne, collés (mot construit de T15, T16).
  String get motConstruit =>
      [for (final id in ordre) element(id).texte ?? ''].join();

  /// Pose [id] à la position [cible] (« fin » ou un index), en le
  /// retirant d'abord de la ligne s'il y était.
  @override
  void poser(String id, String cible) {
    if (!modifiable) return;
    final ancienne = _ordre.indexOf(id);
    if (ancienne < 0 && pleine) return;
    if (ancienne >= 0) _ordre.removeAt(ancienne);
    var index = int.tryParse(cible) ?? _ordre.length;
    if (ancienne >= 0 && ancienne < index) index--;
    _ordre.insert(index.clamp(0, _ordre.length), id);
    _changer();
  }

  @override
  void retirer(String id) {
    if (!modifiable) return;
    _ordre.remove(id);
    _changer();
  }

  /// Retire le dernier élément de la ligne (toucher du mot construit).
  void retirerDernier() {
    if (!modifiable || _ordre.isEmpty) return;
    _ordre.removeLast();
    _changer();
  }

  @override
  bool estPose(String id) => ordre.contains(id);

  @override
  bool estJuste(String id) {
    final i = _ordre.indexOf(id);
    return i >= 0 && i < attendu.length && attendu[i] == id;
  }

  /// Garde le début juste de la ligne, le reste revient dans la réserve.
  @override
  void retirerFaux() {
    var n = 0;
    while (n < _ordre.length && n < attendu.length && _ordre[n] == attendu[n]) {
      n++;
    }
    _ordre.removeRange(n, _ordre.length);
    _changer();
  }

  @override
  bool get complete =>
      exigeTous ? _ordre.length == attendu.length : _ordre.isNotEmpty;

  @override
  Object? get reponse => {'ordre': List.of(_ordre)};

  @override
  bool corriger() => listEquals(_ordre, attendu);

  @override
  void vider() {
    _ordre.clear();
    super.vider();
  }

  @override
  String? get ecouteOuverture => ecoute;
}
