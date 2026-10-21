import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/donnees/base_yasmina.dart';
import 'package:yasmina/profils/avatar.dart';

void main() {
  late BaseYasmina base;
  final t = DateTime.utc(2026, 10, 17, 9);

  setUp(() => base = BaseYasmina(NativeDatabase.memory()));
  tearDown(() => base.close());

  Future<int> profil(String prenom, {int niveau = 1}) => base
      .into(base.profils)
      .insert(
        ProfilsCompanion.insert(
          prenom: prenom,
          niveau: niveau,
          avatar: Avatar.fleur,
          formeAdresse: FormeAdresse.feminin,
          creeLe: t,
          modifieLe: t,
        ),
      );

  Future<int> periode(int profilId, {DateTime? fin}) => base
      .into(base.historiqueNiveaux)
      .insert(
        HistoriqueNiveauxCompanion.insert(
          profilId: profilId,
          niveau: 1,
          debut: t,
          fin: Value(fin),
        ),
      );

  Matcher echoueAvec(String extrait) =>
      throwsA(predicate((e) => '$e'.contains(extrait), 'erreur « $extrait »'));

  test('les clés étrangères sont actives', () async {
    final r = await base.customSelect('PRAGMA foreign_keys').getSingle();
    expect(r.data.values.single, 1);
  });

  test('le déclencheur refuse un 6e profil', () async {
    for (final p in ['A', 'B', 'C', 'D', 'E']) {
      await profil(p);
    }
    await expectLater(profil('F'), echoueAvec('limite_profils'));
    expect(await base.select(base.profils).get(), hasLength(5));
  });

  test('niveau hors de 1 à 6 refusé', () async {
    await expectLater(profil('Lina', niveau: 7), echoueAvec('CHECK'));
    await expectLater(profil('Lina', niveau: 0), echoueAvec('CHECK'));
  });

  test('prénom vide, trop long ou avec espaces autour refusé', () async {
    await expectLater(profil(''), echoueAvec('CHECK'));
    await expectLater(profil('A' * 21), echoueAvec('CHECK'));
    await expectLater(profil(' Lina'), echoueAvec('CHECK'));
  });

  test('prénom unique, sans distinguer les majuscules', () async {
    await profil('Lina');
    await expectLater(profil('lina'), echoueAvec('UNIQUE'));
  });

  test('un seul niveau en cours par profil', () async {
    final id = await profil('Lina');
    await periode(id, fin: t);
    await periode(id);
    await expectLater(periode(id), echoueAvec('UNIQUE'));
  });

  test("supprimer un profil supprime son historique", () async {
    final id = await profil('Lina');
    await periode(id, fin: t);
    await periode(id);
    await (base.delete(base.profils)..where((p) => p.id.equals(id))).go();
    expect(await base.select(base.historiqueNiveaux).get(), isEmpty);
  });

  Future<void> progression(int profilId) async {
    await base
        .into(base.etatsEtapes)
        .insert(
          EtatsEtapesCompanion.insert(
            profilId: profilId,
            etapeId: 'ar-1-t1-u1-e01',
            commenceLe: t,
            modifieLe: t,
          ),
        );
    await base
        .into(base.resultatsExercices)
        .insert(
          ResultatsExercicesCompanion.insert(
            profilId: profilId,
            etapeId: 'ar-1-t1-u1-e01',
            sequenceId: 'ar-1-t1-u1-e01-s1',
            exerciceId: 'ar-1-t1-u1-e01-x01',
            essais: 1,
            reussi: true,
            revele: false,
            joueLe: t,
          ),
        );
  }

  test('supprimer un profil supprime sa progression', () async {
    final id = await profil('Lina');
    await progression(id);
    await (base.delete(base.profils)..where((p) => p.id.equals(id))).go();
    expect(await base.select(base.etatsEtapes).get(), isEmpty);
    expect(await base.select(base.resultatsExercices).get(), isEmpty);
  });

  test(
    'un seul résultat par exercice et par profil, un seul état par étape',
    () async {
      final id = await profil('Lina');
      await progression(id);
      await expectLater(progression(id), echoueAvec('UNIQUE'));
    },
  );

  test('toutEffacer vide toutes les tables', () async {
    final id = await profil('Lina');
    await periode(id);
    await progression(id);
    await base.toutEffacer();
    expect(await base.select(base.profils).get(), isEmpty);
    expect(await base.select(base.historiqueNiveaux).get(), isEmpty);
    expect(await base.select(base.etatsEtapes).get(), isEmpty);
    expect(await base.select(base.resultatsExercices).get(), isEmpty);
  });
}
