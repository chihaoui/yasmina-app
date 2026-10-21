import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/parcours/progression.dart';

import 'fixtures_parcours.dart';

void main() {
  final parcours = catalogueTest().pour(matiere: 'arabe', niveau: 1)!;
  const e1 = 'ar-1-t1-u1-e01';
  const e2 = 'ar-1-t1-u1-e02';

  test('la première étape est ouverte, la suivante se déverrouille quand la '
      'précédente est faite, une étape faite reste faite', () {
    expect(etatEtape(parcours, e1, {}), EtatEtape.ouverte);
    expect(etatEtape(parcours, e2, {}), EtatEtape.verrouillee);
    expect(etatEtape(parcours, e1, {e1}), EtatEtape.faite);
    expect(etatEtape(parcours, e2, {e1}), EtatEtape.ouverte);
    expect(etatEtape(parcours, e2, {e1, e2}), EtatEtape.faite);
  });

  test('« tout débloquer » ouvre les étapes verrouillées', () {
    expect(etatEtape(parcours, e2, {}, toutDebloque: true), EtatEtape.ouverte);
    expect(etatEtape(parcours, e1, {e1}, toutDebloque: true), EtatEtape.faite);
  });

  test('parcours : ordre par unité puis ordre, suivante et précédente', () {
    expect(parcours.etapes.map((e) => e.id), [e1, e2]);
    expect(parcours.suivante(e1)!.id, e2);
    expect(parcours.suivante(e2), isNull);
    expect(parcours.precedente(e1), isNull);
    expect(parcours.precedente(e2)!.id, e1);
    expect(parcours.parUnite.keys, [1]);
  });

  test('étape : lettre lue dans le titre sans T18, défi reconnu, déroulé', () {
    final e = parcours.etape(e1)!;
    expect(e.lettre, 'ب');
    expect(e.estDefi, isFalse);
    expect(e.formes, isEmpty);
    expect(e.nombreExercices, 2);
    expect(e.deroule.map((x) => x.sequence), [0, 0]);
    final defi = parcours.etape(e2)!;
    expect(defi.estDefi, isTrue);
    expect(defi.nombreExercices, 1);
  });
}
