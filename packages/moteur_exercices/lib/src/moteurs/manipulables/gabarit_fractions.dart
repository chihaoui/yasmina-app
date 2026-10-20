import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'materiel.dart';

/// T29 Fractions (docs/moteurs/manipulables.md §14) : l'enfant colorie des
/// parts d'un disque ou d'un rectangle divisé en parts égales, pour
/// représenter la fraction demandée. Juste si le nombre de parts coloriées
/// est le numérateur, quelles que soient les parts.
class GabaritFractions implements GabaritReponse {
  const GabaritFractions();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurFraction creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurFraction(
      config: config,
      parts: donnees['parts'] as int,
      numerateur: donnees['numerateur'] as int,
      disque: (donnees['forme'] as String? ?? 'disque') == 'disque',
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneFraction(controleur as ControleurFraction);
}

/// Les parts coloriées.
class ControleurFraction extends ControleurReponse {
  ControleurFraction({
    required this.config,
    required this.parts,
    required this.numerateur,
    required this.disque,
  });

  final ConfigExercice config;
  final int parts;
  final int numerateur;

  /// Disque (secteurs) ou rectangle (bandes).
  final bool disque;

  final _coloriees = <int>{};

  /// Parts coloriées (les premières, quand la réponse est révélée).
  Set<int> get coloriees => affichage == AffichageReponse.revelee
      ? {for (var i = 0; i < numerateur; i++) i}
      : Set.unmodifiable(_coloriees);

  bool estColoriee(int i) => coloriees.contains(i);

  /// Colorie la part [i], ou la décolorie.
  void basculer(int i) {
    if (!modifiable) return;
    if (!_coloriees.remove(i)) _coloriees.add(i);
    reponseModifiee();
  }

  @override
  bool get complete => _coloriees.isNotEmpty;

  @override
  Object? get reponse => {'parts': _coloriees.length};

  @override
  bool corriger() => _coloriees.length == numerateur;

  @override
  void vider() {
    _coloriees.clear();
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String Function(int n) partN, String sur}) _libellesFraction(String langue) =>
    switch (langue) {
      'ar' => (partN: (n) => 'جُزْءٌ $n', sur: 'مِنْ'),
      'en' => (partN: (n) => 'part $n', sur: 'out of'),
      _ => (partN: (n) => 'part $n', sur: 'sur'),
    };

/// La forme divisée en parts touchables, puis le compte des parts
/// coloriées.
class _ZoneFraction extends StatelessWidget {
  const _ZoneFraction(this.controleur);

  final ControleurFraction controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesFraction(langue);
    final services = ServicesExercice.of(context);
    final styleCompte = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
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
        final couleurPart = switch (etat) {
          EtatMateriel.juste => c.olive,
          EtatMateriel.faux => c.coral,
          EtatMateriel.repos => c.blue,
        };
        void toucher(int i) {
          if (!modifiable) return;
          controleur.basculer(i);
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // La forme ne se retourne pas avec la langue : les parts se
            // numérotent dans le sens des aiguilles d'une montre (disque)
            // ou de gauche à droite (rectangle).
            Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controleur.disque ? 1 : 2,
                  child: LayoutBuilder(
                    builder: (context, contraintes) {
                      final taille = Size(
                        contraintes.maxWidth,
                        contraintes.maxHeight,
                      );
                      return Stack(
                        key: ValueKey(
                          affichage == AffichageReponse.revelee
                              ? 'manipulables_reponse'
                              : 'fraction',
                        ),
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              key: const ValueKey('fraction_dessin'),
                              painter: PeintreFraction(
                                parts: controleur.parts,
                                coloriees: controleur.coloriees,
                                disque: controleur.disque,
                                fond: c.tile,
                                trait: c.ink,
                                couleur: couleurPart,
                              ),
                            ),
                          ),
                          // Une cible d'au moins target-min par part.
                          for (var i = 0; i < controleur.parts; i++)
                            Positioned.fromRect(
                              rect: Rect.fromCenter(
                                center: PeintreFraction.centreDePart(
                                  i,
                                  controleur.parts,
                                  taille,
                                  disque: controleur.disque,
                                ),
                                width: EspacesYasmina.targetMin,
                                height: EspacesYasmina.targetMin,
                              ),
                              child: Semantics(
                                button: true,
                                enabled: modifiable,
                                selected: controleur.estColoriee(i),
                                label: l.partN(i + 1),
                                excludeSemantics: true,
                                child: GestureDetector(
                                  key: ValueKey('part_$i'),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: modifiable ? () => toucher(i) : null,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Text(
              '${controleur.coloriees.length} ${l.sur} ${controleur.parts}',
              key: const ValueKey('fraction_compte'),
              textAlign: TextAlign.center,
              style: styleCompte,
            ),
            motEtatMateriel(context, motEtat, faux: etat == EtatMateriel.faux),
          ],
        );
      },
    );
  }
}

/// Peint un disque en secteurs égaux (le premier part du haut, dans le sens
/// des aiguilles d'une montre) ou un rectangle en bandes verticales, les
/// parts coloriées pleines, les autres en `tile`, un trait entre les parts.
class PeintreFraction extends CustomPainter {
  const PeintreFraction({
    required this.parts,
    required this.coloriees,
    required this.disque,
    required this.fond,
    required this.trait,
    required this.couleur,
  });

  final int parts;
  final Set<int> coloriees;
  final bool disque;
  final Color fond;
  final Color trait;
  final Color couleur;

  /// Centre de la part [i] (cible de toucher) dans une forme de [taille].
  static Offset centreDePart(
    int i,
    int parts,
    Size taille, {
    required bool disque,
  }) {
    if (!disque) {
      final largeur = taille.width / parts;
      return Offset(largeur * (i + 1 / 2), taille.height / 2);
    }
    final centre = taille.center(Offset.zero);
    final rayon = math.min(taille.width, taille.height) / 2;
    if (parts == 1) return centre;
    final angle = -math.pi / 2 + 2 * math.pi * (i + 1 / 2) / parts;
    // design-ok : les cibles sont posées aux deux tiers du rayon.
    const part = 0.62;
    return centre + Offset(math.cos(angle), math.sin(angle)) * rayon * part;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final remplissage = Paint()..style = PaintingStyle.fill;
    final bordure = Paint()
      ..color = trait
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThick
      ..strokeJoin = StrokeJoin.round;
    if (disque) {
      final centre = size.center(Offset.zero);
      final rayon =
          math.min(size.width, size.height) / 2 - TraitsYasmina.borderThick;
      final rect = Rect.fromCircle(center: centre, radius: rayon);
      for (var i = 0; i < parts; i++) {
        final debut = -math.pi / 2 + 2 * math.pi * i / parts;
        final balayage = 2 * math.pi / parts;
        remplissage.color = coloriees.contains(i) ? couleur : fond;
        canvas.drawArc(rect, debut, balayage, true, remplissage);
      }
      canvas.drawCircle(centre, rayon, bordure);
      for (var i = 0; i < parts; i++) {
        final angle = -math.pi / 2 + 2 * math.pi * i / parts;
        canvas.drawLine(
          centre,
          centre + Offset(math.cos(angle), math.sin(angle)) * rayon,
          bordure,
        );
      }
    } else {
      final largeur = size.width / parts;
      for (var i = 0; i < parts; i++) {
        remplissage.color = coloriees.contains(i) ? couleur : fond;
        canvas.drawRect(
          Rect.fromLTWH(largeur * i, 0, largeur, size.height),
          remplissage,
        );
      }
      canvas.drawRect(
        (Offset.zero & size).deflate(TraitsYasmina.borderThick / 2),
        bordure,
      );
      for (var i = 1; i < parts; i++) {
        canvas.drawLine(
          Offset(largeur * i, 0),
          Offset(largeur * i, size.height),
          bordure,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PeintreFraction ancien) =>
      ancien.parts != parts ||
      ancien.disque != disque ||
      ancien.couleur != couleur ||
      ancien.fond != fond ||
      ancien.trait != trait ||
      !ancien.coloriees.containsAll(coloriees) ||
      !coloriees.containsAll(ancien.coloriees);
}
