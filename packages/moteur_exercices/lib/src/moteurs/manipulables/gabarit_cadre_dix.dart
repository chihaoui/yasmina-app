import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../glisser/zone_depot.dart';
import 'materiel.dart';

/// T51 Cadre de 10 (docs/moteurs/manipulables.md) : l'enfant glisse un
/// jeton de la réserve dans une case vide (ou touche la case), et retire un
/// jeton posé en le touchant. Juste si le nombre de jetons est la cible.
class GabaritCadreDix implements GabaritReponse {
  const GabaritCadreDix();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurJetons creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurJetons(config: config, cible: donnees['cible'] as int);
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneCadreDix(controleur as ControleurJetons);
}

/// Cases du cadre (0 à 9) qui portent un jeton.
class ControleurJetons extends ControleurReponse {
  ControleurJetons({required this.config, required this.cible});

  final ConfigExercice config;
  final int cible;

  static const cases = 10;

  final _pleines = <int>{};

  /// Cases pleines (la bonne réponse, remplie depuis le début de ligne,
  /// quand elle est révélée).
  Set<int> get pleines => affichage == AffichageReponse.revelee
      ? {for (var i = 0; i < cible; i++) i}
      : _pleines;

  int get jetons => pleines.length;

  bool estPleine(int i) => pleines.contains(i);

  /// Pose un jeton dans la case [i] si elle est vide.
  bool poser(int i) {
    if (!modifiable || _pleines.contains(i)) return false;
    _pleines.add(i);
    reponseModifiee();
    return true;
  }

  void retirer(int i) {
    if (!modifiable) return;
    _pleines.remove(i);
    reponseModifiee();
  }

  @override
  bool get complete => _pleines.isNotEmpty;

  @override
  Object? get reponse => {'jetons': _pleines.length};

  @override
  bool corriger() => _pleines.length == cible;

  @override
  void vider() {
    _pleines.clear();
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String jeton, String Function(int n) caseN}) _libellesCadre(String langue) =>
    switch (langue) {
      'ar' => (jeton: 'قِطْعَةٌ', caseN: (n) => 'خَانَةٌ $n'),
      'en' => (jeton: 'counter', caseN: (n) => 'cell $n'),
      _ => (jeton: 'jeton', caseN: (n) => 'case $n'),
    };

/// La réserve (un jeton) au début de ligne, puis le cadre de deux lignes de
/// cinq cases, remplies dans le sens d'écriture.
class _ZoneCadreDix extends StatelessWidget {
  const _ZoneCadreDix(this.controleur);

  final ControleurJetons controleur;

  @override
  Widget build(BuildContext context) {
    final config = controleur.config;
    final l = _libellesCadre(config.langue);
    final services = ServicesExercice.of(context);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final etat = switch (affichage) {
          AffichageReponse.juste ||
          AffichageReponse.revelee => EtatMateriel.juste,
          AffichageReponse.faux when !controleur.corriger() =>
            EtatMateriel.faux,
          _ => EtatMateriel.repos,
        };
        final motEtat = !apercu
            ? null
            : switch (etat) {
                EtatMateriel.juste => 'juste',
                EtatMateriel.faux => 'faux',
                EtatMateriel.repos => null,
              };
        void poser(int i) {
          if (!controleur.poser(i)) return;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
        }

        Widget caseW(int i) {
          final pleine = controleur.estPleine(i);
          return ZoneDepot(
            key: ValueKey('case_$i'),
            libelle: l.caseN(i + 1),
            etat: pleine && etat == EtatMateriel.juste
                ? EtatDepot.juste
                : EtatDepot.repos,
            onDepot: modifiable && !pleine ? (_) => poser(i) : null,
            onToucher: modifiable && !pleine ? () => poser(i) : null,
            // Marge réduite : cinq cases tiennent dans la largeur du
            // cadre de téléphone.
            enLigne: true,
            child: SizedBox(
              width: EspacesYasmina.targetMin,
              height: EspacesYasmina.targetMin,
              child: pleine
                  ? Pose(
                      key: ValueKey('jeton_$i'),
                      libelle: l.jeton,
                      onToucher: modifiable
                          ? () => controleur.retirer(i)
                          : null,
                      child: Jeton(etat: etat),
                    )
                  : null,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // La réserve au-dessus du cadre, au début de ligne.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ReserveGlissable(
                key: const ValueKey('reserve_jeton'),
                donnee: 'jeton',
                libelle: l.jeton,
                // Toucher la réserve pose dans la première case vide.
                onToucher:
                    modifiable && controleur.jetons < ControleurJetons.cases
                    ? () {
                        for (var i = 0; i < ControleurJetons.cases; i++) {
                          if (!controleur.estPleine(i)) {
                            poser(i);
                            return;
                          }
                        }
                      }
                    : null,
                child: const Jeton(),
              ),
            ),
            Column(
              key: ValueKey(
                affichage == AffichageReponse.revelee
                    ? 'manipulables_reponse'
                    : 'cadre',
              ),
              spacing: EspacesYasmina.space2,
              children: [
                for (final ligne in [0, 1])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: EspacesYasmina.space2,
                    children: [
                      for (var k = 0; k < 5; k++) caseW(ligne * 5 + k),
                    ],
                  ),
              ],
            ),
            motEtatMateriel(context, motEtat, faux: etat == EtatMateriel.faux),
          ],
        );
      },
    );
  }
}
