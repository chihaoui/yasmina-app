import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/jetons_yasmina.g.dart';
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
/// Statique pour l'instant : les animations arrivent avec le lecteur.
class Yasmina extends StatelessWidget {
  const Yasmina({
    super.key,
    this.humeur = HumeurYasmina.neutre,
    this.taille = TaillesYasmina.yasminaHome,
  });

  final HumeurYasmina humeur;
  final double taille;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    humeur.asset,
    package: 'moteur_exercices',
    width: taille,
    height: taille,
    excludeFromSemantics: true,
  );
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
