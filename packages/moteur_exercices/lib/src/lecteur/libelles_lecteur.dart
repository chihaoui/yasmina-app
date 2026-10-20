import '../forme_adresse.dart';

/// Libellés du lecteur, dans la langue de l'exercice. En arabe, ceux qui
/// s'adressent à l'enfant sont genrés comme les consignes
/// (docs/moteurs/choix.md §6).
class LibellesLecteur {
  const LibellesLecteur._({
    required this.verifier,
    required this.continuer,
    required this.ecouter,
    required this.validation,
    required this.indice,
    required this.explication,
    required this.vrai,
    required this.faux,
    required this.effacer,
    required this.imageNumerotee,
  });

  factory LibellesLecteur.pour(String langue, FormeAdresse forme) {
    final feminin = forme == FormeAdresse.feminin;
    return switch (langue) {
      'ar' => LibellesLecteur._(
        verifier: feminin ? 'تَحَقَّقِي' : 'تَحَقَّقْ',
        continuer: feminin ? 'وَاصِلِي' : 'وَاصِلْ',
        ecouter: feminin ? 'اِسْمَعِي' : 'اِسْمَعْ',
        validation: feminin ? 'أَحْسَنْتِ' : 'أَحْسَنْتَ',
        indice: 'تَلْمِيحٌ',
        explication: 'لِنَتَعَلَّمْ',
        vrai: 'صَحِيحٌ',
        faux: 'خَطَأٌ',
        effacer: feminin ? 'اِمْسَحِي' : 'اِمْسَحْ',
        imageNumerotee: (n) => 'صُورَةٌ $n',
      ),
      'en' => LibellesLecteur._(
        verifier: 'Check',
        continuer: 'Continue',
        ecouter: 'Listen',
        validation: 'Well done',
        indice: 'Hint',
        explication: "Let's learn",
        vrai: 'True',
        faux: 'False',
        effacer: 'Erase',
        imageNumerotee: (n) => 'picture $n',
      ),
      _ => LibellesLecteur._(
        verifier: 'Vérifier',
        continuer: 'Continuer',
        ecouter: 'Écouter',
        validation: 'Bravo',
        indice: 'Indice',
        explication: 'Explication',
        vrai: 'Vrai',
        faux: 'Faux',
        effacer: 'Effacer',
        imageNumerotee: (n) => 'image $n',
      ),
    };
  }

  final String verifier;
  final String continuer;
  final String ecouter;
  final String validation;
  final String indice;
  final String explication;
  final String vrai;
  final String faux;

  /// Effacer (clavier et pavé du moteur, dernière lettre d'un mot
  /// construit), genré en arabe.
  final String effacer;

  /// Libellé neutre d'une tuile en image ou en emoji seul (numéro à partir
  /// de 1) : le lecteur d'écran ne doit pas donner la réponse.
  final String Function(int n) imageNumerotee;

  String image(int n) => imageNumerotee(n);

  /// Tous les libellés (tests des conventions d'écriture).
  List<String> get tous => [
    verifier,
    continuer,
    ecouter,
    validation,
    indice,
    explication,
    vrai,
    faux,
    effacer,
    image(1),
  ];
}
