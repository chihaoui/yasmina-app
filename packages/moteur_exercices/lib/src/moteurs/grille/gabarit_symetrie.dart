import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Une case d'un quadrillage : (ligne, colonne), à partir de 0.
typedef Case = (int, int);

/// T33 Symétrie (docs/moteurs/grille-graphiques.md) : un quadrillage avec un
/// axe vertical au milieu, des cases données d'un côté (grises). L'enfant
/// touche les cases de l'autre côté pour les colorier (re-toucher les
/// décolorie). Juste si les cases coloriées sont exactement les symétriques
/// des cases données.
class GabaritSymetrie implements GabaritReponse {
  const GabaritSymetrie();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurSymetrie creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurSymetrie(
      config: config,
      lignes: donnees['lignes'] as int,
      colonnes: donnees['colonnes'] as int,
      donneesFixes: {
        for (final c in (donnees['cases'] as List).cast<List>())
          (c[0] as int, c[1] as int),
      },
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneSymetrie(controleur as ControleurSymetrie);
}

/// Les cases coloriées par l'enfant.
class ControleurSymetrie extends ControleurReponse {
  ControleurSymetrie({
    required this.config,
    required this.lignes,
    required this.colonnes,
    required this.donneesFixes,
  }) : attendues = {for (final c in donneesFixes) (c.$1, colonnes - 1 - c.$2)};

  final ConfigExercice config;
  final int lignes;

  /// Nombre pair de colonnes : l'axe passe au milieu.
  final int colonnes;

  /// Cases données (à gauche de l'axe).
  final Set<Case> donneesFixes;

  /// Leurs symétriques, à colorier.
  final Set<Case> attendues;

  final _coloriees = <Case>{};

  Set<Case> get coloriees =>
      affichage == AffichageReponse.revelee ? attendues : _coloriees;

  bool estFixe(Case c) => donneesFixes.contains(c);
  bool estColoriee(Case c) => coloriees.contains(c);
  bool estJuste(Case c) => attendues.contains(c);

  /// Côté gauche de l'axe (cases données, non modifiables).
  bool aGauche(Case c) => c.$2 < colonnes ~/ 2;

  void basculer(Case c) {
    if (!modifiable || aGauche(c)) return;
    if (!_coloriees.remove(c)) _coloriees.add(c);
    reponseModifiee();
  }

  /// Après le 1er essai faux : les cases fausses s'effacent.
  @override
  void retirerFaux() {
    _coloriees.removeWhere((c) => !attendues.contains(c));
    reponseModifiee();
  }

  @override
  bool get complete => _coloriees.isNotEmpty;

  @override
  Object? get reponse => {
    'cases': [
      for (final c
          in _coloriees.toList()
            ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2))
        [c.$1, c.$2],
    ],
  };

  @override
  bool corriger() => setEquals(_coloriees, attendues);

  @override
  void vider() {
    _coloriees.clear();
    reponseModifiee();
  }
}

/// Libellé d'une case pour le lecteur d'écran.
String _libelleCase(String langue, Case c) => switch (langue) {
  'ar' => 'خَانَةٌ ${c.$1 + 1} ${c.$2 + 1}',
  'en' => 'cell ${c.$1 + 1} ${c.$2 + 1}',
  _ => 'case ${c.$1 + 1} ${c.$2 + 1}',
};

/// Le quadrillage et son axe.
class _ZoneSymetrie extends StatelessWidget {
  const _ZoneSymetrie(this.controleur);

  final ControleurSymetrie controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final services = ServicesExercice.of(context);
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
        Color couleurDe(Case k) {
          if (controleur.estFixe(k)) return c.muted;
          if (!controleur.estColoriee(k)) return c.tile;
          if (juste) return c.olive;
          if (affichage == AffichageReponse.faux && !controleur.estJuste(k)) {
            return c.coral;
          }
          return c.blue;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // Le quadrillage ne se retourne pas avec la langue.
            Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, contraintes) {
                  final cote = contraintes.maxWidth / controleur.colonnes;
                  return Stack(
                    key: ValueKey(revelee ? 'grille_reponse' : 'quadrillage'),
                    children: [
                      Column(
                        children: [
                          for (var l = 0; l < controleur.lignes; l++)
                            Row(
                              children: [
                                for (var k = 0; k < controleur.colonnes; k++)
                                  Semantics(
                                    button: !controleur.aGauche((l, k)),
                                    enabled: modifiable,
                                    selected: controleur.estColoriee((l, k)),
                                    label: _libelleCase(langue, (l, k)),
                                    excludeSemantics: true,
                                    child: GestureDetector(
                                      key: ValueKey('case_${l}_$k'),
                                      behavior: HitTestBehavior.opaque,
                                      onTap:
                                          modifiable &&
                                              !controleur.aGauche((l, k))
                                          ? () {
                                              controleur.basculer((l, k));
                                              services.vibration.legere();
                                              services.audio.jouerSon(
                                                SonInterface.depot,
                                              );
                                            }
                                          : null,
                                      child: Container(
                                        width: cote,
                                        height: cote,
                                        decoration: BoxDecoration(
                                          color: couleurDe((l, k)),
                                          border: Border.all(
                                            color: c.line,
                                            width: TraitsYasmina.borderThin,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                      // L'axe de symétrie, au milieu, en coral.
                      Positioned(
                        left:
                            cote * (controleur.colonnes / 2) -
                            TraitsYasmina.borderFeedback / 2,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            key: const ValueKey('axe'),
                            width: TraitsYasmina.borderFeedback,
                            color: c.coral,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
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
