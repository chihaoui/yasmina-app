import 'dart:convert';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 2 types de base du moteur Saisie numérique
/// (docs/moteurs/saisie-numerique.md), sur des exercices seuls construits
/// ici (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) => {
  'id': 'ma-2-t1-u1-e01-x01',
  'type': type,
  'gabarit': 'essai',
  'competence': 'ma-essai',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': 'ar',
  'consigne': {'texte': 'اُكْتُبِ الْجَوَابَ.'.replaceAll('اُ', 'اِ')},
  'donnees': donnees,
  'reponse': reponse,
  'feedbacks': {
    'reussite': 'إِجَابَتُكَ صَحِيحَةٌ.',
    'indice': 'اِحْسُبْ مَرَّةً أُخْرَى.',
    'explication': 'هَذَا هُوَ الْجَوَابُ.',
  },
  'empreinte': _empreinte,
  'statut': 'brouillon',
  'version': 1,
};

final valides = <String, Map<String, dynamic> Function()>{
  'T22': () => exercice(
    'T22',
    {'texte': 'كَمْ يُسَاوِي 12 زَائِدُ 15؟'},
    {'valeur': 27},
  ),
  'T48': () => exercice(
    'T48',
    {'a': 34, 'b': 25, 'operation': 'addition'},
    {'valeur': 59},
  ),
};

Matcher probleme(String chemin, String code) => isA<ProblemeValidation>()
    .having((p) => p.chemin, 'chemin', chemin)
    .having((p) => p.code, 'code', code);

List<ProblemeValidation> erreurs(
  String type,
  void Function(Map<String, dynamic> ex) f,
) {
  final ex = valides[type]!();
  f(ex);
  return validerExercice(ex).erreurs;
}

void main() {
  test('T49, T50, T63 : exemples valides et règles', () {
    final avances = <String, Map<String, dynamic>>{
      'T49': exercice(
        'T49',
        {
          'termes': [
            {'numerateur': 1, 'denominateur': 4},
            {'numerateur': 2, 'denominateur': 4},
          ],
          'operation': 'addition',
        },
        {'numerateur': 3, 'denominateur': 4},
      ),
      'T50': exercice('T50', {'exercice': 'complement', 'cible': 10}, {}),
      'T63': exercice(
        'T63',
        {
          'gauche': [2, 2],
          'droite': [3, 3, 3],
          'sac': 'gauche',
        },
        {'valeur': 5},
      ),
    };
    for (final MapEntry(key: type, value: ex) in avances.entries) {
      final r = validerExercice(ex);
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    }
    List<ProblemeValidation> erreursDe(
      String type,
      void Function(Map<String, dynamic> ex) f,
    ) {
      final ex = jsonDecode(jsonEncode(avances[type])) as Map<String, dynamic>;
      f(ex);
      return validerExercice(ex).erreurs;
    }

    // T49 : 6/8 vaut 3/4, 1/2 non. Soustraction négative refusée.
    expect(
      erreursDe(
        'T49',
        (ex) => ex['reponse'] = {'numerateur': 6, 'denominateur': 8},
      ),
      isEmpty,
    );
    expect(
      erreursDe(
        'T49',
        (ex) => ex['reponse'] = {'numerateur': 1, 'denominateur': 2},
      ).single,
      probleme('/reponse', 'fraction_resultat_incoherente'),
    );
    expect(
      erreursDe(
        'T49',
        (ex) => ex['donnees']['operation'] = 'soustraction',
      ).single,
      probleme('/donnees/termes', 'soustraction_negative'),
    );
    expect(
      erreursDe(
        'T49',
        (ex) => ex['reponse'] = {'numerateur': 3, 'denominateur': 0},
      ),
      contains(probleme('/reponse/denominateur', 'valeur_trop_petite')),
    );
    // T50 : sans chronomètre, questions_min dans les questions.
    expect(
      erreursDe('T50', (ex) {
        ex['donnees']['chrono'] = false;
        ex['donnees']['questions'] = 3;
        ex['reponse'] = {'questions_min': 5};
      }).single,
      probleme('/reponse/questions_min', 'questions_min_trop_grand'),
    );
    expect(
      erreursDe('T50', (ex) => ex['donnees']['duree'] = 5),
      contains(probleme('/donnees/duree', 'valeur_trop_petite')),
    );
    // T63 : la réponse est la différence, le sac pèse quelque chose.
    expect(
      erreursDe('T63', (ex) => ex['reponse']['valeur'] = 4).single,
      probleme('/reponse/valeur', 'reponse_valeur_incoherente'),
    );
    expect(
      erreursDe('T63', (ex) => ex['donnees']['gauche'] = [5, 5]).single,
      probleme('/donnees', 'balance_invalide'),
    );
    expect(
      erreursDe('T63', (ex) {
        ex['donnees']['sac'] = 'droite';
        ex['reponse']['valeur'] = 4;
      }).single,
      probleme('/donnees', 'balance_invalide'),
    );
  });

  test('T28 et T30 (moteur Mesure et temps) : exemples valides et règles', () {
    final mesure = <String, Map<String, dynamic>>{
      'T28': exercice('T28', {'pas': 5}, {'heure': 6, 'minutes': 30}),
      'T30': exercice(
        'T30',
        {
          'longueur_regle': 10,
          'objet': {'emoji': '✏️', 'longueur': 7},
        },
        {'valeur': 7},
      ),
    };
    for (final MapEntry(key: type, value: ex) in mesure.entries) {
      final r = validerExercice(ex);
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    }
    List<ProblemeValidation> erreursDe(
      String type,
      void Function(Map<String, dynamic> ex) f,
    ) {
      final ex = jsonDecode(jsonEncode(mesure[type])) as Map<String, dynamic>;
      f(ex);
      return validerExercice(ex).erreurs;
    }

    expect(
      erreursDe('T28', (ex) => ex['reponse']['minutes'] = 32).single,
      probleme('/reponse/minutes', 'heure_hors_pas'),
    );
    expect(
      erreursDe(
        'T28',
        (ex) => ex['donnees']['depart'] = {'heure': 6, 'minutes': 30},
      ).single,
      probleme('/donnees/depart', 'depart_egal_cible'),
    );
    expect(
      erreursDe('T28', (ex) => ex['donnees']['pas'] = 10),
      contains(probleme('/donnees/pas', 'valeur_non_autorisee')),
    );
    expect(
      erreursDe('T30', (ex) => ex['donnees']['objet']['depart'] = 5).single,
      probleme('/donnees/objet', 'objet_hors_regle'),
    );
    expect(
      erreursDe('T30', (ex) => ex['reponse']['valeur'] = 8).single,
      probleme('/reponse/valeur', 'reponse_valeur_incoherente'),
    );
  });

  test('T31, T32, T33, T60 (moteur Grille et graphiques) : exemples valides '
      'et règles', () {
    final grille = <String, Map<String, dynamic>>{
      'T31': exercice(
        'T31',
        {
          'series': [
            {'id': 's1', 'emoji': '🍎', 'valeur': 6},
            {'id': 's2', 'emoji': '🍌', 'valeur': 9},
          ],
          'question': 'plus',
        },
        {'serie': 's2'},
      ),
      'T32': exercice(
        'T32',
        {
          'series': [
            {'id': 's1', 'emoji': '🍎', 'valeur': 3},
            {'id': 's2', 'emoji': '🍌', 'valeur': 5},
          ],
        },
        {
          'valeurs': [
            {'serie': 's1', 'valeur': 3},
            {'serie': 's2', 'valeur': 5},
          ],
        },
      ),
      'T33': exercice(
        'T33',
        {
          'lignes': 4,
          'colonnes': 6,
          'cases': [
            [1, 2],
            [2, 1],
          ],
        },
        {
          'cases': [
            [1, 3],
            [2, 4],
          ],
        },
      ),
      'T60': exercice(
        'T60',
        {
          'lignes': 4,
          'colonnes': 4,
          'depart': {'ligne': 3, 'colonne': 0},
          'but': {'ligne': 1, 'colonne': 2},
          'obstacles': [
            {'ligne': 2, 'colonne': 1},
          ],
        },
        {
          'chemin': ['haut', 'haut', 'droite', 'droite'],
        },
      ),
    };
    for (final MapEntry(key: type, value: ex) in grille.entries) {
      final r = validerExercice(ex);
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    }
    List<ProblemeValidation> erreursDe(
      String type,
      void Function(Map<String, dynamic> ex) f,
    ) {
      final ex = jsonDecode(jsonEncode(grille[type])) as Map<String, dynamic>;
      f(ex);
      return validerExercice(ex).erreurs;
    }

    expect(
      erreursDe('T31', (ex) => ex['reponse']['serie'] = 's1').single,
      probleme('/reponse/serie', 'reponse_valeur_incoherente'),
    );
    expect(
      erreursDe('T31', (ex) => ex['donnees']['series'][0]['valeur'] = 9).single,
      probleme('/donnees/series', 'question_ambigue'),
    );
    expect(
      erreursDe(
        'T31',
        (ex) => ex['donnees']['series'][1]['valeur'] = 12,
      ).single,
      probleme('/donnees/series', 'valeur_hors_axe'),
    );
    expect(
      erreursDe(
        'T32',
        (ex) => ex['reponse']['valeurs'][1]['valeur'] = 4,
      ).single,
      probleme('/reponse/valeurs/1/valeur', 'reponse_valeur_incoherente'),
    );
    expect(
      erreursDe('T32', (ex) => ex['reponse']['valeurs'][1]['serie'] = 's1'),
      contains(probleme('/reponse/valeurs', 'valeurs_incompletes')),
    );
    expect(
      erreursDe('T33', (ex) => ex['reponse']['cases'][0] = [1, 4]).single,
      probleme('/reponse/cases', 'symetrie_incoherente'),
    );
    expect(
      erreursDe('T33', (ex) => ex['donnees']['cases'][0] = [1, 4]),
      contains(probleme('/donnees/cases/0', 'case_hors_moitie')),
    );
    expect(
      erreursDe(
        'T60',
        (ex) => ex['reponse']['chemin'] = ['droite', 'haut', 'haut'],
      ).single,
      probleme('/reponse/chemin', 'chemin_invalide'),
    );
    expect(
      erreursDe(
        'T60',
        (ex) => ex['donnees']['but'] = {'ligne': 3, 'colonne': 0},
      ),
      contains(probleme('/donnees/but', 'depart_egal_but')),
    );
    expect(
      erreursDe(
        'T60',
        (ex) => ex['donnees']['obstacles'] = [
          {'ligne': 1, 'colonne': 2},
        ],
      ),
      contains(probleme('/donnees/obstacles', 'obstacle_sur_chemin')),
    );
  });

  test('un exemple valide pour chacun des 2 types, sans avertissement', () {
    valides.forEach((type, construire) {
      final r = validerExercice(construire());
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    });
  });

  group('schéma', () {
    test('chiffres inconnus, chiffres_max hors bornes, valeur négative', () {
      expect(
        erreurs('T22', (ex) => ex['donnees']['chiffres'] = 'romains'),
        contains(probleme('/donnees/chiffres', 'valeur_non_autorisee')),
      );
      expect(
        erreurs('T22', (ex) => ex['donnees']['chiffres_max'] = 7),
        contains(probleme('/donnees/chiffres_max', 'valeur_trop_grande')),
      );
      expect(
        erreurs('T22', (ex) => ex['reponse']['valeur'] = -1),
        contains(probleme('/reponse/valeur', 'valeur_trop_petite')),
      );
    });

    test('T48 : opération inconnue, opérande à 4 chiffres, sens inconnu', () {
      expect(
        erreurs('T48', (ex) => ex['donnees']['operation'] = 'division'),
        contains(probleme('/donnees/operation', 'valeur_non_autorisee')),
      );
      expect(
        erreurs('T48', (ex) => ex['donnees']['a'] = 1000),
        contains(probleme('/donnees/a', 'valeur_trop_grande')),
      );
      expect(
        erreurs('T48', (ex) => ex['donnees']['sens'] = 'haut-bas'),
        contains(probleme('/donnees/sens', 'valeur_non_autorisee')),
      );
    });
  });

  group('règles métier', () {
    test('T22 : la réponse tient dans chiffres_max', () {
      expect(
        erreurs('T22', (ex) {
          ex['donnees']['chiffres_max'] = 1;
        }).single,
        probleme('/reponse/valeur', 'valeur_trop_longue'),
      );
      expect(
        erreurs('T22', (ex) {
          ex['reponse']['valeur'] = 1234;
        }).single,
        probleme('/reponse/valeur', 'valeur_trop_longue'),
      );
      expect(
        erreurs('T22', (ex) {
          ex['donnees']['chiffres_max'] = 4;
          ex['reponse']['valeur'] = 1234;
        }),
        isEmpty,
      );
    });

    test('T48 : la réponse est le résultat, soustraction jamais négative', () {
      expect(
        erreurs('T48', (ex) => ex['reponse']['valeur'] = 58).single,
        probleme('/reponse/valeur', 'reponse_valeur_incoherente'),
      );
      expect(
        erreurs('T48', (ex) {
          ex['donnees']['operation'] = 'soustraction';
          ex['reponse']['valeur'] = 9;
        }),
        isEmpty,
      );
      expect(
        erreurs('T48', (ex) {
          ex['donnees']['operation'] = 'soustraction';
          ex['donnees']['b'] = 40;
          ex['reponse']['valeur'] = 0;
        }).single,
        probleme('/donnees/b', 'soustraction_negative'),
      );
    });
  });
}
