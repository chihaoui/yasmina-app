import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  const genre = {
    'masculin': 'اِسْتَمِعْ إِلَى أَوَّلِ صَوْتٍ.',
    'feminin': 'اِسْتَمِعِي إِلَى أَوَّلِ صَوْتٍ.',
  };

  test('texte simple : identique pour les deux formes', () {
    expect(FormeAdresse.masculin.accorder('صَحِيحٌ'), 'صَحِيحٌ');
    expect(FormeAdresse.feminin.accorder('صَحِيحٌ'), 'صَحِيحٌ');
  });

  test('texte genré : variante de la forme demandée', () {
    expect(FormeAdresse.masculin.accorder(genre), genre['masculin']);
    expect(FormeAdresse.feminin.accorder(genre), genre['feminin']);
  });

  test('les noms correspondent aux clés du JSON', () {
    expect(FormeAdresse.values.map((f) => f.name), ['masculin', 'feminin']);
  });
}
