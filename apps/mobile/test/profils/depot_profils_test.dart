import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/donnees/base_yasmina.dart';
import 'package:yasmina/profils/avatar.dart';
import 'package:yasmina/profils/depot_profils.dart';

void main() {
  late BaseYasmina base;
  late DepotProfils depot;
  late DateTime maintenant;

  setUp(() {
    maintenant = DateTime.utc(2026, 10, 17, 9);
    base = BaseYasmina(NativeDatabase.memory());
    depot = DepotProfils(base, horloge: () => maintenant);
  });
  tearDown(() => base.close());

  Future<ProfilEnfant> creer(String prenom, {int niveau = 1}) => depot.creer(
    prenom: prenom,
    niveau: niveau,
    avatar: Avatar.soleil,
    formeAdresse: FormeAdresse.masculin,
  );

  group('création', () {
    test('profil créé avec une période de niveau en cours', () async {
      final p = await creer('  Yassine ', niveau: 2);
      expect(p.prenom, 'Yassine');
      expect(p.niveau, 2);
      expect(p.avatar, Avatar.soleil);
      expect(p.formeAdresse, FormeAdresse.masculin);
      final historique = await depot.historiqueNiveaux(p.id);
      expect(historique.single.niveau, 2);
      expect(historique.single.debut, maintenant);
      expect(historique.single.fin, isNull);
    });

    test('prénom arabe conservé tel quel (harakat comprises)', () async {
      const prenom = 'لِينَا';
      final p = await creer(prenom);
      expect(p.prenom.runes, orderedEquals(prenom.runes));
    });

    test('prénom vide ou trop long refusé, 20 caractères acceptés', () async {
      await expectLater(creer('   '), throwsA(isA<PrenomInvalide>()));
      await expectLater(creer('A' * 21), throwsA(isA<PrenomInvalide>()));
      expect((await creer('A' * 20)).prenom, hasLength(20));
    });

    test('prénom déjà utilisé, sans distinguer les majuscules', () async {
      await creer('Lina');
      await expectLater(creer(' lina'), throwsA(isA<PrenomDejaUtilise>()));
    });
  });

  group('limite de 5 profils', () {
    test('le 6e profil est refusé, la base garde 5 profils', () async {
      for (var i = 1; i <= DepotProfils.maxProfils; i++) {
        await creer('Enfant $i');
      }
      await expectLater(
        creer('Enfant 6'),
        throwsA(isA<LimiteProfilsAtteinte>()),
      );
      expect(await depot.lister(), hasLength(5));
    });

    test(
      'la constante du dépôt correspond au déclencheur de la base',
      () async {
        expect(DepotProfils.maxProfils, 5);
        for (var i = 1; i < DepotProfils.maxProfils; i++) {
          await creer('Enfant $i');
        }
        // Écriture directe en base : la 5e passe, la 6e est bloquée par le
        // déclencheur même sans passer par le dépôt.
        Future<int> direct(String prenom) => base
            .into(base.profils)
            .insert(
              ProfilsCompanion.insert(
                prenom: prenom,
                niveau: 1,
                avatar: Avatar.lune,
                formeAdresse: FormeAdresse.feminin,
                creeLe: maintenant,
                modifieLe: maintenant,
              ),
            );
        await direct('Direct 5');
        await expectLater(
          direct('Direct 6'),
          throwsA(predicate((e) => '$e'.contains('limite_profils'))),
        );
      },
    );
  });

  group('modification', () {
    test('prénom, avatar et forme d\'adresse modifiés', () async {
      final p = await creer('Lina');
      maintenant = maintenant.add(const Duration(days: 1));
      await depot.modifier(
        p.id,
        prenom: 'Lina B.',
        avatar: Avatar.nuage,
        formeAdresse: FormeAdresse.feminin,
      );
      final modifie = (await depot.lire(p.id))!;
      expect(modifie.prenom, 'Lina B.');
      expect(modifie.avatar, Avatar.nuage);
      expect(modifie.formeAdresse, FormeAdresse.feminin);
      expect(modifie.modifieLe, maintenant);
      expect(modifie.creeLe, isNot(maintenant));
    });

    test('renommer vers le prénom d\'un autre profil est refusé', () async {
      await creer('Lina');
      final yassine = await creer('Yassine');
      await expectLater(
        depot.modifier(yassine.id, prenom: 'LINA'),
        throwsA(isA<PrenomDejaUtilise>()),
      );
      await depot.modifier(yassine.id, prenom: 'YASSINE');
      expect((await depot.lire(yassine.id))!.prenom, 'YASSINE');
    });
  });

  group('changement de niveau', () {
    test("l'historique garde la trace du niveau précédent", () async {
      final debut = maintenant;
      final p = await creer('Lina', niveau: 1);
      maintenant = DateTime.utc(2027, 9, 15);
      await depot.changerNiveau(p.id, 2);

      expect((await depot.lire(p.id))!.niveau, 2);
      final historique = await depot.historiqueNiveaux(p.id);
      expect(historique, hasLength(2));
      expect(
        (historique[0].niveau, historique[0].debut, historique[0].fin),
        (1, debut, maintenant),
      );
      expect(
        (historique[1].niveau, historique[1].debut, historique[1].fin),
        (2, maintenant, null),
      );
    });

    test('même niveau : aucun changement', () async {
      final p = await creer('Lina', niveau: 3);
      await depot.changerNiveau(p.id, 3);
      expect(await depot.historiqueNiveaux(p.id), hasLength(1));
    });

    test('niveau hors de 1 à 6 refusé', () async {
      final p = await creer('Lina');
      await expectLater(depot.changerNiveau(p.id, 7), throwsArgumentError);
    });
  });

  group('suppression et réinitialisation', () {
    test('supprimer efface le profil et son historique', () async {
      final p = await creer('Lina');
      await depot.changerNiveau(p.id, 2);
      await depot.supprimer(p.id);
      expect(await depot.lire(p.id), isNull);
      expect(await depot.historiqueNiveaux(p.id), isEmpty);
    });

    test('toutEffacer vide tout', () async {
      await creer('Lina');
      await creer('Yassine');
      await depot.toutEffacer();
      expect(await depot.lister(), isEmpty);
    });
  });

  test('surveiller suit les créations', () async {
    final flux = depot.surveiller().asBroadcastStream();
    expect(await flux.first, isEmpty);
    final suivante = flux.first;
    await creer('Lina');
    expect((await suivante).single.prenom, 'Lina');
  });

  test('les profils sont conservés entre deux lancements', () async {
    final dossier = await Directory.systemTemp.createTemp('yasmina_');
    addTearDown(() => dossier.delete(recursive: true));
    final fichier = File('${dossier.path}/yasmina.sqlite');

    final premier = BaseYasmina(NativeDatabase(fichier));
    final p = await DepotProfils(premier).creer(
      prenom: 'Lina',
      niveau: 1,
      avatar: Avatar.fleur,
      formeAdresse: FormeAdresse.feminin,
    );
    await DepotProfils(premier).changerNiveau(p.id, 2);
    await premier.close();

    final second = BaseYasmina(NativeDatabase(fichier));
    addTearDown(second.close);
    final depotSecond = DepotProfils(second);
    final profils = await depotSecond.lister();
    expect(profils.single.prenom, 'Lina');
    expect(profils.single.niveau, 2);
    expect(await depotSecond.historiqueNiveaux(p.id), hasLength(2));
  });
}
