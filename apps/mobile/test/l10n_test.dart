import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Règles des textes de l'interface (CLAUDE.md §5, docs/conventions-arabe.md) :
/// mêmes clés en arabe et en français, pas de tiret cadratin ni de
/// point-virgule en français, aucun alif suscrit (U+0670) en arabe, convention
/// C (soukoun sur le lam devant une lettre lunaire), harakat
/// complètes dans l'interface enfant et aucune dans l'espace parent (clés
/// préfixées par `parent`).
void main() {
  Map<String, String> textes(String langue) {
    final arb = jsonDecode(
      File('lib/l10n/app_$langue.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    return {
      for (final MapEntry(:key, :value) in arb.entries)
        if (!key.startsWith('@')) key: value as String,
    };
  }

  final fr = textes('fr');
  final ar = textes('ar');

  bool contientHaraka(String texte) =>
      texte.runes.any((r) => (r >= 0x064B && r <= 0x0652) || r == 0x0670);

  test('mêmes clés en arabe et en français', () {
    expect(ar.keys.toSet(), fr.keys.toSet());
  });

  test('ni tiret cadratin ni point-virgule en français', () {
    for (final MapEntry(:key, :value) in fr.entries) {
      expect(value, isNot(contains('—')), reason: key);
      expect(value, isNot(contains(';')), reason: key);
    }
  });

  test('aucun alif suscrit (U+0670) en arabe', () {
    for (final MapEntry(:key, :value) in ar.entries) {
      expect(value.runes, isNot(contains(0x0670)), reason: key);
    }
  });

  test('convention C : soukoun sur le lam devant une lettre lunaire', () {
    final lamNu = RegExp(
      '\u0627\u0644[\u0621\u0623\u0625\u0622\u0628\u062C\u062D\u062E'
      '\u0639\u063A\u0641\u0642\u0643\u0645\u0647\u0648\u064A]',
    );
    for (final MapEntry(:key, :value) in ar.entries) {
      if (contientHaraka(value)) {
        expect(lamNu.hasMatch(value), isFalse, reason: key);
      }
    }
  });

  test('harakat dans l\'interface enfant, aucune dans l\'espace parent', () {
    for (final MapEntry(:key, :value) in ar.entries) {
      if (key.startsWith('parent')) {
        expect(contientHaraka(value), isFalse, reason: key);
      } else {
        expect(contientHaraka(value), isTrue, reason: key);
      }
    }
  });
}
