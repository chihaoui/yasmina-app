import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'gabarit_hot_spot.dart';
import 'scene.dart';

/// T53 Écoute et place (docs/moteurs/scene-image.md §14) : l'enfant écoute
/// une consigne de position (« Put the cat under the table »), puis touche
/// **une seule fois** l'emplacement de la scène où va l'objet : l'objet s'y
/// pose. Un autre toucher le déplace, le même emplacement touché à nouveau
/// le retire. Juste si l'emplacement est celui attendu.
class GabaritEcoutePlace implements GabaritReponse {
  const GabaritEcoutePlace();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurPlace creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final scene = donnees['scene'] as Map<String, dynamic>;
    final objet = donnees['objet'] as Map<String, dynamic>;
    return ControleurPlace(
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
      emoji: objet['emoji'] as String,
      libelleObjet: objet['libelle'] as String?,
      ecoute: (donnees['ecoute'] as Map<String, dynamic>)['texte'] as String,
      attendue: reponse['zone'] as String,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneEcoutePlace(controleur as ControleurPlace);
}

/// L'emplacement choisi pour l'objet.
class ControleurPlace extends ControleurReponse {
  ControleurPlace({
    required this.config,
    required this.elements,
    required this.zones,
    required this.emoji,
    required this.ecoute,
    required this.attendue,
    this.libelleObjet,
  });

  final ConfigExercice config;
  final List<ElementScene> elements;
  final List<ZoneScene> zones;

  /// L'objet à placer et son nom (sous-titre).
  final String emoji;
  final String? libelleObjet;

  /// La consigne entendue, jamais affichée.
  final String ecoute;
  final String attendue;

  String? _choisie;

  /// Emplacement de l'objet (celui attendu quand la réponse est révélée).
  String? get choisie =>
      affichage == AffichageReponse.revelee ? attendue : _choisie;

  /// Toucher l'emplacement [id] : l'objet s'y pose, ou s'en retire s'il y
  /// était déjà.
  void toucher(String id) {
    if (!modifiable) return;
    _choisie = _choisie == id ? null : id;
    reponseModifiee();
  }

  @override
  bool get complete => _choisie != null;

  @override
  Object? get reponse => {'zone': _choisie};

  @override
  bool corriger() => _choisie == attendue;

  @override
  void vider() {
    _choisie = null;
    reponseModifiee();
  }

  @override
  String? get ecouteOuverture => ecoute;
}

/// L'objet à placer, Écouter, puis la scène et ses emplacements.
class _ZoneEcoutePlace extends StatelessWidget {
  const _ZoneEcoutePlace(this.controleur);

  final ControleurPlace controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    final styleNom = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        EtatZone etatDe(String id) {
          final choisie = controleur.choisie == id;
          return switch (affichage) {
            AffichageReponse.saisie =>
              choisie ? EtatZone.selectionnee : EtatZone.repos,
            AffichageReponse.juste => choisie ? EtatZone.juste : EtatZone.repos,
            AffichageReponse.faux =>
              !choisie
                  ? EtatZone.repos
                  : id == controleur.attendue
                  ? EtatZone.juste
                  : EtatZone.faux,
            AffichageReponse.revelee =>
              id == controleur.attendue ? EtatZone.juste : EtatZone.repos,
          };
        }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: EspacesYasmina.space4,
              children: [
                // L'objet à placer, en grand, avec son nom.
                Semantics(
                  label: controleur.libelleObjet ?? libelles.image(1),
                  excludeSemantics: true,
                  child: Column(
                    key: const ValueKey('objet'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controleur.emoji, style: StylesYasmina.letterHero),
                      if (controleur.libelleObjet case final nom?)
                        Text(nom, style: styleNom),
                    ],
                  ),
                ),
                BoutonEcouter(
                  key: const ValueKey('place_ecouter'),
                  libelle: libelles.ecouter,
                  onPressed: () => controleur.demanderAudio(
                    controleur.ecoute,
                    langue: langue,
                  ),
                ),
              ],
            ),
            KeyedSubtree(
              key: ValueKey(
                affichage == AffichageReponse.revelee
                    ? 'scene_reponse'
                    : 'scene',
              ),
              child: SceneDessinee(
                elements: controleur.elements,
                zones: controleur.zones,
                zone: (z, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    ZoneTouchable(
                      key: ValueKey('zone_${z.id}'),
                      etat: etatDe(z.id),
                      // Libellé neutre : le nom de l'emplacement donnerait
                      // la réponse.
                      libelle: libelles.image(controleur.zones.indexOf(z) + 1),
                      onTap: controleur.modifiable
                          ? () {
                              controleur.toucher(z.id);
                              if (controleur.choisie == z.id) {
                                services.vibration.legere();
                                services.audio.jouerSon(SonInterface.depot);
                              }
                            }
                          : null,
                    ),
                    // L'objet posé sur l'emplacement choisi.
                    if (controleur.choisie == z.id)
                      IgnorePointer(
                        child: Center(
                          child: FittedBox(
                            key: ValueKey('objet_pose_${z.id}'),
                            fit: BoxFit.scaleDown,
                            child: Text(
                              controleur.emoji,
                              style: StylesYasmina.letterHero,
                            ),
                          ),
                        ),
                      ),
                  ],
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
