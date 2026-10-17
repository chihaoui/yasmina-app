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
