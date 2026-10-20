import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'grille_choix.dart';
import 'selection_choix.dart';

/// Les trois signes de T23, dans leur ordre fixe.
const signesComparaison = ['<', '=', '>'];

/// T23 Comparer : « a ? b » en grand, puis les tuiles <, = et >. La réponse
/// se lit « a signe b » en notation mathématique, de gauche à droite,
/// isolée du sens de la phrase (docs/moteurs/choix.md §9).
class GabaritComparer implements GabaritReponse {
  const GabaritComparer();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurComparer creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurComparer(
      config: config,
      a: donnees['a'] as num,
      b: donnees['b'] as num,
      selection: SelectionChoix(
        propositions: [
          for (final s in signesComparaison) Proposition(id: s, texte: s),
        ],
        attendus: [reponse['signe'] as String],
      ),
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneComparer(controleur as ControleurComparer);
}

/// Réponse de T23 : le signe choisi.
class ControleurComparer extends ControleurReponse {
  ControleurComparer({
    required this.config,
    required this.a,
    required this.b,
    required this.selection,
  });

  final ConfigExercice config;
  final num a;
  final num b;
  final SelectionChoix selection;

  String? get signe => selection.ids.firstOrNull;

  @override
  bool get complete => selection.complete;

  @override
  Object? get reponse => {'signe': signe};

  @override
  bool corriger() => selection.juste;

  @override
  void vider() {
    selection.vider();
    reponseModifiee();
  }
}

class _ZoneComparer extends StatelessWidget {
  const _ZoneComparer(this.controleur);

  final ControleurComparer controleur;

  /// Nombre sans décimale inutile (14, 2,5).
  static String _nombre(num n) =>
      n == n.roundToDouble() ? n.toInt().toString() : '$n';

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final libelles = LibellesLecteur.pour(config.langue, config.formeAdresse);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final signe = controleur.signe;
        // Expression et signes toujours de gauche à droite : < et > ne sont
        // jamais retournés par l'algorithme bidirectionnel.
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: EspacesYasmina.space6,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${_nombre(controleur.a)} '),
                    TextSpan(
                      text: signe ?? '?',
                      style: TextStyle(color: c.blue),
                    ),
                    TextSpan(text: ' ${_nombre(controleur.b)}'),
                  ],
                ),
                key: const ValueKey('comparer_expression'),
                textAlign: TextAlign.center,
                style: StylesYasmina.contentWord.copyWith(color: c.ink),
              ),
              GrilleChoix(
                selection: controleur.selection,
                controleur: controleur,
                libelles: libelles,
                mode: config.mode,
                prefixeCle: 'signe',
                grand: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
