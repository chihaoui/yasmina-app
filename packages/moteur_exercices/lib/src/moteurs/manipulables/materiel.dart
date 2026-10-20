import 'package:flutter/material.dart';

import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// État visuel d'un élément de matériel (bloc, jeton).
enum EtatMateriel { repos, juste, faux }

/// Une barre de dix (dix cases collées, `blue-soft`) ou un cube d'unité
/// (`amber-soft`), docs/moteurs/manipulables.md §11.
class Bloc extends StatelessWidget {
  const Bloc({
    super.key,
    required this.dizaine,
    this.etat = EtatMateriel.repos,
  });

  final bool dizaine;
  final EtatMateriel etat;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, bord) = switch (etat) {
      EtatMateriel.juste => (c.oliveSoft, c.olive),
      EtatMateriel.faux => (c.coralSoft, c.coral),
      EtatMateriel.repos =>
        dizaine ? (c.blueSoft, c.blue) : (c.amberSoft, c.amber),
    };
    Widget cellule() => Container(
      width: EspacesYasmina.space8,
      height: EspacesYasmina.space4,
      decoration: BoxDecoration(
        color: fond,
        border: Border.all(color: bord, width: TraitsYasmina.borderThin),
      ),
    );
    return dizaine
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [for (var i = 0; i < 10; i++) cellule()],
          )
        : cellule();
  }
}

/// Un jeton rond (`olive`) du cadre de 10.
class Jeton extends StatelessWidget {
  const Jeton({super.key, this.etat = EtatMateriel.repos});

  final EtatMateriel etat;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, bord) = switch (etat) {
      EtatMateriel.juste => (c.olive, c.oliveText),
      EtatMateriel.faux => (c.coral, c.coralText),
      EtatMateriel.repos => (c.olive, c.oliveText),
    };
    return Container(
      width: EspacesYasmina.space8 + EspacesYasmina.space2,
      height: EspacesYasmina.space8 + EspacesYasmina.space2,
      decoration: BoxDecoration(
        color: fond,
        shape: BoxShape.circle,
        border: Border.all(color: bord, width: TraitsYasmina.borderThick),
      ),
    );
  }
}

/// Élément de réserve inépuisable : se glisse autant de fois que nécessaire
/// (il reste à sa place), le toucher l'ajoute aussi ([onToucher]).
class ReserveGlissable extends StatelessWidget {
  const ReserveGlissable({
    super.key,
    required this.donnee,
    required this.libelle,
    required this.child,
    this.onToucher,
  });

  /// Donnée du glisser (sorte de bloc, jeton).
  final String donnee;
  final String libelle;
  final Widget child;

  /// `null` : réserve verrouillée (ni glisser, ni toucher).
  final VoidCallback? onToucher;

  @override
  Widget build(BuildContext context) {
    final zone = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: EspacesYasmina.targetMin,
        minHeight: EspacesYasmina.targetMin,
      ),
      child: Center(child: child),
    );
    final corps = Semantics(
      button: true,
      enabled: onToucher != null,
      label: libelle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToucher,
        child: zone,
      ),
    );
    if (onToucher == null) return corps;
    return Draggable<String>(
      data: donnee,
      maxSimultaneousDrags: 1,
      feedback: Material(color: Colors.transparent, child: child),
      child: corps,
    );
  }
}

/// Préfixe de la donnée d'un élément posé pendant un glisser : une cible
/// qui l'accepte le déplace, un lâcher hors cible le retire.
const prefixePose = 'pose:';

/// Élément posé : le toucher le retire ([onToucher]), le glisser hors de sa
/// case aussi (corrections du 20 oct. 2026). Glissé sur une cible qui
/// accepte [donnee] (préfixée par [prefixePose]), il y est déplacé. Zone
/// d'au moins `target-min`.
class Pose extends StatelessWidget {
  const Pose({
    super.key,
    required this.libelle,
    required this.child,
    this.donnee = '',
    this.onToucher,
  });

  final String libelle;
  final Widget child;

  /// Donnée du glisser (sans le préfixe), par exemple l'index de la case.
  final String donnee;

  /// Retire l'élément. `null` : élément verrouillé (ni toucher, ni glisser).
  final VoidCallback? onToucher;

  @override
  Widget build(BuildContext context) {
    final corps = Semantics(
      button: true,
      enabled: onToucher != null,
      label: libelle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToucher,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: EspacesYasmina.targetMin,
            minHeight: EspacesYasmina.targetMin,
          ),
          child: Center(child: child),
        ),
      ),
    );
    if (onToucher == null) return corps;
    return Draggable<String>(
      data: '$prefixePose$donnee',
      maxSimultaneousDrags: 1,
      feedback: Material(color: Colors.transparent, child: child),
      childWhenDragging: Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: corps,
      ),
      // Lâché sans être accepté (toucher sans déplacement, ou hors de toute
      // cible) : l'élément est retiré.
      onDragEnd: (details) {
        if (!details.wasAccepted) onToucher?.call();
      },
      child: corps,
    );
  }
}

/// Mot d'état sous le matériel, en aperçu.
Widget motEtatMateriel(
  BuildContext context,
  String? mot, {
  required bool faux,
}) {
  final c = context.couleurs;
  if (mot == null) return const SizedBox.shrink();
  return Text(
    mot,
    textAlign: TextAlign.center,
    style: StylesYasmina.latinLabel.copyWith(
      color: faux ? c.coralText : c.oliveText,
    ),
  );
}
