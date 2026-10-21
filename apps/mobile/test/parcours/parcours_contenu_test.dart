import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/parcours/parcours.dart';

/// Le parcours d'arabe 1re T1 embarqué (A0-08) lu par l'app : 7 étapes dans
/// l'ordre de la carte, chaque exercice d'un type jouable que le lecteur
/// sait ouvrir.
void main() {
  late CatalogueParcours catalogue;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    catalogue = await CatalogueParcours.charger(rootBundle);
  });

  test('7 étapes d\'arabe 1re T1, dans l\'ordre des unités', () {
    final parcours = catalogue.pour(matiere: 'arabe', niveau: 1)!;
    expect(parcours.etapes.map((e) => e.id), [
      'ar-1-t1-u1-e01',
      'ar-1-t1-u1-e02',
      'ar-1-t1-u1-e03',
      'ar-1-t1-u1-e04',
      'ar-1-t1-u1-e05',
      'ar-1-t1-u2-e01',
      'ar-1-t1-u3-e01',
    ]);
    expect(parcours.parUnite.keys, [1, 2, 3]);
    expect(parcours.etapes.map((e) => e.estDefi ? '🏆' : e.lettre), [
      'ب',
      'ل',
      'م',
      'ر',
      '🏆',
      'د',
      'ف',
    ]);
    expect(parcours.etapes[0].formes, ['ب', 'بـ', 'ـبـ', 'ـب']);
    expect(catalogue.pour(matiere: 'maths', niveau: 1), isNull);
    expect(catalogue.pour(matiere: 'arabe', niveau: 2), isNull);
  });

  test('100 exercices, 4 séquences par lettre, un T17 ouvre أَكْتُبُ', () {
    final parcours = catalogue.pour(matiere: 'arabe', niveau: 1)!;
    var total = 0;
    for (final etape in parcours.etapes) {
      total += etape.nombreExercices;
      if (etape.estDefi) {
        expect(etape.sequences, hasLength(1));
        continue;
      }
      expect(etape.sequences, hasLength(4), reason: etape.id);
      final s4 = etape.sequences[3];
      expect(s4.titre, 'أَكْتُبُ');
      expect(etape.exercices[s4.exercices.first]!['type'], 'T17');
    }
    expect(total, 100);
  });

  test('chaque exercice est d\'un type jouable et le lecteur sait l\'ouvrir '
      '(contrôleur créé, réponse vide)', () {
    final parcours = catalogue.pour(matiere: 'arabe', niveau: 1)!;
    for (final etape in parcours.etapes) {
      for (final x in etape.deroule) {
        final type = x.exercice['type'] as String;
        expect(typeParId(type)?.etat, EtatType.jouable, reason: x.id);
        final gabarit = gabaritPour(type);
        expect(gabarit, isNotNull, reason: x.id);
        final controleur = gabarit!.creerControleur(
          x.exercice,
          const ConfigExercice(
            langue: 'ar',
            formeAdresse: FormeAdresse.feminin,
            graine: 1,
          ),
        );
        expect(controleur.complete, isFalse, reason: x.id);
        controleur.dispose();
      }
    }
  });
}
