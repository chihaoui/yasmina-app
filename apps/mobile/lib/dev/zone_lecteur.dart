import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Zone où un exemple ouvert de l'atelier est joué dans le mode choisi.
///
/// Point de branchement du lecteur d'exercice, le seul de l'atelier : un
/// type passe à [EtatType.jouable] dans le registre du moteur (avec son
/// gabarit) et la zone le joue, sans autre changement. Le journal des
/// événements s'affiche sous le lecteur, le plus récent en haut.
class ZoneLecteur extends StatefulWidget {
  const ZoneLecteur({
    super.key,
    required this.type,
    required this.exemple,
    required this.mode,
    required this.forme,
    required this.services,
  });

  final TypeExercice type;
  final ExempleType exemple;
  final ModeExercice mode;
  final FormeAdresse forme;
  final ServicesExercice services;

  @override
  State<ZoneLecteur> createState() => _ZoneLecteurState();
}

class _ZoneLecteurState extends State<ZoneLecteur> {
  /// Événements reçus, le plus récent en premier.
  final _journal = <String>[];

  /// Incrémenté par Continuer : une nouvelle partie du même exemple.
  var _partie = 0;

  void _ajouter(String ligne) => setState(() => _journal.insert(0, ligne));

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final exemple = widget.exemple;
    final jouable = widget.type.etat == EtatType.jouable && exemple.estValide;
    if (!jouable) return _message(context, c);

    final textes = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: TaillesYasmina.frameHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.screen,
              borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
              border: Border.all(
                color: c.line,
                width: TraitsYasmina.borderThick,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
              child: LecteurExercice(
                key: ValueKey('lecteur_partie_$_partie'),
                exercice: exemple.exercice!,
                config: ConfigExercice(
                  langue: exemple.langue!,
                  formeAdresse: widget.forme,
                  mode: widget.mode,
                ),
                services: widget.services,
                onEvenement: (e) => _ajouter('$e'),
                onContinuer: () {
                  _ajouter('continuer : nouvelle partie');
                  setState(() => _partie++);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: EspacesYasmina.space4),
        Text('Journal des événements', style: textes.titleMedium),
        const SizedBox(height: EspacesYasmina.space2),
        Text(
          _journal.isEmpty ? 'Aucun événement.' : _journal.join('\n'),
          key: const ValueKey('atelier_journal'),
          style: textes.bodySmall,
        ),
      ],
    );
  }

  Widget _message(BuildContext context, CouleursYasmina c) {
    final message = !widget.exemple.estValide
        ? 'Exemple invalide : corriger le JSON avant de le jouer.'
        : 'Type à venir : son moteur n\'est pas encore prêt (A1-01b pour '
              'le moteur Choix).';
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
