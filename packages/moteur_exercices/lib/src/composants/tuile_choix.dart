import 'package:flutter/material.dart';

import '../theme/jetons_yasmina.g.dart';
import '../theme/theme_yasmina.dart';

/// États d'une proposition (docs/design-system/composants/ChoiceTile.md).
enum EtatTuile { repos, selectionne, juste, faux }

/// Une proposition touchable : emoji en grand, texte facultatif. Juste et
/// faux ne passent jamais par la couleur seule : Yasmina et le bandeau le
/// disent aussi, et l'aperçu ajoute un mot d'état.
class TuileChoix extends StatelessWidget {
  const TuileChoix({
    super.key,
    required this.etat,
    this.texte,
    this.emoji,
    this.onTap,
    this.libelleAccessibilite,
    this.motEtat,
  });

  final EtatTuile etat;
  final String? texte;
  final String? emoji;

  /// `null` : tuile verrouillée (après Vérifier, réponse révélée).
  final VoidCallback? onTap;

  /// Libellé lu par le lecteur d'écran. Pour une tuile en image ou en emoji
  /// seul, un libellé neutre (« صُورَةٌ 1 ») pour ne pas donner la réponse.
  /// Par défaut, le texte.
  final String? libelleAccessibilite;

  /// Mot d'état sous la tuile, en mode aperçu (« juste », « faux »).
  final String? motEtat;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = ThemeYasmina.langueDe(context);
    final (fond, bord) = switch (etat) {
      EtatTuile.repos => (c.tile, c.line),
      EtatTuile.selectionne => (c.blueSoft, c.blue),
      EtatTuile.juste => (c.oliveSoft, c.olive),
      EtatTuile.faux => (c.coralSoft, c.coral),
    };
    final couleurEtat = etat == EtatTuile.faux ? c.coralText : c.oliveText;
    return Semantics(
      button: true,
      selected: etat == EtatTuile.selectionne,
      enabled: onTap != null,
      label: libelleAccessibilite ?? texte ?? '',
      excludeSemantics: true,
      child: Material(
        color: fond,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
          side: BorderSide(color: bord, width: TraitsYasmina.borderThick),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TaillesYasmina.choiceMinHeight,
              minWidth: EspacesYasmina.targetMin,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: EspacesYasmina.space2,
                vertical: EspacesYasmina.space3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (emoji != null)
                    Text(emoji!, style: StylesYasmina.contentWord),
                  if (texte != null)
                    Text(
                      texte!,
                      textAlign: TextAlign.center,
                      style: ThemeYasmina.pourLangue(
                        StylesYasmina.contentOption,
                        langue,
                      ).copyWith(color: c.ink),
                    ),
                  if (motEtat != null)
                    Text(
                      motEtat!,
                      style: StylesYasmina.latinLabel.copyWith(
                        color: couleurEtat,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
