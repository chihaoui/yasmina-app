import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'scene.dart';

/// T08 Hot spot sur image (docs/moteurs/scene-image.md) : l'enfant touche
/// la zone demandée de la scène (plusieurs zones si `plusieurs`).
class GabaritHotSpot implements GabaritReponse {
  const GabaritHotSpot();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurZones creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final scene = donnees['scene'] as Map<String, dynamic>;
    return ControleurZones(
      config: config,
      elements: [
        for (final e
            in (scene['elements'] as List).cast<Map<String, dynamic>>())
          ElementScene.depuisJson(e),
      ],
      zones: [
        for (final z in (donnees['zones'] as List).cast<Map<String, dynamic>>())
          ZoneScene.depuisJson(z),
      ],
      attendues: (reponse['zones'] as List).cast<String>().toSet(),
      plusieurs: donnees['plusieurs'] as bool? ?? false,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneHotSpot(controleur as ControleurZones);
}

/// Zones sélectionnées.
class ControleurZones extends ControleurReponse {
  ControleurZones({
    required this.config,
    required this.elements,
    required this.zones,
    required this.attendues,
    required this.plusieurs,
  });

  final ConfigExercice config;
  final List<ElementScene> elements;
  final List<ZoneScene> zones;
  final Set<String> attendues;
  final bool plusieurs;

  final _selection = <String>{};

  Set<String> get selection =>
      affichage == AffichageReponse.revelee ? attendues : _selection;

  void basculer(String id) {
    if (!modifiable) return;
    if (!plusieurs) {
      final deja = _selection.contains(id);
      _selection.clear();
      if (!deja) _selection.add(id);
    } else if (!_selection.remove(id)) {
      _selection.add(id);
    }
    reponseModifiee();
  }

  @override
  bool get complete => _selection.isNotEmpty;

  @override
  Object? get reponse => {'zones': (_selection.toList()..sort())};

  @override
  bool corriger() =>
      _selection.length == attendues.length &&
      _selection.containsAll(attendues);

  @override
  void vider() {
    _selection.clear();
    reponseModifiee();
  }
}

/// État visuel d'une zone touchable.
enum EtatZone { repos, selectionnee, juste, faux }

/// Une zone de la scène (docs/moteurs/scene-image.md §11) : contour `line`
/// au repos, `blue-soft` sélectionnée, `olive-soft` juste, `coral-soft`
/// faux. Libellé neutre pour le lecteur d'écran.
class ZoneTouchable extends StatelessWidget {
  const ZoneTouchable({
    super.key,
    required this.etat,
    required this.libelle,
    this.onTap,
  });

  final EtatZone etat;
  final String libelle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, bord) = switch (etat) {
      EtatZone.repos => (Colors.transparent, c.line),
      EtatZone.selectionnee => (c.blueSoft, c.blue),
      EtatZone.juste => (c.oliveSoft, c.olive),
      EtatZone.faux => (c.coralSoft, c.coral),
    };
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: etat == EtatZone.selectionnee,
      label: libelle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // design-ok : fond translucide pour laisser voir la scène
            // (question 2 de scene-image-questions.md).
            color: fond.withValues(alpha: etat == EtatZone.repos ? 0 : 0.5),
            borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
            border: Border.all(color: bord, width: TraitsYasmina.borderThick),
          ),
        ),
      ),
    );
  }
}

/// La scène et ses zones touchables, puis le mot d'état en aperçu.
class _ZoneHotSpot extends StatelessWidget {
  const _ZoneHotSpot(this.controleur);

  final ControleurZones controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final libelles = LibellesLecteur.pour(config.langue, config.formeAdresse);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        EtatZone etatDe(String id) {
          final choisie = controleur.selection.contains(id);
          return switch (affichage) {
            AffichageReponse.saisie =>
              choisie ? EtatZone.selectionnee : EtatZone.repos,
            AffichageReponse.juste => choisie ? EtatZone.juste : EtatZone.repos,
            AffichageReponse.faux =>
              !choisie
                  ? EtatZone.repos
                  : controleur.attendues.contains(id)
                  ? EtatZone.juste
                  : EtatZone.faux,
            AffichageReponse.revelee =>
              controleur.attendues.contains(id)
                  ? EtatZone.juste
                  : EtatZone.repos,
          };
        }

        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : switch (affichage) {
                AffichageReponse.juste || AffichageReponse.revelee => 'juste',
                AffichageReponse.faux when faux => 'faux',
                _ => null,
              };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space3,
          children: [
            KeyedSubtree(
              key: ValueKey(
                affichage == AffichageReponse.revelee
                    ? 'scene_reponse'
                    : 'scene',
              ),
              child: SceneDessinee(
                elements: controleur.elements,
                zones: controleur.zones,
                zone: (z, _) => ZoneTouchable(
                  key: ValueKey('zone_${z.id}'),
                  etat: etatDe(z.id),
                  // Libellé neutre : le nom de la zone donnerait la réponse.
                  libelle: libelles.image(controleur.zones.indexOf(z) + 1),
                  onTap: controleur.modifiable
                      ? () => controleur.basculer(z.id)
                      : null,
                ),
              ),
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('scene_mot_etat'),
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
