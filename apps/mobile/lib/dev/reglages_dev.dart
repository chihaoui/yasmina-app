import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../reglages/stockage_reglages.dart';

/// Statut d'abonnement simulé (menu développeur). Enregistré, sans effet
/// tant que l'essai et l'abonnement ne sont pas simulés (A1-14).
enum AbonnementSimule {
  essai('Essai'),
  essaiTermine('Essai terminé'),
  abonne('Abonné');

  const AbonnementSimule(this.libelle);

  final String libelle;
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
/// la carte du trimestre n'existe pas (A1-10).
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
