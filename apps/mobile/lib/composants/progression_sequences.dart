import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Barre du haut du lecteur d'une étape
/// (docs/design-system/composants/SequenceProgress.md) : un segment par
/// exercice, coloré par séquence (`seq-1` à `seq-4`, `seq-defi`), à venir en
/// `line`, exercice en cours cerné d'ink. Se remplit dans le sens de
/// l'interface (de droite à gauche en arabe).
class ProgressionSequences extends StatelessWidget {
  const ProgressionSequences({
    super.key,
    required this.sequences,
    required this.courant,
    required this.libelle,
    this.defi = false,
  });

  /// Index de la séquence de chaque exercice, dans l'ordre de passage.
  final List<int> sequences;

  /// Index de l'exercice en cours (égal au nombre d'exercices à la fin).
  final int courant;

  /// Libellé lu par le lecteur d'écran (« Exercice 3 sur 15 »).
  final String libelle;

  /// Défi de l'unité : une seule couleur, `seq-defi`.
  final bool defi;

  /// Couleur de la séquence [index].
  static Color couleurSequence(
    CouleursYasmina c,
    int index, {
    bool defi = false,
  }) {
    if (defi) return c.seqDefi;
    final couleurs = [c.seq1, c.seq2, c.seq3, c.seq4];
    return couleurs[index % couleurs.length];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Semantics(
      label: libelle,
      excludeSemantics: true,
      child: Row(
        spacing: EspacesYasmina.space1,
        children: [
          for (var i = 0; i < sequences.length; i++)
            Expanded(
              child: Container(
                height: EspacesYasmina.space3,
                decoration: BoxDecoration(
                  color: i <= courant
                      ? couleurSequence(c, sequences[i], defi: defi)
                      : c.line,
                  borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
                  border: i == courant
                      ? Border.all(
                          color: c.ink,
                          width: TraitsYasmina.borderThick,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
