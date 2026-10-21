import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Carte d'une matière sur l'accueil
/// (docs/design-system/composants/SubjectCard.md) : pastel de la matière,
/// texte ink-fixed, avancement au bout de ligne. Une matière sans contenu
/// est atténuée, porte « bientôt » et ne s'ouvre pas.
class CarteMatiere extends StatelessWidget {
  const CarteMatiere({
    super.key,
    required this.nom,
    required this.icone,
    required this.couleur,
    required this.onTap,
    this.avancement,
    required this.libelleBientot,
  });

  final String nom;
  final IconData icone;

  /// Pastel de la matière (identique dans les deux thèmes).
  final Color couleur;

  /// `null` : matière sans contenu, carte atténuée.
  final VoidCallback? onTap;

  /// Avancement affiché (« 2 / 7 »), `null` sans parcours.
  final String? avancement;

  /// « Bientôt », affiché quand la matière n'a pas de contenu.
  final String libelleBientot;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    final disponible = onTap != null;
    final encre = disponible ? c.inkFixed : c.muted;
    return Semantics(
      button: true,
      enabled: disponible,
      label: '$nom, ${disponible ? (avancement ?? '') : libelleBientot}',
      excludeSemantics: true,
      child: Material(
        color: disponible ? couleur : c.tile,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radius2xl),
          side: disponible
              ? BorderSide.none
              : BorderSide(color: c.line, width: TraitsYasmina.borderThin),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: EspacesYasmina.space6,
              vertical: EspacesYasmina.space4,
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: TaillesYasmina.avatarCard,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icone,
                      color: disponible ? c.blue : c.muted,
                      size: TaillesYasmina.iconListen,
                    ),
                  ),
                ),
                const SizedBox(width: EspacesYasmina.space4),
                Expanded(
                  child: Text(
                    nom,
                    style: theme.titleMedium!.copyWith(color: encre),
                  ),
                ),
                const SizedBox(width: EspacesYasmina.space3),
                if (disponible)
                  Text(
                    avancement ?? '',
                    style: theme.labelLarge!.copyWith(color: encre),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(
                        RayonsYasmina.radiusPill,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: EspacesYasmina.space3,
                        vertical: EspacesYasmina.space1,
                      ),
                      child: Text(
                        libelleBientot,
                        style: theme.bodySmall!.copyWith(color: c.muted),
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
