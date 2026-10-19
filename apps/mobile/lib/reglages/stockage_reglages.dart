import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages globaux de l'app (pas liés à un profil enfant).
abstract interface class StockageReglages {
  /// Code de la langue de l'interface (`ar` ou `fr`), `null` au premier
  /// lancement.
  String? lireLangue();

  Future<void> ecrireLangue(String code);

  /// Statut d'abonnement simulé du menu développeur (nom de l'énumération),
  /// `null` s'il n'a jamais été choisi.
  String? lireAbonnementSimule();

  Future<void> ecrireAbonnementSimule(String? statut);

  /// « Tout débloquer » du menu développeur.
  bool lireToutDebloque();

  Future<void> ecrireToutDebloque(bool valeur);

  /// Sons des effets (sons d'interface), activés par défaut.
  bool lireSonsEffets();

  Future<void> ecrireSonsEffets(bool valeur);
}

/// Stockage réel, sur l'appareil (et dans le navigateur sur le web).
class StockageSharedPreferences implements StockageReglages {
  StockageSharedPreferences._(this._preferences);

  static const _cleLangue = 'langue_interface';
  static const _cleAbonnement = 'dev_abonnement_simule';
  static const _cleDebloque = 'dev_tout_debloque';
  static const _cleSons = 'sons_effets';

  final SharedPreferencesWithCache _preferences;

  static Future<StockageSharedPreferences> ouvrir() async =>
      StockageSharedPreferences._(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: {_cleLangue, _cleAbonnement, _cleDebloque, _cleSons},
          ),
        ),
      );

  @override
  String? lireLangue() => _preferences.getString(_cleLangue);

  @override
  Future<void> ecrireLangue(String code) =>
      _preferences.setString(_cleLangue, code);

  @override
  String? lireAbonnementSimule() => _preferences.getString(_cleAbonnement);

  @override
  Future<void> ecrireAbonnementSimule(String? statut) => statut == null
      ? _preferences.remove(_cleAbonnement)
      : _preferences.setString(_cleAbonnement, statut);

  @override
  bool lireToutDebloque() => _preferences.getBool(_cleDebloque) ?? false;

  @override
  Future<void> ecrireToutDebloque(bool valeur) =>
      _preferences.setBool(_cleDebloque, valeur);

  @override
  bool lireSonsEffets() => _preferences.getBool(_cleSons) ?? true;

  @override
  Future<void> ecrireSonsEffets(bool valeur) =>
      _preferences.setBool(_cleSons, valeur);
}

/// Stockage en mémoire, pour les tests.
class StockageMemoire implements StockageReglages {
  StockageMemoire([this._langue]);

  String? _langue;
  String? _abonnement;
  bool _debloque = false;
  bool _sons = true;

  @override
  String? lireLangue() => _langue;

  @override
  Future<void> ecrireLangue(String code) async => _langue = code;

  @override
  String? lireAbonnementSimule() => _abonnement;

  @override
  Future<void> ecrireAbonnementSimule(String? statut) async =>
      _abonnement = statut;

  @override
  bool lireToutDebloque() => _debloque;

  @override
  Future<void> ecrireToutDebloque(bool valeur) async => _debloque = valeur;

  @override
  bool lireSonsEffets() => _sons;

  @override
  Future<void> ecrireSonsEffets(bool valeur) async => _sons = valeur;
}

/// Surchargé dans `main()` par [StockageSharedPreferences] et dans les tests
/// par [StockageMemoire].
final stockageReglagesProvider = Provider<StockageReglages>(
  (ref) => throw UnimplementedError('stockageReglagesProvider non surchargé'),
);
