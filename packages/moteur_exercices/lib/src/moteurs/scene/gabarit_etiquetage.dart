import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../choix/selection_choix.dart';
import '../glisser/controleur_glisser.dart';
import '../glisser/tuile_glissable.dart';
import '../glisser/zone_depot.dart';
import 'scene.dart';

/// T47 Étiqueter un schéma (docs/moteurs/scene-image.md) : l'enfant glisse
/// chaque étiquette sur la zone du schéma qu'elle nomme. Affectation
/// « zones » du moteur Glisser-déposer : une étiquette par zone, étiquettes
/// en trop possibles, seules les étiquettes fausses reviennent.
class GabaritEtiquetage implements GabaritReponse {
  const GabaritEtiquetage();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurEtiquetage creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final scene = donnees['scene'] as Map<String, dynamic>;
    final zones = [
      for (final z in (donnees['zones'] as List).cast<Map<String, dynamic>>())
        ZoneScene.depuisJson(z),
    ];
    return ControleurEtiquetage(
      config: config,
      elementsScene: [
        for (final e
            in (scene['elements'] as List).cast<Map<String, dynamic>>())
          ElementScene.depuisJson(e),
      ],
      zones: zones,
      elements: [
        for (final e
            in (donnees['etiquettes'] as List).cast<Map<String, dynamic>>())
          Proposition.depuisJson(e),
      ],
      cibles: [for (final z in zones) Proposition(id: z.id, texte: z.libelle)],
      attendu: {
        for (final p
            in (reponse['placements'] as List).cast<Map<String, dynamic>>())
          p['etiquette'] as String: p['zone'] as String,
      },
      melanger: donnees['melanger'] as bool? ?? true,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneEtiquetage(controleur as ControleurEtiquetage);
}

/// Affectation étiquette → zone, avec la scène à dessiner.
class ControleurEtiquetage extends ControleurAffectation {
  ControleurEtiquetage({
    required super.config,
    required this.elementsScene,
    required this.zones,
    required super.elements,
    required super.cibles,
    required super.attendu,
    super.melanger,
  }) : super(forme: FormeAffectation.zones);

  final List<ElementScene> elementsScene;
  final List<ZoneScene> zones;

  /// Étiquette posée sur la zone [zone], `null` si vide.
  Proposition? etiquetteSur(String zone) => elementsSur(zone).firstOrNull;
}

/// La scène avec une cible par zone, puis la réserve d'étiquettes.
class _ZoneEtiquetage extends StatelessWidget {
  const _ZoneEtiquetage(this.controleur);

  final ControleurEtiquetage controleur;

  @override
  Widget build(BuildContext context) {
    final config = controleur.config;
    final libelles = LibellesLecteur.pour(config.langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final apercu = config.mode != ModeExercice.enfant;
        final modifiable = controleur.modifiable;
        final affichage = controleur.affichage;
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
          return TuileGlissable(
            key: ValueKey('element_$id'),
            id: id,
            etat: controleur.etatDe(id),
            texte: e.texte,
            motEtat: motEtat(id),
            onToucher: modifiable
                ? () {
                    if (controleur.estPose(id)) {
                      controleur.retirer(id);
                    } else {
                      controleur.basculerAttente(id);
                    }
                  }
                : null,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            KeyedSubtree(
              key: ValueKey(
                affichage == AffichageReponse.revelee
                    ? 'scene_reponse'
                    : 'scene',
              ),
              child: SceneDessinee(
                elements: controleur.elementsScene,
                zones: controleur.zones,
                zone: (z, rect) {
                  final posee = controleur.etiquetteSur(z.id);
                  final juste =
                      posee != null &&
                      controleur.estJuste(posee.id) &&
                      affichage != AffichageReponse.saisie &&
                      affichage != AffichageReponse.faux;
                  return ZoneDepot(
                    key: ValueKey('cible_${z.id}'),
                    libelle:
                        z.libelle ??
                        libelles.image(controleur.zones.indexOf(z) + 1),
                    enLigne: true,
                    etat: juste ? EtatDepot.juste : EtatDepot.repos,
                    onDepot: modifiable ? (id) => deposer(id, z.id) : null,
                    onToucher: modifiable ? () => poserAttente(z.id) : null,
                    // L'étiquette posée garde sa taille et peut déborder
                    // de la zone (les zones d'un schéma sont petites).
                    child: posee == null
                        ? const SizedBox.expand()
                        : OverflowBox(
                            minWidth: 0,
                            maxWidth: double.infinity,
                            minHeight: 0,
                            maxHeight: double.infinity,
                            child: tuile(posee.id),
                          ),
                  );
                },
              ),
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
          ],
        );
      },
    );
  }
}
