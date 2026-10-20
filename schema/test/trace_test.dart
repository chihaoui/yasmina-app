import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles de T20 Tracé de lettre (docs/moteurs/trace.md), non noté, sur des
/// exercices seuls construits ici (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> point(double x, double y) => {'x': x, 'y': y};

Map<String, dynamic> t20() => {
  'id': 'ar-1-t1-u1-e01-x01',
  'type': 'T20',
  'gabarit': 'trace-lettre',
  'competence': 'ar-ecriture-trace',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': 'ar',
  'consigne': {'texte': 'اِتْبَعِ النُّقَطَ وَارْسُمْ حَرْفَ الْبَاءِ.'},
  'donnees': {
    'lettre': 'ب',
    'formes': [
      {
        'id': 'f1',
        'texte': 'ب',
        'position': 'isolee',
        'traits': [
          [point(0.9, 0.3), point(0.5, 0.7), point(0.1, 0.4)],
          [point(0.5, 0.85), point(0.5, 0.87)],
        ],
      },
      {'id': 'f2', 'texte': 'بـ', 'position': 'debut'},
    ],
    'ecoute': {'texte': 'بَاءٌ'},
  },
  'reponse': {
    'formes': ['f1'],
  },
  'feedbacks': {
    'reussite': 'رَسَمْتَ الْحَرْفَ.',
    'indice': 'اِبْدَأْ مِنَ النُّقْطَةِ الْكَبِيرَةِ.',
    'explication': 'الْبَاءُ حَرْفٌ لَهُ نُقْطَةٌ وَاحِدَةٌ تَحْتَهُ.',
  },
  'empreinte': _empreinte,
  'statut': 'brouillon',
  'version': 1,
};

Matcher probleme(String chemin, String code) => isA<ProblemeValidation>()
    .having((p) => p.chemin, 'chemin', chemin)
    .having((p) => p.code, 'code', code);

List<ProblemeValidation> erreurs(void Function(Map<String, dynamic> ex) f) {
  final ex = t20();
  f(ex);
  return validerExercice(ex).erreurs;
}

void main() {
  test('exercice valide, sans avertissement, traits facultatifs', () {
    final r = validerExercice(t20());
    expect(r.erreurs, isEmpty, reason: '$r');
    expect(r.avertissements, isEmpty, reason: '$r');
  });

  group('schéma', () {
    test('lettre vocalisée ou double, position inconnue, 5 formes', () {
      expect(
        erreurs((ex) => ex['donnees']['lettre'] = 'بَ'),
        contains(probleme('/donnees/lettre', 'format_incorrect')),
      );
      expect(
        erreurs((ex) => ex['donnees']['lettre'] = 'بت'),
        contains(probleme('/donnees/lettre', 'format_incorrect')),
      );
      expect(
        erreurs((ex) => ex['donnees']['formes'][1]['position'] = 'seule'),
        contains(
          probleme('/donnees/formes/1/position', 'valeur_non_autorisee'),
        ),
      );
      expect(
        erreurs(
          (ex) => ex['donnees']['formes'] = [
            for (var i = 1; i <= 5; i++)
              {'id': 'f$i', 'texte': 'ب', 'position': 'isolee'},
          ],
        ),
        contains(probleme('/donnees/formes', 'liste_trop_longue')),
      );
    });

    test('traits : point hors de la zone, trait d\'un seul point', () {
      expect(
        erreurs(
          (ex) => ex['donnees']['formes'][0]['traits'][0][0] = point(1.2, 0.3),
        ),
        contains(
          probleme('/donnees/formes/0/traits/0/0/x', 'valeur_trop_grande'),
        ),
      );
      expect(
        erreurs(
          (ex) => ex['donnees']['formes'][0]['traits'][1] = [point(0.5, 0.8)],
        ),
        contains(probleme('/donnees/formes/0/traits/1', 'liste_trop_courte')),
      );
    });

    test('réponse : vide ou avec doublon', () {
      expect(
        erreurs((ex) => ex['reponse'] = {'formes': <String>[]}),
        contains(probleme('/reponse/formes', 'liste_trop_courte')),
      );
      expect(
        erreurs(
          (ex) => ex['reponse'] = {
            'formes': ['f1', 'f1'],
          },
        ),
        contains(probleme('/reponse/formes', 'doublon_liste')),
      );
    });
  });

  group('règles métier', () {
    test('arabe seulement', () {
      expect(
        erreurs((ex) {
          ex['langue'] = 'fr';
          ex['competence'] = 'fr-essai';
        }),
        contains(probleme('/langue', 'type_langue')),
      );
    });

    test('chaque forme contient la lettre (tatweel ignoré)', () {
      expect(
        erreurs((ex) => ex['donnees']['formes'][1]['texte'] = 'ـتـ').single,
        probleme('/donnees/formes/1/texte', 'forme_sans_lettre'),
      );
      expect(
        erreurs((ex) => ex['donnees']['formes'][1]['texte'] = 'ـبـ'),
        isEmpty,
      );
    });

    test('id et positions uniques', () {
      final r = erreurs((ex) {
        ex['donnees']['formes'][1]['id'] = 'f1';
        ex['donnees']['formes'][1]['position'] = 'isolee';
      });
      expect(
        r,
        unorderedEquals([
          probleme('/donnees/formes/1/id', 'element_duplique'),
          probleme('/donnees/formes/1/position', 'position_dupliquee'),
        ]),
      );
    });

    test('la réponse désigne des formes existantes', () {
      expect(
        erreurs(
          (ex) => ex['reponse'] = {
            'formes': ['f1', 'f4'],
          },
        ).single,
        probleme('/reponse/formes/1', 'reponse_element_inconnu'),
      );
    });
  });
}
