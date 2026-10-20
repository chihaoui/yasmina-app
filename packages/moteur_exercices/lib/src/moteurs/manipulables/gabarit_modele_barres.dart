import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../choix/selection_choix.dart';
import '../glisser/controleur_glisser.dart';
import '../glisser/tuile_glissable.dart';
import '../glisser/zone_depot.dart';
import '../saisie/pave_numerique.dart';

/// Un segment d'une barre du modèle : sa valeur (celle que l'étiquette
/// posée doit porter), connue ou inconnue.
class SegmentBarre {
  const SegmentBarre({required this.id, required this.valeur});

  final String id;
  final int valeur;
}

/// Une barre du modèle : un libellé et ses segments.
class Barre {
  const Barre({
    required this.id,
    required this.libelle,
    required this.segments,
  });

  final String id;
  final String libelle;
  final List<SegmentBarre> segments;

  int get total => segments.fold(0, (a, s) => a + s.valeur);
}

/// T52 Modèle en barres (docs/moteurs/manipulables.md §14, méthode de
/// Singapour) : l'enfant lit un problème, glisse les nombres du problème
/// dans les segments du schéma en barres (une étiquette par segment connu),
/// puis écrit la valeur inconnue (un segment ou le total d'une barre) sur le
/// pavé. Juste si chaque segment porte sa valeur et si la valeur écrite est
/// la bonne.
class GabaritModeleBarres implements GabaritReponse {
  const GabaritModeleBarres();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurModeleBarres creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final inconnue = (donnees['inconnue'] as Map).cast<String, dynamic>();
    return ControleurModeleBarres(
      config: config,
      texte: donnees['texte'] as String?,
      barres: [
        for (final b
            in (donnees['barres'] as List).cast<Map<String, dynamic>>())
          Barre(
            id: b['id'] as String,
            libelle: b['libelle'] as String,
            segments: [
              for (final s
                  in (b['segments'] as List).cast<Map<String, dynamic>>())
                SegmentBarre(id: s['id'] as String, valeur: s['valeur'] as int),
            ],
          ),
      ],
      barreInconnue: inconnue['barre'] as String?,
      segmentInconnu: inconnue['segment'] as String?,
      elements: [
        for (final e
            in (donnees['etiquettes'] as List).cast<Map<String, dynamic>>())
          Proposition.depuisJson(e),
      ],
      attendu: reponse['valeur'] as int,
      melanger: donnees['melanger'] as bool? ?? true,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneModeleBarres(controleur as ControleurModeleBarres);
}

/// Les étiquettes posées sur les segments connus et la valeur écrite pour
/// l'inconnue. Les étiquettes sont comparées par leur texte (deux « 23 »
/// sont interchangeables).
class ControleurModeleBarres extends ControleurGlisser {
  ControleurModeleBarres({
    required super.config,
    required this.barres,
    required super.elements,
    required this.attendu,
    this.texte,
    this.barreInconnue,
    this.segmentInconnu,
    super.melanger,
  });

  final List<Barre> barres;

  /// Le problème, dit après la consigne.
  final String? texte;

  /// L'inconnue : le total d'une barre, ou un segment.
  final String? barreInconnue;
  final String? segmentInconnu;

  /// Valeur attendue pour l'inconnue.
  final int attendu;

  /// Chiffres de la valeur écrite au plus.
  static const chiffresMax = 3;

  final _placements = <String, String>{};
  int? _valeur;

  bool get _revelee => affichage == AffichageReponse.revelee;

  /// Segments connus (à étiqueter), dans l'ordre des barres.
  List<SegmentBarre> get segmentsConnus => [
    for (final b in barres)
      for (final s in b.segments)
        if (s.id != segmentInconnu) s,
  ];

  SegmentBarre segment(String id) =>
      barres.expand((b) => b.segments).firstWhere((s) => s.id == id);

  /// Valeur portée par l'étiquette [id] (`null` si ce n'est pas un nombre).
  int? valeurDe(String id) => int.tryParse(element(id).texte ?? '');

  /// Segment → étiquette, tel que posé (la bonne réponse quand elle est
  /// révélée : chaque segment reçoit une étiquette de sa valeur).
  Map<String, String> get placements {
    if (!_revelee) return _placements;
    final libres = elements.map((e) => e.id).toList();
    final reveles = <String, String>{};
    for (final s in segmentsConnus) {
      final id = libres.firstWhere(
        (e) => valeurDe(e) == s.valeur,
        orElse: () => '',
      );
      if (id.isEmpty) continue;
      libres.remove(id);
      reveles[s.id] = id;
    }
    return reveles;
  }

  /// Étiquette posée sur le segment [segment], `null` si vide.
  String? etiquetteSur(String segment) => placements[segment];

  /// Valeur écrite (la bonne quand la réponse est révélée).
  int? get valeur => _revelee ? attendu : _valeur;

  @override
  void poser(String id, String cible) {
    if (!modifiable || cible == segmentInconnu) return;
    // Une seule étiquette par segment, une étiquette sur un seul segment.
    _placements.removeWhere((s, e) => e == id || s == cible);
    _placements[cible] = id;
    reponseModifiee();
  }

  @override
  void retirer(String id) {
    if (!modifiable) return;
    _placements.removeWhere((s, e) => e == id);
    reponseModifiee();
  }

  @override
  bool estPose(String id) => placements.containsValue(id);

  @override
  bool estJuste(String id) {
    final segment = placements.entries
        .where((e) => e.value == id)
        .map((e) => e.key)
        .firstOrNull;
    return segment != null && this.segment(segment).valeur == valeurDe(id);
  }

  /// Après le 1er essai faux : les étiquettes mal placées reviennent, la
  /// valeur fausse s'efface.
  @override
  void retirerFaux() {
    _placements.removeWhere((s, e) => segment(s).valeur != valeurDe(e));
    if (_valeur != attendu) _valeur = null;
    reponseModifiee();
  }

  void ajouterChiffre(int chiffre) {
    if (!modifiable) return;
    final courant = _valeur;
    if (courant != null && '$courant'.length >= chiffresMax) return;
    _valeur = (courant ?? 0) * 10 + chiffre;
    reponseModifiee();
  }

  void effacerChiffre() {
    if (!modifiable || _valeur == null) return;
    final texte = '$_valeur';
    _valeur = texte.length <= 1
        ? null
        : int.parse(texte.substring(0, texte.length - 1));
    reponseModifiee();
  }

  bool get valeurJuste => _valeur == attendu;

  @override
  bool get complete =>
      segmentsConnus.every((s) => _placements.containsKey(s.id)) &&
      _valeur != null;

  @override
  Object? get reponse => {
    'placements': [
      for (final MapEntry(key: s, value: e) in _placements.entries)
        {'segment': s, 'etiquette': e},
    ],
    'valeur': _valeur,
  };

  @override
  bool corriger() =>
      segmentsConnus.every(
        (s) =>
            _placements[s.id] != null &&
            valeurDe(_placements[s.id]!) == s.valeur,
      ) &&
      _valeur == attendu;

  @override
  void vider() {
    _placements.clear();
    _valeur = null;
    super.vider();
  }

  @override
  String? get ecouteOuverture => texte;

  /// Pour les tests : l'affectation courante, copie.
  @visibleForTesting
  Map<String, String> get placementsCourants => Map.of(_placements);
}

/// Libellés propres au type.
({String inconnue, String Function(String b) barre}) _libellesBarres(
  String langue,
) => switch (langue) {
  'ar' => (inconnue: 'الْمَجْهُولُ', barre: (b) => 'شَرِيطُ $b'),
  'en' => (inconnue: 'unknown', barre: (b) => 'bar of $b'),
  _ => (inconnue: 'inconnue', barre: (b) => 'barre de $b'),
};

/// Le problème, les barres avec leurs segments (cibles) et l'inconnue, la
/// réserve d'étiquettes, puis le pavé.
class _ZoneModeleBarres extends StatelessWidget {
  const _ZoneModeleBarres(this.controleur);

  final ControleurModeleBarres controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final l = _libellesBarres(langue);
    final services = ServicesExercice.of(context);
    final styleTexte = ThemeYasmina.pourLangue(
      langue == 'ar'
          ? StylesYasmina.contentSentence
          : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    final styleLibelle = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    final styleValeur = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final juste = affichage == AffichageReponse.juste || revelee;
        final fauxValeur =
            affichage == AffichageReponse.faux && !controleur.valeurJuste;
        void deposer(String id, String cible) {
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
          controleur.poser(id, cible);
        }

        void poserAttente(String cible) {
          if (controleur.enAttente == null) return;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
          controleur.poserAttente(cible);
        }

        String? motEtat(String id) {
          if (!apercu) return null;
          return switch (controleur.etatDe(id)) {
            EtatGlissable.juste => 'juste',
            EtatGlissable.faux => 'faux',
            _ => null,
          };
        }

        Widget tuile(String id, {bool fantome = false}) {
          final e = controleur.element(id);
          if (fantome) {
            return Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TuileGlissable(
                key: ValueKey('place_$id'),
                id: id,
                etat: EtatGlissable.repos,
                texte: e.texte,
              ),
            );
          }
          final posee = controleur.estPose(id);
          return TuileGlissable(
            key: ValueKey('element_$id'),
            id: id,
            etat: controleur.etatDe(id),
            texte: e.texte,
            motEtat: motEtat(id),
            onToucher: modifiable
                ? () {
                    if (posee) {
                      controleur.retirer(id);
                    } else {
                      controleur.basculerAttente(id);
                    }
                  }
                : null,
            onSorti: modifiable && posee ? () => controleur.retirer(id) : null,
          );
        }

        final plusLong = controleur.barres
            .map((b) => b.total)
            .fold(1, (a, b) => a > b ? a : b);

        Widget segmentW(SegmentBarre s, double largeur) {
          if (s.id == controleur.segmentInconnu) {
            return _CaseInconnue(
              key: const ValueKey('inconnue'),
              largeur: largeur,
              texte: controleur.valeur == null ? '?' : '${controleur.valeur}',
              style: styleValeur,
              bord: juste
                  ? c.olive
                  : fauxValeur
                  ? c.coral
                  : c.blue,
              libelle: l.inconnue,
            );
          }
          final posee = controleur.etiquetteSur(s.id);
          final posJuste = posee != null && controleur.estJuste(posee) && juste;
          return SizedBox(
            width: largeur,
            child: ZoneDepot(
              key: ValueKey('segment_${s.id}'),
              libelle: s.id,
              enLigne: true,
              etat: posJuste ? EtatDepot.juste : EtatDepot.repos,
              onDepot: modifiable ? (id) => deposer(id, s.id) : null,
              onToucher: modifiable ? () => poserAttente(s.id) : null,
              child: SizedBox(
                height: EspacesYasmina.targetMin,
                child: Center(
                  child: posee == null
                      ? const SizedBox.shrink()
                      : FittedBox(fit: BoxFit.scaleDown, child: tuile(posee)),
                ),
              ),
            ),
          );
        }

        Widget barreW(Barre b, double disponible) {
          // Largeur proportionnelle à la valeur, au moins une cible.
          final echelle = disponible / plusLong;
          final largeurs = [
            for (final s in b.segments)
              (s.valeur * echelle).clamp(
                EspacesYasmina.targetMin + 2 * EspacesYasmina.space2,
                disponible,
              ),
          ];
          final inconnue = controleur.barreInconnue == b.id;
          return Column(
            key: ValueKey('barre_${b.id}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: EspacesYasmina.space1,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: EspacesYasmina.space1,
                  children: [
                    for (final (i, s) in b.segments.indexed)
                      segmentW(s, largeurs[i]),
                  ],
                ),
              ),
              if (inconnue)
                // Accolade sous la barre : la valeur de toute la barre est
                // l'inconnue.
                SizedBox(
                  width:
                      largeurs.fold(0.0, (a, w) => a + w) +
                      EspacesYasmina.space1 * (largeurs.length - 1),
                  child: Column(
                    children: [
                      Container(
                        height: EspacesYasmina.space2,
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            start: BorderSide(
                              color: c.ink,
                              width: TraitsYasmina.borderThin,
                            ),
                            end: BorderSide(
                              color: c.ink,
                              width: TraitsYasmina.borderThin,
                            ),
                            bottom: BorderSide(
                              color: c.ink,
                              width: TraitsYasmina.borderThin,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: _CaseInconnue(
                          key: const ValueKey('inconnue'),
                          largeur:
                              EspacesYasmina.targetMin + EspacesYasmina.space8,
                          texte: controleur.valeur == null
                              ? '?'
                              : '${controleur.valeur}',
                          style: styleValeur,
                          bord: juste
                              ? c.olive
                              : fauxValeur
                              ? c.coral
                              : c.blue,
                          libelle: l.inconnue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            if (controleur.texte case final texte?)
              Text(
                texte,
                key: const ValueKey('barres_texte'),
                textAlign: TextAlign.center,
                style: styleTexte,
              ),
            LayoutBuilder(
              key: ValueKey(revelee ? 'manipulables_reponse' : 'barres'),
              builder: (context, contraintes) {
                // Colonne des libellés : un quart de la largeur.
                final libelle = contraintes.maxWidth / 4;
                final disponible =
                    contraintes.maxWidth - libelle - EspacesYasmina.space3;
                return Column(
                  spacing: EspacesYasmina.space3,
                  children: [
                    for (final b in controleur.barres)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: EspacesYasmina.space3,
                        children: [
                          SizedBox(
                            width: libelle,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: EspacesYasmina.space3,
                              ),
                              child: Semantics(
                                label: l.barre(b.libelle),
                                child: Text(
                                  b.libelle,
                                  key: ValueKey('libelle_${b.id}'),
                                  style: styleLibelle,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: barreW(b, disponible)),
                        ],
                      ),
                  ],
                );
              },
            ),
            Wrap(
              key: const ValueKey('reserve'),
              spacing: EspacesYasmina.space2,
              runSpacing: EspacesYasmina.space2,
              children: [
                for (final e in controleur.elements)
                  tuile(e.id, fantome: controleur.estPose(e.id)),
              ],
            ),
            if (apercu && (juste || fauxValeur))
              Text(
                juste ? 'juste' : 'faux',
                key: const ValueKey('barres_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: juste ? c.oliveText : c.coralText,
                ),
              ),
            PaveNumerique(
              libelleEffacer: libelles.effacer,
              onChiffre: modifiable ? controleur.ajouterChiffre : null,
              onEffacer: modifiable && controleur.valeur != null
                  ? controleur.effacerChiffre
                  : null,
            ),
          ],
        );
      },
    );
  }
}

/// La case de l'inconnue : « ? » puis la valeur écrite, bordure `blue`
/// (`olive` juste, `coral` fausse).
class _CaseInconnue extends StatelessWidget {
  const _CaseInconnue({
    super.key,
    required this.largeur,
    required this.texte,
    required this.style,
    required this.bord,
    required this.libelle,
  });

  final double largeur;
  final String texte;
  final TextStyle style;
  final Color bord;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Semantics(
      label: '$libelle $texte',
      excludeSemantics: true,
      child: Container(
        width: largeur,
        height: EspacesYasmina.targetMin,
        decoration: BoxDecoration(
          color: c.tile,
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
          border: Border.all(color: bord, width: TraitsYasmina.borderThick),
        ),
        child: Center(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(texte, style: style),
          ),
        ),
      ),
    );
  }
}
