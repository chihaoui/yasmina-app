import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 13 types du moteur Choix (docs/moteurs/choix.md), sur des
/// exercices seuls construits ici (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

/// Exercice minimal valide de [type], avec [donnees] et [reponse].
Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse, {
  String langue = 'fr',
}) {
  final arabe = langue == 'ar';
  final texte = arabe ? 'اِخْتَرِ الْجَوَابَ.' : 'Choisis la réponse.';
  return {
    'id': '${arabe ? 'ar' : 'fr'}-2-t1-u1-e01-x01',
    'type': type,
    'gabarit': 'essai',
    'competence': '${arabe ? 'ar' : 'fr'}-essai',
    'critere': 'C1',
    'niveau_critere': 'minimal',
    'langue': langue,
    'consigne': {'texte': texte},
    'donnees': donnees,
    'reponse': reponse,
    'feedbacks': {'reussite': texte, 'indice': texte, 'explication': texte},
    'empreinte': _empreinte,
    'statut': 'brouillon',
    'version': 1,
  };
}

List<Map<String, dynamic>> choix(List<String> textes) => [
  for (var i = 0; i < textes.length; i++)
    {'id': 'c${i + 1}', 'texte': textes[i]},
];

Map<String, dynamic> bons(List<String> ids) => {'choix': ids};

/// Exercice valide de chaque type.
final valides = <String, Map<String, dynamic> Function()>{
  'T01': () => exercice('T01', {
    'choix': choix(['un', 'deux', 'trois']),
  }, bons(['c1'])),
  'T02': () =>
      exercice('T02', {'affirmation': 'Le ciel est bleu.'}, {'valeur': true}),
  'T03': () => exercice('T03', {
    'ecoute': {'texte': 'chat'},
    'choix': [
      {'id': 'c1', 'image': 'images/chat.png'},
      {'id': 'c2', 'image': 'images/chien.png'},
    ],
  }, bons(['c1'])),
  'T04': () => exercice('T04', {
    'choix': choix(['pomme', 'poire', 'chaise']),
  }, bons(['c3'])),
  'T05': () => exercice('T05', {
    'choix': choix(['lire', 'table', 'courir']),
  }, bons(['c1', 'c3'])),
  'T18': () => exercice(
    'T18',
    {
      'lettre': 'ج',
      'position': 'milieu',
      'mot': 'نَجْمَةٌ',
      'choix': choix(['ج', 'جـ', 'ـجـ', 'ـج']),
    },
    bons(['c3']),
    langue: 'ar',
  ),
  'T19': () => exercice(
    'T19',
    {
      'avant': 'كُ',
      'lettre': 'ت',
      'apres': 'بٌ',
      'harakat': ['fatha', 'damma', 'kasra', 'soukoun'],
      'ecoute': {'texte': 'كُتُبٌ'},
    },
    {'haraka': 'damma'},
    langue: 'ar',
  ),
  'T23': () => exercice('T23', {'a': 14, 'b': 9}, {'signe': '>'}),
  'T24': () => exercice('T24', {
    'suite': [
      for (final f in ['a', 'b', 'a', 'b']) {'image': 'formes/$f.png'},
    ],
    'choix': [
      {'id': 'c1', 'image': 'formes/a.png'},
      {'id': 'c2', 'image': 'formes/b.png'},
    ],
  }, bons(['c1'])),
  'T45': () => exercice('T45', {
    'support': {'texte': 'Sami a un chat noir.'},
    'choix': choix(['Le chat est blanc.', 'Le chat est à Sami.']),
  }, bons(['c1'])),
  'T46': () => exercice(
    'T46',
    {
      'texte': 'Il pleut. Adam rentre trempé.',
      'question': 'Adam est-il au sec ?',
      'choix': choix(['Oui', 'Non']),
      'preuves': [
        {'id': 'p1', 'texte': 'Il pleut.'},
        {'id': 'p2', 'texte': 'Adam rentre trempé.'},
      ],
    },
    {
      'choix': ['c2'],
      'preuves': ['p2'],
    },
  ),
  'T55': () => exercice('T55', {
    'ecoute': {'texte': 'bain'},
    'choix': choix(['pain', 'bain']),
  }, bons(['c2'])),
  'T61': () => exercice('T61', {
    'texte': 'Une histoire courte.',
    'choix': choix(['Début.', 'Détail.', 'Fin.']),
  }, bons(['c1', 'c3'])),
};

Matcher probleme(String chemin, String code) => isA<ProblemeValidation>()
    .having((p) => p.chemin, 'chemin', chemin)
    .having((p) => p.code, 'code', code);

/// Erreurs d'un exercice de [type] modifié par [modifier].
List<ProblemeValidation> erreurs(
  String type,
  void Function(Map<String, dynamic> ex) modifier,
) {
  final ex = valides[type]!();
  modifier(ex);
  return validerExercice(ex).erreurs;
}

void main() {
  group('cas valides', () {
    test('un exemple valide pour chacun des 13 types', () {
      expect(valides.keys, hasLength(13));
      valides.forEach((type, construire) {
        final r = validerExercice(construire());
        expect(r.erreurs, isEmpty, reason: '$type : $r');
        expect(r.avertissements, isEmpty, reason: '$type : $r');
      });
    });

    test('T24 : suite arithmétique d\'entiers', () {
      final r = erreurs('T24', (ex) {
        ex['donnees'] = {
          'suite': [
            for (final n in ['2', '4', '6']) {'texte': n},
          ],
          'choix': choix(['7', '8']),
        };
        ex['reponse'] = bons(['c2']);
      });
      expect(r, isEmpty);
    });

    test('T24 : suite sans motif reconnu, réponse non contrôlée', () {
      final r = erreurs('T24', (ex) {
        ex['donnees'] = {
          'suite': [
            for (final n in ['1', '2', '4']) {'texte': n},
          ],
          'choix': choix(['7', '8']),
        };
        ex['reponse'] = bons(['c2']);
      });
      expect(r, isEmpty);
    });

    test('T19 sans écoute et T18 sans mot', () {
      expect(
        erreurs('T19', (ex) => (ex['donnees'] as Map).remove('ecoute')),
        isEmpty,
      );
      expect(
        erreurs('T18', (ex) => (ex['donnees'] as Map).remove('mot')),
        isEmpty,
      );
    });

    test('T01 avec un support et des choix en images', () {
      final r = erreurs('T01', (ex) {
        ex['donnees'] = {
          'support': {'image': 'images/scene.png'},
          'choix': [
            {'id': 'c1', 'image': 'images/a.png'},
            {'id': 'c2', 'image': 'images/b.png', 'texte': 'b'},
          ],
        };
      });
      expect(r, isEmpty);
    });
  });

  group('cas invalides : schéma', () {
    test('T03 sans écoute', () {
      final r = erreurs('T03', (ex) => (ex['donnees'] as Map).remove('ecoute'));
      expect(r.single, probleme('/donnees', 'obligatoire'));
    });

    test('T18 : lettre avec haraka', () {
      final r = erreurs('T18', (ex) => ex['donnees']['lettre'] = 'جَ');
      expect(r.single, probleme('/donnees/lettre', 'format_incorrect'));
    });

    test('T18 : 5 formes proposées', () {
      final r = erreurs(
        'T18',
        (ex) => ex['donnees']['choix'] = choix(['ج', 'جـ', 'ـجـ', 'ـج', 'جج']),
      );
      expect(r.single, probleme('/donnees/choix', 'liste_trop_longue'));
    });

    test('T19 : haraka inconnue', () {
      final r = erreurs('T19', (ex) => ex['reponse'] = {'haraka': 'shadda'});
      expect(r.single, probleme('/reponse/haraka', 'valeur_non_autorisee'));
    });

    test('T23 : signe inconnu et nombre en texte', () {
      final r = erreurs('T23', (ex) {
        ex['donnees']['a'] = '14';
        ex['reponse'] = {'signe': '≥'};
      });
      expect(
        r,
        unorderedEquals([
          probleme('/donnees/a', 'type_incorrect'),
          probleme('/reponse/signe', 'valeur_non_autorisee'),
        ]),
      );
    });

    test('T24 : suite de 2 éléments', () {
      final r = erreurs(
        'T24',
        (ex) => (ex['donnees']['suite'] as List).removeRange(0, 2),
      );
      expect(r.single, probleme('/donnees/suite', 'liste_trop_courte'));
    });

    test('T46 : deux preuves dans la réponse', () {
      final r = erreurs('T46', (ex) => ex['reponse']['preuves'] = ['p1', 'p2']);
      expect(r.single, probleme('/reponse/preuves', 'liste_trop_longue'));
    });

    test('T46 : id de preuve au format des choix', () {
      final r = erreurs(
        'T46',
        (ex) => ex['donnees']['preuves'][0]['id'] = 'c1',
      );
      expect(r.single, probleme('/donnees/preuves/0/id', 'format_incorrect'));
    });

    test('T61 : texte absent', () {
      final r = erreurs('T61', (ex) => (ex['donnees'] as Map).remove('texte'));
      expect(r.single, probleme('/donnees', 'obligatoire'));
    });

    test('T45 : support vide', () {
      final r = erreurs('T45', (ex) => ex['donnees']['support'] = {});
      expect(r.single, probleme('/donnees/support', 'forme_incorrecte'));
    });
  });

  group('cas invalides : règles métier', () {
    for (final type in ['T03', 'T04', 'T18', 'T24', 'T55']) {
      test('$type : exactement une bonne réponse', () {
        final r = erreurs(type, (ex) {
          final ids = [
            for (final c in ex['donnees']['choix'] as List) c['id'] as String,
          ];
          ex['reponse'] = bons(ids.take(2).toList());
        });
        expect(r, contains(probleme('/reponse/choix', 'reponse_unique')));
      });
    }

    test('T01 : le message oriente vers T05', () {
      final r = erreurs('T01', (ex) => ex['reponse'] = bons(['c1', 'c2']));
      expect(r.single, probleme('/reponse/choix', 'reponse_unique'));
      expect(r.single.message, contains('T05'));
    });

    for (final type in ['T05', 'T45', 'T61']) {
      test('$type : jamais toutes les propositions dans la réponse', () {
        final r = erreurs(type, (ex) {
          ex['reponse'] = bons([
            for (final c in ex['donnees']['choix'] as List) c['id'] as String,
          ]);
        });
        expect(
          r,
          contains(probleme('/reponse/choix', 'reponse_tous_les_choix')),
        );
      });
    }

    test('T61 : au moins 2 phrases dans le résumé', () {
      final r = erreurs('T61', (ex) => ex['reponse'] = bons(['c1']));
      expect(r.single, probleme('/reponse/choix', 'reponse_trop_peu'));
    });

    test('T04 : 3 propositions au moins', () {
      final r = erreurs('T04', (ex) {
        ex['donnees']['choix'] = choix(['pomme', 'chaise']);
        ex['reponse'] = bons(['c2']);
      });
      expect(r.single, probleme('/donnees/choix', 'choix_trop_peu'));
    });

    test('T46 : réponse et preuve vers des id absents', () {
      final r = erreurs('T46', (ex) {
        ex['reponse'] = {
          'choix': ['c9'],
          'preuves': ['p9'],
        };
      });
      expect(
        r,
        unorderedEquals([
          probleme('/reponse/choix/0', 'reponse_choix_inconnu'),
          probleme('/reponse/preuves/0', 'reponse_choix_inconnu'),
        ]),
      );
    });

    test('T46 : preuve qui n\'est pas recopiée du texte', () {
      final r = erreurs(
        'T46',
        (ex) => ex['donnees']['preuves'][1]['texte'] = 'Adam est mouillé.',
      );
      expect(
        r.single,
        probleme('/donnees/preuves/1/texte', 'preuve_absente_du_texte'),
      );
    });

    test('T46 : deux preuves identiques', () {
      final r = erreurs(
        'T46',
        (ex) => ex['donnees']['preuves'][1]['texte'] = 'Il pleut.',
      );
      expect(r.single, probleme('/donnees/preuves/1/texte', 'choix_duplique'));
    });

    test('T18 et T19 : uniquement en arabe', () {
      for (final type in ['T18', 'T19']) {
        final r = erreurs(type, (ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
        });
        expect(r, contains(probleme('/langue', 'type_langue')), reason: type);
      }
    });

    test('T18 : forme ou mot sans la lettre', () {
      final r = erreurs('T18', (ex) {
        ex['donnees']['choix'][1]['texte'] = 'حـ';
        ex['donnees']['mot'] = 'قَمَرٌ';
      });
      expect(
        r,
        unorderedEquals([
          probleme('/donnees/choix/1/texte', 'forme_sans_lettre'),
          probleme('/donnees/mot', 'forme_sans_lettre'),
        ]),
      );
    });

    test('T19 : réponse absente des harakat proposées', () {
      final r = erreurs('T19', (ex) {
        ex['donnees']['harakat'] = ['fatha', 'kasra'];
        (ex['donnees'] as Map).remove('ecoute');
      });
      expect(r.single, probleme('/reponse/haraka', 'reponse_haraka_inconnue'));
    });

    test('T19 : la lettre a déjà une haraka dans apres', () {
      final r = erreurs('T19', (ex) {
        ex['donnees']['apres'] = 'ُبٌ';
        (ex['donnees'] as Map).remove('ecoute');
      });
      expect(r.single, probleme('/donnees/apres', 'haraka_deja_presente'));
    });

    test('T19 : mot entendu différent du mot complet', () {
      final r = erreurs('T19', (ex) => ex['reponse'] = {'haraka': 'fatha'});
      expect(
        r.single,
        probleme('/donnees/ecoute/texte', 'ecoute_differente_reponse'),
      );
      expect(r.single.message, contains('كُتَبٌ'));
    });

    test('T23 : signe contraire aux nombres', () {
      for (final signe in ['<', '=']) {
        final r = erreurs('T23', (ex) => ex['reponse'] = {'signe': signe});
        expect(
          r.single,
          probleme('/reponse/signe', 'reponse_comparaison_fausse'),
        );
      }
      expect(
        erreurs('T23', (ex) {
          ex['donnees'] = {'a': 2.5, 'b': 2.5};
          ex['reponse'] = {'signe': '='};
        }),
        isEmpty,
      );
    });

    test('T24 : réponse contraire au motif', () {
      final r = erreurs('T24', (ex) => ex['reponse'] = bons(['c2']));
      expect(r.single, probleme('/reponse/choix', 'suite_reponse_incoherente'));
    });

    test('T24 : réponse contraire à la suite arithmétique', () {
      final r = erreurs('T24', (ex) {
        ex['donnees'] = {
          'suite': [
            for (final n in ['2', '4', '6']) {'texte': n},
          ],
          'choix': choix(['7', '8']),
        };
        ex['reponse'] = bons(['c1']);
      });
      expect(r.single, probleme('/reponse/choix', 'suite_reponse_incoherente'));
    });

    test('T55 : mot entendu différent du bon choix', () {
      final r = erreurs(
        'T55',
        (ex) => ex['donnees']['ecoute']['texte'] = 'pain',
      );
      expect(
        r.single,
        probleme('/donnees/ecoute/texte', 'ecoute_differente_reponse'),
      );
    });

    test('T03 : choix en double (même texte)', () {
      final r = erreurs('T03', (ex) {
        ex['donnees']['choix'] = choix(['chat', 'chat']);
      });
      expect(r.single, probleme('/donnees/choix/1/texte', 'choix_duplique'));
    });
  });

  group('dans une étape de 1re année', () {
    test('les formes de lettre (T18) ne demandent pas de harakat', () {
      final ex = valides['T18']!()..['id'] = 'ar-1-t1-u1-e01-x01';
      ex['competence'] = 'ar-ecriture-formes';
      final etape = {
        'generation': {
          'id': 'gen-ar-1-t1-u1-e01-20261017-01',
          'schema': 'edu-content/1.0',
          'date': '2026-10-17',
          'modele': 'manuel',
          'version_prompt': 'aucun',
          'auteur': 'test',
        },
        'etape': {
          'id': 'ar-1-t1-u1-e01',
          'matiere': 'arabe',
          'niveau': 1,
          'trimestre': 1,
          'unite': 1,
          'ordre': 1,
          'langue': 'ar',
          'titre': 'حَرْفُ الْجِيمِ',
          'sequences': [
            {
              'id': 'ar-1-t1-u1-e01-s1',
              'titre': 'أَتَعَرَّفُ عَلَى الْجِيمِ',
              'exercices': ['ar-1-t1-u1-e01-x01'],
            },
          ],
        },
        'exercices': [ex],
      };
      final r = validerEtapeDecodee(etape);
      expect(r.erreurs, isEmpty, reason: '$r');
      expect(
        r.avertissements.where((a) => a.code == 'harakat_manquantes'),
        isEmpty,
        reason: '$r',
      );
      // Un mot entier sans harakat reste signalé.
      (ex['donnees'] as Map)['mot'] = 'نجمة';
      expect(
        validerEtapeDecodee(etape).avertissements,
        contains(probleme('/exercices/0/donnees/mot', 'harakat_manquantes')),
      );
    });
  });

  group('T19, gabarit lettre-vocalisee', () {
    Map<String, dynamic> lettreVocalisee() => exercice(
      'T19',
      {
        'haraka': 'fatha',
        'choix': choix(['بَ', 'بُ', 'بِ', 'بْ']),
      },
      bons(['c1']),
      langue: 'ar',
    )..['gabarit'] = 'lettre-vocalisee';

    List<ProblemeValidation> erreursLv(
      void Function(Map<String, dynamic> ex) modifier,
    ) {
      final ex = lettreVocalisee();
      modifier(ex);
      return validerExercice(ex).erreurs;
    }

    test('valide, sans avertissement', () {
      final r = validerExercice(lettreVocalisee());
      expect(r.erreurs, isEmpty, reason: '$r');
      expect(r.avertissements, isEmpty, reason: '$r');
    });

    test('choix sans haraka ou avec deux signes', () {
      final r = erreursLv((ex) {
        ex['donnees']['choix'][1]['texte'] = 'ب';
        ex['donnees']['choix'][2]['texte'] = 'بِّ';
      });
      expect(
        r,
        unorderedEquals([
          probleme('/donnees/choix/1/texte', 'lettre_vocalisee_invalide'),
          probleme('/donnees/choix/2/texte', 'lettre_vocalisee_invalide'),
        ]),
      );
    });

    test('la bonne réponse ne porte pas la haraka demandée', () {
      final r = erreursLv((ex) => ex['reponse'] = bons(['c2']));
      expect(
        r,
        unorderedEquals([
          probleme('/donnees/choix/0/texte', 'reponse_haraka_incoherente'),
          probleme('/reponse/choix', 'reponse_haraka_incoherente'),
        ]),
      );
    });

    test('un autre choix porte aussi la haraka demandée', () {
      final r = erreursLv((ex) => ex['donnees']['choix'][3]['texte'] = 'تَ');
      expect(
        r.single,
        probleme('/donnees/choix/3/texte', 'reponse_haraka_incoherente'),
      );
    });

    test('une seule bonne réponse et 4 choix au plus', () {
      expect(
        erreursLv((ex) => ex['reponse'] = bons(['c1', 'c2'])),
        contains(probleme('/reponse/choix', 'reponse_unique')),
      );
      expect(
        erreursLv(
          (ex) =>
              (ex['donnees']['choix'] as List).add({'id': 'c5', 'texte': 'تُ'}),
        ).single,
        probleme('/donnees/choix', 'liste_trop_longue'),
      );
    });

    test('uniquement en arabe', () {
      final r = erreursLv((ex) {
        ex['langue'] = 'fr';
        ex['competence'] = 'fr-essai';
      });
      expect(r, contains(probleme('/langue', 'type_langue')));
    });

    test('forme mot avec le gabarit lettre-vocalisee : chemins précis', () {
      final r = erreurs('T19', (ex) => ex['gabarit'] = 'lettre-vocalisee');
      expect(r, isNotEmpty);
      expect(r.map((e) => e.code), isNot(contains('donnees_type')));
      expect(
        r.every(
          (e) => e.chemin.startsWith('/donnees') || e.chemin == '/reponse',
        ),
        isTrue,
        reason: '$r',
      );
      expect(r, contains(probleme('/donnees', 'obligatoire')));
    });

    test('lettres vocalisées avec un autre gabarit : forme mot attendue', () {
      final ex = lettreVocalisee()..['gabarit'] = 'haraka';
      final r = validerExercice(ex).erreurs;
      expect(r, contains(probleme('/donnees', 'obligatoire')));
      expect(r.map((e) => e.code), isNot(contains('donnees_type')));
    });
  });

  group('emoji et support', () {
    test('T01 : support avec texte sur deux lignes, emoji et écoute', () {
      final r = erreurs('T01', (ex) {
        ex['donnees']['support'] = {
          'texte': 'Une ligne.\nUne autre ligne.',
          'emoji': '🌳',
          'ecoute': {'texte': 'arbre'},
        };
      });
      expect(r, isEmpty);
    });

    test('choix, suite et affirmation en emoji', () {
      expect(
        erreurs('T03', (ex) {
          ex['donnees']['choix'] = [
            {'id': 'c1', 'emoji': '🐱'},
            {'id': 'c2', 'emoji': '🐶'},
          ];
        }),
        isEmpty,
      );
      expect(
        erreurs('T24', (ex) {
          ex['donnees'] = {
            'suite': [
              for (final e in ['🔺', '🔵', '🔺', '🔵']) {'emoji': e},
            ],
            'choix': [
              {'id': 'c1', 'emoji': '🔵'},
              {'id': 'c2', 'emoji': '🔺'},
            ],
          };
          ex['reponse'] = bons(['c2']);
        }),
        isEmpty,
      );
      expect(erreurs('T02', (ex) => ex['donnees']['emoji'] = '☁️'), isEmpty);
    });

    test('T24 : motif en emoji contredit par la réponse', () {
      final r = erreurs('T24', (ex) {
        ex['donnees'] = {
          'suite': [
            for (final e in ['🔺', '🔵', '🔺', '🔵']) {'emoji': e},
          ],
          'choix': [
            {'id': 'c1', 'emoji': '🔵'},
            {'id': 'c2', 'emoji': '🔺'},
          ],
        };
        ex['reponse'] = bons(['c1']);
      });
      expect(r.single, probleme('/reponse/choix', 'suite_reponse_incoherente'));
      expect(r.single.message, contains('🔺'));
    });

    test('image et emoji ensemble : refusé (choix, support, affirmation)', () {
      expect(
        erreurs(
          'T03',
          (ex) => ex['donnees']['choix'][0]['emoji'] = '🐱',
        ).single,
        probleme('/donnees/choix/0', 'proprietes_exclusives'),
      );
      final support = erreurs('T01', (ex) {
        ex['donnees']['support'] = {'image': 'images/a.png', 'emoji': '🌳'};
      });
      expect(
        support.single,
        probleme('/donnees/support', 'proprietes_exclusives'),
      );
      expect(support.single.message, contains('« image » et « emoji »'));
      expect(
        erreurs('T02', (ex) {
          ex['donnees']['image'] = 'images/a.png';
          ex['donnees']['emoji'] = '☁️';
        }).single,
        probleme('/donnees', 'proprietes_exclusives'),
      );
    });

    test('choix sans texte, image ni emoji : refusé', () {
      final r = erreurs(
        'T01',
        (ex) => (ex['donnees']['choix'][0] as Map).remove('texte'),
      );
      expect(r.single, probleme('/donnees/choix/0', 'forme_incorrecte'));
    });
  });

  test('T18 : 2 formes suffisent pour une lettre qui ne s\'attache pas à '
      'gauche (ر)', () {
    final r = erreurs('T18', (ex) {
      ex['donnees'] = {
        'lettre': 'ر',
        'position': 'fin',
        'mot': 'قَمَرٌ',
        'choix': choix(['ر', 'ـر']),
      };
      ex['reponse'] = bons(['c2']);
    });
    expect(r, isEmpty);
  });
}
