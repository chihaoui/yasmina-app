// Génère les sons d'interface provisoires (décision 35) dans assets/sons/ :
// WAV mono 22 050 Hz, 16 bits, notes sinusoïdales douces, courts et à
// volume bas, sans droits d'auteur. Les fichiers définitifs (même nom, WAV)
// les remplaceront sans changer le code.
//
// Usage, depuis packages/moteur_exercices :
//   dart run tool/generer_sons.dart            crée les fichiers absents
//   dart run tool/generer_sons.dart --forcer   réécrit tous les fichiers
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _frequence = 22050;

/// Une note : fréquence (Hz), début et durée (s), amplitude (0 à 1).
typedef _Note = ({double hz, double debut, double duree, double amplitude});

_Note _n(double hz, double debut, double duree, [double amplitude = 0.22]) =>
    (hz: hz, debut: debut, duree: duree, amplitude: amplitude);

// Notes : do5 523, mi5 659, sol5 784, do6 1047, sol4 392, mi4 330.
final _sons = <String, List<_Note>>{
  // Deux notes qui montent : ce qui est juste.
  'juste.wav': [_n(523, 0, 0.14), _n(784, 0.11, 0.24)],
  // Deux notes basses et douces qui descendent, sans dureté : on réessaie.
  'essai-faux.wav': [_n(392, 0, 0.16, 0.16), _n(330, 0.13, 0.22, 0.14)],
  // Trois notes calmes : voici la bonne réponse.
  'revelee.wav': [
    _n(392, 0, 0.18, 0.18),
    _n(523, 0.16, 0.18, 0.18),
    _n(659, 0.32, 0.28, 0.18),
  ],
  // Petit « pop » court.
  'depot.wav': [_n(880, 0, 0.07, 0.2)],
  // Petite fanfare montante.
  'fin-etape.wav': [
    _n(523, 0, 0.14),
    _n(659, 0.12, 0.14),
    _n(784, 0.24, 0.14),
    _n(1047, 0.36, 0.4),
  ],
};

void main(List<String> arguments) {
  final forcer = arguments.contains('--forcer');
  final paquet = File.fromUri(Platform.script).parent.parent.path;
  final dossier = Directory('$paquet/assets/sons')..createSync(recursive: true);
  var ecrits = 0;
  for (final MapEntry(key: nom, value: notes) in _sons.entries) {
    final fichier = File('${dossier.path}/$nom');
    if (fichier.existsSync() && !forcer) continue;
    fichier.writeAsBytesSync(_wav(_synthese(notes)));
    ecrits++;
  }
  stdout.writeln(
    '$ecrits son(s) écrit(s) dans assets/sons/'
    '${forcer ? '' : ' (fichiers existants gardés, --forcer pour réécrire)'}.',
  );
}

/// Échantillons : chaque note a une attaque de 8 ms et une décroissance
/// exponentielle (son de cloche douce), avec un peu d'harmonique 2.
Float64List _synthese(List<_Note> notes) {
  final fin = notes.map((n) => n.debut + n.duree).reduce(math.max);
  final echantillons = Float64List((fin * _frequence).ceil());
  for (final note in notes) {
    final debut = (note.debut * _frequence).round();
    final longueur = (note.duree * _frequence).round();
    for (var i = 0; i < longueur && debut + i < echantillons.length; i++) {
      final t = i / _frequence;
      final attaque = math.min(1.0, t / 0.008);
      final decroissance = math.exp(-4.5 * t / note.duree);
      final onde =
          math.sin(2 * math.pi * note.hz * t) +
          0.25 * math.sin(4 * math.pi * note.hz * t);
      echantillons[debut + i] +=
          note.amplitude * attaque * decroissance * onde / 1.25;
    }
  }
  return echantillons;
}

/// Fichier WAV PCM 16 bits mono.
Uint8List _wav(Float64List echantillons) {
  final donnees = echantillons.length * 2;
  final octets = ByteData(44 + donnees);
  void texte(int position, String s) {
    for (var i = 0; i < s.length; i++) {
      octets.setUint8(position + i, s.codeUnitAt(i));
    }
  }

  texte(0, 'RIFF');
  octets.setUint32(4, 36 + donnees, Endian.little);
  texte(8, 'WAVE');
  texte(12, 'fmt ');
  octets
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, _frequence, Endian.little)
    ..setUint32(28, _frequence * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little);
  texte(36, 'data');
  octets.setUint32(40, donnees, Endian.little);
  for (var i = 0; i < echantillons.length; i++) {
    final valeur = (echantillons[i].clamp(-1.0, 1.0) * 32767).round();
    octets.setInt16(44 + i * 2, valeur, Endian.little);
  }
  return octets.buffer.asUint8List();
}
