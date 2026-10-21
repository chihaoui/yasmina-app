import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/sequences/sequence_test.dart';

/// La séquence embarquée (assets/sequences/tour-1.json) : des séries
/// d'exemples du catalogue, tous jouables, qui couvrent chaque type jouable
/// au moins une fois (tour 1 des familles, A1-22).
void main() {
  final sequence = SequenceTest.depuisTexte(
    File(cheminSequenceTest).readAsStringSync(),
  );
  final catalogue = CatalogueExemples();

  bool estHaraka(int r) => r >= 0x064B && r <= 0x0652;

  test('séries : id uniques, titres arabes avec harakat et sans alif suscrit, '
      'titres français sans tiret cadratin ni point-virgule', () {
    expect(sequence.id, 'tour-1');
    expect(sequence.series, isNotEmpty);
    final ids = sequence.series.map((s) => s.id);
    expect(ids.toSet(), hasLength(ids.length));
    for (final s in sequence.series) {
      expect(s.id, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')));
      expect(s.titre.ar.runes.any(estHaraka), isTrue, reason: s.id);
      expect(s.titre.ar.runes, isNot(contains(0x0670)), reason: s.id);
      for (final t in [s.titre.ar, s.titre.fr]) {
        expect(t, isNot(contains('—')), reason: s.id);
        expect(t, isNot(contains(';')), reason: s.id);
      }
    }
  });

  test('chaque exemple existe dans le catalogue, valide, d\'un type jouable, '
      'cité une seule fois', () {
    final chemins = catalogue.tous.map((e) => e.chemin).toSet();
    final cites = <String>[];
    for (final s in sequence.series) {
      expect(s.exemples, isNotEmpty, reason: s.id);
      for (final chemin in s.exemples) {
        expect(chemins, contains(chemin), reason: '${s.id} : $chemin');
        cites.add(chemin);
      }
      // Rien n'est sauté : tout ce qui est cité se joue.
      expect(s.jouables(catalogue), hasLength(s.exemples.length), reason: s.id);
    }
    expect(cites.toSet(), hasLength(cites.length));
  });

  test('chaque type jouable est joué au moins une fois', () {
    final joues = {
      for (final s in sequence.series)
        for (final e in s.jouables(catalogue)) e.idType,
    };
    final jouables = typesExercices
        .where((t) => t.etat == EtatType.jouable)
        .map((t) => t.id)
        .toSet();
    expect(joues, containsAll(jouables));
  });

  testWidgets('l\'asset déclaré se charge par rootBundle', (tester) async {
    final texte = await rootBundle.loadString(cheminSequenceTest);
    expect(SequenceTest.depuisTexte(texte).id, sequence.id);
  });
}
