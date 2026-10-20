import 'package:flutter/material.dart';

import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// État visuel d'une cible de dépôt.
enum EtatDepot {
  /// Au repos : bordure pointillée.
  repos,

  /// Un élément tenu est au-dessus (aimant) : bordure pleine blue.
  allumee,

  /// Contenu juste (validation, réponse révélée) : bordure pleine olive.
  juste,
}

/// Cible de dépôt du moteur Glisser-déposer (zone du LetterTile du design
/// system) : trou, paire, bac, ligne de réponse, zone du mot. Au moins
/// `target-min` de haut et de large. Reçoit un élément glissé
/// ([onDepot]) ou l'élément en attente au toucher ([onToucher]).
class ZoneDepot extends StatelessWidget {
  const ZoneDepot({
    super.key,
    required this.libelle,
    required this.child,
    this.etat = EtatDepot.repos,
    this.onDepot,
    this.onToucher,
    this.accepte,
    this.enLigne = false,
  });

  /// Libellé d'accessibilité de la cible (titre du bac, mot de droite).
  final String libelle;

  final Widget child;
  final EtatDepot etat;

  /// Dépôt d'un élément (id). `null` : cible verrouillée.
  final ValueChanged<String>? onDepot;

  /// Toucher de la cible (pose l'élément en attente).
  final VoidCallback? onToucher;

  /// Refuse certains éléments (par défaut, tout est accepté).
  final bool Function(String id)? accepte;

  /// Cible posée dans un texte (trou) : largeur au contenu, pas de
  /// remplissage.
  final bool enLigne;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) =>
          onDepot != null && (accepte?.call(d.data) ?? true),
      onAcceptWithDetails: (d) => onDepot?.call(d.data),
      builder: (context, candidats, _) {
        final allumee = candidats.isNotEmpty || etat == EtatDepot.allumee;
        final couleur = switch (etat) {
          EtatDepot.juste => c.olive,
          _ => allumee ? c.blue : c.line,
        };
        final pointille = !allumee && etat != EtatDepot.juste;
        return Semantics(
          button: onToucher != null,
          label: libelle,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToucher,
            child: CustomPaint(
              painter: _BordurePointillee(
                couleur: couleur,
                pointille: pointille,
                fond: allumee ? c.blueSoft : c.tile,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: EspacesYasmina.targetMin,
                  minWidth: EspacesYasmina.targetMin,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.all(
                    enLigne ? EspacesYasmina.space1 : EspacesYasmina.space2,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bordure pointillée ou pleine, coins `radius-lg`, fond `tile`.
class _BordurePointillee extends CustomPainter {
  const _BordurePointillee({
    required this.couleur,
    required this.pointille,
    required this.fond,
  });

  final Color couleur;
  final bool pointille;
  final Color fond;

  // design-ok : longueur des tirets du pointillé, sans jeton (question 5
  // de docs/moteurs/glisser-deposer-questions.md).
  static const _tiret = 6.0;
  static const _ecart = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(TraitsYasmina.borderThick / 2),
      const Radius.circular(RayonsYasmina.radiusLg),
    );
    canvas.drawRRect(rrect, Paint()..color = fond);
    final trait = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThick;
    if (!pointille) {
      canvas.drawRRect(rrect, trait);
      return;
    }
    final chemin = Path()..addRRect(rrect);
    for (final metrique in chemin.computeMetrics()) {
      var distance = 0.0;
      while (distance < metrique.length) {
        final fin = (distance + _tiret).clamp(0.0, metrique.length);
        canvas.drawPath(metrique.extractPath(distance, fin), trait);
        distance = fin + _ecart;
      }
    }
  }

  @override
  bool shouldRepaint(_BordurePointillee ancien) =>
      ancien.couleur != couleur ||
      ancien.pointille != pointille ||
      ancien.fond != fond;
}
