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

  // Conventions d'écriture de l'arabe (docs/conventions-arabe.md).
  final textes = <(String, String)>[
    ('/etape/titre', etape['titre'] as String),
    for (var i = 0; i < sequences.length; i++)
      ('/etape/sequences/$i/titre', sequences[i]['titre'] as String),
  ];
  for (var i = 0; i < exercices.length; i++) {
    _collecterTextes(exercices[i], '/exercices/$i', textes);
  }
  problemes
    ..addAll(_alifSuscrit(textes))
    ..addAll(_lamSansSoukoun(textes));

  // Harakat en 1re et 2e année d'arabe (ou de maths et d'éveil, en arabe).
  final niveau = etape['niveau'] as int;
  if (langue == 'ar' && niveau <= 2) {
    final annee = niveau == 1 ? '1re' : '${niveau}e';
    for (final (chemin, texte) in textes) {
      if (_contientLettreArabe(texte) &&
          !_contientHaraka(texte) &&
          !_formeDeLettre(texte)) {
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
  if (_typesChoix.contains(type)) {
    problemes.addAll(
      _reglesChoix(
        type,
        ex['gabarit'] as String,
        ex['langue'] as String,
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (_typesGlisser.contains(type)) {
    problemes.addAll(
      _reglesGlisser(
        type,
        ex['langue'] as String,
        _niveauDeId(ex['id'] as String),
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (type == 'T07' || type == 'T17') {
    problemes.addAll(
      _reglesTexte(
        type,
        ex['langue'] as String,
        _niveauDeId(ex['id'] as String),
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        (ex['normalisation'] as List?)?.cast<String>() ?? const [],
        chemin,
      ),
    );
  }
  if (const {'T22', 'T48', 'T49', 'T50', 'T63'}.contains(type)) {
    problemes.addAll(
      _reglesSaisie(
        type,
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (type == 'T08' || type == 'T47' || type == 'T53') {
    problemes.addAll(
      _reglesScene(
        type,
        _niveauDeId(ex['id'] as String),
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (type == 'T28' || type == 'T30') {
    problemes.addAll(
      _reglesMesure(
        type,
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (type == 'T54') {
    problemes.addAll(
      _reglesColoriage(
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (type == 'T36' || type == 'T37' || type == 'T38') {
    problemes.addAll(
      _reglesJeux(
        type,
        ex['langue'] as String,
        _niveauDeId(ex['id'] as String),
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
  }
  if (_typesManipulables.contains(type)) {
    problemes.addAll(
      _reglesManipulables(
        type,
        _niveauDeId(ex['id'] as String),
        ex['donnees'] as Map<String, dynamic>,
        ex['reponse'] as Map<String, dynamic>,
        chemin,
      ),
    );
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
    final textes = <(String, String)>[];
    _collecterTextes(ex, chemin, textes);
    problemes
      ..addAll(_alifSuscrit(textes))
      ..addAll(_lamSansSoukoun(textes));
  }
  return problemes;
}

/// Les 13 types du moteur Choix (docs/moteurs/choix.md).
const _typesChoix = {
  'T01',
  'T02',
  'T03',
  'T04',
  'T05',
  'T18',
  'T19',
  'T23',
  'T24',
  'T45',
  'T46',
  'T55',
  'T61',
};

/// Types à une seule bonne réponse dans `reponse.choix` (et T19 au gabarit
/// lettre-vocalisee).
const _typesReponseUnique = {'T01', 'T03', 'T04', 'T18', 'T24', 'T55'};

/// Gabarit de la 2e forme de T19 : lettres vocalisées en choix.
const gabaritLettreVocalisee = 'lettre-vocalisee';

/// Types où toutes les propositions ne peuvent pas être justes (sinon il
/// suffit de tout toucher).
const _typesJamaisTousLesChoix = {'T05', 'T45', 'T61'};

/// Types propres à l'écriture arabe.
const _typesArabes = {'T18', 'T19'};

/// Caractère de chaque haraka de T19.
const _signesHaraka = {
  'fatha': 'َ',
  'damma': 'ُ',
  'kasra': 'ِ',
  'soukoun': 'ْ',
};

/// Règles des types du moteur Choix. Le schéma garantit déjà la forme de
/// `donnees` et de `reponse` pour chaque type.
List<ProblemeValidation> _reglesChoix(
  String type,
  String gabarit,
  String langue,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );

  if (_typesArabes.contains(type) && langue != 'ar') {
    erreur(
      '$chemin/langue',
      'type_langue',
      'un $type porte sur l\'écriture arabe : langue ar attendue, pas $langue.',
    );
  }

  // Propositions : id et textes uniques, réponses existantes.
  Set<String> verifierListe(String champ) {
    final liste = (donnees[champ] as List).cast<Map<String, dynamic>>();
    final ids = <String>{};
    final textes = <String>{};
    for (var k = 0; k < liste.length; k++) {
      final id = liste[k]['id'] as String;
      if (!ids.add(id)) {
        erreur(
          '$chemin/donnees/$champ/$k/id',
          'choix_duplique',
          'deux éléments de $champ ont le même id « $id ».',
        );
      }
      final texte = liste[k]['texte'];
      if (texte is String && !textes.add(texte)) {
        erreur(
          '$chemin/donnees/$champ/$k/texte',
          'choix_duplique',
          'deux éléments de $champ ont le même texte « $texte ».',
        );
      }
    }
    final bons = (reponse[champ] as List).cast<String>();
    for (var k = 0; k < bons.length; k++) {
      if (!ids.contains(bons[k])) {
        erreur(
          '$chemin/reponse/$champ/$k',
          'reponse_choix_inconnu',
          'la réponse désigne « ${bons[k]} », absent de donnees.$champ.',
        );
      }
    }
    return ids;
  }

  final avecChoix = donnees['choix'] is List && reponse['choix'] is List;
  final ids = avecChoix ? verifierListe('choix') : <String>{};
  if (type == 'T46') verifierListe('preuves');
  final bons = avecChoix
      ? (reponse['choix'] as List).cast<String>()
      : const <String>[];

  final lettreVocalisee = type == 'T19' && gabarit == gabaritLettreVocalisee;
  if ((_typesReponseUnique.contains(type) || lettreVocalisee) &&
      bons.length != 1) {
    erreur(
      '$chemin/reponse/choix',
      'reponse_unique',
      'un $type a exactement une bonne réponse (ici ${bons.length}).'
          '${type == 'T01' ? ' Pour plusieurs bonnes réponses, utiliser T05.' : ''}',
    );
  }
  if (_typesJamaisTousLesChoix.contains(type) &&
      ids.isNotEmpty &&
      bons.toSet().containsAll(ids)) {
    erreur(
      '$chemin/reponse/choix',
      'reponse_tous_les_choix',
      'toutes les propositions sont dans la réponse : il suffirait de tout '
          'toucher. Ajouter au moins une proposition fausse.',
    );
  }
  if (type == 'T61' && bons.length < 2) {
    erreur(
      '$chemin/reponse/choix',
      'reponse_trop_peu',
      'un résumé (T61) garde au moins 2 phrases (ici ${bons.length}).',
    );
  }
  if (type == 'T04' && ids.length < 3) {
    erreur(
      '$chemin/donnees/choix',
      'choix_trop_peu',
      'un intrus (T04) se cherche parmi 3 propositions au moins '
          '(ici ${ids.length}).',
    );
  }

  switch (type) {
    case 'T18':
      final lettre = donnees['lettre'] as String;
      final choix = (donnees['choix'] as List).cast<Map<String, dynamic>>();
      for (var k = 0; k < choix.length; k++) {
        final texte = choix[k]['texte'] as String;
        if (!texte.contains(lettre)) {
          erreur(
            '$chemin/donnees/choix/$k/texte',
            'forme_sans_lettre',
            'la forme « $texte » ne contient pas la lettre « $lettre ».',
          );
        }
      }
      final mot = donnees['mot'];
      if (mot is String && !mot.contains(lettre)) {
        erreur(
          '$chemin/donnees/mot',
          'forme_sans_lettre',
          'le mot « $mot » ne contient pas la lettre « $lettre ».',
        );
      }
    case 'T19' when lettreVocalisee:
      final signe = _signesHaraka[donnees['haraka']]!;
      final choix = (donnees['choix'] as List).cast<Map<String, dynamic>>();
      for (var k = 0; k < choix.length; k++) {
        final texte = choix[k]['texte'] as String;
        final runes = texte.runes.toList();
        final valide =
            runes.length == 2 &&
            runes[0] >= 0x0621 &&
            runes[0] <= 0x064A &&
            runes[0] != 0x0640 &&
            _signesHaraka.values.contains(String.fromCharCode(runes[1]));
        if (!valide) {
          erreur(
            '$chemin/donnees/choix/$k/texte',
            'lettre_vocalisee_invalide',
            '« $texte » doit être une seule lettre arabe suivie d\'une seule '
                'haraka (fatha, damma, kasra ou soukoun).',
          );
        }
        final porte = texte.contains(signe);
        final estBon = bons.contains(choix[k]['id']);
        if (porte && !estBon) {
          erreur(
            '$chemin/donnees/choix/$k/texte',
            'reponse_haraka_incoherente',
            '« $texte » porte la haraka demandée (${donnees['haraka']}) mais '
                'n\'est pas la bonne réponse : un seul choix doit la porter.',
          );
        }
        if (!porte && estBon) {
          erreur(
            '$chemin/reponse/choix',
            'reponse_haraka_incoherente',
            'la bonne réponse « $texte » ne porte pas la haraka demandée '
                '(${donnees['haraka']}).',
          );
        }
      }
    case 'T19':
      final apres = donnees['apres'] as String;
      if (apres.isNotEmpty && _estHaraka(apres.runes.first)) {
        erreur(
          '$chemin/donnees/apres',
          'haraka_deja_presente',
          'apres commence par une haraka : la lettre aurait déjà la sienne.',
        );
      }
      final haraka = reponse['haraka'] as String;
      final proposees = (donnees['harakat'] as List).cast<String>();
      if (!proposees.contains(haraka)) {
        erreur(
          '$chemin/reponse/haraka',
          'reponse_haraka_inconnue',
          'la réponse « $haraka » ne fait pas partie des harakat proposées '
              '(${proposees.join(', ')}).',
        );
      }
      final ecoute = donnees['ecoute'] as Map<String, dynamic>?;
      final mot =
          '${donnees['avant']}${donnees['lettre']}'
          '${_signesHaraka[haraka]}$apres';
      if (ecoute != null && ecoute['texte'] != mot) {
        erreur(
          '$chemin/donnees/ecoute/texte',
          'ecoute_differente_reponse',
          'le mot entendu « ${ecoute['texte']} » doit être le mot complet '
              'avec la bonne haraka : « $mot ».',
        );
      }
    case 'T23':
      final a = donnees['a'] as num;
      final b = donnees['b'] as num;
      final attendu = a < b ? '<' : (a == b ? '=' : '>');
      if (reponse['signe'] != attendu) {
        erreur(
          '$chemin/reponse/signe',
          'reponse_comparaison_fausse',
          'la réponse « $a ${reponse['signe']} $b » est fausse : '
              'attendu « $a $attendu $b ».',
        );
      }
    case 'T24':
      final suite = (donnees['suite'] as List).cast<Map<String, dynamic>>();
      final attendu = _suivantDeLaSuite(suite);
      final choix = (donnees['choix'] as List).cast<Map<String, dynamic>>();
      final bon = choix.where((c) => bons.contains(c['id'])).firstOrNull;
      if (attendu != null && bon != null && _cleElement(bon) != attendu) {
        erreur(
          '$chemin/reponse/choix',
          'suite_reponse_incoherente',
          'la suite appelle « ${attendu.split('|').where((p) => p.isNotEmpty).join(' ')} », '
              'pas le choix « ${bon['id']} ».',
        );
      }
    case 'T46':
      final texte = donnees['texte'] as String;
      final preuves = (donnees['preuves'] as List).cast<Map<String, dynamic>>();
      for (var k = 0; k < preuves.length; k++) {
        final phrase = preuves[k]['texte'] as String;
        if (!texte.contains(phrase)) {
          erreur(
            '$chemin/donnees/preuves/$k/texte',
            'preuve_absente_du_texte',
            'la preuve « $phrase » doit être recopiée telle quelle du texte.',
          );
        }
      }
    case 'T55':
      final ecoute = (donnees['ecoute'] as Map<String, dynamic>)['texte'];
      final choix = (donnees['choix'] as List).cast<Map<String, dynamic>>();
      final bon = choix.where((c) => bons.contains(c['id'])).firstOrNull;
      if (bons.length == 1 && bon != null && bon['texte'] != ecoute) {
        erreur(
          '$chemin/donnees/ecoute/texte',
          'ecoute_differente_reponse',
          'le mot entendu « $ecoute » doit être le texte du bon choix '
              '« ${bon['texte'] ?? bon['id']} ».',
        );
      }
  }
  return problemes;
}

/// Niveau (1 à 6) lu dans l'id d'un exercice (`ar-1-t1-u1-e01-x01`).
int? _niveauDeId(String id) =>
    int.tryParse(RegExp(r'^[a-z]{2}-([1-6])-').firstMatch(id)?.group(1) ?? '');

/// Les 10 types du moteur Glisser-déposer (docs/moteurs/glisser-deposer.md).
const _typesGlisser = {
  'T06',
  'T09',
  'T11',
  'T12',
  'T13',
  'T14',
  'T15',
  'T16',
  'T56',
  'T62',
};

/// Runes de chaque haraka d'un emplacement de schème (T56).
const _signesHarakaScheme = <String, List<int>>{
  'fatha': [0x064E],
  'damma': [0x064F],
  'kasra': [0x0650],
  'soukoun': [0x0652],
  'fathatan': [0x064B],
  'dammatan': [0x064C],
  'kasratan': [0x064D],
  'shadda-fatha': [0x0651, 0x064E],
  'shadda-damma': [0x0651, 0x064F],
  'shadda-kasra': [0x0651, 0x0650],
};

/// Types où l'enfant manipule des éléments : 4 à 6 au maximum en 1re et 2e
/// année (CLAUDE.md §5).
const _elementsMaxPetits = 6;

/// Règles des types du moteur Glisser-déposer. Le schéma garantit déjà la
/// forme de `donnees` et de `reponse` pour chaque type.
List<ProblemeValidation> _reglesGlisser(
  String type,
  String langue,
  int? niveau,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  void avertissement(String c, String code, String message) => problemes.add(
    ProblemeValidation(
      chemin: c,
      code: code,
      message: message,
      gravite: Gravite.avertissement,
    ),
  );

  // Langue imposée : T12 (règle de la langue arabe), T15 (lettres liées)
  // et T56 (racine et schème) en arabe, T16 (syllabes) jamais en arabe.
  if ((type == 'T12' || type == 'T15' || type == 'T56') && langue != 'ar') {
    erreur(
      '$chemin/langue',
      'type_langue',
      'un $type porte sur l\'écriture arabe : langue ar attendue, pas $langue.',
    );
  }
  if (type == 'T16' && langue == 'ar') {
    erreur(
      '$chemin/langue',
      'type_langue',
      'un T16 (syllabes) ne se joue pas en arabe : des syllabes isolées '
          'casseraient la liaison des lettres. Utiliser T15.',
    );
  }

  /// Ids d'une liste d'éléments, avec contrôle des doublons (id, et texte
  /// sauf pour les lettres et syllabes, où une lettre peut revenir).
  Set<String> ids(String champ, {bool textesUniques = true}) {
    final liste = (donnees[champ] as List).cast<Map<String, dynamic>>();
    final vus = <String>{};
    final textes = <String>{};
    for (var k = 0; k < liste.length; k++) {
      final id = liste[k]['id'] as String;
      if (!vus.add(id)) {
        erreur(
          '$chemin/donnees/$champ/$k/id',
          'element_duplique',
          'deux éléments de $champ ont le même id « $id ».',
        );
      }
      final texte = liste[k]['texte'];
      if (textesUniques && texte is String && !textes.add(texte)) {
        erreur(
          '$chemin/donnees/$champ/$k/texte',
          'element_duplique',
          'deux éléments de $champ ont le même texte « $texte ».',
        );
      }
    }
    return vus;
  }

  void inconnu(String c, String champ, String id) => erreur(
    c,
    'reponse_element_inconnu',
    'la réponse désigne « $id », absent de donnees.$champ.',
  );

  var nbElements = 0;
  switch (type) {
    case 'T06':
      final etiquettes = ids('etiquettes');
      nbElements = etiquettes.length;
      final texte = donnees['texte'] as String;
      final trous = RegExp(r'\{(t[1-9])\}')
          .allMatches(texte)
          .map((m) => m.group(1)!)
          .toList();
      final trousUniques = trous.toSet();
      if (trousUniques.length != trous.length) {
        erreur(
          '$chemin/donnees/texte',
          'trou_duplique',
          'un trou apparaît deux fois dans le texte : « $texte ».',
        );
      }
      final reponses = (reponse['trous'] as List).cast<Map<String, dynamic>>();
      final trousRepondus = <String>{};
      final etiquettesUtilisees = <String>{};
      for (var k = 0; k < reponses.length; k++) {
        final trou = reponses[k]['trou'] as String;
        final etiquette = reponses[k]['etiquette'] as String;
        if (!trousUniques.contains(trou)) {
          erreur(
            '$chemin/reponse/trous/$k/trou',
            'reponse_trou_inconnu',
            'le trou « $trou » n\'est pas dans le texte.',
          );
        }
        if (!trousRepondus.add(trou)) {
          erreur(
            '$chemin/reponse/trous/$k/trou',
            'trou_duplique',
            'le trou « $trou » a deux réponses.',
          );
        }
        if (!etiquettes.contains(etiquette)) {
          inconnu(
            '$chemin/reponse/trous/$k/etiquette',
            'etiquettes',
            etiquette,
          );
        } else if (!etiquettesUtilisees.add(etiquette)) {
          erreur(
            '$chemin/reponse/trous/$k/etiquette',
            'etiquette_reutilisee',
            'l\'étiquette « $etiquette » remplit deux trous.',
          );
        }
      }
      for (final trou in trousUniques.difference(trousRepondus)) {
        erreur(
          '$chemin/reponse/trous',
          'trou_sans_reponse',
          'le trou « $trou » du texte n\'a pas de réponse.',
        );
      }
      if (trousUniques.length > 1 &&
          etiquettesUtilisees.length == etiquettes.length) {
        avertissement(
          '$chemin/donnees/etiquettes',
          'etiquettes_sans_intrus',
          'toutes les étiquettes servent : avec plusieurs trous, ajouter une '
              'étiquette en trop évite de deviner le dernier trou.',
        );
      }
    case 'T09':
      final gauche = ids('gauche');
      final droite = ids('droite');
      nbElements = gauche.length;
      if (gauche.length != droite.length) {
        erreur(
          '$chemin/donnees/droite',
          'association_incomplete',
          'gauche (${gauche.length}) et droite (${droite.length}) doivent '
              'avoir le même nombre d\'éléments.',
        );
      }
      final paires = (reponse['paires'] as List).cast<Map<String, dynamic>>();
      final gauchesVues = <String>{};
      final droitesVues = <String>{};
      for (var k = 0; k < paires.length; k++) {
        final g = paires[k]['gauche'] as String;
        final d = paires[k]['droite'] as String;
        if (!gauche.contains(g)) {
          inconnu('$chemin/reponse/paires/$k/gauche', 'gauche', g);
        }
        if (!droite.contains(d)) {
          inconnu('$chemin/reponse/paires/$k/droite', 'droite', d);
        }
        if (!gauchesVues.add(g) || !droitesVues.add(d)) {
          erreur(
            '$chemin/reponse/paires/$k',
            'association_incomplete',
            'un élément ne fait partie que d\'une paire (« $g », « $d »).',
          );
        }
      }
      if (gauchesVues.length != gauche.length ||
          droitesVues.length != droite.length) {
        erreur(
          '$chemin/reponse/paires',
          'association_incomplete',
          'chaque élément de gauche et de droite doit être dans une paire.',
        );
      }
    case 'T11' || 'T12':
      final categories = ids('categories');
      final elements = ids('elements');
      nbElements = elements.length;
      final classement = (reponse['classement'] as List)
          .cast<Map<String, dynamic>>();
      final classes = <String>{};
      final utilisees = <String>{};
      for (var k = 0; k < classement.length; k++) {
        final e = classement[k]['element'] as String;
        final c = classement[k]['categorie'] as String;
        if (!elements.contains(e)) {
          inconnu('$chemin/reponse/classement/$k/element', 'elements', e);
        }
        if (!categories.contains(c)) {
          inconnu('$chemin/reponse/classement/$k/categorie', 'categories', c);
        }
        if (!classes.add(e)) {
          erreur(
            '$chemin/reponse/classement/$k/element',
            'classement_incomplet',
            'l\'élément « $e » est classé deux fois.',
          );
        }
        utilisees.add(c);
      }
      for (final e in elements.difference(classes)) {
        erreur(
          '$chemin/reponse/classement',
          'classement_incomplet',
          'l\'élément « $e » n\'est pas classé.',
        );
      }
      for (final c in categories.difference(utilisees)) {
        erreur(
          '$chemin/reponse/classement',
          'categorie_vide',
          'la catégorie « $c » ne reçoit aucun élément.',
        );
      }
      if (type == 'T12') {
        final liste = (donnees['elements'] as List)
            .cast<Map<String, dynamic>>();
        for (var k = 0; k < liste.length; k++) {
          if (liste[k]['texte'] == null) {
            erreur(
              '$chemin/donnees/elements/$k',
              'element_sans_texte',
              'un tableau de tri (T12) classe des mots : texte obligatoire.',
            );
          }
        }
      }
    case 'T13' || 'T14' || 'T62':
      final elements = ids('elements');
      nbElements = elements.length;
      final ordre = (reponse['ordre'] as List).cast<String>();
      for (var k = 0; k < ordre.length; k++) {
        if (!elements.contains(ordre[k])) {
          inconnu('$chemin/reponse/ordre/$k', 'elements', ordre[k]);
        }
      }
      if (ordre.toSet().length != elements.length) {
        erreur(
          '$chemin/reponse/ordre',
          'ordre_incomplet',
          'l\'ordre doit citer chacun des ${elements.length} éléments une '
              'fois (ici ${ordre.length}).',
        );
      }
    case 'T15' || 'T16':
      final elements = ids('elements', textesUniques: false);
      nbElements = elements.length;
      final ordre = (reponse['ordre'] as List).cast<String>();
      for (var k = 0; k < ordre.length; k++) {
        if (!elements.contains(ordre[k])) {
          inconnu('$chemin/reponse/ordre/$k', 'elements', ordre[k]);
        }
      }
      final ecoute = donnees['ecoute'] as Map<String, dynamic>?;
      if (ecoute != null) {
        final liste = (donnees['elements'] as List)
            .cast<Map<String, dynamic>>();
        final mot = [
          for (final id in ordre)
            liste.where((e) => e['id'] == id).firstOrNull?['texte'] ?? '',
        ].join();
        final entendu = _sansHarakat(ecoute['texte'] as String);
        if (mot != entendu) {
          erreur(
            '$chemin/donnees/ecoute/texte',
            'mot_different_ecoute',
            'le mot construit « $mot » doit être le mot entendu sans ses '
                'harakat « $entendu ».',
          );
        }
      }
    case 'T56':
      final lettres = ids('lettres', textesUniques: false);
      nbElements = lettres.length;
      final liste = (donnees['lettres'] as List).cast<Map<String, dynamic>>();
      for (var k = 0; k < liste.length; k++) {
        final texte = liste[k]['texte'] as String;
        if (!_lettreNue(texte)) {
          erreur(
            '$chemin/donnees/lettres/$k/texte',
            'lettre_invalide',
            'une tuile de T56 porte une seule lettre arabe sans haraka, '
                'pas « $texte ».',
          );
        }
      }
      final emplacements = (donnees['emplacements'] as List)
          .cast<Map<String, dynamic>>();
      final forme = donnees['forme'] as String;
      final ordre = (reponse['ordre'] as List).cast<String>();
      for (var k = 0; k < ordre.length; k++) {
        if (!lettres.contains(ordre[k])) {
          inconnu('$chemin/reponse/ordre/$k', 'lettres', ordre[k]);
        }
      }
      if (ordre.length != emplacements.length) {
        erreur(
          '$chemin/reponse/ordre',
          'ordre_incomplet',
          'l\'ordre doit citer une lettre par emplacement '
              '(${emplacements.length} emplacements, ${ordre.length} '
              'lettres).',
        );
      }
      final mot = donnees['mot'] as String;
      final lettresDuMot = _lettresEtHarakat(mot);
      final construites = [
        for (final id in ordre)
          liste.where((e) => e['id'] == id).firstOrNull?['texte'] as String? ??
              '',
      ];
      if (forme == 'racine') {
        for (var k = 0; k < emplacements.length; k++) {
          if (emplacements[k].containsKey('haraka')) {
            erreur(
              '$chemin/donnees/emplacements/$k/haraka',
              'haraka_hors_scheme',
              'une racine s\'écrit en lettres nues : la haraka d\'un '
                  'emplacement est réservée à la forme scheme.',
            );
          }
        }
        // Les lettres de la racine se lisent dans l'ordre dans le mot.
        // Sinon (racine creuse, défectueuse, hamzée) : à relire.
        var i = 0;
        for (final (lettre, _) in lettresDuMot) {
          if (i < construites.length && lettre == construites[i]) i++;
        }
        if (i < construites.length) {
          avertissement(
            '$chemin/reponse/ordre',
            'racine_hors_mot',
            'la racine « ${construites.join(' ')} » ne se lit pas dans '
                'l\'ordre dans « $mot » : à relire (racine creuse ou '
                'défectueuse ?).',
          );
        }
      } else if (lettresDuMot.length != emplacements.length) {
        erreur(
          '$chemin/donnees/emplacements',
          'scheme_longueur',
          'le schème a ${emplacements.length} emplacements pour un mot de '
              '${lettresDuMot.length} lettres : un emplacement par lettre '
              'du mot « $mot ».',
        );
      } else {
        for (var k = 0; k < emplacements.length; k++) {
          final attendues = String.fromCharCodes(lettresDuMot[k].$2..sort());
          final nom = emplacements[k]['haraka'] as String?;
          final donnees = String.fromCharCodes(
            [...?_signesHarakaScheme[nom]]..sort(),
          );
          if (attendues != donnees) {
            erreur(
              '$chemin/donnees/emplacements/$k',
              'scheme_harakat_differentes',
              'l\'emplacement ${k + 1} porte « ${nom ?? 'aucune haraka'} » '
                  'alors que la lettre « ${lettresDuMot[k].$1} » du mot '
                  '« $mot » porte « ${lettresDuMot[k].$1}$attendues ».',
            );
          }
        }
      }
      final ecoute = donnees['ecoute'] as Map<String, dynamic>?;
      if (ecoute != null && ecoute['texte'] != mot) {
        erreur(
          '$chemin/donnees/ecoute/texte',
          'ecoute_differente_reponse',
          'le mot entendu doit être le mot « $mot », pas '
              '« ${ecoute['texte']} ».',
        );
      }
  }

  if (niveau != null && niveau <= 2 && nbElements > _elementsMaxPetits) {
    avertissement(
      '$chemin/donnees',
      'elements_trop_nombreux',
      '$nbElements éléments à manipuler en ${niveau == 1 ? '1re' : '2e'} '
          'année : 4 à 6 au maximum (CLAUDE.md §5).',
    );
  }
  return problemes;
}

/// Sens de lecture des lignes d'une grille de mots mêlés (T38) : de droite
/// à gauche en arabe par défaut.
bool motsMelesDroiteGauche(Map<String, dynamic> donnees, String langue) =>
    (donnees['sens'] as String?) == null
    ? langue == 'ar'
    : donnees['sens'] == 'droite-gauche';

/// Paires du memory (T37) selon le niveau (revision-jeux.md §3) : grille de
/// 3 colonnes toujours pleine, 3 × 2 en 1re, 3 × 4 en 2e et 3e, 3 × 6 en 4e
/// et 5e, 3 × 8 en 6e. `null` si le niveau est inconnu.
int? pairesMemoryParNiveau(int? niveau) => switch (niveau) {
  1 => 3,
  2 || 3 => 6,
  4 || 5 => 9,
  6 => 12,
  _ => null,
};

/// Règles du moteur Révision et jeux (docs/moteurs/revision-jeux.md) : T36
/// Flashcards, T37 Memory, T38 Mots mêlés.
List<ProblemeValidation> _reglesJeux(
  String type,
  String langue,
  int? niveau,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );

  /// Ids uniques d'une liste d'objets.
  Set<String> ids(String champ) {
    final liste = (donnees[champ] as List).cast<Map<String, dynamic>>();
    final vus = <String>{};
    for (var k = 0; k < liste.length; k++) {
      final id = liste[k]['id'] as String;
      if (!vus.add(id)) {
        erreur(
          '$chemin/donnees/$champ/$k/id',
          'element_duplique',
          'deux éléments de $champ ont le même id « $id ».',
        );
      }
    }
    return vus;
  }

  void inconnu(String c, String champ, String id) => erreur(
    c,
    'reponse_element_inconnu',
    'la réponse désigne « $id », absent de donnees.$champ.',
  );

  switch (type) {
    case 'T36':
      final cartes = ids('cartes');
      final demandees = (reponse['cartes'] as List).cast<String>();
      for (var k = 0; k < demandees.length; k++) {
        if (!cartes.contains(demandees[k])) {
          inconnu('$chemin/reponse/cartes/$k', 'cartes', demandees[k]);
        }
      }
    case 'T37':
      final paires = ids('paires');
      final pairesNiveau = pairesMemoryParNiveau(niveau);
      if (pairesNiveau != null && paires.length != pairesNiveau) {
        erreur(
          '$chemin/donnees/paires',
          'memory_cartes_niveau',
          'en ${niveau == 1 ? '1re' : '${niveau}e'} année, le memory a '
              '$pairesNiveau paires (${pairesNiveau * 2} cartes sur 3 '
              'colonnes), pas ${paires.length}.',
        );
      }
      final attendues = (reponse['paires'] as List).cast<String>();
      for (var k = 0; k < attendues.length; k++) {
        if (!paires.contains(attendues[k])) {
          inconnu('$chemin/reponse/paires/$k', 'paires', attendues[k]);
        }
      }
      if (attendues.where(paires.contains).toSet().length != paires.length) {
        erreur(
          '$chemin/reponse/paires',
          'paires_incompletes',
          'la réponse doit citer chacune des ${paires.length} paires une '
              'fois (ici ${attendues.length}).',
        );
      }
    case 'T38':
      final grille = (donnees['grille'] as List).cast<String>();
      final lignes = [for (final l in grille) l.runes.toList()];
      final largeur = lignes.first.length;
      var reguliere = true;
      for (var k = 0; k < lignes.length; k++) {
        if (lignes[k].length != largeur) {
          reguliere = false;
          erreur(
            '$chemin/donnees/grille/$k',
            'grille_irreguliere',
            'la ligne $k a ${lignes[k].length} lettres, la première en a '
                '$largeur.',
          );
        }
        if (langue == 'ar') {
          for (final r in lignes[k]) {
            if (!_estLettreArabe(r)) {
              erreur(
                '$chemin/donnees/grille/$k',
                'lettre_invalide',
                'une grille arabe ne porte que des lettres nues, sans '
                    'harakat ni espace : « ${grille[k]} ».',
              );
              break;
            }
          }
        }
      }
      final mots = ids('mots');
      final liste = (donnees['mots'] as List).cast<Map<String, dynamic>>();
      final droiteGauche = motsMelesDroiteGauche(donnees, langue);
      for (var k = 0; k < liste.length; k++) {
        final m = liste[k];
        final lettres = _sansHarakat(m['texte'] as String).runes.toList();
        var ligne = m['ligne'] as int;
        var colonne = m['colonne'] as int;
        final enLigne = m['direction'] == 'ligne';
        var lu = true;
        for (final lettre in lettres) {
          if (ligne < 0 ||
              ligne >= lignes.length ||
              colonne < 0 ||
              colonne >= lignes[ligne].length ||
              lignes[ligne][colonne] != lettre) {
            lu = false;
            break;
          }
          if (enLigne) {
            colonne += droiteGauche ? -1 : 1;
          } else {
            ligne += 1;
          }
        }
        if (reguliere && !lu) {
          erreur(
            '$chemin/donnees/mots/$k',
            'mot_hors_grille',
            'le mot « ${m['texte']} » ne se lit pas dans la grille à la '
                'ligne ${m['ligne']}, colonne ${m['colonne']}, en '
                '${m['direction']} (${droiteGauche ? 'droite-gauche' : 'gauche-droite'}).',
          );
        }
      }
      final attendus = (reponse['mots'] as List).cast<String>();
      for (var k = 0; k < attendus.length; k++) {
        if (!mots.contains(attendus[k])) {
          inconnu('$chemin/reponse/mots/$k', 'mots', attendus[k]);
        }
      }
      if (attendus.where(mots.contains).toSet().length != mots.length) {
        erreur(
          '$chemin/reponse/mots',
          'ordre_incomplet',
          'la réponse doit citer chacun des ${mots.length} mots une fois '
              '(ici ${attendus.length}).',
        );
      }
  }
  return problemes;
}

/// T47 : écart vertical minimal (part de la hauteur de la scène) entre deux
/// zones du même côté, sinon leurs cases d'étiquettes se superposent.
const _ecartEtiquettesMin = 0.1;

/// Règles du moteur Scène image (docs/moteurs/scene-image.md) : T08 Hot
/// spot sur image, T47 Étiqueter un schéma.
List<ProblemeValidation> _reglesScene(
  String type,
  int? niveau,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  void avertissement(String c, String code, String message) => problemes.add(
    ProblemeValidation(
      chemin: c,
      code: code,
      message: message,
      gravite: Gravite.avertissement,
    ),
  );
  final zones = (donnees['zones'] as List).cast<Map<String, dynamic>>();
  final idsZones = <String>{};
  for (var k = 0; k < zones.length; k++) {
    final id = zones[k]['id'] as String;
    if (!idsZones.add(id)) {
      erreur(
        '$chemin/donnees/zones/$k/id',
        'element_duplique',
        'deux zones ont le même id « $id ».',
      );
    }
    final x = zones[k]['x'] as num;
    final y = zones[k]['y'] as num;
    if (x + (zones[k]['l'] as num) > 1 || y + (zones[k]['h'] as num) > 1) {
      erreur(
        '$chemin/donnees/zones/$k',
        'zone_hors_scene',
        'la zone « $id » dépasse la scène : x + l et y + h valent 1 au plus.',
      );
    }
  }
  void inconnu(String c, String id, String champ) => erreur(
    c,
    'reponse_element_inconnu',
    'la réponse désigne « $id », absent de donnees.$champ.',
  );
  switch (type) {
    case 'T08':
      final attendues = (reponse['zones'] as List).cast<String>();
      for (var k = 0; k < attendues.length; k++) {
        if (!idsZones.contains(attendues[k])) {
          inconnu('$chemin/reponse/zones/$k', attendues[k], 'zones');
        }
      }
      final plusieurs = donnees['plusieurs'] as bool? ?? false;
      if (!plusieurs && attendues.length > 1) {
        erreur(
          '$chemin/reponse/zones',
          'reponse_unique',
          'une seule zone attendue sans « plusieurs » (ici '
              '${attendues.length}).',
        );
      }
    case 'T53':
      final attendue = reponse['zone'] as String;
      if (!idsZones.contains(attendue)) {
        inconnu('$chemin/reponse/zone', attendue, 'zones');
      }
    case 'T47':
      final etiquettes = (donnees['etiquettes'] as List)
          .cast<Map<String, dynamic>>();
      final idsEtiquettes = <String>{};
      final textes = <String>{};
      for (var k = 0; k < etiquettes.length; k++) {
        final id = etiquettes[k]['id'] as String;
        if (!idsEtiquettes.add(id)) {
          erreur(
            '$chemin/donnees/etiquettes/$k/id',
            'element_duplique',
            'deux étiquettes ont le même id « $id ».',
          );
        }
        final texte = etiquettes[k]['texte'] as String;
        if (!textes.add(texte)) {
          erreur(
            '$chemin/donnees/etiquettes/$k/texte',
            'element_duplique',
            'deux étiquettes ont le même texte « $texte ».',
          );
        }
      }
      final placements = (reponse['placements'] as List)
          .cast<Map<String, dynamic>>();
      final zonesServies = <String>{};
      final etiquettesServies = <String>{};
      for (var k = 0; k < placements.length; k++) {
        final zone = placements[k]['zone'] as String;
        final etiquette = placements[k]['etiquette'] as String;
        if (!idsZones.contains(zone)) {
          inconnu('$chemin/reponse/placements/$k/zone', zone, 'zones');
        }
        if (!idsEtiquettes.contains(etiquette)) {
          inconnu(
            '$chemin/reponse/placements/$k/etiquette',
            etiquette,
            'etiquettes',
          );
        }
        if (!zonesServies.add(zone)) {
          erreur(
            '$chemin/reponse/placements/$k/zone',
            'zone_sans_reponse',
            'la zone « $zone » reçoit deux étiquettes.',
          );
        }
        if (!etiquettesServies.add(etiquette)) {
          erreur(
            '$chemin/reponse/placements/$k/etiquette',
            'etiquette_reutilisee',
            'l\'étiquette « $etiquette » est posée sur deux zones.',
          );
        }
      }
      for (final id in idsZones.difference(zonesServies)) {
        erreur(
          '$chemin/reponse/placements',
          'zone_sans_reponse',
          'la zone « $id » n\'a pas d\'étiquette attendue.',
        );
      }
      // Les cases d'étiquettes sont placées par le moteur à gauche ou à
      // droite de la scène, à la hauteur du point de leur zone : deux zones
      // du même côté à la même hauteur donneraient des cases superposées.
      double centreX(Map<String, dynamic> z) =>
          (z['x'] as num) + (z['l'] as num) / 2;
      double centreY(Map<String, dynamic> z) =>
          (z['y'] as num) + (z['h'] as num) / 2;
      for (var i = 0; i < zones.length; i++) {
        for (var j = i + 1; j < zones.length; j++) {
          final a = zones[i];
          final b = zones[j];
          if ((centreX(a) < 0.5) == (centreX(b) < 0.5) &&
              (centreY(a) - centreY(b)).abs() < _ecartEtiquettesMin) {
            erreur(
              '$chemin/donnees/zones/$j',
              'etiquettes_superposees',
              'les zones « ${a['id']} » et « ${b['id']} » sont du même côté '
                  'de la scène à la même hauteur : leurs cases d\'étiquettes '
                  'se chevaucheraient. Écarter les points d\'au moins '
                  '$_ecartEtiquettesMin de la hauteur, ou changer de côté.',
            );
          }
        }
      }
      if (idsEtiquettes.length <= idsZones.length && idsZones.length > 1) {
        avertissement(
          '$chemin/donnees/etiquettes',
          'etiquettes_sans_intrus',
          'toutes les étiquettes servent : ajouter une étiquette en trop, '
              'sinon il suffit de tout poser.',
        );
      }
  }
  if (niveau != null && niveau <= 2 && zones.length > _elementsMaxPetits) {
    avertissement(
      '$chemin/donnees/zones',
      'elements_trop_nombreux',
      '${zones.length} zones en ${niveau == 1 ? '1re' : '2e'} année : '
          '4 à 6 au maximum (CLAUDE.md §5).',
    );
  }
  return problemes;
}

/// Règles du moteur Mesure et temps (docs/moteurs/mesure-temps.md) : T28
/// Horloge, T30 Règle.
List<ProblemeValidation> _reglesMesure(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  switch (type) {
    case 'T28':
      final pas = donnees['pas'] as int? ?? 5;
      final minutes = reponse['minutes'] as int;
      final heure = reponse['heure'] as int;
      if (minutes % pas != 0) {
        erreur(
          '$chemin/reponse/minutes',
          'heure_hors_pas',
          'les minutes de la cible ($minutes) doivent être un multiple du '
              'pas ($pas) pour que l\'aiguille s\'y aimante.',
        );
      }
      final depart = (donnees['depart'] as Map?)?.cast<String, dynamic>();
      final departHeure = depart?['heure'] as int? ?? 12;
      final departMinutes = depart?['minutes'] as int? ?? 0;
      if (departHeure % 12 == heure % 12 && departMinutes == minutes) {
        erreur(
          '$chemin/donnees/depart',
          'depart_egal_cible',
          'les aiguilles partent déjà de l\'heure demandée.',
        );
      }
    case 'T30':
      final longueurRegle = donnees['longueur_regle'] as int? ?? 10;
      final objet = donnees['objet'] as Map<String, dynamic>;
      final longueur = objet['longueur'] as int;
      final depart = objet['depart'] as int? ?? 0;
      if (depart + longueur > longueurRegle) {
        erreur(
          '$chemin/donnees/objet',
          'objet_hors_regle',
          'l\'objet va de $depart à ${depart + longueur} : la règle fait '
              '$longueurRegle.',
        );
      }
      if (reponse['valeur'] != longueur) {
        erreur(
          '$chemin/reponse/valeur',
          'reponse_valeur_incoherente',
          'la réponse (${reponse['valeur']}) doit être la longueur de '
              'l\'objet ($longueur).',
        );
      }
  }
  return problemes;
}

/// Règles de T54 Écoute et colorie (docs/moteurs/scene-image.md §14) : id
/// uniques, réponses existantes, un coloriage par objet.
List<ProblemeValidation> _reglesColoriage(
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  final objets = (donnees['objets'] as List).cast<Map<String, dynamic>>();
  final ids = <String>{};
  final libelles = <String>{};
  for (var k = 0; k < objets.length; k++) {
    final id = objets[k]['id'] as String;
    if (!ids.add(id)) {
      erreur(
        '$chemin/donnees/objets/$k/id',
        'element_duplique',
        'deux objets ont le même id « $id ».',
      );
    }
    final libelle = objets[k]['libelle'] as String;
    if (!libelles.add(libelle)) {
      erreur(
        '$chemin/donnees/objets/$k/libelle',
        'element_duplique',
        'deux objets ont le même nom « $libelle ».',
      );
    }
  }
  final couleurs = (donnees['couleurs'] as List).cast<String>().toSet();
  final coloriages = (reponse['coloriages'] as List)
      .cast<Map<String, dynamic>>();
  final colories = <String>{};
  for (var k = 0; k < coloriages.length; k++) {
    final objet = coloriages[k]['objet'] as String;
    final couleur = coloriages[k]['couleur'] as String;
    if (!ids.contains(objet)) {
      erreur(
        '$chemin/reponse/coloriages/$k/objet',
        'reponse_element_inconnu',
        'la réponse désigne « $objet », absent de donnees.objets.',
      );
    }
    if (!couleurs.contains(couleur)) {
      erreur(
        '$chemin/reponse/coloriages/$k/couleur',
        'reponse_element_inconnu',
        'la réponse désigne la couleur « $couleur », absente de '
            'donnees.couleurs.',
      );
    }
    if (!colories.add(objet)) {
      erreur(
        '$chemin/reponse/coloriages/$k/objet',
        'element_duplique',
        'l\'objet « $objet » reçoit deux couleurs.',
      );
    }
  }
  return problemes;
}

/// Règles du moteur Saisie numérique (docs/moteurs/saisie-numerique.md) :
/// T22 Saisie numérique, T48 Calcul posé.
List<ProblemeValidation> _reglesSaisie(
  String type,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  switch (type) {
    case 'T22':
      final valeur = reponse['valeur'] as int;
      final max = donnees['chiffres_max'] as int? ?? 3;
      if ('$valeur'.length > max) {
        erreur(
          '$chemin/reponse/valeur',
          'valeur_trop_longue',
          'la réponse $valeur a ${'$valeur'.length} chiffres : '
              'chiffres_max vaut $max.',
        );
      }
    case 'T48':
      final valeur = reponse['valeur'] as int;
      final a = donnees['a'] as int;
      final b = donnees['b'] as int;
      final addition = donnees['operation'] == 'addition';
      if (!addition && a < b) {
        erreur(
          '$chemin/donnees/b',
          'soustraction_negative',
          '$a moins $b est négatif : b doit être au plus a.',
        );
      }
      final resultat = addition ? a + b : a - b;
      if (resultat >= 0 && valeur != resultat) {
        erreur(
          '$chemin/reponse/valeur',
          'reponse_valeur_incoherente',
          'la réponse ($valeur) doit être le résultat du calcul '
              '($resultat).',
        );
      }
    case 'T49':
      final termes = (donnees['termes'] as List).cast<Map<String, dynamic>>();
      final addition = donnees['operation'] == 'addition';
      final n1 = termes[0]['numerateur'] as int;
      final d1 = termes[0]['denominateur'] as int;
      final n2 = termes[1]['numerateur'] as int;
      final d2 = termes[1]['denominateur'] as int;
      // Résultat sur le dénominateur commun d1 × d2.
      final numerateur = addition ? n1 * d2 + n2 * d1 : n1 * d2 - n2 * d1;
      final denominateur = d1 * d2;
      if (numerateur < 0) {
        erreur(
          '$chemin/donnees/termes',
          'soustraction_negative',
          '$n1/$d1 moins $n2/$d2 est négatif.',
        );
      } else {
        final rn = reponse['numerateur'] as int;
        final rd = reponse['denominateur'] as int;
        if (rn * denominateur != numerateur * rd) {
          erreur(
            '$chemin/reponse',
            'fraction_resultat_incoherente',
            'la réponse $rn/$rd ne vaut pas $n1/$d1 '
                '${addition ? '+' : '−'} $n2/$d2 '
                '(= $numerateur/$denominateur).',
          );
        }
      }
    case 'T50':
      final chrono = donnees['chrono'] as bool? ?? true;
      final exercice = donnees['exercice'] as String? ?? 'complement';
      final questionsMin = reponse['questions_min'] as int? ?? 1;
      if (!chrono && questionsMin > (donnees['questions'] as int? ?? 10)) {
        erreur(
          '$chemin/reponse/questions_min',
          'questions_min_trop_grand',
          'sans chronomètre, questions_min ($questionsMin) dépasse le nombre '
              'de questions (${donnees['questions'] ?? 10}).',
        );
      }
      if (exercice == 'complement' && donnees['max'] != null) {
        problemes.add(
          ProblemeValidation(
            chemin: '$chemin/donnees/max',
            code: 'champ_inutile',
            message: 'max ne sert pas aux compléments (cible).',
            gravite: Gravite.avertissement,
          ),
        );
      }
    case 'T63':
      final valeur = reponse['valeur'] as int;
      final gauche = (donnees['gauche'] as List).cast<int>();
      final droite = (donnees['droite'] as List).cast<int>();
      final sacAGauche = donnees['sac'] != 'droite';
      final sommeGauche = gauche.fold(0, (a, b) => a + b);
      final sommeDroite = droite.fold(0, (a, b) => a + b);
      final attendu = sacAGauche
          ? sommeDroite - sommeGauche
          : sommeGauche - sommeDroite;
      if (attendu <= 0) {
        erreur(
          '$chemin/donnees',
          'balance_invalide',
          'le plateau du sac (${sacAGauche ? 'gauche' : 'droite'}) pèse '
              'déjà autant ou plus que l\'autre : la masse du sac serait '
              '$attendu.',
        );
      } else if (valeur != attendu) {
        erreur(
          '$chemin/reponse/valeur',
          'reponse_valeur_incoherente',
          'la réponse ($valeur) doit être la masse qui équilibre '
              '($attendu).',
        );
      }
  }
  return problemes;
}

/// Nombre de mots d'une phrase de T07.
const _motsMin = 2;
const _motsMax = 20;

/// Règles du moteur Texte (docs/moteurs/texte.md) : T07 Toucher les mots,
/// T17 Dictée au clavier.
List<ProblemeValidation> _reglesTexte(
  String type,
  String langue,
  int? niveau,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  List<String> normalisation,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  void avertissement(String c, String code, String message) => problemes.add(
    ProblemeValidation(
      chemin: c,
      code: code,
      message: message,
      gravite: Gravite.avertissement,
    ),
  );
  switch (type) {
    case 'T07':
      final mots = (donnees['texte'] as String)
          .split(' ')
          .where((m) => m.isNotEmpty)
          .toList();
      if (mots.length < _motsMin || mots.length > _motsMax) {
        erreur(
          '$chemin/donnees/texte',
          'phrase_invalide',
          'la phrase a ${mots.length} mot(s) : de $_motsMin à $_motsMax '
              'attendus.',
        );
      }
      final attendus = (reponse['mots'] as List).cast<int>();
      for (var k = 0; k < attendus.length; k++) {
        if (attendus[k] >= mots.length) {
          erreur(
            '$chemin/reponse/mots/$k',
            'mot_inconnu',
            'le mot ${attendus[k]} n\'existe pas : la phrase a '
                '${mots.length} mots (index de 0 à ${mots.length - 1}).',
          );
        }
      }
      final plusieurs = donnees['plusieurs'] as bool? ?? false;
      if (!plusieurs && attendus.length > 1) {
        erreur(
          '$chemin/reponse/mots',
          'reponse_unique',
          'un seul mot attendu sans « plusieurs » (ici '
              '${attendus.length}).',
        );
      }
    case 'T17':
      final entendu = (donnees['ecoute'] as Map<String, dynamic>)['texte'];
      final attendu = reponse['texte'] as String;
      if (entendu != attendu) {
        erreur(
          '$chemin/reponse/texte',
          'ecoute_differente_reponse',
          'le texte attendu « $attendu » doit être le mot entendu '
              '« $entendu ».',
        );
      }
      final harakat = donnees['harakat'] as bool? ?? false;
      if (harakat && langue != 'ar') {
        erreur(
          '$chemin/donnees/harakat',
          'harakat_hors_arabe',
          'la rangée de harakat n\'existe que pour un exercice en arabe.',
        );
      }
      if (langue == 'ar') {
        final avecHarakat = _contientHaraka(attendu);
        if (avecHarakat &&
            !harakat &&
            !normalisation.contains('harakat_ignorees')) {
          erreur(
            '$chemin/reponse/texte',
            'harakat_impossibles',
            'le mot attendu porte des harakat que l\'enfant ne peut pas '
                'écrire : proposer la rangée de harakat (donnees.harakat) '
                'ou comparer sans harakat (normalisation '
                'harakat_ignorees).',
          );
        }
        if (harakat && !avecHarakat) {
          avertissement(
            '$chemin/reponse/texte',
            'harakat_manquantes_reponse',
            'la rangée de harakat est proposée mais le mot attendu '
                '« $attendu » n\'en porte aucune.',
          );
        }
      }
      // Clavier réduit (texte.md §3) : les lettres du mot et 4 à 6 lettres
      // en trop, recommandé en 1re et 2e.
      final clavier = donnees['clavier'] as String?;
      final lettres = donnees['lettres'] as String?;
      if (langue != 'ar' && (clavier != null || lettres != null)) {
        erreur(
          '$chemin/donnees/clavier',
          'clavier_hors_arabe',
          'le clavier du moteur (clavier, lettres) n\'existe que pour un '
              'exercice en arabe : le clavier système sert en $langue.',
        );
      }
      if (clavier == 'reduit') {
        if (lettres == null) {
          erreur(
            '$chemin/donnees/lettres',
            'clavier_sans_lettres',
            'un clavier réduit exige donnees.lettres : les lettres du mot '
                'et 4 à 6 lettres en trop.',
          );
        } else {
          final touches = <int>{};
          for (final r in lettres.runes) {
            if (!touches.add(r)) {
              erreur(
                '$chemin/donnees/lettres',
                'element_duplique',
                'la lettre « ${String.fromCharCode(r)} » est deux fois sur '
                    'le clavier réduit.',
              );
            }
          }
          final attenduNu = _sansHarakat(attendu).runes
              .where(_estLettreArabe)
              .toSet();
          final manquantes = attenduNu.where((r) => !touches.contains(r));
          if (manquantes.isNotEmpty) {
            erreur(
              '$chemin/donnees/lettres',
              'clavier_lettre_manquante',
              'le clavier réduit ne porte pas toutes les lettres du mot '
                  'attendu : il manque '
                  '« ${manquantes.map(String.fromCharCode).join(' ')} ».',
            );
          }
          final enTrop = touches.difference(attenduNu).length;
          if (enTrop < _lettresEnTropMin || enTrop > _lettresEnTropMax) {
            avertissement(
              '$chemin/donnees/lettres',
              'clavier_lettres_en_trop',
              '$enTrop lettre(s) en trop sur le clavier réduit : de '
                  '$_lettresEnTropMin à $_lettresEnTropMax attendues.',
            );
          }
        }
      } else if (lettres != null) {
        erreur(
          '$chemin/donnees/lettres',
          'clavier_lettres_inutiles',
          'donnees.lettres ne sert qu\'avec clavier: reduit.',
        );
      }
      if (langue == 'ar' &&
          niveau != null &&
          niveau <= _niveauClavierReduit &&
          clavier != 'reduit') {
        avertissement(
          '$chemin/donnees',
          'clavier_complet_petits',
          'en ${niveau == 1 ? '1re' : '2e'} année, le clavier réduit est '
              'recommandé (clavier: reduit, lettres du mot et 4 à 6 lettres '
              'en trop).',
        );
      }
  }
  return problemes;
}

/// Clavier réduit de T17 : lettres en trop attendues, et dernier niveau où
/// il est recommandé (texte.md §3).
const _lettresEnTropMin = 4;
const _lettresEnTropMax = 6;
const _niveauClavierReduit = 2;

/// Les 3 types de base du moteur Manipulables (docs/moteurs/manipulables.md).
const _typesManipulables = {'T25', 'T27', 'T51', 'T26', 'T29', 'T52'};

/// T26 : le montant [cible] se forme avec les [pieces] (chacune autant de
/// fois qu'on veut).
bool montantAtteignable(int cible, List<int> pieces) {
  if (cible < 0) return false;
  final possible = List<bool>.filled(cible + 1, false)..[0] = true;
  for (var m = 1; m <= cible; m++) {
    for (final p in pieces) {
      if (p <= m && possible[m - p]) {
        possible[m] = true;
        break;
      }
    }
  }
  return possible[cible];
}

/// Droite numérique : au plus 20 intervalles, et 10 en 1re ou 2e année.
const _intervallesMax = 20;
const _intervallesMaxPetits = 10;

/// Règles des types de base du moteur Manipulables : la réponse correspond
/// à la cible, la droite numérique est cohérente.
List<ProblemeValidation> _reglesManipulables(
  String type,
  int? niveau,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
  String chemin,
) {
  final problemes = <ProblemeValidation>[];
  void erreur(String c, String code, String message) => problemes.add(
    ProblemeValidation(chemin: c, code: code, message: message),
  );
  switch (type) {
    case 'T25':
      final min = donnees['min'] as int;
      final max = donnees['max'] as int;
      final pas = donnees['pas'] as int? ?? 1;
      final cible = donnees['cible'] as int;
      if (max <= min) {
        erreur(
          '$chemin/donnees/max',
          'droite_invalide',
          'max ($max) doit dépasser min ($min).',
        );
      } else if ((max - min) % pas != 0) {
        erreur(
          '$chemin/donnees/pas',
          'droite_invalide',
          'l\'étendue de la droite ($min à $max) doit être un multiple du '
              'pas ($pas).',
        );
      } else {
        final intervalles = (max - min) ~/ pas;
        if (intervalles > _intervallesMax) {
          erreur(
            '$chemin/donnees',
            'droite_trop_longue',
            '$intervalles intervalles : $_intervallesMax au plus.',
          );
        } else if (niveau != null &&
            niveau <= 2 &&
            intervalles > _intervallesMaxPetits) {
          problemes.add(
            ProblemeValidation(
              chemin: '$chemin/donnees',
              code: 'graduations_trop_nombreuses',
              message:
                  '$intervalles intervalles en ${niveau == 1 ? '1re' : '2e'} '
                  'année : $_intervallesMaxPetits au plus.',
              gravite: Gravite.avertissement,
            ),
          );
        }
        if (cible < min || cible > max || (cible - min) % pas != 0) {
          erreur(
            '$chemin/donnees/cible',
            'cible_hors_droite',
            'la cible ($cible) doit être une graduation de la droite '
                '($min à $max par $pas).',
          );
        }
      }
      if (reponse['valeur'] != cible) {
        erreur(
          '$chemin/reponse/valeur',
          'reponse_valeur_incoherente',
          'la réponse (${reponse['valeur']}) doit être la cible ($cible).',
        );
      }
    case 'T27':
      final cible = donnees['cible'] as int;
      final canonique = donnees['canonique'] as bool? ?? true;
      final dizaines = reponse['dizaines'] as int;
      final unites = reponse['unites'] as int;
      if (dizaines * 10 + unites != cible) {
        erreur(
          '$chemin/reponse',
          'reponse_valeur_incoherente',
          '$dizaines dizaines et $unites unités font '
              '${dizaines * 10 + unites}, pas $cible.',
        );
      } else if (canonique && unites > 9) {
        erreur(
          '$chemin/reponse/unites',
          'reponse_valeur_incoherente',
          'en mode canonique, 9 unités au plus ($unites données).',
        );
      }
    case 'T51':
      final cible = donnees['cible'] as int;
      if (reponse['jetons'] != cible) {
        erreur(
          '$chemin/reponse/jetons',
          'reponse_valeur_incoherente',
          'la réponse (${reponse['jetons']}) doit être la cible ($cible).',
        );
      }
    case 'T26':
      final pieces = (donnees['pieces'] as List).cast<int>();
      final cible = donnees['cible'] as int;
      if (!montantAtteignable(cible, pieces)) {
        erreur(
          '$chemin/donnees/cible',
          'montant_inatteignable',
          'le montant $cible millimes ne se forme pas avec les pièces '
              '${pieces.join(', ')}.',
        );
      }
      if (reponse['montant'] != cible) {
        erreur(
          '$chemin/reponse/montant',
          'reponse_valeur_incoherente',
          'la réponse (${reponse['montant']}) doit être la cible ($cible).',
        );
      }
      if (niveau != null && niveau <= 2 && pieces.length > _elementsMaxPetits) {
        problemes.add(
          ProblemeValidation(
            chemin: '$chemin/donnees/pieces',
            code: 'elements_trop_nombreux',
            message:
                '${pieces.length} sortes de pièces en '
                '${niveau == 1 ? '1re' : '2e'} année : '
                '$_elementsMaxPetits au plus (CLAUDE.md §5).',
            gravite: Gravite.avertissement,
          ),
        );
      }
    case 'T29':
      final parts = donnees['parts'] as int;
      final numerateur = donnees['numerateur'] as int;
      if (numerateur > parts) {
        erreur(
          '$chemin/donnees/numerateur',
          'fraction_invalide',
          'le numérateur ($numerateur) dépasse le nombre de parts ($parts).',
        );
      }
      if (reponse['parts'] != numerateur) {
        erreur(
          '$chemin/reponse/parts',
          'reponse_valeur_incoherente',
          'la réponse (${reponse['parts']}) doit être le numérateur '
              '($numerateur).',
        );
      }
    case 'T52':
      final barres = (donnees['barres'] as List).cast<Map<String, dynamic>>();
      final idsBarres = <String>{};
      final segments = <String, int>{};
      final totaux = <String, int>{};
      for (var k = 0; k < barres.length; k++) {
        final id = barres[k]['id'] as String;
        if (!idsBarres.add(id)) {
          erreur(
            '$chemin/donnees/barres/$k/id',
            'element_duplique',
            'deux barres ont le même id « $id ».',
          );
        }
        var total = 0;
        final liste = (barres[k]['segments'] as List)
            .cast<Map<String, dynamic>>();
        for (var j = 0; j < liste.length; j++) {
          final sid = liste[j]['id'] as String;
          final valeur = liste[j]['valeur'] as int;
          if (segments.containsKey(sid)) {
            erreur(
              '$chemin/donnees/barres/$k/segments/$j/id',
              'element_duplique',
              'deux segments ont le même id « $sid ».',
            );
          }
          segments[sid] = valeur;
          total += valeur;
        }
        totaux[id] = total;
      }
      final inconnue = (donnees['inconnue'] as Map).cast<String, dynamic>();
      final barre = inconnue['barre'] as String?;
      final segment = inconnue['segment'] as String?;
      int? attendu;
      if ((barre == null) == (segment == null)) {
        erreur(
          '$chemin/donnees/inconnue',
          'inconnue_invalide',
          'l\'inconnue est le total d\'une barre ou un segment, un seul des '
              'deux.',
        );
      } else if (barre != null) {
        attendu = totaux[barre];
        if (attendu == null) {
          erreur(
            '$chemin/donnees/inconnue/barre',
            'inconnue_invalide',
            'la barre « $barre » n\'existe pas.',
          );
        }
      } else {
        attendu = segments[segment];
        if (attendu == null) {
          erreur(
            '$chemin/donnees/inconnue/segment',
            'inconnue_invalide',
            'le segment « $segment » n\'existe pas.',
          );
        }
      }
      final etiquettes = (donnees['etiquettes'] as List)
          .cast<Map<String, dynamic>>();
      final idsEtiquettes = <String>{};
      final valeursEtiquettes = <int>[];
      for (var k = 0; k < etiquettes.length; k++) {
        final id = etiquettes[k]['id'] as String;
        if (!idsEtiquettes.add(id)) {
          erreur(
            '$chemin/donnees/etiquettes/$k/id',
            'element_duplique',
            'deux étiquettes ont le même id « $id ».',
          );
        }
        final valeur = int.tryParse(etiquettes[k]['texte'] as String);
        if (valeur == null) {
          erreur(
            '$chemin/donnees/etiquettes/$k/texte',
            'etiquette_non_numerique',
            'une étiquette du modèle en barres est un nombre entier, pas '
                '« ${etiquettes[k]['texte']} ».',
          );
        } else {
          valeursEtiquettes.add(valeur);
        }
      }
      // Chaque segment connu a une étiquette de sa valeur, une par segment.
      final libres = List.of(valeursEtiquettes);
      final connus = [
        for (final MapEntry(key: sid, value: v) in segments.entries)
          if (sid != segment) (sid, v),
      ];
      for (final (sid, v) in connus) {
        if (!libres.remove(v)) {
          erreur(
            '$chemin/donnees/etiquettes',
            'segment_sans_etiquette',
            'aucune étiquette « $v » libre pour le segment « $sid ».',
          );
        }
      }
      if (libres.isEmpty && connus.isNotEmpty) {
        problemes.add(
          ProblemeValidation(
            chemin: '$chemin/donnees/etiquettes',
            code: 'etiquettes_sans_intrus',
            message:
                'toutes les étiquettes servent : ajouter une étiquette en '
                'trop, sinon il suffit de tout poser.',
            gravite: Gravite.avertissement,
          ),
        );
      }
      if (attendu != null && reponse['valeur'] != attendu) {
        erreur(
          '$chemin/reponse/valeur',
          'reponse_valeur_incoherente',
          'la réponse (${reponse['valeur']}) doit être l\'inconnue '
              '($attendu).',
        );
      }
  }
  return problemes;
}

/// Texte sans ses harakat (comparaison seulement, jamais appliqué au texte
/// stocké).
String _sansHarakat(String texte) => String.fromCharCodes(
  texte.runes.where((r) => !_estHaraka(r) && r != 0x0670),
);

/// Clé de comparaison d'un élément de suite ou d'un choix (texte, image et
/// emoji).
String _cleElement(Map<String, dynamic> e) =>
    '${e['texte'] ?? ''}|${e['image'] ?? ''}|${e['emoji'] ?? ''}';

/// Élément attendu après [suite] : motif répété au moins deux fois
/// (triangle, cercle, triangle, cercle), ou suite arithmétique d'entiers
/// (2, 4, 6). `null` si aucune des deux règles ne s'applique : la réponse
/// n'est alors pas contrôlée.
String? _suivantDeLaSuite(List<Map<String, dynamic>> suite) {
  final cles = suite.map(_cleElement).toList();
  for (var p = 1; p * 2 <= cles.length; p++) {
    var periodique = true;
    for (var i = p; i < cles.length && periodique; i++) {
      periodique = cles[i] == cles[i - p];
    }
    if (periodique) return cles[cles.length - p];
  }
  final nombres = [
    for (final e in suite)
      if (e['image'] == null && e['emoji'] == null)
        int.tryParse('${e['texte']}'),
  ];
  if (nombres.length == suite.length && !nombres.contains(null)) {
    final pas = nombres[1]! - nombres[0]!;
    var arithmetique = true;
    for (var i = 2; i < nombres.length && arithmetique; i++) {
      arithmetique = nombres[i]! - nombres[i - 1]! == pas;
    }
    if (arithmetique) return '${nombres.last! + pas}||';
  }
  return null;
}

bool _estHaraka(int r) => r >= 0x064B && r <= 0x0652;

/// Une lettre arabe nue : une seule rune, lettre de base, sans tatweel ni
/// haraka (tuile de T56).
bool _lettreNue(String texte) {
  final runes = texte.runes.toList();
  return runes.length == 1 && _estLettreArabe(runes.single);
}

bool _estLettreArabe(int r) => r >= 0x0621 && r <= 0x064A && r != 0x0640;

/// Lettres d'un mot vocalisé, chacune avec les runes de ses harakat (dans
/// l'ordre du texte, jamais réordonnées ici). Les autres caractères
/// (espaces, tatweel) sont ignorés.
List<(String, List<int>)> _lettresEtHarakat(String mot) {
  final lettres = <(String, List<int>)>[];
  for (final r in mot.runes) {
    if (_estLettreArabe(r)) {
      lettres.add((String.fromCharCode(r), []));
    } else if (_estHaraka(r) && lettres.isNotEmpty) {
      lettres.last.$2.add(r);
    }
  }
  return lettres;
}

/// Convention B : alif suscrit simplifié (هَذِهِ, jamais هٰذِهِ), donc aucun
/// U+0670 dans les textes.
List<ProblemeValidation> _alifSuscrit(List<(String, String)> textes) => [
  for (final (chemin, texte) in textes)
    if (texte.runes.contains(0x0670))
      ProblemeValidation(
        chemin: chemin,
        code: 'alif_suscrit',
        message:
            'alif suscrit (U+0670) interdit par la convention B : écrire '
            'هَذِهِ et non هٰذِهِ (docs/conventions-arabe.md). Texte : « $texte ».',
        gravite: Gravite.avertissement,
      ),
];

/// Convention C : le lam de l'article porte un soukoun devant une lettre
/// lunaire, hamza comprise (الْكَلِمَةُ, الْإِعْدَادَاتُ). Seuls les textes
/// vocalisés sont contrôlés. Un lam avec kasra (الِاسْمُ) ou suivi d'une
/// lettre solaire (الصَّحِيحَةُ) n'est pas signalé.
final _lamNuDevantLunaire = RegExp(
  '\u0627\u0644[\u0621\u0623\u0625\u0622\u0628\u062C\u062D\u062E'
  '\u0639\u063A\u0641\u0642\u0643\u0645\u0647\u0648\u064A]',
);

List<ProblemeValidation> _lamSansSoukoun(List<(String, String)> textes) => [
  for (final (chemin, texte) in textes)
    if (_contientHaraka(texte) && _lamNuDevantLunaire.hasMatch(texte))
      ProblemeValidation(
        chemin: chemin,
        code: 'lam_sans_soukoun',
        message:
            "lam de l'article sans soukoun devant une lettre lunaire "
            '(convention C) : écrire الْ, par exemple الْكَلِمَةُ '
            '(docs/conventions-arabe.md). Texte : « $texte ».',
        gravite: Gravite.avertissement,
      ),
];

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

// Une lettre arabe seule, avec ou sans tatweel (ـجـ) : forme de lettre des
// T18 et lettre cible des T19, qui ne portent pas de haraka.
bool _formeDeLettre(String texte) {
  final runes = texte.runes.where((r) => r != 0x0640).toList();
  return runes.length == 1 && runes.single >= 0x0621 && runes.single <= 0x064A;
}

// Lettres arabes de base (hamza à yā').
bool _contientLettreArabe(String texte) =>
    texte.runes.any((r) => r >= 0x0621 && r <= 0x064A);

// Tanwīn, fatha, damma, kasra, shadda, sukūn et alif suscrit.
bool _contientHaraka(String texte) =>
    texte.runes.any((r) => (r >= 0x064B && r <= 0x0652) || r == 0x0670);
