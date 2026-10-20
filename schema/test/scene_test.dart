import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Règles des 2 types de base du moteur Scène image
/// (docs/moteurs/scene-image.md), sur des exercices seuls construits ici
/// (les tests tournent aussi dans Chrome).

const _empreinte =
    'sha256:0000000000000000000000000000000000000000000000000000000000000000';

Map<String, dynamic> zone(String id, {double x = 0.1, double y = 0.1}) => {
  'id': id,
  'x': x,
  'y': y,
  'l': 0.2,
  'h': 0.2,
  'libelle': 'zone $id',
};

Map<String, dynamic> exercice(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse, {
  int niveau = 3,
}) => {
  'id': 'fr-$niveau-t1-u1-e01-x01',
  'type': type,
  'gabarit': 'essai',
  'competence': 'fr-essai',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': 'fr',
  'consigne': {'texte': 'Touche.'},
  'donnees': donnees,
  'reponse': reponse,
  'feedbacks': {
    'reussite': 'Oui.',
    'indice': 'Regarde.',
    'explication': 'Voilà.',
  },
  'empreinte': _empreinte,
  'statut': 'brouillon',
  'version': 1,
};

// Une scène neuve à chaque appel : les tests modifient l'exercice.
Map<String, dynamic> scene() => {
  'elements': [
    {'emoji': '☀️', 'x': 0.2, 'y': 0.2, 'h': 0.2},
    {
      'forme': 'cercle',
      'couleur': 'olive',
      'x': 0.5,
      'y': 0.5,
      'l': 0.2,
      'h': 0.2,
    },
  ],
};

final valides = <String, Map<String, dynamic> Function()>{
  'T08': () => exercice(
    'T08',
    {
      'scene': scene(),
      'zones': [zone('z1'), zone('z2', x: 0.5)],
    },
    {
      'zones': ['z1'],
    },
  ),
  'T47': () => exercice(
    'T47',
    {
      'scene': scene(),
      'zones': [zone('z1'), zone('z2', x: 0.5)],
      'etiquettes': [
        {'id': 'e1', 'texte': 'soleil'},
        {'id': 'e2', 'texte': 'balle'},
        {'id': 'e3', 'texte': 'lune'},
      ],
    },
    {
      'placements': [
        {'zone': 'z1', 'etiquette': 'e1'},
        {'zone': 'z2', 'etiquette': 'e2'},
      ],
    },
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

List<ProblemeValidation> avertissements(
  String type,
  void Function(Map<String, dynamic> ex) f,
) {
  final ex = valides[type]!();
  f(ex);
  return validerExercice(ex).avertissements;
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
    test('élément sans emoji ni forme, les deux, coordonnée hors de 0 à 1, '
        'couleur inconnue', () {
      expect(
        erreurs(
          'T08',
          (ex) => ex['donnees']['scene']['elements'][0] = {'x': 0.1, 'y': 0.1},
        ),
        contains(probleme('/donnees/scene/elements/0', 'forme_incorrecte')),
      );
      expect(
        erreurs(
          'T08',
          (ex) => ex['donnees']['scene']['elements'][0]['forme'] = 'carre',
        ),
        contains(probleme('/donnees/scene/elements/0', 'forme_incorrecte')),
      );
      expect(
        erreurs('T08', (ex) => ex['donnees']['zones'][0]['x'] = 1.2),
        contains(probleme('/donnees/zones/0/x', 'valeur_trop_grande')),
      );
      expect(
        erreurs(
          'T08',
          (ex) => ex['donnees']['scene']['elements'][1]['couleur'] = 'rose',
        ),
        contains(
          probleme('/donnees/scene/elements/1/couleur', 'valeur_non_autorisee'),
        ),
      );
    });

    test('id de zone hors format, 10 zones', () {
      expect(
        erreurs('T08', (ex) => ex['donnees']['zones'][0]['id'] = 'k1'),
        contains(probleme('/donnees/zones/0/id', 'format_incorrect')),
      );
      expect(
        erreurs(
          'T08',
          (ex) => ex['donnees']['zones'] = [
            for (var i = 1; i <= 10; i++) zone('z${i % 9 + 1}'),
          ],
        ),
        contains(probleme('/donnees/zones', 'liste_trop_longue')),
      );
    });
  });

  group('règles métier', () {
    test('zone qui dépasse la scène, id de zone en double', () {
      expect(
        erreurs('T08', (ex) => ex['donnees']['zones'][1]['x'] = 0.9).single,
        probleme('/donnees/zones/1', 'zone_hors_scene'),
      );
      expect(
        erreurs('T08', (ex) => ex['donnees']['zones'][1]['id'] = 'z1').single,
        probleme('/donnees/zones/1/id', 'element_duplique'),
      );
    });

    test('T08 : zone inconnue, une seule zone sans plusieurs', () {
      expect(
        erreurs(
          'T08',
          (ex) => ex['reponse'] = {
            'zones': ['z9'],
          },
        ).single,
        probleme('/reponse/zones/0', 'reponse_element_inconnu'),
      );
      expect(
        erreurs(
          'T08',
          (ex) => ex['reponse'] = {
            'zones': ['z1', 'z2'],
          },
        ).single,
        probleme('/reponse/zones', 'reponse_unique'),
      );
      expect(
        erreurs('T08', (ex) {
          ex['donnees']['plusieurs'] = true;
          ex['reponse'] = {
            'zones': ['z1', 'z2'],
          };
        }),
        isEmpty,
      );
    });

    test('T47 : zone sans étiquette, étiquette sur deux zones, inconnus', () {
      expect(
        erreurs('T47', (ex) {
          ex['reponse'] = {
            'placements': [
              {'zone': 'z1', 'etiquette': 'e1'},
              {'zone': 'z1', 'etiquette': 'e1'},
            ],
          };
        }),
        unorderedEquals([
          probleme('/reponse/placements/1/zone', 'zone_sans_reponse'),
          probleme('/reponse/placements/1/etiquette', 'etiquette_reutilisee'),
          probleme('/reponse/placements', 'zone_sans_reponse'),
        ]),
      );
      expect(
        erreurs('T47', (ex) {
          ex['reponse']['placements'][1] = {'zone': 'z5', 'etiquette': 'e9'};
        }),
        containsAll([
          probleme('/reponse/placements/1/zone', 'reponse_element_inconnu'),
          probleme(
            '/reponse/placements/1/etiquette',
            'reponse_element_inconnu',
          ),
        ]),
      );
    });

    test('T47 : avertissements, aucune étiquette en trop, 7 zones en 1re', () {
      expect(
        avertissements(
          'T47',
          (ex) => (ex['donnees']['etiquettes'] as List).removeLast(),
        ).single,
        probleme('/donnees/etiquettes', 'etiquettes_sans_intrus'),
      );
      // Le schéma plafonne T47 à 6 zones : l'avertissement se voit sur T08.
      final a = avertissements('T08', (ex) {
        ex['id'] = 'fr-1-t1-u1-e01-x01';
        ex['donnees']['zones'] = [
          for (var i = 1; i <= 7; i++) zone('z$i', x: 0.1 * i, y: 0.1),
        ];
      });
      expect(a, hasLength(1));
      expect(a.single, probleme('/donnees/zones', 'elements_trop_nombreux'));
    });
  });
}
