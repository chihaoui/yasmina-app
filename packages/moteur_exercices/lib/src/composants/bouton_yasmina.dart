import 'package:flutter/material.dart';

import '../theme/jetons_yasmina.g.dart';
import '../theme/theme_yasmina.dart';

/// Variantes du bouton principal (docs/design-system/composants/Button.md).
enum VarianteBouton {
  /// Vérifier, Commencer.
  bleu,

  /// Continuer, après une réponse juste ou l'explication.
  vert,

  /// Action secondaire (rejouer, changer d'enfant).
  alt,
}

/// Bouton principal pleine largeur, avec un relief de touche qui disparaît
/// au toucher (le bouton s'enfonce).
///
/// Le libellé suit la langue de l'endroit où le bouton est posé : celle de
/// l'exercice dans le lecteur (LangueExercice), celle de l'interface ailleurs.
class BoutonYasmina extends StatefulWidget {
  const BoutonYasmina({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.variante = VarianteBouton.bleu,
    this.icone,
  });

  final String libelle;

  /// `null` : bouton désactivé.
  final VoidCallback? onPressed;

  final VarianteBouton variante;

  /// Icône facultative, avant le libellé.
  final IconData? icone;

  @override
  State<BoutonYasmina> createState() => _BoutonYasminaState();
}

class _BoutonYasminaState extends State<BoutonYasmina> {
  bool _enfonce = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final actif = widget.onPressed != null;
    final alt = widget.variante == VarianteBouton.alt;
    final (fond, texte) = switch (widget.variante) {
      _ when !actif => (c.line, c.muted),
      VarianteBouton.bleu => (c.blue, c.onAccent),
      VarianteBouton.vert => (c.olive, c.onAccent),
      VarianteBouton.alt => (c.surface, c.blue),
    };
    final relief = actif && !alt && !_enfonce;
    final enfoncement = actif && !alt && _enfonce
        ? OmbresYasmina.shadowPress.offset.dy
        : 0.0;
    final rayon = BorderRadius.circular(RayonsYasmina.radiusXl);
    final style = ThemeYasmina.pourLangue(
      alt
          ? StylesYasmina.buttonCta.copyWith(
              fontSize: StylesYasmina.titleBar.fontSize,
            )
          : StylesYasmina.buttonCta,
      ThemeYasmina.langueDe(context),
    ).copyWith(color: texte);
    final duree = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 80);
    final decalage = TraitsYasmina.focusRing + TraitsYasmina.focusOffset;

    return Semantics(
      container: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            key: const ValueKey('bouton_yasmina_corps'),
            duration: duree,
            transform: Matrix4.translationValues(0, enfoncement, 0),
            decoration: BoxDecoration(
              color: fond,
              borderRadius: rayon,
              border: alt && actif
                  ? Border.all(color: c.blue, width: TraitsYasmina.borderThick)
                  : null,
              boxShadow: relief ? const [OmbresYasmina.shadowPress] : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: rayon,
                onTap: widget.onPressed,
                onHighlightChanged: (valeur) =>
                    setState(() => _enfonce = valeur),
                onFocusChange: (valeur) => setState(() => _focus = valeur),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: EspacesYasmina.targetMin,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: EspacesYasmina.padButtonX,
                      vertical: EspacesYasmina.padButtonY,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icone != null) ...[
                          Icon(widget.icone, color: texte),
                          const SizedBox(width: EspacesYasmina.space2),
                        ],
                        Flexible(
                          child: Text(
                            widget.libelle,
                            style: style,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Anneau de focus (clavier, contrôle de sélection), hors du flux.
          if (_focus)
            Positioned(
              left: -decalage,
              top: -decalage,
              right: -decalage,
              bottom: -decalage,
              child: IgnorePointer(
                child: DecoratedBox(
                  key: const ValueKey('bouton_yasmina_focus'),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      RayonsYasmina.radiusXl + decalage,
                    ),
                    border: Border.all(
                      color: c.blue,
                      width: TraitsYasmina.focusRing,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
