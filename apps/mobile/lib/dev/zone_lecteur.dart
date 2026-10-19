import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Zone où un exemple ouvert de l'atelier est joué dans le mode choisi.
///
/// **Point de branchement du lecteur d'exercice, le seul de l'atelier.**
/// Aujourd'hui aucun type n'est jouable : la zone affiche pourquoi. Quand un
/// type passe à [EtatType.jouable] dans le registre du moteur et que
/// l'exemple est valide, remplacer le message par le lecteur (A0-13), par
/// exemple :
///
/// ```dart
/// LecteurExercice(
///   exercice: exemple.exercice!,
///   config: ConfigExercice(
///     langue: exemple.langue!,
///     formeAdresse: FormeAdresse.feminin,
///     mode: mode,
///   ),
///   onEvenement: journal.ajouter, // affiché sous la zone
/// )
/// ```
///
/// Le reste de l'atelier ne change pas.
class ZoneLecteur extends StatelessWidget {
  const ZoneLecteur({
    super.key,
    required this.type,
    required this.exemple,
    required this.mode,
  });

  final TypeExercice type;
  final ExempleType exemple;
  final ModeExercice mode;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final message = !exemple.estValide
        ? 'Exemple invalide : corriger le JSON avant de le jouer.'
        : type.etat == EtatType.aVenir
        ? 'Type à venir : le lecteur arrive avec A0-13 et le moteur avec '
              'A1-01b.'
        : 'Lecteur à brancher ici (A0-13), en mode ${mode.name}.';
    return DecoratedBox(
      key: const ValueKey('zone_lecteur'),
      decoration: BoxDecoration(
        color: c.tile,
        borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
        border: Border.all(color: c.line, width: TraitsYasmina.borderThick),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: TaillesYasmina.yasminaHome,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
          child: Center(
            child: Text(
              message,
              key: const ValueKey('zone_lecteur_message'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge!
                  .copyWith(color: c.muted),
            ),
          ),
        ),
      ),
    );
  }
}
