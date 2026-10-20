import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 3 types de base du moteur Manipulables
/// (docs/moteurs/manipulables.md), sur des exercices seuls construits ici
/// (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse, {
  int niveau = 2,
}) => {
  'id': 'ma-$niveau-t1-u1-e01-x01',
  'type': type,
  'gabarit': 'essai',
  'competence': 'ma-essai',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': 'ar',
  'consigne': {'texte': 'ضَعِ الْعَدَدَ فِي مَكَانِهِ.'},
  'donnees': donnees,
  'reponse': reponse,
  'feedbacks': {
    'reussite': 'إِجَابَتُكَ صَحِيحَةٌ.',
    'indice': 'عُدَّ مِنَ الصِّفْرِ.',
    'explication': 'هَذَا هُوَ الْجَوَابُ.',
  },
  'empreinte': _empreinte,
  'statut': 'brouillon',
  'version': 1,
};

final valides = <String, Map<String, dynamic> Function()>{
  'T25': () =>
      exercice('T25', {'min': 0, 'max': 10, 'cible': 7}, {'valeur': 7}),
  'T27': () => exercice('T27', {'cible': 34}, {'dizaines': 3, 'unites': 4}),
  'T51': () => exercice('T51', {'cible': 7}, {'jetons': 7}),
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

List<ProblemeValidation> avertissements(
  String type,
  void Function(Map<String, dynamic> ex) f,
) {
  final ex = valides[type]!();
  f(ex);
  return validerExercice(ex).avertissements;
}

void main() {
  test('un exemple valide pour chacun des 3 types, sans avertissement', () {
    expect(valides.keys, hasLength(3));
    valides.forEach((type, construire) {
      final r = validerExercice(construire());
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    });
  });

  test('maths en arabe : la compétence ma- impose la langue', () {
    expect(
      erreurs('T25', (ex) => ex['langue'] = 'fr'),
      contains(probleme('/langue', 'langue_competence')),
    );
  });

  group('schéma', () {
    test('T25 : sens inconnu, max hors bornes, pas nul', () {
      expect(
        erreurs('T25', (ex) => ex['donnees']['sens'] = 'haut-bas'),
        contains(probleme('/donnees/sens', 'valeur_non_autorisee')),
      );
      expect(
        erreurs('T25', (ex) => ex['donnees']['max'] = 101),
        contains(probleme('/donnees/max', 'valeur_trop_grande')),
      );
      expect(
        erreurs('T25', (ex) => ex['donnees']['pas'] = 0),
        contains(probleme('/donnees/pas', 'valeur_trop_petite')),
      );
    });

    test('T27 : cible à un chiffre ou à trois chiffres, 10 dizaines', () {
      expect(
        erreurs('T27', (ex) => ex['donnees']['cible'] = 9),
        contains(probleme('/donnees/cible', 'valeur_trop_petite')),
      );
      expect(
        erreurs('T27', (ex) => ex['donnees']['cible'] = 120),
        contains(probleme('/donnees/cible', 'valeur_trop_grande')),
      );
      expect(
        erreurs('T27', (ex) => ex['reponse']['dizaines'] = 10),
        contains(probleme('/reponse/dizaines', 'valeur_trop_grande')),
      );
    });

    test('T51 : cible 0 ou 11', () {
      expect(
        erreurs('T51', (ex) => ex['donnees']['cible'] = 0),
        contains(probleme('/donnees/cible', 'valeur_trop_petite')),
      );
      expect(
        erreurs('T51', (ex) => ex['donnees']['cible'] = 11),
        contains(probleme('/donnees/cible', 'valeur_trop_grande')),
      );
    });
  });

  group('règles métier', () {
    test('T25 : max sous min, étendue qui n\'est pas un multiple du pas', () {
      expect(
        erreurs('T25', (ex) => ex['donnees']['min'] = 10).single,
        probleme('/donnees/max', 'droite_invalide'),
      );
      expect(
        erreurs('T25', (ex) => ex['donnees']['pas'] = 3).single,
        probleme('/donnees/pas', 'droite_invalide'),
      );
    });

    test('T25 : droite trop longue, trop de graduations en 1re ou 2e', () {
      expect(
        erreurs('T25', (ex) {
          ex['donnees']['max'] = 30;
          ex['donnees']['cible'] = 7;
        }).single,
        probleme('/donnees', 'droite_trop_longue'),
      );
      final a = avertissements('T25', (ex) => ex['donnees']['max'] = 20);
      expect(a.single, probleme('/donnees', 'graduations_trop_nombreuses'));
      expect(
        avertissements('T25', (ex) {
          ex['id'] = 'ma-3-t1-u1-e01-x01';
          ex['donnees']['max'] = 20;
        }),
        isEmpty,
      );
      expect(
        erreurs('T25', (ex) {
          ex['donnees']['max'] = 100;
          ex['donnees']['pas'] = 10;
          ex['donnees']['cible'] = 70;
          ex['reponse']['valeur'] = 70;
        }),
        isEmpty,
      );
    });

    test('T25 : cible hors de la droite ou entre deux graduations', () {
      expect(
        erreurs('T25', (ex) {
          ex['donnees']['cible'] = 12;
          ex['reponse']['valeur'] = 12;
        }).single,
        probleme('/donnees/cible', 'cible_hors_droite'),
      );
      expect(
        erreurs('T25', (ex) {
          ex['donnees']['pas'] = 2;
          ex['donnees']['cible'] = 7;
        }).single,
        probleme('/donnees/cible', 'cible_hors_droite'),
      );
    });

    test('T25 : la réponse est la cible', () {
      expect(
        erreurs('T25', (ex) => ex['reponse']['valeur'] = 8).single,
        probleme('/reponse/valeur', 'reponse_valeur_incoherente'),
      );
    });

    test('T27 : somme fausse, 14 unités en mode canonique, libre accepté', () {
      expect(
        erreurs('T27', (ex) => ex['reponse']['unites'] = 5).single,
        probleme('/reponse', 'reponse_valeur_incoherente'),
      );
      expect(
        erreurs('T27', (ex) {
          ex['reponse'] = {'dizaines': 2, 'unites': 14};
        }).single,
        probleme('/reponse/unites', 'reponse_valeur_incoherente'),
      );
      expect(
        erreurs('T27', (ex) {
          ex['donnees']['canonique'] = false;
          ex['reponse'] = {'dizaines': 2, 'unites': 14};
        }),
        isEmpty,
      );
    });

    test('T51 : la réponse est la cible', () {
      expect(
        erreurs('T51', (ex) => ex['reponse']['jetons'] = 6).single,
        probleme('/reponse/jetons', 'reponse_valeur_incoherente'),
      );
    });
  });
}
