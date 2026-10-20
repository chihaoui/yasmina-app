import 'package:flutter_tts/flutter_tts.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'sons_audioplayers.dart';

/// Audio de l'app mobile : voix de l'appareil par flutter_tts (sans voix
/// pour une langue, rien n'est dit et rien ne casse) et sons d'interface
/// par audioplayers.
class AudioMobile implements ServiceAudio {
  AudioMobile({FlutterTts? tts, this.sons}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  /// Sons d'interface, `null` : aucun son.
  final SonsAudioplayers? sons;

  /// Locales essayées pour chaque langue d'exercice, dans l'ordre.
  static const localesParLangue = {
    'ar': ['ar-SA', 'ar'],
    'fr': ['fr-FR', 'fr'],
    'en': ['en-GB', 'en-US', 'en'],
  };

  final _locales = <String, String?>{};
  bool _attenteReglee = false;

  /// `dire` ne rend la main qu'à la fin de la synthèse : le lecteur peut
  /// enchaîner la consigne puis le mot à écouter sans couper la consigne.
  Future<void> _reglerAttente() async {
    if (_attenteReglee) return;
    _attenteReglee = true;
    try {
      await _tts.awaitSpeakCompletion(true);
    } on Object {
      // Plugin indisponible : la synthèse rend la main tout de suite.
    }
  }

  /// Première locale de [langue] reconnue par l'appareil, `null` sinon.
  Future<String?> _locale(String langue) async {
    if (_locales.containsKey(langue)) return _locales[langue];
    String? trouvee;
    for (final locale in localesParLangue[langue] ?? const <String>[]) {
      try {
        if (await _tts.isLanguageAvailable(locale) == true) {
          trouvee = locale;
          break;
        }
      } on Object {
        // Plugin indisponible ou erreur de plateforme : langue sans voix.
      }
    }
    return _locales[langue] = trouvee;
  }

  @override
  Future<bool> voixDisponible(String langue) async =>
      await _locale(langue) != null;

  @override
  Future<void> dire(String texte, {required String langue}) async {
    final locale = await _locale(langue);
    if (locale == null) return;
    try {
      await _reglerAttente();
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.speak(texte);
    } on Object {
      // Une voix qui échoue ne doit jamais bloquer l'exercice.
    }
  }

  @override
  Future<void> jouerSon(SonInterface son) async => sons?.jouer(son);

  @override
  Future<void> arreter() async {
    try {
      await _tts.stop();
    } on Object {
      // Rien à arrêter.
    }
  }
}
