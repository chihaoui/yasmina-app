@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  test('les jetons générés sont à jour avec tokens.json', () {
    final racineFlutter = Platform.environment['FLUTTER_ROOT'];
    final dart = racineFlutter == null ? 'dart' : '$racineFlutter/bin/dart';
    final resultat = Process.runSync(dart, [
      'run',
      'tool/generer_theme.dart',
      '--verifier',
    ]);
    expect(
      resultat.exitCode,
      0,
      reason:
          'tokens.json ou les SVG de Yasmina modifiés sans régénération : '
          'lancer `dart run tool/generer_theme.dart` dans '
          'packages/moteur_exercices.\n${resultat.stdout}${resultat.stderr}',
    );
  });

  test('quelques valeurs de tokens.json, telles quelles', () {
    expect(CouleursYasmina.clair.blue, const Color(0xFF1F5FA8));
    expect(CouleursYasmina.sombre.onAccent, const Color(0xFF0E1520));
    expect(EspacesYasmina.targetMin, 48);
    expect(RayonsYasmina.radius2xl, 20);
    expect(StylesYasmina.buttonCta.fontWeight, FontWeight.w800);
    expect(
      StylesYasmina.contentSentence.fontFamily,
      PolicesYasmina.contenuArabe,
    );
    expect(StylesYasmina.latinBody.fontFamily, PolicesYasmina.latin);
  });
}
