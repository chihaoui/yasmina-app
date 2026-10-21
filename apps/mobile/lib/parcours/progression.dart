import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../donnees/base_yasmina.dart';
import '../donnees/providers.dart';
import 'parcours.dart';

/// État d'une étape sur la carte, pour un profil.
enum EtatEtape { ouverte, faite, verrouillee }

/// Bilan d'une séquence ou d'une étape : exercices réussis sur ceux joués.
class Bilan {
  const Bilan({required this.reussis, required this.joues});

  final int reussis;
  final int joues;
}

/// Progression locale d'un profil (A3-03), dans drift : résultat par
/// exercice, état par étape (en cours avec reprise, ou faite), bilan par
/// séquence calculé à partir des exercices. Seul point d'écriture de la
/// progression dans l'app.
class DepotProgression {
  DepotProgression(this._base, {DateTime Function()? horloge})
    : _maintenant = horloge ?? DateTime.now;

  final BaseYasmina _base;
  final DateTime Function() _maintenant;

  SimpleSelectStatement<EtatsEtapes, EtatEtapeProfil> _etats(int profilId) =>
      _base.select(_base.etatsEtapes)
        ..where((e) => e.profilId.equals(profilId))
        ..orderBy([(e) => OrderingTerm(expression: e.commenceLe)]);

  SimpleSelectStatement<EtatsEtapes, EtatEtapeProfil> _etat(
    int profilId,
    String etapeId,
  ) =>
      _base.select(_base.etatsEtapes)
        ..where((e) => e.profilId.equals(profilId) & e.etapeId.equals(etapeId));

  /// Ids des étapes faites par le profil, mis à jour à chaque changement.
  Stream<Set<String>> etapesFaites(int profilId) => _etats(profilId)
      .watch()
      .map(
        (etats) => {
          for (final e in etats)
            if (e.faite) e.etapeId,
        },
      );

  /// État de chaque étape commencée par le profil, en continu.
  Stream<List<EtatEtapeProfil>> etatsEtapes(int profilId) =>
      _etats(profilId).watch();

  Future<EtatEtapeProfil?> lireEtat(int profilId, String etapeId) =>
      _etat(profilId, etapeId).getSingleOrNull();

  Stream<EtatEtapeProfil?> surveillerEtat(int profilId, String etapeId) =>
      _etat(profilId, etapeId).watchSingleOrNull();

  /// Une partie est en cours quand l'index de reprise est entre le premier
  /// et le dernier exercice.
  static bool enCours(EtatEtapeProfil etat) =>
      etat.indexReprise > 0 && etat.indexReprise < etat.total;

  /// Ouvre une partie. Une partie en cours est reprise telle quelle ;
  /// sinon (nouvelle étape, étape faite rejouée, partie finie) l'index et
  /// le compte repartent à 0. Une étape faite le reste (la carte garde
  /// l'étape suivante ouverte pendant qu'on rejoue).
  Future<EtatEtapeProfil> commencerEtape(
    int profilId,
    String etapeId, {
    required int total,
  }) => _base.transaction(() async {
    final etat = await lireEtat(profilId, etapeId);
    final maintenant = _maintenant();
    if (etat == null) {
      await _base
          .into(_base.etatsEtapes)
          .insert(
            EtatsEtapesCompanion.insert(
              profilId: profilId,
              etapeId: etapeId,
              total: Value(total),
              commenceLe: maintenant,
              modifieLe: maintenant,
            ),
          );
    } else if (!enCours(etat) || etat.total != total) {
      await (_base.update(
        _base.etatsEtapes,
      )..where((e) => e.id.equals(etat.id))).write(
        EtatsEtapesCompanion(
          indexReprise: const Value(0),
          reussis: const Value(0),
          total: Value(total),
          commenceLe: Value(maintenant),
          modifieLe: Value(maintenant),
        ),
      );
    }
    return (await lireEtat(profilId, etapeId))!;
  });

  /// Enregistre le résultat d'un exercice (le dernier passage remplace le
  /// précédent) et avance l'index de reprise de l'étape.
  Future<void> enregistrerExercice(
    int profilId, {
    required String etapeId,
    required String sequenceId,
    required String exerciceId,
    required int essais,
    required bool reussi,
    required bool revele,
    required int indexSuivant,
  }) => _base.transaction(() async {
    final maintenant = _maintenant();
    // Un seul résultat par exercice et par profil (index unique) : le
    // dernier passage remplace le précédent.
    await _base
        .into(_base.resultatsExercices)
        .insert(
          ResultatsExercicesCompanion.insert(
            profilId: profilId,
            etapeId: etapeId,
            sequenceId: sequenceId,
            exerciceId: exerciceId,
            essais: essais,
            reussi: reussi,
            revele: revele,
            joueLe: maintenant,
          ),
          onConflict: DoUpdate(
            (ancien) => ResultatsExercicesCompanion(
              etapeId: Value(etapeId),
              sequenceId: Value(sequenceId),
              essais: Value(essais),
              reussi: Value(reussi),
              revele: Value(revele),
              joueLe: Value(maintenant),
            ),
            target: [
              _base.resultatsExercices.profilId,
              _base.resultatsExercices.exerciceId,
            ],
          ),
        );
    final etat = await lireEtat(profilId, etapeId);
    if (etat == null) return;
    await (_base.update(
      _base.etatsEtapes,
    )..where((e) => e.id.equals(etat.id))).write(
      EtatsEtapesCompanion(
        indexReprise: Value(indexSuivant),
        reussis: Value(etat.reussis + (reussi ? 1 : 0)),
        modifieLe: Value(maintenant),
      ),
    );
  });

  /// Marque l'étape faite (la meilleure partie est gardée) : l'étape
  /// suivante s'ouvre sur la carte.
  Future<void> terminerEtape(
    int profilId,
    String etapeId, {
    required int reussis,
    required int total,
  }) => _base.transaction(() async {
    final etat = await lireEtat(profilId, etapeId);
    final maintenant = _maintenant();
    if (etat == null) {
      await _base
          .into(_base.etatsEtapes)
          .insert(
            EtatsEtapesCompanion.insert(
              profilId: profilId,
              etapeId: etapeId,
              faite: const Value(true),
              reussis: Value(reussis),
              total: Value(total),
              meilleursReussis: Value(reussis),
              commenceLe: maintenant,
              termineLe: Value(maintenant),
              modifieLe: maintenant,
            ),
          );
      return;
    }
    await (_base.update(
      _base.etatsEtapes,
    )..where((e) => e.id.equals(etat.id))).write(
      EtatsEtapesCompanion(
        faite: const Value(true),
        indexReprise: Value(total),
        reussis: Value(reussis),
        total: Value(total),
        meilleursReussis: Value(
          reussis > etat.meilleursReussis ? reussis : etat.meilleursReussis,
        ),
        termineLe: Value(maintenant),
        modifieLe: Value(maintenant),
      ),
    );
  });

  /// Résultats des exercices d'une étape, dans l'ordre de passage.
  Future<List<ResultatExercice>> resultatsEtape(int profilId, String etapeId) =>
      (_base.select(_base.resultatsExercices)
            ..where(
              (r) => r.profilId.equals(profilId) & r.etapeId.equals(etapeId),
            )
            ..orderBy([(r) => OrderingTerm(expression: r.id)]))
          .get();

  /// Bilan par séquence d'une étape, calculé à partir des exercices joués.
  Future<Map<String, Bilan>> bilanSequences(
    int profilId,
    String etapeId,
  ) async {
    final bilans = <String, Bilan>{};
    for (final r in await resultatsEtape(profilId, etapeId)) {
      final b = bilans[r.sequenceId] ?? const Bilan(reussis: 0, joues: 0);
      bilans[r.sequenceId] = Bilan(
        reussis: b.reussis + (r.reussi ? 1 : 0),
        joues: b.joues + 1,
      );
    }
    return bilans;
  }

  /// Efface la progression de tous les profils (réinitialisation).
  Future<void> toutEffacer() => _base.transaction(() async {
    await _base.delete(_base.resultatsExercices).go();
    await _base.delete(_base.etatsEtapes).go();
  });
}

final depotProgressionProvider = Provider<DepotProgression>(
  (ref) => DepotProgression(ref.watch(baseYasminaProvider)),
);

/// Étapes faites par un profil, en continu.
final etapesFaitesProvider = StreamProvider.family<Set<String>, int>(
  (ref, profilId) => ref.watch(depotProgressionProvider).etapesFaites(profilId),
);

/// État d'une étape pour un profil (`(profilId, etapeId)`), en continu,
/// `null` tant qu'elle n'a pas été commencée.
final etatEtapeProfilProvider =
    StreamProvider.family<EtatEtapeProfil?, (int, String)>(
      (ref, cle) =>
          ref.watch(depotProgressionProvider).surveillerEtat(cle.$1, cle.$2),
    );

/// État de chaque étape d'un parcours : la première est ouverte, une étape
/// s'ouvre quand la précédente est faite, une étape faite reste rejouable.
/// [toutDebloque] (menu développeur) ouvre tout.
EtatEtape etatEtape(
  Parcours parcours,
  String etapeId,
  Set<String> faites, {
  bool toutDebloque = false,
}) {
  if (faites.contains(etapeId)) return EtatEtape.faite;
  if (toutDebloque) return EtatEtape.ouverte;
  final precedente = parcours.precedente(etapeId);
  if (precedente == null || faites.contains(precedente.id)) {
    return EtatEtape.ouverte;
  }
  return EtatEtape.verrouillee;
}
