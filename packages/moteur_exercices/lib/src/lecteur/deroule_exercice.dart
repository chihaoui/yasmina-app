// Machine d'états d'un exercice, en Dart pur (aucun import Flutter) :
// essais, feedback en 3 temps et résultat, testée sans widget.

import '../registre/registre_types.dart';
import 'evenements.dart';

/// Comment un type se termine.
enum ModeValidation {
  /// Par défaut : bouton Vérifier, 2 essais, feedback en 3 temps.
  verifier,

  /// La zone signale elle-même la fin et si elle est juste (T37 Memory,
  /// T38 Mots mêlés, T50 fin du chrono, T35 et T57 dernière étape). Pas de
  /// bouton Vérifier : feedback puis Continuer.
  automatique,

  /// Type non noté (T20) : Continuer dès que la réponse est complète, sans
  /// correction ni feedback juste ou faux.
  sansNote,
}

/// Phase d'un exercice.
enum PhaseExercice {
  /// L'enfant répond.
  saisie,

  /// 1er essai faux : l'indice est affiché, l'enfant répond à nouveau.
  indice,

  /// Juste : validation affichée, Continuer.
  reussi,

  /// Faux au 2e essai (ou fin automatique fausse) : explication et bonne
  /// réponse, Continuer.
  explique,

  /// Type non noté, fini.
  termine,
}

/// Temps du feedback à afficher.
enum TempsFeedback { validation, indice, explication }

/// Déroulé d'un exercice : seul endroit où vivent les règles des essais.
class DerouleExercice {
  DerouleExercice({
    this.validation = ModeValidation.verifier,
    this.mode = ModeExercice.enfant,
  });

  /// Nombre d'essais avant l'explication (CLAUDE.md §5).
  static const essaisMax = 2;

  final ModeValidation validation;
  final ModeExercice mode;

  PhaseExercice phase = PhaseExercice.saisie;
  int essais = 0;

  bool get estTermine => switch (phase) {
    PhaseExercice.reussi ||
    PhaseExercice.explique ||
    PhaseExercice.termine => true,
    PhaseExercice.saisie || PhaseExercice.indice => false,
  };

  /// Feedback affiché dans cette phase, `null` sans feedback.
  TempsFeedback? get feedback => switch (phase) {
    PhaseExercice.reussi => TempsFeedback.validation,
    PhaseExercice.indice => TempsFeedback.indice,
    PhaseExercice.explique => TempsFeedback.explication,
    PhaseExercice.saisie || PhaseExercice.termine => null,
  };

  /// La bonne réponse est montrée (après l'explication).
  bool get reponseRevelee => phase == PhaseExercice.explique;

  /// Mode vérifier : corrige un essai. Juste au 1er ou au 2e essai donne
  /// [PhaseExercice.reussi], faux au 1er [PhaseExercice.indice], faux au 2e
  /// [PhaseExercice.explique]. Ignoré dans un autre mode ou après la fin.
  List<EvenementExercice> verifier({required bool juste}) {
    if (validation != ModeValidation.verifier || estTermine) return const [];
    essais++;
    phase = juste
        ? PhaseExercice.reussi
        : essais >= essaisMax
        ? PhaseExercice.explique
        : PhaseExercice.indice;
    return _progression([
      Essai(essais, juste: juste),
      if (estTermine) _resultat(),
    ]);
  }

  /// Mode automatique : la zone a signalé la fin. Un seul résultat, sans
  /// indice ni second essai.
  List<EvenementExercice> finAutomatique({required bool juste}) {
    if (validation != ModeValidation.automatique || estTermine) {
      return const [];
    }
    essais = 1;
    phase = juste ? PhaseExercice.reussi : PhaseExercice.explique;
    return _progression([Essai(1, juste: juste), _resultat()]);
  }

  /// Mode sans note : l'enfant a fini (Continuer).
  List<EvenementExercice> terminerSansNote() {
    if (validation != ModeValidation.sansNote || estTermine) return const [];
    phase = PhaseExercice.termine;
    return _progression([_resultat()]);
  }

  /// Recommence l'exercice (aperçu, édition, atelier).
  void rejouer() {
    phase = PhaseExercice.saisie;
    essais = 0;
  }

  Resultat _resultat() => Resultat(switch (phase) {
    PhaseExercice.reussi => IssueExercice.reussi,
    PhaseExercice.termine => IssueExercice.termine,
    _ => IssueExercice.explique,
  }, essais: essais);

  /// En aperçu et en édition, aucun événement de progression.
  List<EvenementExercice> _progression(List<EvenementExercice> evenements) =>
      mode == ModeExercice.enfant ? evenements : const [];
}
