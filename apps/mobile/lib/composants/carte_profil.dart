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

/// Carte pointillée « Ajouter un enfant », absente à 5 profils.
class CarteAjoutProfil extends StatelessWidget {
  const CarteAjoutProfil({
    super.key,
    required this.libelle,
    required this.onTap,
  });

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return _Cadre(
      onTap: onTap,
      pointille: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: TaillesYasmina.avatarCard,
            child: Icon(Icons.add_rounded, color: c.muted),
          ),
          const SizedBox(height: EspacesYasmina.space1),
          Text(
            libelle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!
                .copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

/// Fond surface, bordure line (pleine ou pointillée), coins radius-2xl.
class _Cadre extends StatelessWidget {
  const _Cadre({
    required this.onTap,
    required this.child,
    this.pointille = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool pointille;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final rayon = BorderRadius.circular(RayonsYasmina.radius2xl);
    final contenu = Material(
      color: pointille ? Colors.transparent : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: rayon,
        side: pointille
            ? BorderSide.none
            : BorderSide(color: c.line, width: TraitsYasmina.borderThick),
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
    if (!pointille) return contenu;
    return CustomPaint(
      foregroundPainter: _BordurePointillee(couleur: c.line),
      child: contenu,
    );
  }
}

/// Bordure pointillée arrondie (pas de paquet : Flutter ne la dessine pas).
class _BordurePointillee extends CustomPainter {
  const _BordurePointillee({required this.couleur});

  final Color couleur;

  /// Longueur d'un trait et d'un espace : 3 fois l'épaisseur, comme le
  /// pointillé CSS de la démo.
  static const _pas = TraitsYasmina.borderThick * 3;

  @override
  void paint(Canvas canvas, Size size) {
    const demi = TraitsYasmina.borderThick / 2;
    final contour = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(RayonsYasmina.radius2xl),
        ).deflate(demi),
      );
    final pinceau = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThick;
    for (final mesure in contour.computeMetrics()) {
      for (var d = 0.0; d < mesure.length; d += _pas * 2) {
        canvas.drawPath(mesure.extractPath(d, d + _pas), pinceau);
      }
    }
  }

  @override
  bool shouldRepaint(_BordurePointillee ancien) => ancien.couleur != couleur;
}
