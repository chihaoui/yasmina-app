import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  test('53 types, 12 moteurs, aucun doublon, ids T01 à T63', () {
    expect(typesExercices, hasLength(53));
    expect(Moteur.values, hasLength(12));
    final ids = typesExercices.map((t) => t.id).toList();
    expect(ids.toSet(), hasLength(53));
    for (final id in ids) {
      expect(id, matches(RegExp(r'^T(0[1-9]|[1-5][0-9]|6[0-3])$')));
    }
    expect(typesExercices.map((t) => t.nom).toSet(), hasLength(53));
  });

  test('36 types en lot 1 (jalon G1) et 17 en lot 2', () {
    expect(typesExercices.where((t) => t.lot == 1), hasLength(36));
    expect(typesExercices.where((t) => t.lot == 2), hasLength(17));
  });

  test('chaque moteur a ses types, le moteur Choix en a 13', () {
    for (final moteur in Moteur.values) {
      expect(typesDuMoteur(moteur), isNotEmpty, reason: moteur.nom);
    }
    expect(typesDuMoteur(Moteur.choix).map((t) => t.id), [
      'T01',
      'T02',
      'T03',
      'T04',
      'T05',
      'T18',
      'T19',
      'T23',
      'T24',
      'T45',
      'T46',
      'T55',
      'T61',
    ]);
  });

  test("ordre de développement de l'atelier (décision 34)", () {
    expect(Moteur.values.take(4), [
      Moteur.choix,
      Moteur.glisserDeposer,
      Moteur.trace,
      Moteur.manipulables,
    ]);
    // Moteurs entièrement en lot 2, après tous ceux qui ont du lot 1.
    bool aDuLot1(Moteur m) => typesDuMoteur(m).any((t) => t.lot == 1);
    final premierLot2 = Moteur.values.indexWhere((m) => !aDuLot1(m));
    expect(Moteur.values.skip(premierLot2).any(aDuLot1), isFalse);
  });

  test('les types jouables sont ceux des moteurs déjà branchés', () {
    final jouables = typesExercices
        .where((t) => t.etat == EtatType.jouable)
        .map((t) => t.id);
    expect(jouables, contains('T02'));
    expect(jouables, gabaritsJouables.keys);
    for (final id in jouables) {
      expect(
        typeParId(id)!.moteur,
        isIn([
          Moteur.choix,
          Moteur.glisserDeposer,
          Moteur.trace,
          Moteur.manipulables,
          Moteur.texte,
          Moteur.saisieNumerique,
        ]),
        reason: id,
      );
    }
    expect(typeParId('T19')!.nom, 'Choisir la haraka');
    expect(typeParId('T99'), isNull);
  });

  test('un type est jouable si et seulement s\'il a un gabarit', () {
    for (final type in typesExercices) {
      expect(
        gabaritPour(type.id) != null,
        type.etat == EtatType.jouable,
        reason: type.id,
      );
    }
    expect(gabaritsJouables.keys.every((id) => typeParId(id) != null), isTrue);
  });
}
