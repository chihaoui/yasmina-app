import 'dart:convert';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  group('exemples réels (schema/exemples)', () {
    final catalogue = CatalogueExemples();

    test('tous valides et rattachés à un moteur du registre (Choix, '
        'Glisser-déposer, Tracé, Manipulables)', () {
      expect(catalogue.tous, hasLength(exemplesEduContent.length));
      for (final e in catalogue.tous) {
        expect(e.estValide, isTrue, reason: '${e.chemin} : ${e.erreurs}');
        expect(
          typeParId(e.idType!)!.moteur,
          isIn([
            Moteur.choix,
            Moteur.glisserDeposer,
            Moteur.trace,
            Moteur.manipulables,
          ]),
          reason: e.chemin,
        );
      }
      expect(catalogue.nonRattaches, isEmpty);
    });

    test('T01 a 4 exemples, T19 et T06 en ont 2, T20 en a 3, T07 aucun', () {
      expect(catalogue.exemplesDuType('T01'), hasLength(4));
      expect(catalogue.exemplesDuType('T19'), hasLength(2));
      expect(catalogue.exemplesDuType('T06'), hasLength(2));
      expect(catalogue.exemplesDuType('T20'), hasLength(3));
      expect(catalogue.exemplesDuType('T07'), isEmpty);
    });

    test('gabarit, langue et consigne (masculin si genrée)', () {
      final scene = catalogue
          .exemplesDuType('T01')
          .firstWhere((e) => e.fichier == 'T01-qcm-scene.json');
      expect(scene.gabarit, 'qcm-scene');
      expect(scene.langue, 'ar');
      expect(scene.consigne, 'مَاذَا تَأْخُذُ سَلْمَى مَعَهَا؟');
    });
  });

  group('exemples en erreur : jamais d\'exception', () {
    final valide = exemplesEduContent['choix/T04-intrus.json']!;
    final invalide = jsonDecode(valide) as Map<String, dynamic>
      ..['reponse'] = {
        'choix': ['c9'],
      };
    final catalogue = CatalogueExemples({
      'choix/T04-ok.json': valide,
      'choix/T04-illisible.json': '{"type": ',
      'choix/T04-invalide.json': jsonEncode(invalide),
      'choix/T05-mauvais-type.json': valide,
      'choix/T99-hors-registre.json': valide,
      'choix/sans-prefixe.json': valide,
      'choix/T02-liste.json': '[]',
    });

    ExempleType exemple(String fichier) =>
        catalogue.tous.firstWhere((e) => e.fichier == fichier);

    test('JSON illisible, rangé sous son type', () {
      final e = exemple('T04-illisible.json');
      expect(e.estValide, isFalse);
      expect(e.idType, 'T04');
      expect(e.erreurs.single, startsWith('JSON illisible'));
      expect(catalogue.exemplesDuType('T04'), hasLength(3));
    });

    test('exemple invalide : erreur du validateur', () {
      final e = exemple('T04-invalide.json');
      expect(e.estValide, isFalse);
      expect(e.erreurs.single, contains('reponse_choix_inconnu'));
    });

    test('type du JSON différent du nom de fichier', () {
      final e = exemple('T05-mauvais-type.json');
      expect(e.estValide, isFalse);
      expect(e.erreurs.single, contains('T05'));
    });

    test('JSON qui n\'est pas un objet', () {
      expect(exemple('T02-liste.json').erreurs.single, contains('objet'));
    });

    test('préfixe absent ou hors registre : non rattachés', () {
      expect(catalogue.nonRattaches.map((e) => e.fichier), [
        'T99-hors-registre.json',
        'sans-prefixe.json',
      ]);
      expect(exemple('T04-ok.json').estValide, isTrue);
    });
  });
}
