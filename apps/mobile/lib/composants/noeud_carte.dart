import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../parcours/progression.dart';

/// Pulsation douce de l'étape ouverte (démo : 1,8 s), jouée [_pulsations]
/// fois à l'arrivée sur la carte (comme les sauts de Yasmina : un mouvement
/// fini, pour que l'écran se pose), coupée si l'appareil demande moins
/// d'animations.
const _dureePulsation = Duration(milliseconds: 1800);
const _pulsations = 3;

/// Une étape sur la carte du trimestre
/// (docs/design-system/composants/MapNode.md) : la lettre (ou 🏆 pour le
/// défi, en carré arrondi) dans un rond de `map-node`, sur `sun` quand
/// elle est ouverte (pulsation), `node-done` quand elle est faite,
/// `line` avec un cadenas quand elle est verrouillée. Texte en ink-fixed.
class NoeudCarte extends StatefulWidget {
  const NoeudCarte({
    super.key,
    required this.glyphe,
    required this.etat,
    required this.libelle,
    required this.onTap,
    this.defi = false,
  });

  /// Lettre affichée (ou 🏆).
  final String glyphe;

  final EtatEtape etat;

  /// Libellé lu par le lecteur d'écran : le titre de l'étape et son état.
  final String libelle;

  /// Toujours appelé, même verrouillée (l'écran explique pourquoi).
  final VoidCallback onTap;

  final bool defi;

  @override
  State<NoeudCarte> createState() => _NoeudCarteState();
}

class _NoeudCarteState extends State<NoeudCarte>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulsation = AnimationController(
    vsync: this,
    duration: _dureePulsation * _pulsations,
  );
  var _lancee = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_lancee) {
      _lancee = true;
      _regler();
    }
  }

  @override
  void didUpdateWidget(NoeudCarte ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.etat != widget.etat) _regler();
  }

  void _regler() {
    _pulsation
      ..stop()
      ..value = 0;
    if (widget.etat == EtatEtape.ouverte &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pulsation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulsation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, encre) = switch (widget.etat) {
      EtatEtape.ouverte => (c.sun, c.inkFixed),
      EtatEtape.faite => (c.nodeDone, c.inkFixed),
      EtatEtape.verrouillee => (c.line, c.muted),
    };
    final verrouillee = widget.etat == EtatEtape.verrouillee;
    final forme = widget.defi
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RayonsYasmina.radius2xl),
          )
        : const CircleBorder();
    final style = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      ThemeYasmina.langueDe(context),
    ).copyWith(color: encre, fontFamily: StylesYasmina.bubble.fontFamily);

    return Semantics(
      button: true,
      label: widget.libelle,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _pulsation,
        builder: (context, enfant) {
          // Une pulsation par cycle : aller et retour en sinusoïde.
          final t = _pulsation.value;
          final cycle = t == 0 || t == 1
              ? 0.0
              : math.sin(math.pi * ((t * _pulsations) % 1));
          return Transform.scale(
            scale: 1 + (MouvementsYasmina.echelleTenue - 1) * cycle,
            child: enfant,
          );
        },
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: forme,
            shadows: verrouillee ? null : const [OmbresYasmina.shadowNode],
          ),
          child: Material(
            color: fond,
            shape: forme,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              customBorder: forme,
              child: SizedBox.square(
                dimension: TaillesYasmina.mapNode,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      widget.glyphe,
                      textDirection: TextDirection.rtl,
                      style: style,
                    ),
                    if (verrouillee)
                      PositionedDirectional(
                        bottom: EspacesYasmina.space1,
                        end: EspacesYasmina.space1,
                        child: Icon(
                          Icons.lock_rounded,
                          size: TaillesYasmina.iconMd,
                          color: c.muted,
                        ),
                      ),
                    if (widget.etat == EtatEtape.faite)
                      PositionedDirectional(
                        top: EspacesYasmina.space1,
                        end: EspacesYasmina.space1,
                        child: Icon(
                          Icons.star_rounded,
                          size: TaillesYasmina.iconMd,
                          color: c.amber,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
