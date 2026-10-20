import 'package:flutter/material.dart';

import '../../composants/tuile_choix.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import 'selection_choix.dart';

/// Grille des propositions d'une [SelectionChoix] (docs/moteurs/choix.md
/// §10) : 2 propositions sur 2 colonnes, 3 sur 3, 4 en 2 × 2, 5 ou 6 sur 3
/// colonnes, phrases en pleine largeur. Elle suit le sens d'écriture de
/// l'exercice : en arabe, elle se remplit de droite à gauche.
///
/// Chaque tuile porte la clé `<prefixeCle>_<id>` (tests, atelier).
class GrilleChoix extends StatelessWidget {
  const GrilleChoix({
    super.key,
    required this.selection,
    required this.controleur,
    required this.libelles,
    required this.mode,
    this.prefixeCle = 'choix',
    this.pleineLargeur = false,
    this.barrer = false,
    this.grand = false,
    this.onToucher,
  });

  final SelectionChoix selection;

  /// Contrôleur qui porte l'affichage imposé par le lecteur et reçoit les
  /// changements.
  final ControleurReponse controleur;

  final LibellesLecteur libelles;
  final ModeExercice mode;
  final String prefixeCle;

  /// Une proposition par ligne (phrases de T45, T46 partie B, T61).
  final bool pleineLargeur;

  /// Une tuile sélectionnée est barrée (T45).
  final bool barrer;

  /// Texte des tuiles en content-word (formes de lettre, lettres
  /// vocalisées, signes).
  final bool grand;

  /// Appelé après le basculement de [SelectionChoix] (pour un affichage
  /// dérivé, comme la case « ? » de T24).
  final ValueChanged<String>? onToucher;

  /// Nombre de colonnes pour [n] propositions.
  static int colonnes(int n, {bool pleineLargeur = false}) {
    if (pleineLargeur) return 1;
    return switch (n) {
      <= 2 => 2,
      3 => 3,
      4 => 2,
      _ => 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    final vibration = ServicesExercice.of(context).vibration;
    final propositions = selection.propositions;
    final nbColonnes = colonnes(
      propositions.length,
      pleineLargeur: pleineLargeur,
    );
    final revelee = controleur.affichage == AffichageReponse.revelee;

    Widget tuile(Proposition p) {
      final etat = selection.etatDe(p.id, controleur.affichage);
      return TuileChoix(
        key: ValueKey('${prefixeCle}_${p.id}'),
        etat: etat,
        texte: p.texte,
        emoji: p.emoji,
        grand: grand,
        barre: barrer && selection.estSelectionne(p.id),
        // Une tuile sans texte garde un libellé neutre : le mot à trouver
        // reste seulement audio (choix.md §10).
        libelleAccessibilite: p.texte == null
            ? libelles.image(selection.numero(p.id))
            : null,
        // Aperçu (adulte) : la bonne réponse porte un mot d'état.
        motEtat:
            revelee &&
                mode != ModeExercice.enfant &&
                selection.attendus.contains(p.id)
            ? 'bonne réponse'
            : null,
        onTap: controleur.modifiable
            ? () {
                vibration.legere();
                selection.basculer(p.id);
                onToucher?.call(p.id);
                controleur.reponseModifiee();
              }
            : null,
      );
    }

    final lignes = <Widget>[];
    for (var debut = 0; debut < propositions.length; debut += nbColonnes) {
      final fin = (debut + nbColonnes).clamp(0, propositions.length);
      lignes.add(
        // Tuiles d'une même ligne à la même hauteur (la colonne défile :
        // sans IntrinsicHeight, l'étirement n'aurait pas de borne).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: EspacesYasmina.space3,
            children: [
              for (final p in propositions.sublist(debut, fin))
                Expanded(child: tuile(p)),
              // Cases vides de la dernière ligne : même largeur de tuile.
              for (var i = fin; i < debut + nbColonnes; i++)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: EspacesYasmina.space3,
      children: lignes,
    );
  }
}
