import 'dart:math' as math;

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
import 'scene.dart';

/// T47 Étiqueter un schéma (docs/moteurs/scene-image.md) : l'enfant glisse
/// chaque étiquette dans une case à gauche ou à droite de la scène, reliée
/// par un trait au point du schéma qu'elle nomme, comme dans un manuel. Les
/// cases sont placées par le moteur selon la hauteur des points (le contenu
/// ne donne que les zones). Affectation « zones » du moteur Glisser-déposer :
/// une étiquette par zone, étiquettes en trop possibles, seules les
/// étiquettes fausses reviennent.
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

/// Côté d'une zone : à gauche de la scène si son centre est dans la moitié
/// gauche, sinon à droite. Même règle que le validateur
/// (`etiquettes_superposees`).
bool zoneAGauche(ZoneScene z) => z.x + z.l / 2 < 0.5;

/// Place les cases d'un côté : chaque case vise la hauteur de son point,
/// puis les cases trop proches sont écartées d'au moins [ecart], dans les
/// limites de [hauteur]. [cibles] : haut voulu de chaque case, dans l'ordre
/// des points de haut en bas.
List<double> placerCases(
  List<double> cibles, {
  required double hauteurCase,
  required double ecart,
  required double hauteur,
}) {
  final ys = List.of(cibles);
  for (var i = 0; i < ys.length; i++) {
    final min = i == 0 ? 0.0 : ys[i - 1] + hauteurCase + ecart;
    ys[i] = math.max(ys[i], min);
  }
  for (var i = ys.length - 1; i >= 0; i--) {
    final max = i == ys.length - 1
        ? hauteur - hauteurCase
        : ys[i + 1] - hauteurCase - ecart;
    ys[i] = math.min(ys[i], max);
  }
  return ys;
}

/// Une case (zone de dépôt) à côté de la scène et le trait qui la relie à
/// son point.
class _CaseSchema {
  const _CaseSchema({
    required this.zone,
    required this.rect,
    required this.depart,
    required this.point,
  });

  final ZoneScene zone;

  /// Rectangle de la case dans la figure.
  final Rect rect;

  /// Bord de la case d'où part le trait.
  final Offset depart;

  /// Point désigné sur la scène.
  final Offset point;
}

/// La figure : les cases de gauche, la scène, les cases de droite, les
/// traits par-dessus, puis la réserve d'étiquettes.
class _ZoneEtiquetage extends StatelessWidget {
  const _ZoneEtiquetage(this.controleur);

  final ControleurEtiquetage controleur;

  /// Hauteur d'une case : celle d'une tuile de choix.
  static const hauteurCase = TaillesYasmina.choiceMinHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
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
            // Glissée hors de sa case : elle revient dans la réserve.
            onSorti: modifiable && posee ? () => controleur.retirer(id) : null,
          );
        }

        Widget figure(BoxConstraints contraintes) {
          final total = contraintes.maxWidth;
          // Colonnes des cases : un quart de la largeur, au moins une tuile.
          final colonne = math.max(
            EspacesYasmina.targetMin + 2 * EspacesYasmina.space2,
            total / 4,
          );
          final largeurScene = math.max(
            EspacesYasmina.targetMin,
            total - 2 * (colonne + EspacesYasmina.space2),
          );
          final hauteurScene = largeurScene * 3 / 4;
          final gauche = controleur.zones.where(zoneAGauche).toList()
            ..sort((a, b) => (a.y + a.h / 2).compareTo(b.y + b.h / 2));
          final droite = controleur.zones.where((z) => !zoneAGauche(z)).toList()
            ..sort((a, b) => (a.y + a.h / 2).compareTo(b.y + b.h / 2));
          double hauteurColonne(int n) =>
              n == 0 ? 0 : n * hauteurCase + (n - 1) * EspacesYasmina.space2;
          final hauteurFigure = math.max(
            hauteurScene,
            hauteurColonne(math.max(gauche.length, droite.length)),
          );
          final hautScene = (hauteurFigure - hauteurScene) / 2;
          final gaucheScene = colonne + EspacesYasmina.space2;
          Offset point(ZoneScene z) => Offset(
            gaucheScene + (z.x + z.l / 2) * largeurScene,
            hautScene + (z.y + z.h / 2) * hauteurScene,
          );
          List<_CaseSchema> cases(
            List<ZoneScene> cote, {
            required bool aGauche,
          }) {
            final ys = placerCases(
              [for (final z in cote) point(z).dy - hauteurCase / 2],
              hauteurCase: hauteurCase,
              ecart: EspacesYasmina.space2,
              hauteur: hauteurFigure,
            );
            return [
              for (final (i, z) in cote.indexed)
                _CaseSchema(
                  zone: z,
                  rect: Rect.fromLTWH(
                    aGauche ? 0 : total - colonne,
                    ys[i],
                    colonne,
                    hauteurCase,
                  ),
                  depart: Offset(
                    aGauche ? colonne : total - colonne,
                    ys[i] + hauteurCase / 2,
                  ),
                  point: point(z),
                ),
            ];
          }

          final toutes = [
            ...cases(gauche, aGauche: true),
            ...cases(droite, aGauche: false),
          ];

          return SizedBox(
            width: total,
            height: hauteurFigure,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: gaucheScene,
                  top: hautScene,
                  width: largeurScene,
                  height: hauteurScene,
                  child: SceneDessinee(
                    elements: controleur.elementsScene,
                    zones: const [],
                    zone: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      key: const ValueKey('schema_traits'),
                      painter: _TraitsSchema(
                        traits: [for (final k in toutes) (k.depart, k.point)],
                        couleur: c.ink,
                      ),
                    ),
                  ),
                ),
                for (final k in toutes)
                  Positioned.fromRect(
                    rect: k.rect,
                    child: Builder(
                      builder: (context) {
                        final z = k.zone;
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
                          onDepot: modifiable
                              ? (id) => deposer(id, z.id)
                              : null,
                          onToucher: modifiable
                              ? () => poserAttente(z.id)
                              : null,
                          child: posee == null
                              ? const SizedBox.expand()
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: tuile(posee.id),
                                ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // La figure ne se retourne pas avec la langue : les coordonnées
            // de la scène sont absolues.
            Directionality(
              textDirection: TextDirection.ltr,
              child: KeyedSubtree(
                key: ValueKey(
                  affichage == AffichageReponse.revelee
                      ? 'scene_reponse'
                      : 'scene',
                ),
                child: LayoutBuilder(
                  builder: (context, contraintes) => figure(contraintes),
                ),
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

/// Traits d'un schéma de manuel : de chaque case vers son point, avec un
/// petit disque sur le point.
class _TraitsSchema extends CustomPainter {
  const _TraitsSchema({required this.traits, required this.couleur});

  final List<(Offset, Offset)> traits;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final trait = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThin
      ..strokeCap = StrokeCap.round;
    final disque = Paint()..color = couleur;
    for (final (depart, point) in traits) {
      canvas.drawLine(depart, point, trait);
      canvas.drawCircle(point, EspacesYasmina.space1, disque);
    }
  }

  @override
  bool shouldRepaint(_TraitsSchema ancien) =>
      ancien.couleur != couleur ||
      ancien.traits.toString() != traits.toString();
}
