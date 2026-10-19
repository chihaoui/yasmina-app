@TestOn('vm')
library;

import 'dart:io';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la constante générée contient exactement les fichiers d\'exemples', () {
    final dossier = Directory('exemples');
    final attendus = {
      for (final f
          in dossier
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.json')))
        f.path.substring(dossier.path.length + 1).replaceAll(r'\', '/'): f
            .readAsStringSync(),
    };
    expect(
      exemplesEduContent,
      attendus,
      reason:
          'Exemple ajouté, modifié ou supprimé sans régénération : lancer '
          '`dart run tool/generer_exemples.dart` dans schema/.',
    );
  });
}
