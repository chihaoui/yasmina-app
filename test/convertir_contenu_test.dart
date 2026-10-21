@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/convertir_contenu.dart';

/// Le convertisseur du parcours d'arabe 1re T1 (A0-08) : empreintes
/// conformes, fichiers produits à jour, textes arabes de la source
/// inchangés, T20 remplacé par un T17 au clavier réduit.
void main() {
  final racine = Directory.current.path;
  final source = jsonDecode(
    File('$racine/$cheminSource').readAsStringSync(),
  ) as Map<String, dynamic>;
  final etapes = convertirParcours(source);

  group('sha256', () {
    test('vecteurs connus', () {
      expect(
        sha256Hex(utf8.encode('')),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
      expect(
        sha256Hex(utf8.encode('abc')),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      // Deux blocs de 64 octets.
      expect(
        sha256Hex(
          utf8.encode(
            'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq',
          ),
        ),
        '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
      );
    });

    test('empreintes relues le 17 oct. 2026 (x01 et x02) retrouvées', () {
      final exercices = (etapes['ar-1-t1-u1-e01']!['exercices'] as List)
          .cast<Map<String, dynamic>>();
      Map<String, dynamic> x(String id) =>
          exercices.firstWhere((e) => e['id'] == 'ar-1-t1-u1-e01-$id');
      expect(
        x('x01')['empreinte'],
        'sha256:c95ff8d173e8f25ced8216e3fef9b9319fd7a7a4db2da093ab49aa18ff7992b8',
      );
      expect(x('x01')['statut'], 'valide');
      expect(
        x('x02')['empreinte'],
        'sha256:c056f6b567aaaeb3e3bb48b12e06761637d047a14abbf7bf8c1d65f373286642',
      );
      expect(x('x02')['statut'], 'valide');
    });
  });

  test('les fichiers de apps/mobile/assets/content sont à jour', () {
    expect(etapes, hasLength(7));
    for (final MapEntry(key: id, value: etape) in etapes.entries) {
      final fichier = File('$racine/${cheminEtape(id)}');
      expect(fichier.existsSync(), isTrue, reason: fichier.path);
      expect(
        fichier.readAsStringSync(),
        texteEtape(etape),
        reason:
            'relancer dart run tool/convertir_contenu.dart (${fichier.path})',
      );
    }
  });

  test('7 étapes, 100 exercices, ids uniques, aucun T20, tout en brouillon '
      'sauf x01 et x02', () {
    var total = 0;
    final ids = <String>{};
    for (final etape in etapes.values) {
      for (final ex in (etape['exercices'] as List).cast<Map>()) {
        total++;
        expect(ids.add(ex['id'] as String), isTrue, reason: '${ex['id']}');
        expect(ex['type'], isNot('T20'));
        expect(ex['langue'], 'ar');
        expect(ex['version'], 1);
        expect(
          ex['statut'],
          ex['id'] == 'ar-1-t1-u1-e01-x01' || ex['id'] == 'ar-1-t1-u1-e01-x02'
              ? 'valide'
              : 'brouillon',
        );
      }
    }
    expect(total, 100);
  });

  test('chaque exercice est cité une fois dans les séquences de son étape', () {
    for (final etape in etapes.values) {
      final cites = [
        for (final s in (etape['etape'] as Map)['sequences'] as List)
          ...(s as Map)['exercices'] as List,
      ];
      final ids = [for (final ex in etape['exercices'] as List) ex['id']];
      expect(
        cites,
        unorderedEquals(ids),
        reason: '${(etape['etape'] as Map)['id']}',
      );
      expect(cites.toSet(), hasLength(cites.length));
    }
  });

  test('T20 remplacé dans la séquence أَكْتُبُ par un T17 au clavier réduit '
      "d'un mot de l'étape, avec un id nouveau", () {
    final blocs = (source['etapes'] as List).cast<Map<String, dynamic>>();
    for (final bloc in blocs) {
      final idEtape = (bloc['etape'] as Map)['id'] as String;
      final sourcesT20 = (bloc['exercices'] as List)
          .cast<Map>()
          .where((x) => x['type'] == 'T20')
          .toList();
      final etape = etapes[idEtape]!;
      final exercices = (etape['exercices'] as List)
          .cast<Map<String, dynamic>>();
      final dictees = exercices.where((x) => x['type'] == 'T17').toList();
      expect(dictees, hasLength(sourcesT20.length), reason: idEtape);
      if (sourcesT20.isEmpty) continue;
      final t20 = sourcesT20.single;
      final t17 = dictees.single;
      // Id nouveau, jamais celui du T20.
      expect(t17['id'], isNot(t20['id']));
      final idsSource = bloc['exercices'].map((x) => x['id']).toSet();
      expect(idsSource, isNot(contains(t17['id'])));
      // À la place du T20 dans la 4e séquence.
      final s4 = ((etape['etape'] as Map)['sequences'] as List)
          .cast<Map>()
          .firstWhere((s) => (s['id'] as String).endsWith('-s4'));
      expect((s4['titre'] as String), 'أَكْتُبُ');
      expect((s4['exercices'] as List).first, t17['id']);
      // Clavier réduit : lettres du mot et 5 en trop, mot commençant par la
      // lettre de l'étape, normalisation sans harakat.
      final donnees = t17['donnees'] as Map;
      final mot = (donnees['ecoute'] as Map)['texte'] as String;
      final lettre = (t20['donnees'] as Map)['lettre'] as String;
      expect(mot, startsWith(lettre));
      expect(donnees['clavier'], 'reduit');
      final touches = (donnees['lettres'] as String).runes.toSet();
      final nues = lettresNues(mot).map((l) => l.runes.single).toSet();
      expect(touches.containsAll(nues), isTrue);
      expect(touches.length - nues.length, lettresEnTrop);
      expect((t17['reponse'] as Map)['texte'], mot);
      expect(t17['normalisation'], ['harakat_ignorees']);
      // Le mot appartient à l'étape (un texte de la source le contient).
      expect(jsonEncode(bloc), contains(mot));
    }
  });

  test('aucun texte arabe de la source ne change (hors T20 et champs sans '
      'place dans le schéma)', () {
    final blocs = (source['etapes'] as List).cast<Map<String, dynamic>>();
    final arabe = RegExp('[ء-ي]');
    for (final bloc in blocs) {
      final idEtape = (bloc['etape'] as Map)['id'] as String;
      final sortie = texteEtape(etapes[idEtape]!);
      final textes = <String>[];
      void collecter(Object? v, String chemin) {
        if (v is String) {
          if (arabe.hasMatch(v)) textes.add(v);
        } else if (v is Map) {
          v.forEach((k, e) => collecter(e, '$chemin/$k'));
        } else if (v is List) {
          for (final e in v) {
            collecter(e, chemin);
          }
        }
      }

      collecter(bloc['etape'], '/etape');
      for (final x
          in (bloc['exercices'] as List).cast<Map<String, dynamic>>()) {
        if (x['type'] == 'T20') continue;
        final copie = jsonDecode(jsonEncode(x)) as Map<String, dynamic>;
        // Mot à écouter de T02 : pas d'écoute dans le moteur Vrai ou faux.
        if (x['type'] == 'T02') (copie['donnees'] as Map).remove('audio');
        collecter(copie, '/exercices');
      }
      for (final t in textes) {
        // Le JSON produit échappe seulement les guillemets et les sauts de
        // ligne : un texte à plusieurs lignes est cherché ligne par ligne.
        for (final ligne in t.split('\n')) {
          expect(
            sortie,
            contains(jsonEncode(ligne).replaceAll(RegExp(r'^"|"$'), '')),
            reason: '$idEtape : « $ligne » absent de la sortie',
          );
        }
      }
    }
  });

  test('T18 : lettre et position lues sur la forme attendue, T19 : haraka '
      'lue sur la bonne réponse', () {
    final exercices = (etapes['ar-1-t1-u1-e01']!['exercices'] as List)
        .cast<Map<String, dynamic>>();
    final t18 = exercices.firstWhere((x) => x['type'] == 'T18');
    expect((t18['donnees'] as Map)['lettre'], 'ب');
    expect((t18['donnees'] as Map)['position'], 'debut');
    final t19 = exercices.firstWhere((x) => x['type'] == 'T19');
    expect(t19['gabarit'], 'lettre-vocalisee');
    expect((t19['donnees'] as Map)['haraka'], 'fatha');
    // ر n'a que deux formes : isolée et finale.
    final e04 = (etapes['ar-1-t1-u1-e04']!['exercices'] as List)
        .cast<Map<String, dynamic>>();
    final t18r = e04.firstWhere((x) => x['type'] == 'T18');
    expect((t18r['donnees'] as Map)['lettre'], 'ر');
    expect((t18r['donnees'] as Map)['position'], 'fin');
  });

  test('ids des éléments : une lettre répétée prend un élément libre', () {
    expect(idsParTexte(['ب', 'ا', 'ب'], ['ب', 'ا', 'ب']), ['e1', 'e2', 'e3']);
    expect(() => idsParTexte(['ب', 'ا'], ['ب', 'ب']), throwsFormatException);
  });
}
