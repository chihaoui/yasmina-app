import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../donnees/base_yasmina.dart';
import '../donnees/providers.dart';
import 'avatar.dart';

/// Plus de 5 profils sur l'appareil.
class LimiteProfilsAtteinte implements Exception {
  const LimiteProfilsAtteinte();

  @override
  String toString() =>
      'LimiteProfilsAtteinte : ${DepotProfils.maxProfils} profils au maximum.';
}

/// Prénom vide ou trop long (après suppression des espaces autour).
class PrenomInvalide implements Exception {
  const PrenomInvalide();

  @override
  String toString() =>
      'PrenomInvalide : 1 à ${DepotProfils.longueurMaxPrenom} caractères.';
}

/// Prénom déjà porté par un autre profil (majuscules latines ignorées).
class PrenomDejaUtilise implements Exception {
  const PrenomDejaUtilise();

  @override
  String toString() => 'PrenomDejaUtilise';
}

/// Accès aux profils enfants. Seul point d'écriture des profils dans l'app.
class DepotProfils {
  DepotProfils(this._base, {DateTime Function()? horloge})
    : _maintenant = horloge ?? DateTime.now;

  /// Doit rester égal à la limite du déclencheur limite_cinq_profils.
  static const maxProfils = 5;
  static const longueurMaxPrenom = 20;

  final BaseYasmina _base;
  final DateTime Function() _maintenant;

  /// Profils par date de création, mis à jour à chaque changement.
  Stream<List<ProfilEnfant>> surveiller() => _requeteProfils().watch();

  Future<List<ProfilEnfant>> lister() => _requeteProfils().get();

  Future<ProfilEnfant?> lire(int id) => (_base.select(
    _base.profils,
  )..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<ProfilEnfant> creer({
    required String prenom,
    required int niveau,
    required Avatar avatar,
    required FormeAdresse formeAdresse,
  }) async {
    final prenomValide = _validerPrenom(prenom);
    _validerNiveau(niveau);
    return _base.transaction(() async {
      if (await _compter() >= maxProfils) throw const LimiteProfilsAtteinte();
      await _verifierUnicite(prenomValide);
      final maintenant = _maintenant();
      final int id;
      try {
        id = await _base
            .into(_base.profils)
            .insert(
              ProfilsCompanion.insert(
                prenom: prenomValide,
                niveau: niveau,
                avatar: avatar,
                formeAdresse: formeAdresse,
                creeLe: maintenant,
                modifieLe: maintenant,
              ),
            );
      } on Exception catch (e) {
        // Filet de sécurité : la base applique la même limite.
        if ('$e'.contains('limite_profils')) {
          throw const LimiteProfilsAtteinte();
        }
        rethrow;
      }
      await _ouvrirPeriode(id, niveau, maintenant);
      return (await lire(id))!;
    });
  }

  /// Modifie le prénom, l'avatar ou la forme d'adresse. Le niveau passe par
  /// [changerNiveau] pour garder l'historique.
  Future<void> modifier(
    int id, {
    String? prenom,
    Avatar? avatar,
    FormeAdresse? formeAdresse,
  }) async {
    final prenomValide = prenom == null ? null : _validerPrenom(prenom);
    return _base.transaction(() async {
      if (prenomValide != null) await _verifierUnicite(prenomValide, sauf: id);
      await (_base.update(_base.profils)..where((p) => p.id.equals(id))).write(
        ProfilsCompanion(
          prenom: Value.absentIfNull(prenomValide),
          avatar: Value.absentIfNull(avatar),
          formeAdresse: Value.absentIfNull(formeAdresse),
          modifieLe: Value(_maintenant()),
        ),
      );
    });
  }

  /// Change le niveau en gardant la trace du précédent : la période en cours
  /// est fermée et une nouvelle est ouverte. Sans effet si le niveau est le
  /// même.
  Future<void> changerNiveau(int id, int niveau) async {
    _validerNiveau(niveau);
    return _base.transaction(() async {
      final profil = await lire(id);
      if (profil == null || profil.niveau == niveau) return;
      final maintenant = _maintenant();
      await (_base.update(_base.historiqueNiveaux)
            ..where((h) => h.profilId.equals(id) & h.fin.isNull()))
          .write(HistoriqueNiveauxCompanion(fin: Value(maintenant)));
      await _ouvrirPeriode(id, niveau, maintenant);
      await (_base.update(_base.profils)..where((p) => p.id.equals(id))).write(
        ProfilsCompanion(niveau: Value(niveau), modifieLe: Value(maintenant)),
      );
    });
  }

  /// Périodes de niveau du profil, de la plus ancienne à la plus récente.
  Future<List<PeriodeNiveau>> historiqueNiveaux(int id) =>
      (_base.select(_base.historiqueNiveaux)
            ..where((h) => h.profilId.equals(id))
            ..orderBy([
              (h) => OrderingTerm(expression: h.debut),
              (h) => OrderingTerm(expression: h.id),
            ]))
          .get();

  /// Supprime le profil et tout ce qui lui est rattaché (cascade).
  Future<void> supprimer(int id) =>
      (_base.delete(_base.profils)..where((p) => p.id.equals(id))).go();

  /// Réinitialisation complète des données locales.
  Future<void> toutEffacer() => _base.toutEffacer();

  SimpleSelectStatement<Profils, ProfilEnfant> _requeteProfils() =>
      _base.select(_base.profils)..orderBy([
        (p) => OrderingTerm(expression: p.creeLe),
        (p) => OrderingTerm(expression: p.id),
      ]);

  Future<int> _compter() async {
    final nombre = _base.profils.id.count();
    final ligne = await (_base.selectOnly(
      _base.profils,
    )..addColumns([nombre])).getSingle();
    return ligne.read(nombre)!;
  }

  Future<void> _verifierUnicite(String prenom, {int? sauf}) async {
    // La colonne est en COLLATE NOCASE : la comparaison ignore les
    // majuscules latines, les lettres arabes sont comparées telles quelles.
    final requete = _base.select(_base.profils)
      ..where((p) => p.prenom.equals(prenom));
    if (sauf != null) requete.where((p) => p.id.equals(sauf).not());
    if (await requete.getSingleOrNull() != null) {
      throw const PrenomDejaUtilise();
    }
  }

  Future<void> _ouvrirPeriode(int profilId, int niveau, DateTime debut) => _base
      .into(_base.historiqueNiveaux)
      .insert(
        HistoriqueNiveauxCompanion.insert(
          profilId: profilId,
          niveau: niveau,
          debut: debut,
        ),
      );

  String _validerPrenom(String brut) {
    final prenom = brut.trim();
    if (prenom.isEmpty || prenom.length > longueurMaxPrenom) {
      throw const PrenomInvalide();
    }
    return prenom;
  }

  void _validerNiveau(int niveau) {
    if (niveau < 1 || niveau > 6) {
      throw ArgumentError.value(niveau, 'niveau', 'doit être entre 1 et 6');
    }
  }
}

final depotProfilsProvider = Provider<DepotProfils>(
  (ref) => DepotProfils(ref.watch(baseYasminaProvider)),
);

/// Profils de l'appareil, mis à jour en continu.
final profilsProvider = StreamProvider<List<ProfilEnfant>>(
  (ref) => ref.watch(depotProfilsProvider).surveiller(),
);
