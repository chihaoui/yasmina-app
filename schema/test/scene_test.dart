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

/// T53 et T54 en anglais : la consigne entendue est en anglais.
Map<String, dynamic> exerciceAudio(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) => exercice(type, donnees, reponse)
  ..['id'] = 'en-4-t1-u1-e01-x01'
  ..['langue'] = 'en'
  ..['competence'] = 'en-essai'
  ..['consigne'] = {'texte': 'Listen.'};

final validesAudio = <String, Map<String, dynamic> Function()>{
  'T53': () => exerciceAudio(
    'T53',
    {
      'scene': scene(),
      'objet': {'emoji': '🐱', 'libelle': 'the cat'},
      'zones': [zone('z1'), zone('z2', x: 0.6)],
      'ecoute': {'texte': 'Put the cat on the table.'},
    },
    {'zone': 'z1'},
  ),
  'T54': () => exerciceAudio(
    'T54',
    {
      'objets': [
        {'id': 'o1', 'emoji': '⚽', 'libelle': 'ball'},
        {'id': 'o2', 'emoji': '🚗', 'libelle': 'car'},
      ],
      'couleurs': ['red', 'blue'],
      'ecoute': {'texte': 'Colour the ball red.'},
    },
    {
      'coloriages': [
        {'objet': 'o1', 'couleur': 'red'},
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
  test('T53 et T54 : exemples valides, zone inconnue, objet ou couleur '
      'inconnus, objet colorié deux fois, nom en double', () {
    for (final construire in validesAudio.values) {
      final r = validerExercice(construire());
      expect(r.erreurs, isEmpty, reason: '$r');
      expect(r.avertissements, isEmpty, reason: '$r');
    }
    List<ProblemeValidation> erreursAudio(
      String type,
      void Function(Map<String, dynamic> ex) f,
    ) {
      final ex = validesAudio[type]!();
      f(ex);
      return validerExercice(ex).erreurs;
    }

    expect(
      erreursAudio('T53', (ex) => ex['reponse'] = {'zone': 'z9'}).single,
      probleme('/reponse/zone', 'reponse_element_inconnu'),
    );
    expect(
      erreursAudio('T53', (ex) => ex['donnees'].remove('ecoute')),
      contains(probleme('/donnees', 'obligatoire')),
    );
    expect(
      erreursAudio(
        'T54',
        (ex) => ex['reponse'] = {
          'coloriages': [
            {'objet': 'o3', 'couleur': 'green'},
          ],
        },
      ),
      unorderedEquals([
        probleme('/reponse/coloriages/0/objet', 'reponse_element_inconnu'),
        probleme('/reponse/coloriages/0/couleur', 'reponse_element_inconnu'),
      ]),
    );
    expect(
      erreursAudio(
        'T54',
        (ex) => ex['reponse'] = {
          'coloriages': [
            {'objet': 'o1', 'couleur': 'red'},
            {'objet': 'o1', 'couleur': 'blue'},
          ],
        },
      ).single,
      probleme('/reponse/coloriages/1/objet', 'element_duplique'),
    );
    expect(
      erreursAudio(
        'T54',
        (ex) => ex['donnees']['objets'][1]['libelle'] = 'ball',
      ).single,
      probleme('/donnees/objets/1/libelle', 'element_duplique'),
    );
    expect(
      erreursAudio('T54', (ex) => ex['donnees']['couleurs'] = ['red', 'gold']),
      contains(probleme('/donnees/couleurs/1', 'valeur_non_autorisee')),
    );
  });

  test('T34 et T57 (moteur Simulateur) : exemples valides et règles', () {
    Map<String, dynamic> simulateur(String type, String decor) => exerciceAudio(
      type,
      {
        'decor': decor,
        'issues': {
          'a': {'libelle': 'floats'},
          'b': {'libelle': 'sinks'},
        },
        'objets': [
          {'id': 'o1', 'emoji': '🪵', 'libelle': 'wood'},
          {'id': 'o2', 'emoji': '🪨', 'libelle': 'stone'},
        ],
      },
      {
        'resultats': [
          {'objet': 'o1', 'issue': 'a'},
          {'objet': 'o2', 'issue': 'b'},
        ],
      },
    )..['competence'] = 'en-essai';
    for (final (type, decor) in [('T34', 'eau'), ('T57', 'circuit')]) {
      final r = validerExercice(simulateur(type, decor));
      expect(r.erreurs, isEmpty, reason: '$type : $r');
      expect(r.avertissements, isEmpty, reason: '$type : $r');
    }
    List<ProblemeValidation> erreursDe(
      String type,
      String decor,
      void Function(Map<String, dynamic> ex) f,
    ) {
      final ex = simulateur(type, decor);
      f(ex);
      return validerExercice(ex).erreurs;
    }

    expect(
      erreursDe('T34', 'circuit', (_) {}).single,
      probleme('/donnees/decor', 'decor_attendu'),
    );
    expect(
      erreursDe(
        'T57',
        'aucun',
        (ex) => ex['donnees']['objets'].add({
          'id': 'o3',
          'emoji': '🍎',
          'libelle': 'apple',
        }),
      ).single,
      probleme('/reponse/resultats', 'resultats_incomplets'),
    );
    expect(
      erreursDe(
        'T57',
        'aucun',
        (ex) => ex['reponse']['resultats'][1]['objet'] = 'o1',
      ),
      unorderedEquals([
        probleme('/reponse/resultats/1/objet', 'element_duplique'),
        probleme('/reponse/resultats', 'resultats_incomplets'),
      ]),
    );
    expect(
      erreursDe(
        'T57',
        'aucun',
        (ex) => ex['donnees']['objets'][1]['libelle'] = 'wood',
      ).single,
      probleme('/donnees/objets/1/libelle', 'element_duplique'),
    );
    expect(
      erreursDe('T57', 'aucun', (ex) => ex['donnees']['decor'] = 'feu'),
      contains(probleme('/donnees/decor', 'valeur_non_autorisee')),
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

    test('T47 : deux zones du même côté à la même hauteur : cases '
        'd\'étiquettes superposées', () {
      // z1 (centre x 0,2) et z2 (centre x 0,4) sont toutes deux à gauche,
      // à la même hauteur : refusé. z2 à droite (x 0,7) : accepté.
      final ex = valides['T47']!();
      final zones = (ex['donnees']['zones'] as List)
          .cast<Map<String, dynamic>>();
      zones[0]
        ..['x'] = 0.1
        ..['y'] = 0.3;
      zones[1]
        ..['x'] = 0.3
        ..['y'] = 0.34;
      expect(
        validerExercice(ex).erreurs,
        contains(probleme('/donnees/zones/1', 'etiquettes_superposees')),
      );
      zones[1]['x'] = 0.6;
      expect(
        validerExercice(ex).erreurs
            .where((p) => p.code == 'etiquettes_superposees'),
        isEmpty,
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
