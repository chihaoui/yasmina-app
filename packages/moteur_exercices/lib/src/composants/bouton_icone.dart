import 'package:flutter/material.dart';

import '../theme/jetons_yasmina.g.dart';
import '../theme/theme_yasmina.dart';

/// Bouton sans libellé visible : retour, quitter, réglages, réécouter
/// (docs/design-system/composants/IconButton.md).
class BoutonIcone extends StatelessWidget {
  const BoutonIcone({
    super.key,
    required this.icone,
    required this.libelle,
    required this.onPressed,
    this.rond = false,
    this.suitLeSens = false,
  });

  final IconData icone;

  /// Libellé d'accessibilité et infobulle, dans la langue de l'interface.
  final String libelle;

  final VoidCallback? onPressed;

  /// Rond (réécoute : fond surface, icône blue) ou carré (fond tile, icône
  /// ink).
  final bool rond;

  /// Retourne l'icône en arabe (flèches). Les icônes Material qui suivent
  /// déjà le sens d'écriture (`matchTextDirection`, comme
  /// `Icons.chevron_left`) ne sont pas retournées une seconde fois.
  final bool suitLeSens;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final miroir =
        suitLeSens &&
        !icone.matchTextDirection &&
        Directionality.of(context) == TextDirection.rtl;
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        rond ? RayonsYasmina.radiusPill : RayonsYasmina.radiusMd,
      ),
      side: BorderSide(color: c.line, width: TraitsYasmina.borderThin),
    );
    Widget dessin = Icon(icone, color: rond ? c.blue : c.ink);
    if (miroir) dessin = Transform.flip(flipX: true, child: dessin);
    return IconButton(
      onPressed: onPressed,
      tooltip: libelle,
      icon: dessin,
      style: IconButton.styleFrom(
        backgroundColor: rond ? c.surface : c.tile,
        minimumSize: const Size(
          EspacesYasmina.targetMin,
          EspacesYasmina.targetMin,
        ),
        shape: forme,
      ),
    );
  }
}

/// Grand bouton Écouter (variante `listen` du IconButton du design system,
/// docs/design-system/composants/IconButton.md) : « اِسْمَعْ » ou
/// « Écouter » sur fond blue, pour faire entendre un mot (T03, T55, support
/// écouté de T01, mot de T19). Le libellé suit la langue de l'exercice.
class BoutonEcouter extends StatelessWidget {
  const BoutonEcouter({
    super.key,
    required this.libelle,
    required this.onPressed,
  });

  final String libelle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final style = ThemeYasmina.pourLangue(
      StylesYasmina.listen,
      ThemeYasmina.langueDe(context),
    ).copyWith(color: c.onAccent);
    return Semantics(
      button: true,
      label: libelle,
      excludeSemantics: true,
      child: Material(
        color: c.blue,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusPill),
        ),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: EspacesYasmina.targetMin,
              minWidth: EspacesYasmina.targetMin,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: EspacesYasmina.padListenX,
                vertical: EspacesYasmina.padListenY,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    color: c.onAccent,
                    size: TaillesYasmina.iconListen,
                  ),
                  const SizedBox(width: EspacesYasmina.space2),
                  Text(libelle, style: style),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
