import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/jetons_yasmina.g.dart';
import '../theme/mouvements_yasmina.dart';
import '../theme/theme_yasmina.dart';

/// Humeurs de la mascotte (placeholders SVG de la démo).
enum HumeurYasmina {
  /// Au repos.
  neutre('yasmina-neutral.svg'),

  /// Réponse juste.
  bravo('yasmina-bravo.svg'),

  /// Réponse fausse.
  encourage('yasmina-encourage.svg');

  const HumeurYasmina(this.fichier);

  final String fichier;

  /// Asset du moteur (assets/yasmina/, copié par tool/generer_theme.dart).
  String get asset => 'assets/yasmina/$fichier';
}

/// Yasmina seule, décorative (la tâche ne dépend jamais de son humeur).
/// Elle saute 3 fois en passant à [HumeurYasmina.bravo] et se penche 2 fois
/// en passant à [HumeurYasmina.encourage]. Aucun mouvement si l'appareil
/// demande moins d'animations.
class Yasmina extends StatefulWidget {
  const Yasmina({
    super.key,
    this.humeur = HumeurYasmina.neutre,
    this.taille = TaillesYasmina.yasminaHome,
  });

  final HumeurYasmina humeur;
  final double taille;

  @override
  State<Yasmina> createState() => _YasminaState();
}

class _YasminaState extends State<Yasmina> with SingleTickerProviderStateMixin {
  late final AnimationController _mouvement = AnimationController(vsync: this);

  @override
  void didUpdateWidget(Yasmina ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.humeur != widget.humeur) _lancer();
  }

  void _lancer() {
    _mouvement.stop();
    _mouvement.value = 0;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    final (duree, fois) = switch (widget.humeur) {
      HumeurYasmina.bravo => (
        MouvementsYasmina.dureeSaut,
        MouvementsYasmina.sauts,
      ),
      HumeurYasmina.encourage => (
        MouvementsYasmina.dureePenche,
        MouvementsYasmina.penches,
      ),
      HumeurYasmina.neutre => (Duration.zero, 0),
    };
    if (fois == 0) return;
    _mouvement
      ..duration = duree * fois
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _mouvement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = SvgPicture.asset(
      widget.humeur.asset,
      package: 'moteur_exercices',
      width: widget.taille,
      height: widget.taille,
      excludeFromSemantics: true,
    );
    return AnimatedBuilder(
      animation: _mouvement,
      child: image,
      builder: (context, enfant) {
        final t = _mouvement.value;
        if (t == 0 || t == 1) return enfant!;
        final fois = widget.humeur == HumeurYasmina.bravo
            ? MouvementsYasmina.sauts
            : MouvementsYasmina.penches;
        // Une demi-sinusoïde par saut ou par mouvement penché.
        final cycle = math.sin(math.pi * ((t * fois) % 1));
        return switch (widget.humeur) {
          HumeurYasmina.bravo => Transform.translate(
            offset: Offset(0, -MouvementsYasmina.hauteurSaut * cycle),
            child: enfant,
          ),
          HumeurYasmina.encourage => Transform.rotate(
            angle: -MouvementsYasmina.anglePenche * cycle,
            alignment: Alignment.bottomCenter,
            child: enfant,
          ),
          HumeurYasmina.neutre => enfant!,
        };
      },
    );
  }
}

/// Yasmina au-dessus de sa bulle de parole
/// (docs/design-system/composants/YasminaBubble.md).
///
/// Le texte suit la langue de l'endroit où la bulle est posée.
class YasminaBulle extends StatelessWidget {
  const YasminaBulle({
    super.key,
    required this.texte,
    this.sousTitre,
    this.humeur = HumeurYasmina.neutre,
    this.taille = TaillesYasmina.yasminaHome,
    this.cleTexte,
  });

  final String texte;

  /// Ligne facultative sous le texte, en caption et muted.
  final String? sousTitre;

  final HumeurYasmina humeur;

  /// Taille de Yasmina : yasminaHome (accueil, intro, résultat) ou
  /// yasminaReader (lecteur).
  final double taille;

  /// Clé du texte de la bulle (tests).
  final Key? cleTexte;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = ThemeYasmina.langueDe(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Yasmina(humeur: humeur, taille: taille),
        const SizedBox(height: EspacesYasmina.space4),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(RayonsYasmina.radiusXl),
            border: Border.all(color: c.line, width: TraitsYasmina.borderThick),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: EspacesYasmina.padBubbleX,
              vertical: EspacesYasmina.padBubbleY,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  texte,
                  key: cleTexte,
                  textAlign: TextAlign.center,
                  style: ThemeYasmina.pourLangue(
                    StylesYasmina.bubble,
                    langue,
                  ).copyWith(color: c.ink),
                ),
                if (sousTitre != null)
                  Text(
                    sousTitre!,
                    textAlign: TextAlign.center,
                    style: StylesYasmina.caption.copyWith(color: c.muted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
