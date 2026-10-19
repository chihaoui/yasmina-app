import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  group('mode vérifier (2 essais, 3 temps)', () {
    test('juste au 1er essai : validation, résultat réussi', () {
      final d = DerouleExercice();
      expect(d.feedback, isNull);
      expect(d.verifier(juste: true), [
        const Essai(1, juste: true),
        const Resultat(IssueExercice.reussi, essais: 1),
      ]);
      expect(d.phase, PhaseExercice.reussi);
      expect(d.feedback, TempsFeedback.validation);
      expect(d.estTermine, isTrue);
      expect(d.reponseRevelee, isFalse);
    });

    test('faux puis juste : indice, puis validation au 2e essai', () {
      final d = DerouleExercice();
      expect(d.verifier(juste: false), [const Essai(1, juste: false)]);
      expect(d.phase, PhaseExercice.indice);
      expect(d.feedback, TempsFeedback.indice);
      expect(d.estTermine, isFalse);
      expect(d.verifier(juste: true), [
        const Essai(2, juste: true),
        const Resultat(IssueExercice.reussi, essais: 2),
      ]);
      expect(d.feedback, TempsFeedback.validation);
    });

    test('faux deux fois : explication et bonne réponse révélée', () {
      final d = DerouleExercice()..verifier(juste: false);
      expect(d.verifier(juste: false), [
        const Essai(2, juste: false),
        const Resultat(IssueExercice.explique, essais: 2),
      ]);
      expect(d.phase, PhaseExercice.explique);
      expect(d.feedback, TempsFeedback.explication);
      expect(d.reponseRevelee, isTrue);
    });

    test('après la fin, une vérification est ignorée', () {
      final d = DerouleExercice()..verifier(juste: true);
      expect(d.verifier(juste: false), isEmpty);
      expect(d.phase, PhaseExercice.reussi);
      expect(d.essais, 1);
    });

    test('les autres chemins ne s\'appliquent pas', () {
      final d = DerouleExercice();
      expect(d.finAutomatique(juste: true), isEmpty);
      expect(d.terminerSansNote(), isEmpty);
      expect(d.phase, PhaseExercice.saisie);
    });
  });

  group('mode automatique (la zone signale la fin)', () {
    test('fin juste : réussi en un essai, validation', () {
      final d = DerouleExercice(validation: ModeValidation.automatique);
      expect(d.finAutomatique(juste: true), [
        const Essai(1, juste: true),
        const Resultat(IssueExercice.reussi, essais: 1),
      ]);
      expect(d.feedback, TempsFeedback.validation);
    });

    test('fin fausse : explication directe, sans indice ni 2e essai', () {
      final d = DerouleExercice(validation: ModeValidation.automatique);
      expect(d.finAutomatique(juste: false), [
        const Essai(1, juste: false),
        const Resultat(IssueExercice.explique, essais: 1),
      ]);
      expect(d.phase, PhaseExercice.explique);
      expect(d.reponseRevelee, isTrue);
    });

    test('une seule fin, Vérifier ne s\'applique pas', () {
      final d = DerouleExercice(validation: ModeValidation.automatique);
      expect(d.verifier(juste: true), isEmpty);
      d.finAutomatique(juste: true);
      expect(d.finAutomatique(juste: false), isEmpty);
      expect(d.phase, PhaseExercice.reussi);
    });
  });

  group('mode sans note (T20)', () {
    test('terminé sans feedback juste ou faux', () {
      final d = DerouleExercice(validation: ModeValidation.sansNote);
      expect(d.verifier(juste: true), isEmpty);
      expect(d.terminerSansNote(), [
        const Resultat(IssueExercice.termine, essais: 0),
      ]);
      expect(d.phase, PhaseExercice.termine);
      expect(d.feedback, isNull);
      expect(d.estTermine, isTrue);
    });
  });

  test('aperçu et édition : aucun événement de progression', () {
    for (final mode in [ModeExercice.apercu, ModeExercice.edition]) {
      final d = DerouleExercice(mode: mode);
      expect(d.verifier(juste: false), isEmpty, reason: mode.name);
      expect(d.verifier(juste: false), isEmpty, reason: mode.name);
      expect(d.phase, PhaseExercice.explique, reason: mode.name);
      final auto = DerouleExercice(
        validation: ModeValidation.automatique,
        mode: mode,
      );
      expect(auto.finAutomatique(juste: true), isEmpty, reason: mode.name);
    }
  });

  test('rejouer remet à zéro', () {
    final d = DerouleExercice()
      ..verifier(juste: false)
      ..verifier(juste: false)
      ..rejouer();
    expect(d.phase, PhaseExercice.saisie);
    expect(d.essais, 0);
    expect(d.verifier(juste: true), contains(const Essai(1, juste: true)));
  });

  test('les événements se décrivent pour le journal', () {
    expect('${const Essai(2, juste: false)}', 'essai 2 : faux');
    expect(
      '${const DemandeAudio('Hi', langue: 'en', origine: OrigineAudio.consigne)}',
      'demandeAudio (consigne, en) : Hi',
    );
  });
}
