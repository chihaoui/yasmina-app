/// Les 12 moteurs du MVP, dans l'ordre de développement de l'atelier
/// (décision 34) : Choix, Glisser-déposer, Tracé, Manipulables, autres
/// moteurs du lot 1, puis les moteurs du lot 2. Les types de lot 2 d'un
/// moteur du lot 1 restent dans le groupe de leur moteur.
enum Moteur {
  choix('Choix'),
  glisserDeposer('Glisser-déposer'),
  trace('Tracé'),
  manipulables('Manipulables'),
  texte('Texte'),
  saisieNumerique('Saisie numérique'),
  sceneImage('Scène image'),
  revisionJeux('Révision et jeux'),
  mesureTemps('Mesure et temps'),
  grilleGraphiques('Grille et graphiques'),
  simulateur('Simulateur'),
  recit('Récit');

  const Moteur(this.nom);

  /// Nom en français (outils internes : atelier, back-office).
  final String nom;
}

/// État d'un type dans l'atelier.
enum EtatType {
  /// Le moteur sait le jouer : l'atelier ouvre le lecteur.
  jouable,

  /// Pas encore de moteur : l'atelier montre seulement les exemples.
  aVenir,
}

/// Modes du moteur (CLAUDE.md §4).
enum ModeExercice {
  /// Parcours normal de l'enfant.
  enfant,

  /// « Afficher la réponse », rejouer, sans progression enregistrée.
  apercu,

  /// Comme l'aperçu, avec rechargement quand le JSON change.
  edition,
}

/// Un type d'exercice du catalogue.
class TypeExercice {
  const TypeExercice(
    this.id,
    this.nom,
    this.moteur, {
    required this.lot,
    this.etat = EtatType.aVenir,
  });

  /// `T01` à `T63`.
  final String id;

  /// Nom en français.
  final String nom;

  final Moteur moteur;

  /// Lot de développement : 1 (jalon G1) ou 2 (jalon G2).
  final int lot;

  final EtatType etat;
}

/// Les 53 types du MVP, source unique pour l'app, l'aperçu web et le
/// back-office. Un type passe à [EtatType.jouable] quand son moteur est
/// prêt.
const typesExercices = <TypeExercice>[
  // Choix (lot 1).
  TypeExercice('T01', 'QCM', Moteur.choix, lot: 1),
  TypeExercice(
    'T02',
    'Vrai ou faux',
    Moteur.choix,
    lot: 1,
    etat: EtatType.jouable,
  ),
  TypeExercice('T03', 'Écoute et choisis', Moteur.choix, lot: 1),
  TypeExercice('T04', "Trouve l'intrus", Moteur.choix, lot: 1),
  TypeExercice('T05', 'Choix multiple', Moteur.choix, lot: 1),
  TypeExercice('T18', 'Forme de la lettre', Moteur.choix, lot: 1),
  TypeExercice('T19', 'Choisir la haraka', Moteur.choix, lot: 1),
  TypeExercice('T23', 'Comparer', Moteur.choix, lot: 1),
  TypeExercice('T24', 'Suites et motifs', Moteur.choix, lot: 1),
  TypeExercice('T45', "Barrer l'élément faux", Moteur.choix, lot: 1),
  TypeExercice('T46', 'Réponse puis justification', Moteur.choix, lot: 1),
  TypeExercice('T55', 'Paires minimales sonores', Moteur.choix, lot: 1),
  TypeExercice('T61', 'Résumé par sélection', Moteur.choix, lot: 1),
  // Glisser-déposer (lot 1).
  TypeExercice('T06', 'Texte à trous', Moteur.glisserDeposer, lot: 1),
  TypeExercice('T09', 'Association', Moteur.glisserDeposer, lot: 1),
  TypeExercice('T11', 'Tri en catégories', Moteur.glisserDeposer, lot: 1),
  TypeExercice('T12', 'Tableau de tri', Moteur.glisserDeposer, lot: 1),
  TypeExercice('T13', 'Remise en ordre', Moteur.glisserDeposer, lot: 1),
  TypeExercice('T14', "Séquence d'images", Moteur.glisserDeposer, lot: 1),
  TypeExercice(
    'T15',
    'Construire un mot (lettres)',
    Moteur.glisserDeposer,
    lot: 1,
  ),
  TypeExercice(
    'T16',
    'Construire un mot (syllabes)',
    Moteur.glisserDeposer,
    lot: 1,
  ),
  TypeExercice('T56', 'Racine et schème', Moteur.glisserDeposer, lot: 1),
  TypeExercice('T62', 'Frise chronologique', Moteur.glisserDeposer, lot: 1),
  // Tracé (lot 1).
  TypeExercice('T20', 'Tracé de lettre (non noté)', Moteur.trace, lot: 1),
  // Manipulables.
  TypeExercice('T25', 'Droite numérique', Moteur.manipulables, lot: 1),
  TypeExercice('T27', 'Blocs base 10', Moteur.manipulables, lot: 1),
  TypeExercice('T51', 'Cadre de 10', Moteur.manipulables, lot: 1),
  TypeExercice('T26', 'Monnaie', Moteur.manipulables, lot: 2),
  TypeExercice('T29', 'Fractions', Moteur.manipulables, lot: 2),
  TypeExercice('T52', 'Modèle en barres', Moteur.manipulables, lot: 2),
  // Texte (lot 1).
  TypeExercice('T07', 'Toucher les mots', Moteur.texte, lot: 1),
  TypeExercice('T17', 'Dictée au clavier', Moteur.texte, lot: 1),
  // Saisie numérique.
  TypeExercice('T22', 'Saisie numérique', Moteur.saisieNumerique, lot: 1),
  TypeExercice('T48', 'Calcul posé', Moteur.saisieNumerique, lot: 1),
  TypeExercice('T49', 'Saisie de fraction', Moteur.saisieNumerique, lot: 2),
  TypeExercice('T50', 'Fluidité chronométrée', Moteur.saisieNumerique, lot: 2),
  TypeExercice('T63', "Balance d'équivalence", Moteur.saisieNumerique, lot: 2),
  // Scène image.
  TypeExercice('T08', 'Hot spot sur image', Moteur.sceneImage, lot: 1),
  TypeExercice('T47', 'Étiqueter un schéma', Moteur.sceneImage, lot: 1),
  TypeExercice('T53', 'Écoute et place', Moteur.sceneImage, lot: 2),
  TypeExercice('T54', 'Écoute et colorie', Moteur.sceneImage, lot: 2),
  // Révision et jeux (lot 1).
  TypeExercice('T36', 'Flashcards', Moteur.revisionJeux, lot: 1),
  TypeExercice('T37', 'Memory', Moteur.revisionJeux, lot: 1),
  TypeExercice('T38', 'Mots mêlés', Moteur.revisionJeux, lot: 1),
  // Mesure et temps (lot 2).
  TypeExercice('T28', 'Horloge', Moteur.mesureTemps, lot: 2),
  TypeExercice('T30', 'Règle', Moteur.mesureTemps, lot: 2),
  // Grille et graphiques (lot 2).
  TypeExercice('T31', 'Lire un graphique', Moteur.grilleGraphiques, lot: 2),
  TypeExercice(
    'T32',
    'Construire un graphique',
    Moteur.grilleGraphiques,
    lot: 2,
  ),
  TypeExercice('T33', 'Symétrie', Moteur.grilleGraphiques, lot: 2),
  TypeExercice('T60', 'Codage de déplacement', Moteur.grilleGraphiques, lot: 2),
  // Simulateur (lot 2).
  TypeExercice('T34', 'Flotte ou coule', Moteur.simulateur, lot: 2),
  TypeExercice('T57', "Simulateur d'expérience", Moteur.simulateur, lot: 2),
  // Récit (lot 2).
  TypeExercice('T35', 'Histoire à choix', Moteur.recit, lot: 2),
];

/// Type d'id [id] (`T01`), ou `null` s'il ne fait pas partie du MVP.
TypeExercice? typeParId(String id) =>
    typesExercices.where((t) => t.id == id).firstOrNull;

/// Types de [moteur], dans l'ordre du registre.
List<TypeExercice> typesDuMoteur(Moteur moteur) =>
    typesExercices.where((t) => t.moteur == moteur).toList();
