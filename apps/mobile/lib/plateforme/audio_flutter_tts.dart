import 'package:flutter_tts/flutter_tts.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Audio du prototype : voix de l'appareil par flutter_tts. Sans voix pour
/// une langue, rien n'est dit et rien ne casse.
class AudioFlutterTts implements ServiceAudio {
  AudioFlutterTts([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  /// Locales essayées pour chaque langue d'exercice, dans l'ordre.
  static const localesParLangue = {
    'ar': ['ar-SA', 'ar'],
    'fr': ['fr-FR', 'fr'],
    'en': ['en-GB', 'en-US', 'en'],
  };

  final _locales = <String, String?>{};

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
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.speak(texte);
    } on Object {
      // Une voix qui échoue ne doit jamais bloquer l'exercice.
    }
  }

  @override
  Future<void> arreter() async {
    try {
      await _tts.stop();
    } on Object {
      // Rien à arrêter.
    }
  }
}
