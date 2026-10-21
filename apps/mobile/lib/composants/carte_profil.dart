import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../profils/avatar.dart';

/// Carte d'un enfant sur l'écran « Qui joue ? »
/// (docs/design-system/composants/ProfileCard.md).
class CarteProfil extends StatelessWidget {
  const CarteProfil({
    super.key,
    required this.prenom,
    required this.niveau,
    required this.avatar,
    required this.onTap,
    this.action,
  });

  /// Tel que saisi, harakat comprises.
  final String prenom;

  /// Libellé du niveau dans la langue de l'interface.
  final String niveau;

  final Avatar avatar;
  final VoidCallback onTap;

  /// Bouton facultatif sous le niveau (modifier le profil).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;
    return _Cadre(
      onTap: onTap,
      child: Column(
        children: [
          AvatarVisuel(avatar),
          const SizedBox(height: EspacesYasmina.space1),
          Text(
            prenom,
            style: textes.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            niveau,
            style: textes.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Fond surface, bordure line, coins radius-2xl. La carte pointillée
/// « Ajouter un enfant » a quitté l'écran enfant avec la décision 28 : les
/// profils se créent dans l'espace parent.
class _Cadre extends StatelessWidget {
  const _Cadre({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final rayon = BorderRadius.circular(RayonsYasmina.radius2xl);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: rayon,
        side: BorderSide(color: c.line, width: TraitsYasmina.borderThick),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: EspacesYasmina.space2,
            vertical: EspacesYasmina.space4,
          ),
          child: child,
        ),
      ),
    );
  }
}
