@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/relecture_harakat.dart';

/// tool/relecture_harakat.dart : collecte des textes arabes en brouillon
/// (exemples, étapes embarquées, fixtures, libellés, ARB) et page de
/// relecture autonome.
void main() {
  late Directory depot;

  void ecrire(String chemin, String contenu) {
    final f = File('${depot.path}/$chemin');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(contenu);
  }

  Map<String, dynamic> exercice({
    required String id,
    required String type,
    required String statut,
    Map<String, dynamic>? donnees,
  }) => {
    'id': id,
    'type': type,
    'statut': statut,
    'langue': 'ar',
    'consigne': {
      'texte': {'masculin': 'اِسْتَمِعْ.', 'feminin': 'اِسْتَمِعِي.'},
    },
    'donnees': donnees ?? {'texte': 'قَلَمٌ'},
    'empreinte': 'sha256:00',
  };

  setUp(() {
    depot = Directory.systemTemp.createTempSync('yasmina_relecture_');
    ecrire('packages/moteur_exercices/lib/src/registre/registre_types.dart', """
const typesExercices = <TypeExercice>[
  TypeExercice('T01', 'QCM', Moteur.choix, lot: 1),
  TypeExercice(
    'T38',
    'Mots mêlés',
    Moteur.revisionJeux,
    lot: 1,
  ),
  TypeExercice('T17', 'Dictée au clavier', Moteur.texte, lot: 1),
];
""");
    ecrire(
      'schema/exemples/choix/T01-brouillon.json',
      jsonEncode(exercice(id: 'ar-1-x', type: 'T01', statut: 'brouillon')),
    );
    ecrire(
      'schema/exemples/choix/T01-valide.json',
      jsonEncode(
        exercice(
          id: 'ar-1-y',
          type: 'T01',
          statut: 'valide',
          donnees: {'texte': 'كِتَابٌ'},
        ),
      ),
    );
    ecrire(
      'schema/exemples/revision-jeux/T38-grille.json',
      jsonEncode(
        exercice(
          id: 'ar-3-z',
          type: 'T38',
          statut: 'brouillon',
          donnees: {
            'grille': ['تملقب', 'كسردا'],
            'mots': [
              {'id': 'm1', 'texte': 'قَلَمٌ'},
            ],
          },
        ),
      ),
    );
    ecrire(
      'schema/exemples/texte/T17-clavier.json',
      jsonEncode(
        exercice(
          id: 'ar-1-w',
          type: 'T17',
          statut: 'brouillon',
          donnees: {
            'ecoute': {'texte': 'بَابٌ'},
            'lettres': 'بابنتر',
            'formes': ['ب', 'بـ'],
          },
        ),
      ),
    );
    ecrire(
      'apps/mobile/assets/content/ar/1/ar-1-t1-u1-e01.json',
      jsonEncode({
        'etape': {'id': 'ar-1-t1-u1-e01'},
        'exercices': [
          exercice(id: 'e-1', type: 'T01', statut: 'valide'),
          exercice(
            id: 'e-2',
            type: 'T01',
            statut: 'brouillon',
            donnees: {'texte': 'شَمْسٌ'},
          ),
        ],
      }),
    );
    ecrire('packages/moteur_exercices/test/moteurs/jeux/fixtures_jeux.dart', """
Map<String, dynamic> t37() => exerciceChoix(
  type: 'T37',
  consigne: 'اِبْحَثْ عَنِ الْأَزْوَاجِ.',
  explication: 'Voilà.',
);
""");
    ecrire(
      'packages/moteur_exercices/lib/src/lecteur/libelles_lecteur.dart',
      """
        verifier: feminin ? 'تَحَقَّقِي' : 'تَحَقَّقْ',
""",
    );
    ecrire(
      'apps/mobile/lib/l10n/app_ar.arb',
      jsonEncode({
        '@@locale': 'ar',
        'appTitre': 'يَاسْمِينَة',
        '@appTitre': {'description': 'Nom'},
        'reglagesTitre': 'الْإِعْدَادَاتُ',
      }),
    );
  });

  tearDown(() => depot.deleteSync(recursive: true));

  test('texteARelire : lettres arabes, pas une lettre seule sans haraka', () {
    expect(texteARelire('قَلَمٌ'), isTrue);
    expect(texteARelire('قلم'), isTrue);
    expect(texteARelire('بَ'), isTrue);
    expect(texteARelire('ب'), isFalse);
    expect(texteARelire('بـ'), isFalse);
    expect(texteARelire('Bonjour'), isFalse);
    expect(texteARelire('12'), isFalse);
  });

  test('collecte : brouillons seulement, groupés par type, grille et touches '
      'exclues, fixtures, libellés et ARB compris', () {
    final textes = collecterTextes(depot);
    final parGroupe = <String, List<String>>{};
    for (final t in textes) {
      parGroupe.putIfAbsent(t.groupe, () => []).add(t.texte);
    }
    expect(parGroupe.keys.toSet(), {
      'T01 QCM',
      'T38 Mots mêlés',
      'T17 Dictée au clavier',
      'T37',
      'Libellés du moteur',
      'Interface (ARB)',
    });
    // L'exemple valide est exclu, l'exercice brouillon de l'étape est pris.
    expect(parGroupe['T01 QCM'], containsAll(['قَلَمٌ', 'شَمْسٌ']));
    expect(parGroupe['T01 QCM'], isNot(contains('كِتَابٌ')));
    // La grille et les touches ne sont pas des textes à relire, les formes
    // d'une lettre seule non plus.
    expect(parGroupe['T38 Mots mêlés'], isNot(contains('تملقب')));
    expect(parGroupe['T38 Mots mêlés'], contains('قَلَمٌ'));
    expect(parGroupe['T17 Dictée au clavier'], isNot(contains('بابنتر')));
    expect(parGroupe['T17 Dictée au clavier'], isNot(contains('ب')));
    expect(parGroupe['T17 Dictée au clavier'], contains('بَابٌ'));
    // Fixture rattachée à son type par `type: 'T37'`.
    expect(parGroupe['T37'], ['اِبْحَثْ عَنِ الْأَزْوَاجِ.']);
    expect(parGroupe['Libellés du moteur'], ['تَحَقَّقِي', 'تَحَقَّقْ']);
    expect(parGroupe['Interface (ARB)'], ['يَاسْمِينَة', 'الْإِعْدَادَاتُ']);
    // Source et chemin.
    final arb = textes.firstWhere((t) => t.chemin == 'reglagesTitre');
    expect(arb.source, 'apps/mobile/lib/l10n/app_ar.arb');
    final consigne = textes.firstWhere(
      (t) => t.source == 'schema/exemples/choix/T01-brouillon.json',
    );
    expect(consigne.chemin, '/consigne/texte/masculin');
    expect(consigne.cle, '${consigne.source}#${consigne.chemin}');
  });

  test('page autonome : textes en grand et de droite à gauche, source, '
      'ok ou à corriger, commentaire, export JSON, aucun lien réseau', () {
    final textes = collecterTextes(depot);
    final html = genererHtml(
      textes,
      police: [0x00, 0x01, 0x02],
      date: DateTime(2026, 10, 21),
    );
    expect(html, startsWith('<!doctype html>'));
    expect(html, contains('2026-10-21'));
    expect(html, contains('<div class="texte" lang="ar">قَلَمٌ</div>'));
    expect(html, contains('direction: rtl'));
    expect(html, contains("font-family: 'Noto Naskh Arabic'"));
    expect(html, contains('data:font/ttf;base64,AAEC'));
    expect(html, contains('schema/exemples/choix/T01-brouillon.json'));
    expect(html, contains('value="ok"'));
    expect(html, contains('value="a-corriger"'));
    expect(html, contains('<textarea'));
    expect(html, contains('Exporter en JSON'));
    expect(html, contains('localStorage'));
    // Groupes dans l'ordre des types, puis les autres.
    expect(
      html.indexOf('<summary>T01 QCM'),
      lessThan(html.indexOf('<summary>T17 Dictée au clavier')),
    );
    expect(
      html.indexOf('<summary>T38 Mots mêlés'),
      lessThan(html.indexOf('<summary>Interface (ARB)')),
    );
    // Sans réseau : aucune adresse http.
    expect(html, isNot(contains('http://')));
    expect(html, isNot(contains('https://')));
    // Texte échappé.
    final avecChevron = genererHtml([
      const TexteARelire(
        groupe: 'T01',
        source: 's',
        chemin: '/c',
        texte: 'أ <b>',
      ),
    ], date: DateTime(2026, 10, 21));
    expect(avecChevron, contains('أ &lt;b&gt;'));
    expect(avecChevron, isNot(contains('@font-face')));
  });

  test('comparerGroupes : types par numéro, puis le reste par ordre', () {
    final groupes = ['Interface (ARB)', 'T38 Mots mêlés', 'T01 QCM', 'Autre']
      ..sort(comparerGroupes);
    expect(groupes, ['T01 QCM', 'T38 Mots mêlés', 'Autre', 'Interface (ARB)']);
  });
}
