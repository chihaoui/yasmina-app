import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/donnees/base_yasmina.dart';
import 'package:yasmina/parcours/progression.dart';
import 'package:yasmina/profils/avatar.dart';
import 'package:yasmina/profils/depot_profils.dart';

import 'fixtures_parcours.dart';

/// Progression locale dans drift (A3-03) : résultat par exercice, état par
/// étape avec reprise, bilan par séquence, par profil, effacée avec lui.
void main() {
  late BaseYasmina base;
  late DepotProgression depot;
  late DepotProfils profils;
  late int lina;
  late int yassine;
  var maintenant = DateTime.utc(2026, 10, 21, 9);
  const e1 = 'ar-1-t1-u1-e01';
  const e2 = 'ar-1-t1-u1-e02';
  final parcours = catalogueTest().pour(matiere: 'arabe', niveau: 1)!;

  setUp(() async {
    base = BaseYasmina(NativeDatabase.memory());
    depot = DepotProgression(base, horloge: () => maintenant);
    profils = DepotProfils(base);
    lina = (await profils.creer(
      prenom: 'Lina',
      niveau: 1,
      avatar: Avatar.fleur,
      formeAdresse: FormeAdresse.feminin,
    )).id;
    yassine = (await profils.creer(
      prenom: 'Yassine',
      niveau: 1,
      avatar: Avatar.bateau,
      formeAdresse: FormeAdresse.masculin,
    )).id;
  });
  tearDown(() => base.close());

  Future<void> jouer(
    int profil,
    String etape,
    int index, {
    bool reussi = true,
  }) => depot.enregistrerExercice(
    profil,
    etapeId: etape,
    sequenceId: '$etape-s1',
    exerciceId: '$etape-x${(index + 1).toString().padLeft(2, '0')}',
    essais: reussi ? 1 : 2,
    reussi: reussi,
    revele: !reussi,
    indexSuivant: index + 1,
  );

  test('commencer, jouer, reprendre, terminer : état de l\'étape', () async {
    var etat = await depot.commencerEtape(lina, e1, total: 2);
    expect(
      (etat.indexReprise, etat.reussis, etat.total, etat.faite),
      (0, 0, 2, false),
    );
    await jouer(lina, e1, 0);
    etat = (await depot.lireEtat(lina, e1))!;
    expect((etat.indexReprise, etat.reussis), (1, 1));
    expect(DepotProgression.enCours(etat), isTrue);

    // Reprise : la partie en cours est gardée.
    maintenant = maintenant.add(const Duration(hours: 1));
    etat = await depot.commencerEtape(lina, e1, total: 2);
    expect(etat.indexReprise, 1);

    await jouer(lina, e1, 1, reussi: false);
    await depot.terminerEtape(lina, e1, reussis: 1, total: 2);
    etat = (await depot.lireEtat(lina, e1))!;
    expect(
      (etat.faite, etat.meilleursReussis, etat.indexReprise),
      (true, 1, 2),
    );
    expect(etat.termineLe, maintenant);
    expect(DepotProgression.enCours(etat), isFalse);
    expect(await depot.etapesFaites(lina).first, {e1});

    // Rejouer : l'index repart à 0, l'étape reste faite, la meilleure note
    // est gardée.
    etat = await depot.commencerEtape(lina, e1, total: 2);
    expect((etat.indexReprise, etat.reussis, etat.faite), (0, 0, true));
    await jouer(lina, e1, 0);
    await jouer(lina, e1, 1);
    await depot.terminerEtape(lina, e1, reussis: 2, total: 2);
    expect((await depot.lireEtat(lina, e1))!.meilleursReussis, 2);
    await depot.commencerEtape(lina, e1, total: 2);
    await jouer(lina, e1, 0, reussi: false);
    await jouer(lina, e1, 1, reussi: false);
    await depot.terminerEtape(lina, e1, reussis: 0, total: 2);
    expect((await depot.lireEtat(lina, e1))!.meilleursReussis, 2);
  });

  test('résultats par exercice : le dernier passage remplace le précédent, '
      'bilan par séquence', () async {
    await depot.commencerEtape(lina, e1, total: 2);
    await jouer(lina, e1, 0, reussi: false);
    await jouer(lina, e1, 1);
    var resultats = await depot.resultatsEtape(lina, e1);
    expect(resultats.map((r) => (r.exerciceId, r.essais, r.reussi, r.revele)), [
      ('$e1-x01', 2, false, true),
      ('$e1-x02', 1, true, false),
    ]);
    expect((await depot.bilanSequences(lina, e1))['$e1-s1']!.reussis, 1);
    expect((await depot.bilanSequences(lina, e1))['$e1-s1']!.joues, 2);

    await depot.commencerEtape(lina, e1, total: 2);
    await jouer(lina, e1, 0);
    resultats = await depot.resultatsEtape(lina, e1);
    expect(resultats, hasLength(2));
    expect(resultats.first.reussi, isTrue);
    expect((await depot.bilanSequences(lina, e1))['$e1-s1']!.reussis, 2);
    expect(await depot.bilanSequences(lina, e2), isEmpty);
  });

  test(
    'terminer une étape jamais commencée (tout débloquer) la crée faite',
    () async {
      await depot.terminerEtape(yassine, e2, reussis: 1, total: 1);
      final etat = (await depot.lireEtat(yassine, e2))!;
      expect((etat.faite, etat.reussis, etat.total), (true, 1, 1));
    },
  );

  test('par profil : la progression de Lina ne touche pas celle de Yassine, '
      'le flux des étapes faites suit', () async {
    final flux = depot.etapesFaites(yassine).asBroadcastStream();
    expect(await flux.first, isEmpty);
    await depot.commencerEtape(lina, e1, total: 2);
    await depot.terminerEtape(lina, e1, reussis: 2, total: 2);
    expect(await depot.etapesFaites(yassine).first, isEmpty);
    expect(await depot.etatsEtapes(yassine).first, isEmpty);
    final suivant = flux.first;
    await depot.terminerEtape(yassine, e1, reussis: 1, total: 2);
    expect(await suivant, {e1});
    expect(etatEtape(parcours, e2, {e1}), EtatEtape.ouverte);
  });

  test('la progression est conservée entre deux lancements', () async {
    final dossier = await Directory.systemTemp.createTemp('yasmina_');
    addTearDown(() => dossier.delete(recursive: true));
    final fichier = File('${dossier.path}/yasmina.sqlite');

    final premiere = BaseYasmina(NativeDatabase(fichier));
    final id = (await DepotProfils(premiere).creer(
      prenom: 'Lina',
      niveau: 1,
      avatar: Avatar.fleur,
      formeAdresse: FormeAdresse.feminin,
    )).id;
    final depotPremier = DepotProgression(premiere);
    await depotPremier.commencerEtape(id, e1, total: 2);
    await depotPremier.enregistrerExercice(
      id,
      etapeId: e1,
      sequenceId: '$e1-s1',
      exerciceId: '$e1-x01',
      essais: 1,
      reussi: true,
      revele: false,
      indexSuivant: 1,
    );
    await premiere.close();

    final seconde = BaseYasmina(NativeDatabase(fichier));
    addTearDown(seconde.close);
    final etat = (await DepotProgression(seconde).lireEtat(id, e1))!;
    expect((etat.indexReprise, etat.reussis), (1, 1));
    expect(
      await DepotProgression(seconde).resultatsEtape(id, e1),
      hasLength(1),
    );
  });

  test('supprimer le profil ou tout effacer efface la progression', () async {
    await depot.commencerEtape(lina, e1, total: 2);
    await jouer(lina, e1, 0);
    await depot.commencerEtape(yassine, e1, total: 2);
    await profils.supprimer(lina);
    expect(await base.select(base.resultatsExercices).get(), isEmpty);
    expect(await depot.etatsEtapes(yassine).first, hasLength(1));
    await depot.toutEffacer();
    expect(await depot.etatsEtapes(yassine).first, isEmpty);
  });
}
