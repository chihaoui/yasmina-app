@TestOn('vm')
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Les sons d'interface, provisoires ou définitifs : WAV PCM 16 bits mono,
/// courts et à volume bas (décision 35).
void main() {
  ByteData lire(SonInterface son) =>
      ByteData.sublistView(File(son.asset).readAsBytesSync());

  String texte(ByteData d, int position) => String.fromCharCodes([
    for (var i = 0; i < 4; i++) d.getUint8(position + i),
  ]);

  /// Crête du son, de 0 à 1.
  double crete(ByteData d) {
    var max = 0;
    for (var i = 44; i + 1 < d.lengthInBytes; i += 2) {
      final v = d.getInt16(i, Endian.little).abs();
      if (v > max) max = v;
    }
    return max / 32767;
  }

  for (final son in SonInterface.values) {
    test('${son.fichier} : WAV PCM 16 bits mono, court, volume bas', () {
      final d = lire(son);
      expect(texte(d, 0), 'RIFF');
      expect(texte(d, 8), 'WAVE');
      expect(d.getUint16(20, Endian.little), 1, reason: 'PCM');
      expect(d.getUint16(22, Endian.little), 1, reason: 'mono');
      expect(d.getUint16(34, Endian.little), 16, reason: '16 bits');
      final frequence = d.getUint32(24, Endian.little);
      final duree = d.getUint32(40, Endian.little) / 2 / frequence;
      expect(duree, lessThanOrEqualTo(1.5));
      expect(crete(d), lessThanOrEqualTo(0.5));
    });
  }

  test('l\'essai faux est plus doux que la réponse juste', () {
    expect(
      crete(lire(SonInterface.essaiFaux)),
      lessThan(crete(lire(SonInterface.juste))),
    );
  });

  test('chaque son est déclaré par son chemin de package', () {
    expect(
      SonInterface.juste.cleAsset,
      'packages/moteur_exercices/assets/sons/juste.wav',
    );
    expect(SonInterface.values.map((s) => s.fichier).toSet(), hasLength(5));
  });
}
