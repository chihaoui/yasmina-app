import 'dart:convert';
import 'dart:io';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chaque JSON de assets/content doit passer le validateur edu-content/1.0 :
/// un contenu invalide fait échouer `flutter test`.
void main() {
  final fichiers =
      Directory('assets/content')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('assets/content contient au moins une étape', () {
    expect(fichiers, isNotEmpty);
  });

  for (final fichier in fichiers) {
    test('${fichier.path} est valide', () {
      final texte = fichier.readAsStringSync();
      final resultat = validerEtape(texte);
      expect(resultat.erreurs, isEmpty, reason: '$resultat');

      final id = (jsonDecode(texte) as Map)['etape']['id'];
      expect(
        fichier.uri.pathSegments.last,
        '$id.json',
        reason: "Le fichier doit porter l'id de son étape.",
      );
    });
  }
}
