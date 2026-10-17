import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages globaux de l'app (pas liés à un profil enfant).
abstract interface class StockageReglages {
  /// Code de la langue de l'interface (`ar` ou `fr`), `null` au premier
  /// lancement.
  String? lireLangue();

  Future<void> ecrireLangue(String code);
}

/// Stockage réel, sur l'appareil (et dans le navigateur sur le web).
class StockageSharedPreferences implements StockageReglages {
  StockageSharedPreferences._(this._preferences);

  static const _cleLangue = 'langue_interface';

  final SharedPreferencesWithCache _preferences;

  static Future<StockageSharedPreferences> ouvrir() async =>
      StockageSharedPreferences._(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: {_cleLangue},
          ),
        ),
      );

  @override
  String? lireLangue() => _preferences.getString(_cleLangue);

  @override
  Future<void> ecrireLangue(String code) =>
      _preferences.setString(_cleLangue, code);
}

/// Stockage en mémoire, pour les tests.
class StockageMemoire implements StockageReglages {
  StockageMemoire([this._langue]);

  String? _langue;

  @override
  String? lireLangue() => _langue;

  @override
  Future<void> ecrireLangue(String code) async => _langue = code;
}

/// Surchargé dans `main()` par [StockageSharedPreferences] et dans les tests
/// par [StockageMemoire].
final stockageReglagesProvider = Provider<StockageReglages>(
  (ref) => throw UnimplementedError('stockageReglagesProvider non surchargé'),
);
