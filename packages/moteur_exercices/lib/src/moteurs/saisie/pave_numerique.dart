import 'package:flutter/material.dart';

import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Chiffres arabes orientaux (٠ à ٩).
const _orientaux = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// [texte] avec ses chiffres 0 à 9 affichés en chiffres orientaux si
/// [orientaux] (docs/moteurs/saisie-numerique.md §3). La valeur stockée
/// reste un entier.
String afficherChiffres(String texte, {required bool orientaux}) {
  if (!orientaux) return texte;
  return String.fromCharCodes(
    texte.runes.map(
      (r) => r >= 0x30 && r <= 0x39 ? _orientaux[r - 0x30].runes.first : r,
    ),
  );
}

/// Pavé numérique du moteur : 1 2 3 en haut comme un téléphone, 0 en bas,
/// Effacer. Toujours de gauche à droite.
class PaveNumerique extends StatelessWidget {
  const PaveNumerique({
    super.key,
    required this.onChiffre,
    required this.onEffacer,
    required this.libelleEffacer,
    this.orientaux = false,
  });

  /// `null` : pavé verrouillé.
  final ValueChanged<int>? onChiffre;
  final VoidCallback? onEffacer;
  final String libelleEffacer;
  final bool orientaux;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final style = ThemeYasmina.pourLangue(
      StylesYasmina.contentOption,
      ThemeYasmina.langueDe(context),
    ).copyWith(color: c.ink);
    Widget touche(
      String cle,
      Widget enfant,
      String libelle,
      VoidCallback? action,
    ) => Semantics(
      button: true,
      enabled: action != null,
      label: libelle,
      excludeSemantics: true,
      child: Material(
        key: ValueKey('touche_$cle'),
        color: c.tile,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
          side: BorderSide(color: c.line, width: TraitsYasmina.borderThin),
        ),
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: EspacesYasmina.targetMin + EspacesYasmina.space6,
              minHeight: EspacesYasmina.targetMin,
            ),
            child: Center(child: enfant),
          ),
        ),
      ),
    );
    Widget chiffre(int n) => touche(
      '$n',
      Text(afficherChiffres('$n', orientaux: orientaux), style: style),
      '$n',
      onChiffre == null ? null : () => onChiffre!(n),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        key: const ValueKey('pave'),
        mainAxisSize: MainAxisSize.min,
        spacing: EspacesYasmina.space1,
        children: [
          for (final rangee in [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ])
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: EspacesYasmina.space1,
              children: [for (final n in rangee) chiffre(n)],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: EspacesYasmina.space1,
            children: [
              chiffre(0),
              touche(
                'effacer',
                Icon(
                  Icons.backspace_outlined,
                  color: c.ink,
                  size: TaillesYasmina.iconMd,
                ),
                libelleEffacer,
                onEffacer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
