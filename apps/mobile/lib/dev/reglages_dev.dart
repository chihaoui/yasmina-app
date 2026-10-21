import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../reglages/stockage_reglages.dart';

/// Statut d'abonnement simulé (A3-05, décision 13), choisi dans le menu
/// développeur ou par les offres de l'espace parent, sans paiement ni
/// réseau. Le parcours le respecte : essai, le trimestre en cours est
/// ouvert ; essai terminé, la carte explique et renvoie vers l'espace
/// parent ; abonné, tout est ouvert.
enum AbonnementSimule {
  essai('Essai'),
  essaiTermine('Essai terminé'),
  abonne('Abonné');

  const AbonnementSimule(this.libelle);

  /// Libellé du menu développeur (français).
  final String libelle;

  /// Le parcours est jouable (essai en cours ou abonné).
  bool get parcoursOuvert => this != AbonnementSimule.essaiTermine;
}

final abonnementSimuleProvider =
    NotifierProvider<AbonnementSimuleNotifier, AbonnementSimule>(
      AbonnementSimuleNotifier.new,
    );

class AbonnementSimuleNotifier extends Notifier<AbonnementSimule> {
  @override
  AbonnementSimule build() =>
      AbonnementSimule.values.asNameMap()[ref
          .watch(stockageReglagesProvider)
          .lireAbonnementSimule()] ??
      AbonnementSimule.essai;

  Future<void> choisir(AbonnementSimule statut) {
    state = statut;
    return ref
        .read(stockageReglagesProvider)
        .ecrireAbonnementSimule(statut.name);
  }

  /// Retour à la valeur par défaut (réinitialisation).
  Future<void> oublier() {
    state = AbonnementSimule.essai;
    return ref.read(stockageReglagesProvider).ecrireAbonnementSimule(null);
  }
}

/// « Tout débloquer » (menu développeur). Enregistré, sans effet tant que
/// la carte du trimestre n'existe pas (A3-01).
final toutDebloqueProvider = NotifierProvider<ToutDebloqueNotifier, bool>(
  ToutDebloqueNotifier.new,
);

class ToutDebloqueNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(stockageReglagesProvider).lireToutDebloque();

  Future<void> choisir(bool valeur) {
    state = valeur;
    return ref.read(stockageReglagesProvider).ecrireToutDebloque(valeur);
  }
}

/// « Sons des effets » (menu développeur) : sons d'interface du lecteur,
/// activés par défaut, respectés par l'implémentation mobile.
final sonsEffetsProvider = NotifierProvider<SonsEffetsNotifier, bool>(
  SonsEffetsNotifier.new,
);

class SonsEffetsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(stockageReglagesProvider).lireSonsEffets();

  Future<void> choisir(bool valeur) {
    state = valeur;
    return ref.read(stockageReglagesProvider).ecrireSonsEffets(valeur);
  }
}
