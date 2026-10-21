import 'parcours.dart';
import 'progression.dart';

/// Progression d'exemple du profil de test Lina (CLAUDE.md §7) : la
/// première étape du parcours faite (deux exercices révélés), la deuxième
/// en cours au 5e exercice. Sans parcours, rien n'est écrit.
Future<void> ecrireProgressionExemple(
  DepotProgression depot,
  int profilId,
  Parcours? parcours,
) async {
  if (parcours == null || parcours.etapes.length < 2) return;
  final premiere = parcours.etapes[0];
  final deroule = premiere.deroule;
  await depot.commencerEtape(profilId, premiere.id, total: deroule.length);
  var reussis = 0;
  for (var i = 0; i < deroule.length; i++) {
    final reussi = i != 2 && i != 6;
    if (reussi) reussis++;
    await depot.enregistrerExercice(
      profilId,
      etapeId: premiere.id,
      sequenceId: premiere.sequences[deroule[i].sequence].id,
      exerciceId: deroule[i].id,
      essais: reussi ? 1 : 2,
      reussi: reussi,
      revele: !reussi,
      indexSuivant: i + 1,
    );
  }
  await depot.terminerEtape(
    profilId,
    premiere.id,
    reussis: reussis,
    total: deroule.length,
  );

  final deuxieme = parcours.etapes[1];
  final suite = deuxieme.deroule;
  final joues = suite.length > 5 ? 5 : suite.length - 1;
  await depot.commencerEtape(profilId, deuxieme.id, total: suite.length);
  for (var i = 0; i < joues; i++) {
    final reussi = i != 1;
    await depot.enregistrerExercice(
      profilId,
      etapeId: deuxieme.id,
      sequenceId: deuxieme.sequences[suite[i].sequence].id,
      exerciceId: suite[i].id,
      essais: reussi ? 1 : 2,
      reussi: reussi,
      revele: !reussi,
      indexSuivant: i + 1,
    );
  }
}
