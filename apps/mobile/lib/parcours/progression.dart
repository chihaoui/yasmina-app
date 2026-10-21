import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'parcours.dart';

/// État d'une étape sur la carte, pour un profil.
enum EtatEtape { ouverte, faite, verrouillee }

/// Résultat d'une étape jouée jusqu'au bout.
class ResultatEtape {
  const ResultatEtape({
    required this.etapeId,
    required this.reussis,
    required this.total,
  });

  final String etapeId;

  /// Exercices réussis (juste au 1er ou au 2e essai, ou sans note).
  final int reussis;
  final int total;
}

/// Ce que le parcours lit et écrit de la progression d'un profil. En A3-02,
/// une version en mémoire ; la progression locale dans drift vient en A3-03.
abstract interface class DepotProgression {
  /// Ids des étapes faites par le profil, mis à jour à chaque changement.
  Stream<Set<String>> etapesFaites(int profilId);

  /// Enregistre une étape terminée (la meilleure note est gardée).
  Future<void> terminerEtape(int profilId, ResultatEtape resultat);

  /// Efface la progression de tous les profils (réinitialisation).
  Future<void> toutEffacer();
}

/// Progression gardée en mémoire : perdue à la fermeture de l'app.
class ProgressionMemoire implements DepotProgression {
  final _faites = <int, Map<String, ResultatEtape>>{};
  final _changements = StreamController<void>.broadcast();

  Set<String> _lire(int profilId) => _faites[profilId]?.keys.toSet() ?? {};

  @override
  Stream<Set<String>> etapesFaites(int profilId) => Stream.multi((sortie) {
    sortie.add(_lire(profilId));
    final abonnement = _changements.stream.listen(
      (_) => sortie.add(_lire(profilId)),
    );
    sortie.onCancel = abonnement.cancel;
  });

  @override
  Future<void> terminerEtape(int profilId, ResultatEtape resultat) async {
    final etapes = _faites.putIfAbsent(profilId, () => {});
    final ancien = etapes[resultat.etapeId];
    if (ancien == null || resultat.reussis >= ancien.reussis) {
      etapes[resultat.etapeId] = resultat;
    }
    _changements.add(null);
  }

  @override
  Future<void> toutEffacer() async {
    _faites.clear();
    _changements.add(null);
  }
}

final depotProgressionProvider = Provider<DepotProgression>(
  (ref) => ProgressionMemoire(),
);

/// Étapes faites par un profil, en continu.
final etapesFaitesProvider = StreamProvider.family<Set<String>, int>(
  (ref, profilId) => ref.watch(depotProgressionProvider).etapesFaites(profilId),
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
