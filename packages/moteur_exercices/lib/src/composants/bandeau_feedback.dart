import 'package:flutter/material.dart';

import '../theme/jetons_yasmina.g.dart';
import '../theme/theme_yasmina.dart';

/// Les 3 temps du feedback (docs/design-system/composants/Feedback.md).
enum VarianteFeedback {
  /// Réponse juste : ce qui est juste, jamais un compliment sur l'enfant.
  validation,

  /// 1er essai faux.
  indice,

  /// 2e essai faux : explication et bonne réponse.
  explication,
}

/// Bandeau de feedback au-dessus du bouton principal. Libellé et texte
/// suivent la langue de l'endroit où il est posé (celle de l'exercice).
class BandeauFeedback extends StatelessWidget {
  const BandeauFeedback({
    super.key,
    required this.variante,
    required this.libelle,
    required this.texte,
  });

  final VarianteFeedback variante;

  /// « أَحْسَنْتَ », « Indice »... fourni par le lecteur.
  final String libelle;

  /// Texte du JSON, déjà accordé à la forme d'adresse.
  final String texte;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = ThemeYasmina.langueDe(context);
    final (fond, bord) = switch (variante) {
      VarianteFeedback.validation => (c.oliveSoft, c.olive),
      VarianteFeedback.indice => (c.amberSoft, c.amber),
      VarianteFeedback.explication => (c.coralSoft, c.coral),
    };
    // Libellé : latin-label, en famille kid pour l'arabe.
    final styleLibelle = langue == 'ar'
        ? StylesYasmina.latinLabel.copyWith(
            fontFamily: StylesYasmina.option.fontFamily,
            fontFamilyFallback: StylesYasmina.option.fontFamilyFallback,
          )
        : StylesYasmina.latinLabel;
    return Semantics(
      container: true,
      liveRegion: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
        child: ColoredBox(
          color: fond,
          // Bord en début de ligne : une Row, car une bordure non uniforme
          // n'accepte pas de coins arrondis.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: TraitsYasmina.borderFeedback,
                  child: ColoredBox(color: bord),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: EspacesYasmina.padFeedbackX,
                      vertical: EspacesYasmina.padBubbleY,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          libelle,
                          style: styleLibelle.copyWith(color: c.ink),
                        ),
                        Text(
                          texte,
                          style: ThemeYasmina.pourLangue(
                            StylesYasmina.feedback,
                            langue,
                          ).copyWith(color: c.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
