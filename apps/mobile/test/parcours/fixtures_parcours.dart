import 'package:yasmina/parcours/parcours.dart';

/// Un T02 valide en arabe (réponse « vrai »), pour jouer une étape de test
/// sans le contenu embarqué.
Map<String, dynamic> exerciceT02(String id, String affirmation) => {
  'id': id,
  'type': 'T02',
  'gabarit': 'vrai-faux-texte',
  'competence': 'ar-essai',
  'critere': 'C1',
  'niveau_critere': 'minimal',
  'langue': 'ar',
  'consigne': {'texte': 'هَلْ هَذِهِ الْجُمْلَةُ صَحِيحَةٌ؟'},
  'donnees': {'affirmation': affirmation},
  'reponse': {'valeur': true},
  'feedbacks': {
    'reussite': 'إِجَابَتُكَ صَحِيحَةٌ.',
    'indice': 'اِنْظُرْ جَيِّدًا.',
    'explication': 'هَذَا هُوَ الْجَوَابُ.',
  },
  'empreinte':
      'sha256:0000000000000000000000000000000000000000000000000000000000000000',
  'statut': 'brouillon',
  'version': 1,
};

/// Une étape d'arabe 1re T1 : [sequences] séquences de [parSequence]
/// exercices T02 chacune.
Etape etapeTest(
  String id, {
  required int unite,
  required int ordre,
  required String titre,
  int sequences = 1,
  int parSequence = 2,
}) {
  final exercices = <Map<String, dynamic>>[];
  final listeSequences = <Map<String, dynamic>>[];
  var n = 0;
  for (var s = 1; s <= sequences; s++) {
    final ids = <String>[];
    for (var i = 0; i < parSequence; i++) {
      n++;
      final idExercice = '$id-x${n.toString().padLeft(2, '0')}';
      ids.add(idExercice);
      exercices.add(exerciceT02(idExercice, 'بَابٌ كَلِمَةٌ. ($n)'));
    }
    listeSequences.add({
      'id': '$id-s$s',
      'titre': 'أَكْتَشِفُ $s',
      'exercices': ids,
    });
  }
  return Etape.depuisJson({
    'etape': {
      'id': id,
      'matiere': 'arabe',
      'niveau': 1,
      'trimestre': 1,
      'unite': unite,
      'ordre': ordre,
      'langue': 'ar',
      'titre': titre,
      'sequences': listeSequences,
    },
    'exercices': exercices,
  });
}

/// Deux étapes : la lettre ب (2 exercices) puis le défi (1 exercice).
CatalogueParcours catalogueTest() => CatalogueParcours.depuisEtapes([
  etapeTest('ar-1-t1-u1-e01', unite: 1, ordre: 1, titre: 'حَرْفُ الْبَاءِ'),
  etapeTest(
    'ar-1-t1-u1-e02',
    unite: 1,
    ordre: 2,
    titre: 'تَحَدِّي الْوَحْدَةِ الْأُولَى',
    parSequence: 1,
  ),
]);
