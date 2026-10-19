import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  test('arabe genré comme les consignes (choix.md §6)', () {
    final m = LibellesLecteur.pour('ar', FormeAdresse.masculin);
    final f = LibellesLecteur.pour('ar', FormeAdresse.feminin);
    expect(
      [m.verifier, m.continuer, m.ecouter, m.validation],
      ['تَحَقَّقْ', 'وَاصِلْ', 'اِسْمَعْ', 'أَحْسَنْتَ'],
    );
    expect(
      [f.verifier, f.continuer, f.ecouter, f.validation],
      ['تَحَقَّقِي', 'وَاصِلِي', 'اِسْمَعِي', 'أَحْسَنْتِ'],
    );
    for (final l in [m, f]) {
      expect(
        [l.indice, l.explication, l.vrai, l.faux],
        ['تَلْمِيحٌ', 'لِنَتَعَلَّمْ', 'صَحِيحٌ', 'خَطَأٌ'],
      );
      expect(l.image(1), 'صُورَةٌ 1');
    }
  });

  test('français et anglais, identiques au masculin et au féminin', () {
    for (final forme in FormeAdresse.values) {
      final fr = LibellesLecteur.pour('fr', forme);
      expect(
        [fr.verifier, fr.continuer, fr.vrai, fr.faux, fr.image(2)],
        ['Vérifier', 'Continuer', 'Vrai', 'Faux', 'image 2'],
      );
      final en = LibellesLecteur.pour('en', forme);
      expect(
        [en.verifier, en.continuer, en.vrai, en.faux],
        ['Check', 'Continue', 'True', 'False'],
      );
    }
  });

  test('conventions de l\'arabe : harakat, ni alif suscrit ni lam nu', () {
    final lamNu = RegExp(
      'ال[ءأإآبجحخ'
      'عغفقكمهوي]',
    );
    for (final forme in FormeAdresse.values) {
      for (final texte in LibellesLecteur.pour('ar', forme).tous) {
        expect(texte.runes, isNot(contains(0x0670)), reason: texte);
        expect(
          texte.runes.any((r) => r >= 0x064B && r <= 0x0652),
          isTrue,
          reason: texte,
        );
        expect(lamNu.hasMatch(texte), isFalse, reason: texte);
        // Convention A : alif de liaison avec kasra (اِسْمَعْ).
        if (texte.startsWith('ا') && !texte.startsWith('ال')) {
          expect(texte.runes.elementAt(1), 0x0650, reason: texte);
        }
      }
    }
  });

  test('ni tiret cadratin ni point-virgule en français', () {
    for (final texte in LibellesLecteur.pour('fr', FormeAdresse.feminin).tous) {
      expect(texte, isNot(contains('—')));
      expect(texte, isNot(contains(';')));
    }
  });
}
