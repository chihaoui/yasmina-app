import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/plateforme/audio_mobile.dart';
import 'package:yasmina/plateforme/sons_audioplayers.dart';

/// FlutterTts factice : seules les locales de [disponibles] ont une voix.
class _TtsFactice implements FlutterTts {
  _TtsFactice(this.disponibles, {this.echoue = false});

  final Set<String> disponibles;
  final bool echoue;
  final appels = <String>[];

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    if (echoue) throw Exception('plugin absent');
    return disponibles.contains(language);
  }

  @override
  Future<dynamic> setLanguage(String language) async =>
      appels.add('langue $language');

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async =>
      appels.add('dire $text');

  @override
  Future<dynamic> stop() async => appels.add('stop');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test("arabe : première locale reconnue, puis la phrase est dite", () async {
    final tts = _TtsFactice({'ar'});
    final audio = AudioMobile(tts: tts);
    expect(await audio.voixDisponible('ar'), isTrue);
    await audio.dire('هَلْ هَذِهِ الْجُمْلَةُ صَحِيحَةٌ؟', langue: 'ar');
    expect(tts.appels, [
      'stop',
      'langue ar',
      'dire هَلْ هَذِهِ الْجُمْلَةُ صَحِيحَةٌ؟',
    ]);
  });

  test('sans voix : rien n\'est dit, aucune exception', () async {
    final tts = _TtsFactice({'fr-FR'});
    final audio = AudioMobile(tts: tts);
    expect(await audio.voixDisponible('ar'), isFalse);
    await audio.dire('مَرْحَبًا', langue: 'ar');
    expect(tts.appels, isEmpty);
    expect(await audio.voixDisponible('fr'), isTrue);
  });

  test('plugin en erreur : langue sans voix, aucune exception', () async {
    final audio = AudioMobile(tts: _TtsFactice({}, echoue: true));
    expect(await audio.voixDisponible('en'), isFalse);
    await audio.dire('Hello', langue: 'en');
    await audio.arreter();
  });

  group('sons d\'interface', () {
    late List<(String, double)> joues;
    late bool actifs;
    late AudioMobile audio;

    setUp(() {
      joues = [];
      actifs = true;
      audio = AudioMobile(
        tts: _TtsFactice({}),
        sons: SonsAudioplayers(
          actifs: () => actifs,
          jouerAsset: (cle, volume) async => joues.add((cle, volume)),
        ),
      );
    });

    test('joués à volume bas depuis les assets du moteur', () async {
      await audio.jouerSon(SonInterface.essaiFaux);
      expect(joues, [
        ('packages/moteur_exercices/assets/sons/essai-faux.wav', 0.4),
      ]);
      expect(SonsAudioplayers.volume, lessThanOrEqualTo(0.5));
    });

    test('rien quand les sons des effets sont désactivés', () async {
      actifs = false;
      await audio.jouerSon(SonInterface.juste);
      expect(joues, isEmpty);
    });

    test('une lecture en erreur ne lève rien', () async {
      final enErreur = SonsAudioplayers(
        actifs: () => true,
        jouerAsset: (_, _) async => throw Exception('plugin absent'),
      );
      await enErreur.jouer(SonInterface.revelee);
      await AudioMobile(tts: _TtsFactice({})).jouerSon(SonInterface.juste);
    });
  });
}
