import 'package:audioplayers/audioplayers.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Lecture d'un asset audio à un volume (de 0 à 1).
typedef JouerAsset = Future<void> Function(String cleAsset, double volume);

/// Sons d'interface de l'app mobile (décision 35) : volume bas, coupés si
/// les sons des effets sont désactivés (menu développeur), jamais
/// d'exception.
class SonsAudioplayers {
  SonsAudioplayers({required this.actifs, JouerAsset? jouerAsset})
    : _jouerAsset = jouerAsset ?? _LecteursAudioplayers().jouer;

  /// Volume des sons d'interface, bas.
  static const volume = 0.4;

  /// Sons des effets activés (lu à chaque son).
  final bool Function() actifs;

  final JouerAsset _jouerAsset;

  Future<void> jouer(SonInterface son) async {
    if (!actifs()) return;
    try {
      await _jouerAsset(son.cleAsset, volume);
    } on Object {
      // Un son qui échoue ne doit jamais gêner l'exercice.
    }
  }
}

/// Lecture réelle par audioplayers : un lecteur basse latence par son.
///
/// Mode silencieux : sur iOS, la catégorie `ambient` suit le bouton
/// silencieux et se mêle aux autres sons. Sur Android, l'usage
/// « sonification » suit le volume système, coupé en mode silencieux.
class _LecteursAudioplayers {
  final _lecteurs = <String, AudioPlayer>{};

  static final _contexte = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  Future<void> jouer(String cleAsset, double volume) async {
    // Les sons sont des assets du package moteur_exercices : clé complète,
    // sans le préfixe « assets/ » par défaut d'audioplayers.
    final lecteur = _lecteurs.putIfAbsent(
      cleAsset,
      () => AudioPlayer()..audioCache = AudioCache(prefix: ''),
    );
    await lecteur.stop();
    await lecteur.play(
      AssetSource(cleAsset),
      volume: volume,
      ctx: _contexte,
      mode: PlayerMode.lowLatency,
    );
  }
}
