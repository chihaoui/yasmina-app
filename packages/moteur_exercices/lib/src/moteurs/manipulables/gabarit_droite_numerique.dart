import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// T25 Droite numérique (docs/moteurs/manipulables.md) : l'enfant glisse le
/// repère le long de la droite (il s'aimante à la graduation la plus proche
/// au lâcher) ou touche une graduation. Juste si la valeur est la cible.
class GabaritDroiteNumerique implements GabaritReponse {
  const GabaritDroiteNumerique();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurDroiteNumerique creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurDroiteNumerique(
      config: config,
      min: donnees['min'] as int,
      max: donnees['max'] as int,
      pas: donnees['pas'] as int? ?? 1,
      reperes: donnees['reperes'] as int? ?? 5,
      cible: donnees['cible'] as int,
      // Sens de la droite, configurable (question 1 de
      // manipulables-questions.md) : min à gauche par défaut.
      minAGauche: donnees['sens'] != 'droite-gauche',
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneDroite(controleur as ControleurDroiteNumerique);
}

/// Position du repère sur la droite : une valeur posée, ou aucune.
class ControleurDroiteNumerique extends ControleurReponse {
  ControleurDroiteNumerique({
    required this.config,
    required this.min,
    required this.max,
    required this.pas,
    required this.reperes,
    required this.cible,
    required this.minAGauche,
  });

  final ConfigExercice config;
  final int min;
  final int max;
  final int pas;

  /// Une étiquette toutes les [reperes] valeurs (et toujours aux deux
  /// bouts).
  final int reperes;
  final int cible;

  /// `min` à gauche (sens `gauche-droite`) ou à droite.
  final bool minAGauche;

  int? _valeur;

  /// Position du doigt le long de la droite pendant un glisser (0 à 1, de
  /// gauche à droite), `null` sinon.
  double? _tenue;

  /// Nombre de graduations, bouts compris.
  int get graduations => (max - min) ~/ pas + 1;

  /// Valeur du repère (la cible quand la réponse est révélée), `null` tant
  /// qu'il n'est pas posé.
  int? get valeur => affichage == AffichageReponse.revelee ? cible : _valeur;

  double? get tenue => _tenue;

  /// Position (0 à 1, de gauche à droite) de la valeur [v] sur la droite.
  double position(int v) {
    final t = (v - min) / (max - min);
    return minAGauche ? t : 1 - t;
  }

  /// Graduation la plus proche de la position [x] (0 à 1, de gauche à
  /// droite) : l'aimant.
  int valeurA(double x) {
    final t = (minAGauche ? x : 1 - x).clamp(0.0, 1.0);
    return min + (t * (graduations - 1)).round() * pas;
  }

  /// Le repère suit le doigt.
  void tenir(double x) {
    if (!modifiable) return;
    _tenue = x.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Le repère est lâché : il s'aimante à la graduation la plus proche.
  void poser(double x) {
    if (!modifiable) return;
    _tenue = null;
    _valeur = valeurA(x);
    reponseModifiee();
  }

  @override
  bool get complete => _valeur != null;

  @override
  Object? get reponse => {'valeur': _valeur};

  @override
  bool corriger() => _valeur == cible;

  /// Tout revient à l'état de départ (manipulables.md §6).
  @override
  void vider() {
    _valeur = null;
    _tenue = null;
    reponseModifiee();
  }
}

/// La droite graduée et son repère, toujours de gauche à droite (les
/// chiffres ne se retournent pas), puis rien d'autre : la consigne porte le
/// nombre.
class _ZoneDroite extends StatelessWidget {
  const _ZoneDroite(this.controleur);

  final ControleurDroiteNumerique controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final apercu = config.mode != ModeExercice.enfant;
        final couleurRepere = switch (controleur.affichage) {
          AffichageReponse.juste || AffichageReponse.revelee => c.olive,
          AffichageReponse.faux => c.coral,
          AffichageReponse.saisie =>
            controleur.valeur == null && controleur.tenue == null
                ? c.muted
                : c.blue,
        };
        final motEtat = !apercu
            ? null
            : switch (controleur.affichage) {
                AffichageReponse.juste || AffichageReponse.revelee => 'juste',
                AffichageReponse.faux => 'faux',
                AffichageReponse.saisie => null,
              };
        void poser(double x) {
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
          controleur.poser(x);
        }

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: EspacesYasmina.space3,
            children: [
              AspectRatio(
                aspectRatio: 3,
                child: LayoutBuilder(
                  builder: (context, contraintes) {
                    final largeur = contraintes.maxWidth;
                    double normaliser(Offset p) =>
                        ((p.dx - PeintreDroite.marge) /
                                (largeur - 2 * PeintreDroite.marge))
                            .clamp(0.0, 1.0);
                    return Semantics(
                      slider: true,
                      label: libelles.verifier,
                      value: '${controleur.valeur ?? ''}',
                      child: GestureDetector(
                        key: const ValueKey('droite'),
                        behavior: HitTestBehavior.opaque,
                        onTapDown: modifiable
                            ? (d) => poser(normaliser(d.localPosition))
                            : null,
                        onPanStart: modifiable
                            ? (d) =>
                                  controleur.tenir(normaliser(d.localPosition))
                            : null,
                        onPanUpdate: modifiable
                            ? (d) =>
                                  controleur.tenir(normaliser(d.localPosition))
                            : null,
                        onPanEnd: modifiable
                            ? (d) => poser(normaliser(d.localPosition))
                            : null,
                        onPanCancel: modifiable
                            ? () => controleur.tenir(controleur.tenue ?? 0)
                            : null,
                        child: CustomPaint(
                          key: ValueKey(
                            revelee ? 'droite_reponse' : 'droite_dessin',
                          ),
                          size: Size.infinite,
                          painter: PeintreDroite(
                            min: controleur.min,
                            max: controleur.max,
                            pas: controleur.pas,
                            reperes: controleur.reperes,
                            minAGauche: controleur.minAGauche,
                            valeur: controleur.valeur,
                            tenue: controleur.tenue,
                            positionDe: controleur.position,
                            couleurTrait: c.ink,
                            couleurGraduation: c.line,
                            couleurRepere: couleurRepere,
                            styleEtiquette: ThemeYasmina.pourLangue(
                              StylesYasmina.option,
                              langue,
                            ).copyWith(color: c.ink),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (motEtat != null)
                Text(
                  motEtat,
                  key: const ValueKey('droite_mot_etat'),
                  textAlign: TextAlign.center,
                  style: StylesYasmina.latinLabel.copyWith(
                    color: controleur.affichage == AffichageReponse.faux
                        ? c.coralText
                        : c.oliveText,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Peint la droite (trait, graduations, étiquettes) et le repère : à sa
/// valeur, ou sous le doigt pendant un glisser, ou au début de la droite
/// tant qu'il n'est pas posé.
class PeintreDroite extends CustomPainter {
  const PeintreDroite({
    required this.min,
    required this.max,
    required this.pas,
    required this.reperes,
    required this.minAGauche,
    required this.valeur,
    required this.tenue,
    required this.positionDe,
    required this.couleurTrait,
    required this.couleurGraduation,
    required this.couleurRepere,
    required this.styleEtiquette,
  });

  final int min;
  final int max;
  final int pas;
  final int reperes;
  final bool minAGauche;
  final int? valeur;
  final double? tenue;
  final double Function(int valeur) positionDe;
  final Color couleurTrait;
  final Color couleurGraduation;
  final Color couleurRepere;
  final TextStyle styleEtiquette;

  /// Marge de chaque côté de la droite, pour les étiquettes des bouts.
  static const marge = EspacesYasmina.space6;

  /// Abscisse (en pixels) d'une position 0 à 1.
  static double abscisse(double position, double largeur) =>
      marge + position * (largeur - 2 * marge);

  /// Valeurs étiquetées : tous les [reperes], et les deux bouts.
  List<int> get etiquettes => [
    for (var v = min; v <= max; v += pas)
      if ((v - min) % reperes == 0 || v == max) v,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final trait = Paint()
      ..color = couleurTrait
      ..strokeWidth = TraitsYasmina.borderThick
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(abscisse(0, size.width), y),
      Offset(abscisse(1, size.width), y),
      trait,
    );
    final graduation = Paint()
      ..color = couleurGraduation
      ..strokeWidth = TraitsYasmina.borderThick;
    final etiquetees = etiquettes;
    for (var v = min; v <= max; v += pas) {
      final x = abscisse(positionDe(v), size.width);
      final hauteur = etiquetees.contains(v)
          ? EspacesYasmina.space4
          : EspacesYasmina.space2;
      canvas.drawLine(
        Offset(x, y - hauteur),
        Offset(x, y + hauteur),
        graduation,
      );
      if (etiquetees.contains(v)) {
        final texte = TextPainter(
          text: TextSpan(text: '$v', style: styleEtiquette),
          textDirection: TextDirection.ltr,
        )..layout();
        texte.paint(
          canvas,
          Offset(x - texte.width / 2, y + EspacesYasmina.space5),
        );
      }
    }
    // Le repère : sous le doigt, à sa valeur, ou au début de la droite.
    final position =
        tenue ?? (valeur == null ? positionDe(min) : positionDe(valeur!));
    final x = abscisse(position, size.width);
    final repere = Paint()..color = couleurRepere;
    final rayon = EspacesYasmina.space3;
    canvas.drawCircle(
      Offset(x, y - rayon - EspacesYasmina.space4),
      rayon,
      repere,
    );
    final pointe = Path()
      ..moveTo(x - rayon / 2, y - EspacesYasmina.space4 - rayon / 2)
      ..lineTo(x + rayon / 2, y - EspacesYasmina.space4 - rayon / 2)
      ..lineTo(x, y - EspacesYasmina.space1)
      ..close();
    canvas.drawPath(pointe, repere);
  }

  @override
  bool shouldRepaint(PeintreDroite ancien) =>
      ancien.valeur != valeur ||
      ancien.tenue != tenue ||
      ancien.couleurRepere != couleurRepere ||
      ancien.minAGauche != minAGauche ||
      ancien.min != min ||
      ancien.max != max;
}
