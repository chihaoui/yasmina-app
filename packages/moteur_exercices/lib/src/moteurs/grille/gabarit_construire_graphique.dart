import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../saisie/pave_numerique.dart';
import 'gabarit_lire_graphique.dart';

/// T32 Construire un graphique (docs/moteurs/grille-graphiques.md) : un
/// tableau de valeurs, un graphique vide quadrillé. L'enfant touche, dans
/// chaque colonne, la cellule de la hauteur voulue : la barre monte jusque
/// là (toucher la cellule du haut d'une barre la baisse d'un cran). Juste
/// si chaque barre a la valeur du tableau.
class GabaritConstruireGraphique implements GabaritReponse {
  const GabaritConstruireGraphique();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurConstruireGraphique creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurConstruireGraphique(
      config: config,
      series: [
        for (final s
            in (donnees['series'] as List).cast<Map<String, dynamic>>())
          SerieGraphique.depuisJson(s),
      ],
      maximum: donnees['maximum'] as int? ?? 6,
      orientaux: donnees['chiffres'] == 'orientaux',
      attendu: {
        for (final v
            in (reponse['valeurs'] as List).cast<Map<String, dynamic>>())
          v['serie'] as String: v['valeur'] as int,
      },
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneConstruireGraphique(controleur as ControleurConstruireGraphique);
}

/// La hauteur de chaque barre.
class ControleurConstruireGraphique extends ControleurReponse {
  ControleurConstruireGraphique({
    required this.config,
    required this.series,
    required this.maximum,
    required this.orientaux,
    required this.attendu,
  });

  final ConfigExercice config;
  final List<SerieGraphique> series;
  final int maximum;
  final bool orientaux;

  /// Série → valeur attendue.
  final Map<String, int> attendu;

  final _valeurs = <String, int>{};

  /// Série → hauteur de la barre (la réponse quand elle est révélée).
  Map<String, int> get valeurs =>
      affichage == AffichageReponse.revelee ? attendu : _valeurs;

  /// Toucher la cellule [niveau] de la série [id] : la barre monte jusque
  /// là, ou baisse d'un cran si c'est déjà son sommet.
  void toucher(String id, int niveau) {
    if (!modifiable) return;
    final courant = _valeurs[id] ?? 0;
    final nouveau = courant == niveau ? niveau - 1 : niveau;
    if (nouveau <= 0) {
      _valeurs.remove(id);
    } else {
      _valeurs[id] = nouveau;
    }
    reponseModifiee();
  }

  bool estJuste(String id) => _valeurs[id] == attendu[id];

  /// Après le 1er essai faux : seules les barres fausses redescendent.
  @override
  void retirerFaux() {
    _valeurs.removeWhere((id, v) => attendu[id] != v);
    reponseModifiee();
  }

  @override
  bool get complete => series.every((s) => (_valeurs[s.id] ?? 0) > 0);

  @override
  Object? get reponse => {
    'valeurs': [
      for (final s in series) {'serie': s.id, 'valeur': _valeurs[s.id] ?? 0},
    ],
  };

  @override
  bool corriger() => mapEquals(_valeurs, attendu);

  @override
  void vider() {
    _valeurs.clear();
    reponseModifiee();
  }
}

/// Le tableau des valeurs, puis le graphique à construire.
class _ZoneConstruireGraphique extends StatelessWidget {
  const _ZoneConstruireGraphique(this.controleur);

  final ControleurConstruireGraphique controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final services = ServicesExercice.of(context);
    final styleTableau = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
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
        final fauxGlobal =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : juste
            ? 'juste'
            : fauxGlobal
            ? 'faux'
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // Le tableau : une ligne par série, l'étiquette et la valeur.
            Table(
              key: const ValueKey('tableau'),
              border: TableBorder.all(
                color: c.line,
                width: TraitsYasmina.borderThin,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    for (final s in controleur.series)
                      Padding(
                        padding: const EdgeInsets.all(EspacesYasmina.space2),
                        child: Text(
                          s.libelle,
                          textAlign: TextAlign.center,
                          style: styleTableau,
                        ),
                      ),
                  ],
                ),
                TableRow(
                  children: [
                    for (final s in controleur.series)
                      Padding(
                        padding: const EdgeInsets.all(EspacesYasmina.space2),
                        child: Text(
                          afficherChiffres(
                            '${controleur.attendu[s.id]}',
                            orientaux: controleur.orientaux,
                          ),
                          key: ValueKey('tableau_${s.id}'),
                          textAlign: TextAlign.center,
                          style: styleTableau,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            GraphiqueBarres(
              key: ValueKey(revelee ? 'grille_reponse' : 'graphique'),
              series: controleur.series,
              valeurs: controleur.valeurs,
              maximum: controleur.maximum,
              orientaux: controleur.orientaux,
              langue: langue,
              couleurDe: (id) {
                if (juste) return c.olive;
                if (affichage == AffichageReponse.faux &&
                    !controleur.estJuste(id)) {
                  return c.coral;
                }
                return c.blue;
              },
              onCellule: modifiable
                  ? (id, n) {
                      controleur.toucher(id, n);
                      services.vibration.legere();
                      services.audio.jouerSon(SonInterface.depot);
                    }
                  : null,
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('grille_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: fauxGlobal ? c.coralText : c.oliveText,
                ),
              ),
          ],
        );
      },
    );
  }
}
