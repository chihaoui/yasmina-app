@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les exemples de schema/exemples/glisser-deposer/ : un exercice valide par
/// type du moteur Glisser-déposer (deux gabarits pour T06), en brouillon, en
/// emoji, qui respecte les conventions de docs/conventions-arabe.md.
void main() {
  const types = ['T06', 'T09', 'T11', 'T12', 'T13', 'T14', 'T15', 'T16'];
  final fichiers =
      Directory('exemples/glisser-deposer')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  String nom(File f) => f.uri.pathSegments.last;
  Map<String, dynamic> lire(File f) =>
      jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;

  test('au moins un exemple par type, nommé par son type, id uniques', () {
    expect(fichiers.map((f) => lire(f)['type']).toSet(), types.toSet());
    for (final f in fichiers) {
      expect(nom(f), startsWith('${lire(f)['type']}-'));
    }
    final ids = fichiers.map((f) => lire(f)['id']).toSet();
    expect(ids, hasLength(fichiers.length));
    expect(
      fichiers.map((f) => lire(f)['gabarit']),
      containsAll(['texte-trou', 'texte-trous']),
    );
  });

  bool estHaraka(int r) => r >= 0x064B && r <= 0x0652;
  bool lettreArabe(int r) => r >= 0x0621 && r <= 0x064A && r != 0x0640;

  void textes(Object? v, String chemin, List<(String, String)> sortie) {
    if (v is String) sortie.add((chemin, v));
    if (v is Map) {
      v.forEach((k, x) => textes(x, '$chemin/$k', sortie));
    }
    if (v is List) {
      for (var i = 0; i < v.length; i++) {
        textes(v[i], '$chemin/$i', sortie);
      }
    }
  }

  for (final f in fichiers) {
    group(nom(f), () {
      final ex = lire(f);
      final tous = <(String, String)>[];
      textes(ex, '', tous);

      test('valide, sans aucun avertissement, en brouillon', () {
        final r = validerExercice(ex);
        expect(r.erreurs, isEmpty, reason: '$r');
        expect(r.avertissements, isEmpty, reason: '$r');
        expect(ex['statut'], 'brouillon');
        expect(ex['empreinte'], matches(RegExp(r'^sha256:[0-9a-f]{64}$')));
      });

      test('harakat complètes et conventions A et B en arabe', () {
        for (final (chemin, texte) in tous) {
          final runes = texte.runes.toList();
          if (!runes.any(lettreArabe)) continue;
          expect(runes, isNot(contains(0x0670)), reason: chemin);
          final lettres = runes.where(lettreArabe).length;
          // Une lettre seule (tuile de T15) ne porte pas de haraka.
          if (lettres > 1) {
            expect(runes.any(estHaraka), isTrue, reason: chemin);
          }
          for (final phrase in texte.split(RegExp(r'[.!?؟]\s+'))) {
            final p = phrase.runes.toList();
            if (p.length > 1 && p[0] == 0x0627 && p[1] != 0x0644) {
              expect(p[1], 0x0650, reason: '$chemin : « $phrase »');
            }
          }
        }
      });

      test('aucune image : des emoji dans le prototype', () {
        expect(
          tous.map((t) => t.$1).where((c) => c.endsWith('/image')),
          isEmpty,
        );
      });

      test('ni tiret cadratin ni point-virgule', () {
        for (final (chemin, texte) in tous) {
          expect(texte, isNot(contains('—')), reason: chemin);
          expect(texte, isNot(contains(';')), reason: chemin);
        }
      });
    });
  }
}
