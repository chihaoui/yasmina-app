import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Pastille d'état d'un type dans l'atelier (Pill du design system).
class PastilleEtat extends StatelessWidget {
  const PastilleEtat(this.etat, {super.key});

  final EtatType etat;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (texte, fond, encre) = switch (etat) {
      EtatType.jouable => ('Jouable', c.oliveSoft, c.oliveText),
      EtatType.aVenir => ('À venir', c.amberSoft, c.amberText),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(RayonsYasmina.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EspacesYasmina.space2,
          vertical: EspacesYasmina.space1,
        ),
        child: Text(
          texte,
          style: StylesYasmina.latinLabel.copyWith(color: encre),
        ),
      ),
    );
  }
}
