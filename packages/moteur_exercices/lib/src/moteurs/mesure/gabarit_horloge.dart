import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../saisie/pave_numerique.dart';

/// Une heure sur un cadran de 12 heures.
class HeureCadran {
  const HeureCadran(this.heure, this.minutes);

  factory HeureCadran.depuisJson(Map<String, dynamic> json) =>
      HeureCadran(json['heure'] as int, json['minutes'] as int);

  /// De 1 à 12.
  final int heure;
  final int minutes;

  /// Minutes depuis 12 h 00, de 0 à 719.
  int get totales => (heure % 12) * 60 + minutes;

  static HeureCadran depuisTotales(int totales) {
    final t = totales % 720;
    final h = t ~/ 60;
    return HeureCadran(h == 0 ? 12 : h, t % 60);
  }

  Map<String, int> get json => {'heure': heure, 'minutes': minutes};
}

/// Aiguille tenue pendant un glisser.
enum Aiguille { heures, minutes }

/// T28 Horloge (docs/moteurs/mesure-temps.md) : l'enfant règle l'horloge sur
/// l'heure demandée en déplaçant les aiguilles au doigt. L'aiguille des
/// minutes s'aimante au pas (5 minutes par défaut) et entraîne celle des
/// heures comme sur une vraie horloge, l'aiguille des heures s'aimante à
/// l'heure en gardant les minutes. Juste si l'heure réglée est la cible.
class GabaritHorloge implements GabaritReponse {
  const GabaritHorloge();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurHorloge creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurHorloge(
      config: config,
      attendu: HeureCadran.depuisJson(reponse),
      pas: donnees['pas'] as int? ?? 5,
      depart: donnees['depart'] == null
          ? const HeureCadran(12, 0)
          : HeureCadran.depuisJson(donnees['depart'] as Map<String, dynamic>),
      orientaux: donnees['chiffres'] == 'orientaux',
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneHorloge(controleur as ControleurHorloge);
}

/// L'heure réglée, en minutes depuis 12 h 00.
class ControleurHorloge extends ControleurReponse {
  ControleurHorloge({
    required this.config,
    required this.attendu,
    required this.pas,
    required this.depart,
    required this.orientaux,
  }) : _totales = depart.totales;

  final ConfigExercice config;
  final HeureCadran attendu;

  /// Pas de l'aiguille des minutes (5, 15 ou 30).
  final int pas;

  /// Position des aiguilles à l'ouverture.
  final HeureCadran depart;
  final bool orientaux;

  int _totales;
  bool _touchee = false;
  Aiguille? _tenue;

  /// Minutes depuis 12 h 00 (la cible quand la réponse est révélée).
  int get totales =>
      affichage == AffichageReponse.revelee ? attendu.totales : _totales;

  HeureCadran get heure => HeureCadran.depuisTotales(totales);

  /// Aiguille en cours de déplacement.
  Aiguille? get tenue => _tenue;

  /// Angle d'une aiguille en radians depuis le haut, dans le sens des
  /// aiguilles d'une montre.
  static double angleMinutes(int totales) => (totales % 60) / 60 * 2 * math.pi;
  static double angleHeures(int totales) => (totales % 720) / 720 * 2 * math.pi;

  /// L'aiguille la plus proche de l'angle [angle] (depuis le haut, sens
  /// horaire) : celle que le doigt prend.
  Aiguille aiguilleProche(double angle) {
    double ecart(double a) {
      final d = (a - angle).abs() % (2 * math.pi);
      return math.min(d, 2 * math.pi - d);
    }

    return ecart(angleMinutes(_totales)) <= ecart(angleHeures(_totales))
        ? Aiguille.minutes
        : Aiguille.heures;
  }

  void prendre(Aiguille aiguille) {
    if (!modifiable) return;
    _tenue = aiguille;
    notifyListeners();
  }

  /// Déplace l'aiguille tenue vers [angle] (depuis le haut, sens horaire).
  void deplacer(double angle) {
    final tenue = _tenue;
    if (!modifiable || tenue == null) return;
    final tour = ((angle % (2 * math.pi)) + 2 * math.pi) % (2 * math.pi);
    final int nouvelles;
    if (tenue == Aiguille.minutes) {
      // Aimant au pas, l'heure suit (passer 12 change d'heure).
      final minutes = ((tour / (2 * math.pi) * 60) / pas).round() * pas % 60;
      final heureCourante = _totales ~/ 60;
      final ancienne = _totales % 60;
      var h = heureCourante;
      if (ancienne >= 45 && minutes <= 15) h = (h + 1) % 12;
      if (ancienne <= 15 && minutes >= 45) h = (h + 11) % 12;
      nouvelles = h * 60 + minutes;
    } else {
      // Aimant à l'heure, les minutes restent.
      final h = (tour / (2 * math.pi) * 12).round() % 12;
      nouvelles = h * 60 + _totales % 60;
    }
    if (nouvelles == _totales) return;
    _totales = nouvelles;
    _touchee = true;
    reponseModifiee();
  }

  void lacher() {
    if (_tenue == null) return;
    _tenue = null;
    notifyListeners();
  }

  @override
  bool get complete => _touchee;

  @override
  Object? get reponse => HeureCadran.depuisTotales(_totales).json;

  @override
  bool corriger() => _totales == attendu.totales;

  /// Les aiguilles reviennent au départ (manipulables.md §6).
  @override
  void vider() {
    _totales = depart.totales;
    _touchee = false;
    _tenue = null;
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String horloge, String heures, String minutes}) _libellesHorloge(
  String langue,
) => switch (langue) {
  'ar' => (
    horloge: 'السَّاعَةُ',
    heures: 'عَقْرَبُ السَّاعَاتِ',
    minutes: 'عَقْرَبُ الدَّقَائِقِ',
  ),
  'en' => (horloge: 'clock', heures: 'hour hand', minutes: 'minute hand'),
  _ => (
    horloge: 'horloge',
    heures: 'aiguille des heures',
    minutes: 'aiguille des minutes',
  ),
};

/// Le cadran, pris au doigt.
class _ZoneHorloge extends StatelessWidget {
  const _ZoneHorloge(this.controleur);

  final ControleurHorloge controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesHorloge(langue);
    final services = ServicesExercice.of(context);
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
        final heure = controleur.heure;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, contraintes) {
                    final taille = Size(
                      contraintes.maxWidth,
                      contraintes.maxHeight,
                    );
                    final centre = taille.center(Offset.zero);
                    double angleDe(Offset p) {
                      final v = p - centre;
                      return math.atan2(v.dx, -v.dy);
                    }

                    return Semantics(
                      label:
                          '${l.horloge} ${afficherChiffres('${heure.heure}', orientaux: controleur.orientaux)}'
                          ':${afficherChiffres(heure.minutes.toString().padLeft(2, '0'), orientaux: controleur.orientaux)}',
                      child: GestureDetector(
                        key: const ValueKey('horloge_geste'),
                        behavior: HitTestBehavior.opaque,
                        onPanStart: modifiable
                            ? (d) => controleur.prendre(
                                controleur.aiguilleProche(
                                  angleDe(d.localPosition),
                                ),
                              )
                            : null,
                        onPanUpdate: modifiable
                            ? (d) =>
                                  controleur.deplacer(angleDe(d.localPosition))
                            : null,
                        onPanEnd: modifiable
                            ? (_) {
                                if (controleur.tenue != null) {
                                  services.vibration.legere();
                                  services.audio.jouerSon(SonInterface.depot);
                                }
                                controleur.lacher();
                              }
                            : null,
                        onPanCancel: controleur.lacher,
                        child: CustomPaint(
                          key: ValueKey(revelee ? 'saisie_reponse' : 'horloge'),
                          painter: PeintreHorloge(
                            totales: controleur.totales,
                            tenue: controleur.tenue,
                            couleurs: c,
                            couleurAiguilles: juste
                                ? c.olive
                                : faux
                                ? c.coral
                                : c.ink,
                            orientaux: controleur.orientaux,
                            style: ThemeYasmina.pourLangue(
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
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('saisie_mot_etat'),
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

/// Peint le cadran : cercle `tile`, 12 nombres (de gauche à droite),
/// graduations des minutes, aiguille des heures (courte, épaisse) et des
/// minutes (longue), l'aiguille tenue en `blue`.
class PeintreHorloge extends CustomPainter {
  const PeintreHorloge({
    required this.totales,
    required this.tenue,
    required this.couleurs,
    required this.couleurAiguilles,
    required this.orientaux,
    required this.style,
  });

  final int totales;
  final Aiguille? tenue;
  final CouleursYasmina couleurs;
  final Color couleurAiguilles;
  final bool orientaux;
  final TextStyle style;

  /// Longueur des aiguilles, en part du rayon.
  static const partHeures = 0.55;
  static const partMinutes = 0.85;

  /// Bout d'une aiguille pour une horloge de [taille].
  static Offset bout(Size taille, double angle, double part) {
    final centre = taille.center(Offset.zero);
    final rayon = math.min(taille.width, taille.height) / 2;
    return centre + Offset(math.sin(angle), -math.cos(angle)) * rayon * part;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final rayon =
        math.min(size.width, size.height) / 2 - TraitsYasmina.borderThick;
    canvas.drawCircle(centre, rayon, Paint()..color = couleurs.tile);
    canvas.drawCircle(
      centre,
      rayon,
      Paint()
        ..color = couleurs.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = TraitsYasmina.borderThick,
    );
    final trait = Paint()
      ..color = couleurs.line
      ..strokeWidth = TraitsYasmina.borderThin
      ..strokeCap = StrokeCap.round;
    for (var m = 0; m < 60; m++) {
      final angle = m / 60 * 2 * math.pi;
      final longue = m % 5 == 0;
      final a = centre + Offset(math.sin(angle), -math.cos(angle)) * rayon;
      final b =
          centre +
          Offset(math.sin(angle), -math.cos(angle)) *
              (rayon -
                  (longue ? EspacesYasmina.space4 : EspacesYasmina.space2));
      canvas.drawLine(
        a,
        b,
        trait..color = longue ? couleurs.ink : couleurs.line,
      );
    }
    for (var h = 1; h <= 12; h++) {
      final angle = h / 12 * 2 * math.pi;
      final position =
          centre +
          Offset(math.sin(angle), -math.cos(angle)) *
              (rayon - EspacesYasmina.space8);
      final peintre = TextPainter(
        text: TextSpan(
          text: afficherChiffres('$h', orientaux: orientaux),
          style: style,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      peintre.paint(
        canvas,
        position - Offset(peintre.width / 2, peintre.height / 2),
      );
      peintre.dispose();
    }
    void aiguille(double angle, double part, double epaisseur, bool tenueIci) {
      canvas.drawLine(
        centre,
        bout(size, angle, part),
        Paint()
          ..color = tenueIci ? couleurs.blue : couleurAiguilles
          ..strokeWidth = epaisseur
          ..strokeCap = StrokeCap.round,
      );
    }

    aiguille(
      ControleurHorloge.angleHeures(totales),
      partHeures,
      EspacesYasmina.space2,
      tenue == Aiguille.heures,
    );
    aiguille(
      ControleurHorloge.angleMinutes(totales),
      partMinutes,
      EspacesYasmina.space1,
      tenue == Aiguille.minutes,
    );
    canvas.drawCircle(
      centre,
      EspacesYasmina.space2,
      Paint()..color = couleurAiguilles,
    );
  }

  @override
  bool shouldRepaint(PeintreHorloge ancien) =>
      ancien.totales != totales ||
      ancien.tenue != tenue ||
      ancien.couleurAiguilles != couleurAiguilles;
}
