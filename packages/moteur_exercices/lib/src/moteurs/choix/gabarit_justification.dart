import 'dart:math';

import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'grille_choix.dart';
import 'selection_choix.dart';

/// T46 Réponse puis justification : le texte, la question et ses réponses
/// (partie A), puis les phrases du texte (partie B). Juste si les deux
/// parties le sont (docs/moteurs/choix.md §5).
class GabaritJustification implements GabaritReponse {
  const GabaritJustification();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurJustification creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final aleatoire = config.graine == null ? null : Random(config.graine);
    return ControleurJustification(
      config: config,
      texte: donnees['texte'] as String,
      question: donnees['question'] as String,
      choix: SelectionChoix(
        propositions: [
          for (final c
              in (donnees['choix'] as List).cast<Map<String, dynamic>>())
            Proposition.depuisJson(c),
        ],
        attendus: (reponse['choix'] as List).cast<String>(),
        melanger: donnees['melanger'] as bool? ?? true,
        aleatoire: aleatoire,
      ),
      // Les preuves sont des phrases du texte : toujours dans son ordre.
      preuves: SelectionChoix(
        propositions: [
          for (final p
              in (donnees['preuves'] as List).cast<Map<String, dynamic>>())
            Proposition.depuisJson(p),
        ],
        attendus: (reponse['preuves'] as List).cast<String>(),
      ),
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneJustification(controleur as ControleurJustification);
}

/// Réponse de T46 : une réponse (A) et une preuve (B).
class ControleurJustification extends ControleurReponse {
  ControleurJustification({
    required this.config,
    required this.texte,
    required this.question,
    required this.choix,
    required this.preuves,
  });

  final ConfigExercice config;
  final String texte;
  final String question;
  final SelectionChoix choix;
  final SelectionChoix preuves;

  @override
  bool get complete => choix.complete && preuves.complete;

  @override
  Object? get reponse => {'choix': choix.ids, 'preuves': preuves.ids};

  @override
  bool corriger() => choix.juste && preuves.juste;

  @override
  void vider() {
    choix.vider();
    preuves.vider();
    reponseModifiee();
  }
}

class _ZoneJustification extends StatelessWidget {
  const _ZoneJustification(this.controleur);

  final ControleurJustification controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final arabe = langue == 'ar';
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: EspacesYasmina.space6,
        children: [
          // Texte long à lire : content-sentence en arabe, latin-body
          // sinon (décision 38).
          Text(
            controleur.texte,
            key: const ValueKey('justification_texte'),
            style: ThemeYasmina.pourLangue(
              arabe ? StylesYasmina.contentSentence : StylesYasmina.latinBody,
              langue,
            ).copyWith(color: c.ink),
          ),
          Text(
            controleur.question,
            key: const ValueKey('justification_question'),
            style: ThemeYasmina.pourLangue(
              arabe ? StylesYasmina.prompt : StylesYasmina.latinPrompt,
              langue,
            ).copyWith(color: c.ink),
          ),
          GrilleChoix(
            selection: controleur.choix,
            controleur: controleur,
            libelles: libelles,
            mode: config.mode,
          ),
          GrilleChoix(
            selection: controleur.preuves,
            controleur: controleur,
            libelles: libelles,
            mode: config.mode,
            prefixeCle: 'preuve',
            pleineLargeur: true,
          ),
        ],
      ),
    );
  }
}
