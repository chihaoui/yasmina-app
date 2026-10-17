@TestOn('vm')
library;

import 'dart:io';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la constante générée est identique au fichier du schéma', () {
    final fichier = File('edu-content-1.0.schema.json').readAsStringSync();
    expect(
      texteSchemaEduContent,
      fichier,
      reason:
          'Schéma modifié sans régénération : lancer '
          '`dart run tool/generer_schema.dart` dans schema/.',
    );
  });
}
