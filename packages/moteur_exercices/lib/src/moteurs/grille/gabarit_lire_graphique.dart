import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../saisie/pave_numerique.dart';

/// Une série d'un graphique en barres : une étiquette (emoji ou texte) et
/// une valeur.
class SerieGraphique {
  const SerieGraphique({
    required this.id,
    required this.valeur,
    this.emoji,
    this.texte,
  });

  factory SerieGraphique.depuisJson(Map<String, dynamic> json) =>
      SerieGraphique(
        id: json['id'] as String,
        valeur: json['valeur'] as int,
        emoji: json['emoji'] as String?,
        texte: json['texte'] as String?,
      );

  final String id;
  final int valeur;
  final String? emoji;
  final String? texte;

  String get libelle => texte ?? emoji ?? id;
}

/// T31 Lire un graphique (docs/moteurs/grille-graphiques.md) : un graphique
/// en barres dessiné par le moteur, l'enfant touche la barre qui répond à
/// la question (la plus grande, la plus petite).
class GabaritLireGraphique implements GabaritReponse {
  const GabaritLireGraphique();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurLireGraphique creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurLireGraphique(
      config: config,
      series: [
        for (final s
            in (donnees['series'] as List).cast<Map<String, dynamic>>())
          SerieGraphique.depuisJson(s),
      ],
      maximum: donnees['maximum'] as int? ?? 10,
      orientaux: donnees['chiffres'] == 'orientaux',
      attendue: reponse['serie'] as String,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneLireGraphique(controleur as ControleurLireGraphique);
}

/// La barre choisie.
class ControleurLireGraphique extends ControleurReponse {
  ControleurLireGraphique({
    required this.config,
    required this.series,
    required this.maximum,
    required this.orientaux,
    required this.attendue,
  });

  final ConfigExercice config;
  final List<SerieGraphique> series;

  /// Haut de l'axe des valeurs.
  final int maximum;
  final bool orientaux;
  final String attendue;

  String? _choisie;

  String? get choisie =>
      affichage == AffichageReponse.revelee ? attendue : _choisie;

  void toucher(String id) {
    if (!modifiable) return;
    _choisie = _choisie == id ? null : id;
    reponseModifiee();
  }

  @override
  bool get complete => _choisie != null;

  @override
  Object? get reponse => {'serie': _choisie};

  @override
  bool corriger() => _choisie == attendue;

  @override
  void vider() {
    _choisie = null;
    reponseModifiee();
  }
}

/// Le graphique en barres, chaque barre touchable, puis le mot d'état.
class _ZoneLireGraphique extends StatelessWidget {
  const _ZoneLireGraphique(this.controleur);

  final ControleurLireGraphique controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final juste = affichage == AffichageReponse.juste || revelee;
        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : juste
            ? 'juste'
            : faux
            ? 'faux'
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            GraphiqueBarres(
              key: ValueKey(revelee ? 'grille_reponse' : 'graphique'),
              series: controleur.series,
              valeurs: {for (final s in controleur.series) s.id: s.valeur},
              maximum: controleur.maximum,
              orientaux: controleur.orientaux,
              langue: langue,
              couleurDe: (id) {
                if (controleur.choisie != id) return c.blueSoft;
                if (juste) return c.olive;
                if (faux) return c.coral;
                return c.blue;
              },
              onToucher: modifiable ? controleur.toucher : null,
              choisie: controleur.choisie,
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('grille_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: faux ? c.coralText : c.oliveText,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Graphique en barres partagé par T31 et T32 : un axe gradué de 0 à
/// [maximum] (lignes fines), une barre par série de hauteur [valeurs],
/// l'étiquette (emoji ou texte) sous la barre, chaque colonne touchable
/// ([onToucher], la barre entière) ou cellule par cellule ([onCellule], la
/// hauteur touchée). Les colonnes se lisent de gauche à droite.
class GraphiqueBarres extends StatelessWidget {
  const GraphiqueBarres({
    super.key,
    required this.series,
    required this.valeurs,
    required this.maximum,
    required this.orientaux,
    required this.langue,
    required this.couleurDe,
    this.onToucher,
    this.onCellule,
    this.choisie,
  });

  final List<SerieGraphique> series;
  final Map<String, int> valeurs;
  final int maximum;
  final bool orientaux;
  final String langue;
  final Color Function(String id) couleurDe;
  final ValueChanged<String>? onToucher;

  /// Toucher la cellule de hauteur [niveau] (1 à maximum) de la série.
  final void Function(String id, int niveau)? onCellule;
  final String? choisie;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final styleAxe = ThemeYasmina.pourLangue(
      StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.muted);
    final styleEtiquette = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    // design-ok : hauteur d'une graduation, au moins une cible touchable
    // quand les cellules se touchent une à une.
    final hauteurNiveau = onCellule == null
        ? EspacesYasmina.space8
        : EspacesYasmina.targetMin * 0.75;
    final hauteur = hauteurNiveau * maximum;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          SizedBox(
            height: hauteur,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Axe des valeurs.
                SizedBox(
                  width: EspacesYasmina.space8 + EspacesYasmina.space2,
                  child: Stack(
                    children: [
                      for (var n = 0; n <= maximum; n += maximum >= 10 ? 2 : 1)
                        Positioned(
                          right: EspacesYasmina.space1,
                          bottom: n * hauteurNiveau - EspacesYasmina.space2,
                          child: Text(
                            afficherChiffres('$n', orientaux: orientaux),
                            style: styleAxe,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Lignes de graduation.
                      for (var n = 1; n <= maximum; n++)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: n * hauteurNiveau,
                          child: Divider(
                            height: TraitsYasmina.borderThin,
                            color: c.line,
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final s in series)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: EspacesYasmina.space3,
                                ),
                                child: _Colonne(
                                  serie: s,
                                  valeur: valeurs[s.id] ?? 0,
                                  maximum: maximum,
                                  hauteurNiveau: hauteurNiveau,
                                  couleur: couleurDe(s.id),
                                  choisie: choisie == s.id,
                                  onToucher: onToucher == null
                                      ? null
                                      : () => onToucher!(s.id),
                                  onCellule: onCellule == null
                                      ? null
                                      : (n) => onCellule!(s.id, n),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: TraitsYasmina.borderThick, color: c.ink),
          Row(
            children: [
              const SizedBox(
                width: EspacesYasmina.space8 + EspacesYasmina.space2,
              ),
              for (final s in series)
                Expanded(
                  child: Column(
                    key: ValueKey('etiquette_${s.id}'),
                    children: [
                      if (s.emoji case final e?)
                        Text(e, style: StylesYasmina.contentOption),
                      if (s.texte case final t?)
                        Text(
                          t,
                          style: styleEtiquette,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Une colonne du graphique : la barre (touchable en bloc) ou une pile de
/// cellules touchables une à une.
class _Colonne extends StatelessWidget {
  const _Colonne({
    required this.serie,
    required this.valeur,
    required this.maximum,
    required this.hauteurNiveau,
    required this.couleur,
    required this.choisie,
    this.onToucher,
    this.onCellule,
  });

  final SerieGraphique serie;
  final int valeur;
  final int maximum;
  final double hauteurNiveau;
  final Color couleur;
  final bool choisie;
  final VoidCallback? onToucher;
  final ValueChanged<int>? onCellule;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    if (onCellule != null) {
      // Cellules de haut en bas : la cellule n (1 en bas) remplie si
      // valeur >= n.
      return Column(
        key: ValueKey('barre_${serie.id}'),
        children: [
          for (var n = maximum; n >= 1; n--)
            Semantics(
              button: true,
              label: '${serie.libelle} $n',
              excludeSemantics: true,
              child: GestureDetector(
                key: ValueKey('cellule_${serie.id}_$n'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onCellule!(n),
                child: Container(
                  height: hauteurNiveau,
                  decoration: BoxDecoration(
                    color: valeur >= n ? couleur : c.tile,
                    border: Border.all(
                      color: valeur >= n ? couleur : c.line,
                      width: TraitsYasmina.borderThin,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return Semantics(
      button: onToucher != null,
      selected: choisie,
      label: serie.libelle,
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('barre_${serie.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onToucher,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: valeur * hauteurNiveau,
            decoration: BoxDecoration(
              color: couleur,
              border: Border.all(
                color: choisie ? c.ink : couleur,
                width: TraitsYasmina.borderThick,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(RayonsYasmina.radiusSm),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
