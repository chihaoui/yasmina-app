// Règles qu'un JSON Schema ne sait pas exprimer. Elles ne tournent que sur un
// JSON déjà conforme au schéma : les types et les champs obligatoires sont
// donc garantis.
//
// Aucune normalisation Unicode (NFC, NFD) n'est appliquée aux textes : elle
// réordonnerait shadda et fatha. Les textes sont lus, jamais modifiés.

import 'probleme.dart';

const _codeMatiere = {
  'arabe': 'ar',
  'francais': 'fr',
  'anglais': 'en',
  'maths': 'ma',
  'eveil': 'ev',
};

/// Langue imposée par chaque matière (maths et éveil en arabe).
const _langueMatiere = {
  'arabe': 'ar',
  'francais': 'fr',
  'anglais': 'en',
  'maths': 'ar',
  'eveil': 'ar',
};

/// Langue imposée par le code matière qui préfixe une compétence.
const _langueCodeMatiere = {
  'ar': 'ar',
  'fr': 'fr',
  'en': 'en',
  'ma': 'ar',
  'ev': 'ar',
};

const _nomMatiere = {
  'arabe': "d'arabe",
  'francais': 'de français',
  'anglais': "d'anglais",
  'maths': 'de maths',
  'eveil': "d'éveil",
};

const _nomLangue = {'ar': 'arabe', 'fr': 'français', 'en': 'anglais'};

/// Nombre de séquences prévu par le parcours (avertissement seulement).
const sequencesParEtape = 4;

/// Règles d'une étape complète.
List<ProblemeValidation> reglesEtape(Map<String, dynamic> racine) {
  final problemes = <ProblemeValidation>[];
  void erreur(String chemin, String code, String message) => problemes.add(
    ProblemeValidation(chemin: chemin, code: code, message: message),
  );
  void avertissement(String chemin, String code, String message) =>
      problemes.add(
        ProblemeValidation(
          chemin: chemin,
          code: code,
          message: message,
          gravite: Gravite.avertissement,
        ),
      );

  final generation = racine['generation'] as Map<String, dynamic>;
  final etape = racine['etape'] as Map<String, dynamic>;
  final exercices = (racine['exercices'] as List).cast<Map<String, dynamic>>();
  final sequences = (etape['sequences'] as List).cast<Map<String, dynamic>>();
  final matiere = etape['matiere'] as String;
  final langue = etape['langue'] as String;
  final etapeId = etape['id'] as String;

  // Date réelle.
  final date = generation['date'] as String;
  if (!_dateExiste(date)) {
    erreur(
      '/generation/date',
      'date_invalide',
      "la date « $date » n'existe pas.",
    );
  }

  // Cohérence des id avec les champs.
  final ordre = (etape['ordre'] as int).toString().padLeft(2, '0');
  final idAttendu =
      '${_codeMatiere[matiere]}-${etape['niveau']}-t${etape['trimestre']}'
      '-u${etape['unite']}-e$ordre';
  if (etapeId != idAttendu) {
    erreur(
      '/etape/id',
      'id_incoherent',
      "l'id « $etapeId » ne correspond pas aux champs de l'étape "
          '(attendu « $idAttendu »).',
    );
  }
  final prefixeGeneration = 'gen-$etapeId-${date.replaceAll('-', '')}-';
  final generationId = generation['id'] as String;
  if (!generationId.startsWith(prefixeGeneration)) {
    erreur(
      '/generation/id',
      'id_incoherent',
      "l'id « $generationId » doit commencer par « $prefixeGeneration » "
          "(id de l'étape et date de génération).",
    );
  }

  // Langue de l'étape imposée par la matière.
  final langueAttendue = _langueMatiere[matiere]!;
  if (langue != langueAttendue) {
    erreur(
      '/etape/langue',
      'langue_matiere',
      'une étape ${_nomMatiere[matiere]} doit être en '
          '${_nomLangue[langueAttendue]} ($langueAttendue), '
          'pas en ${_nomLangue[langue]} ($langue).',
    );
  }

  // Id uniques sur toute l'étape, préfixés par l'id de l'étape.
  final premiers = <String, String>{};
  void enregistrer(String id, String chemin, String prefixe) {
    final deja = premiers[id];
    if (deja != null) {
      erreur(
        chemin,
        'id_duplique',
        "l'id « $id » est déjà utilisé (première occurrence : $deja).",
      );
    } else {
      premiers[id] = chemin;
    }
    if (!id.startsWith(prefixe)) {
      erreur(
        chemin,
        'id_incoherent',
        "l'id « $id » doit commencer par « $prefixe » (id de l'étape).",
      );
    }
  }

  for (var i = 0; i < sequences.length; i++) {
    enregistrer(
      sequences[i]['id'] as String,
      '/etape/sequences/$i/id',
      '$etapeId-s',
    );
  }
  final idsExercices = <String>{};
  for (var i = 0; i < exercices.length; i++) {
    final id = exercices[i]['id'] as String;
    idsExercices.add(id);
    enregistrer(id, '/exercices/$i/id', '$etapeId-x');
  }

  // Références des séquences.
  final sequenceDe = <String, String>{};
  for (var i = 0; i < sequences.length; i++) {
    final sequenceId = sequences[i]['id'] as String;
    final cites = (sequences[i]['exercices'] as List).cast<String>();
    for (var j = 0; j < cites.length; j++) {
      final id = cites[j];
      final chemin = '/etape/sequences/$i/exercices/$j';
      if (!idsExercices.contains(id)) {
        erreur(
          chemin,
          'id_inconnu',
          "l'exercice « $id » cité par la séquence n'existe pas dans exercices.",
        );
      } else if (sequenceDe.containsKey(id)) {
        erreur(
          chemin,
          'exercice_en_double',
          "l'exercice « $id » est déjà dans la séquence « ${sequenceDe[id]} ».",
        );
      } else {
        sequenceDe[id] = sequenceId;
      }
    }
  }
  if (sequences.length != sequencesParEtape) {
    avertissement(
      '/etape/sequences',
      'sequences_nombre',
      "l'étape a ${sequences.length} séquence(s) au lieu des "
          '$sequencesParEtape prévues par le parcours.',
    );
  }

  // Exercices.
  final code = _codeMatiere[matiere]!;
  for (var i = 0; i < exercices.length; i++) {
    final ex = exercices[i];
    final chemin = '/exercices/$i';
    if (!sequenceDe.containsKey(ex['id'])) {
      avertissement(
        '$chemin/id',
        'exercice_orphelin',
        "l'exercice « ${ex['id']} » n'est cité dans aucune séquence.",
      );
    }
    if (ex['langue'] != langue) {
      erreur(
        '$chemin/langue',
        'langue_incoherente',
        "la langue de l'exercice (${ex['langue']}) doit être celle de "
            "l'étape ($langue).",
      );
    }
    final competence = ex['competence'] as String;
    if (!competence.startsWith('$code-')) {
      erreur(
        '$chemin/competence',
        'competence_matiere',
        "la compétence « $competence » doit commencer par « $code- » "
            "(matière de l'étape).",
      );
    }
    problemes.addAll(reglesExercice(ex, chemin));
  }

  // Harakat en 1re et 2e année d'arabe (ou de maths et d'éveil, en arabe).
  final niveau = etape['niveau'] as int;
  if (langue == 'ar' && niveau <= 2) {
    final annee = niveau == 1 ? '1re' : '${niveau}e';
    final textes = <(String, String)>[
      ('/etape/titre', etape['titre'] as String),
      for (var i = 0; i < sequences.length; i++)
        ('/etape/sequences/$i/titre', sequences[i]['titre'] as String),
    ];
    for (var i = 0; i < exercices.length; i++) {
      _collecterTextes(exercices[i], '/exercices/$i', textes);
    }
    for (final (chemin, texte) in textes) {
      if (_contientLettreArabe(texte) && !_contientHaraka(texte)) {
        avertissement(
          chemin,
          'harakat_manquantes',
          'texte arabe sans harakat en $annee année : « $texte ».',
        );
      }
    }
  }

  return problemes;
}

/// Règles propres à un exercice. Avec [seul], l'exercice est validé hors de
/// son étape (aperçu web) : sa langue est alors contrôlée par rapport au code
/// matière de sa compétence.
List<ProblemeValidation> reglesExercice(
  Map<String, dynamic> ex,
  String chemin, {
  bool seul = false,
}) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );

  final type = ex['type'] as String;
  if (type == 'T01' || type == 'T05') {
    final choix = ((ex['donnees'] as Map<String, dynamic>)['choix'] as List)
        .cast<Map<String, dynamic>>();
    final ids = <String>{};
    final textes = <String>{};
    for (var k = 0; k < choix.length; k++) {
      final id = choix[k]['id'] as String;
      if (!ids.add(id)) {
        erreur(
          '$chemin/donnees/choix/$k/id',
          'choix_duplique',
          'deux choix ont le même id « $id ».',
        );
      }
      final texte = choix[k]['texte'];
      if (texte is String && !textes.add(texte)) {
        erreur(
          '$chemin/donnees/choix/$k/texte',
          'choix_duplique',
          'deux choix ont le même texte « $texte ».',
        );
      }
    }
    final bons = ((ex['reponse'] as Map<String, dynamic>)['choix'] as List)
        .cast<String>();
    for (var k = 0; k < bons.length; k++) {
      if (!ids.contains(bons[k])) {
        erreur(
          '$chemin/reponse/choix/$k',
          'reponse_choix_inconnu',
          'la réponse désigne le choix « ${bons[k]} », absent de donnees.choix.',
        );
      }
    }
    if (type == 'T01' && bons.length != 1) {
      erreur(
        '$chemin/reponse/choix',
        'reponse_t01_unique',
        'un T01 a exactement une bonne réponse (ici ${bons.length}). '
            'Pour plusieurs bonnes réponses, utiliser T05.',
      );
    }
  }

  if (seul) {
    final competence = ex['competence'] as String;
    final code = competence.split('-').first;
    final attendue = _langueCodeMatiere[code]!;
    if (ex['langue'] != attendue) {
      erreur(
        '$chemin/langue',
        'langue_competence',
        'la compétence « $competence » impose la langue $attendue, '
            'pas ${ex['langue']}.',
      );
    }
  }
  return problemes;
}

bool _dateExiste(String date) {
  final parties = date.split('-').map(int.parse).toList();
  final d = DateTime.utc(parties[0], parties[1], parties[2]);
  return d.year == parties[0] && d.month == parties[1] && d.day == parties[2];
}

void _collecterTextes(
  Object? valeur,
  String chemin,
  List<(String, String)> textes,
) {
  if (valeur is String) {
    textes.add((chemin, valeur));
  } else if (valeur is Map) {
    for (final entree in valeur.entries) {
      _collecterTextes(entree.value, '$chemin/${entree.key}', textes);
    }
  } else if (valeur is List) {
    for (var i = 0; i < valeur.length; i++) {
      _collecterTextes(valeur[i], '$chemin/$i', textes);
    }
  }
}

// Lettres arabes de base (hamza à yā').
bool _contientLettreArabe(String texte) =>
    texte.runes.any((r) => r >= 0x0621 && r <= 0x064A);

// Tanwīn, fatha, damma, kasra, shadda, sukūn et alif suscrit.
bool _contientHaraka(String texte) =>
    texte.runes.any((r) => (r >= 0x064B && r <= 0x0652) || r == 0x0670);
