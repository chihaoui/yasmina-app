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
