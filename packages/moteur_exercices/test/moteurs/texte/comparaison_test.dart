import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Chaque normalisation de `comparerTextes` est testée séparément
/// (CLAUDE.md §5), plus la comparaison exacte sans normalisation.
void main() {
  test('sans normalisation : égalité exacte, harakat dans leur ordre', () {
    expect(comparerTextes('قَلَمٌ', 'قَلَمٌ', const []), isTrue);
    expect(comparerTextes('قلم', 'قَلَمٌ', const []), isFalse);
    // Shadda puis fatha, ou fatha puis shadda : deux textes différents,
    // jamais réordonnés (aucune normalisation Unicode).
    expect(
      comparerTextes('\u0628\u0651\u064E', '\u0628\u0651\u064E', const []),
      isTrue,
    );
    expect(
      comparerTextes('\u0628\u0651\u064E', '\u0628\u064E\u0651', const []),
      isFalse,
    );
    expect(comparerTextes('Poule', 'poule', const []), isFalse);
  });

  test('harakat_ignorees : lettres seules, alif suscrit compris', () {
    const n = ['harakat_ignorees'];
    expect(comparerTextes('قلم', 'قَلَمٌ', n), isTrue);
    expect(comparerTextes('قَلَمْ', 'قَلَمٌ', n), isTrue);
    expect(comparerTextes('قمل', 'قَلَمٌ', n), isFalse);
    expect(normaliserTexte('هٰذِهِ', n), 'هذه');
  });

  test('casse', () {
    expect(comparerTextes('Poule', 'poule', const ['casse']), isTrue);
    expect(comparerTextes('ÉCOLE', 'école', const ['casse']), isTrue);
  });

  test('espaces : bords et doublons', () {
    expect(comparerTextes('  le  chat ', 'le chat', const ['espaces']), isTrue);
    expect(comparerTextes('lechat', 'le chat', const ['espaces']), isFalse);
  });

  test('ponctuation latine et arabe', () {
    const n = ['ponctuation'];
    expect(comparerTextes('Le chat dort.', 'Le chat dort', n), isTrue);
    expect(comparerTextes('كَيْفَ حَالُكَ؟', 'كَيْفَ حَالُكَ', n), isTrue);
    expect(comparerTextes('a، b', 'a b', n), isTrue);
  });

  test('tatweel', () {
    expect(comparerTextes('بـــاب', 'باب', const ['tatweel']), isTrue);
  });

  test('chiffres arabes orientaux et persans vers 0 à 9', () {
    expect(comparerTextes('٣٤', '34', const ['chiffres']), isTrue);
    expect(comparerTextes('۳۴', '34', const ['chiffres']), isTrue);
    expect(comparerTextes('٣٤', '43', const ['chiffres']), isFalse);
  });

  test('plusieurs normalisations, dans l\'ordre, texte source inchangé', () {
    const source = '  Le Chat.  ';
    expect(
      comparerTextes(source, 'le chat', const [
        'espaces',
        'casse',
        'ponctuation',
      ]),
      isTrue,
    );
    expect(source, '  Le Chat.  ');
    expect(normaliserTexte('abc', const ['inconnue']), 'abc');
  });
}
