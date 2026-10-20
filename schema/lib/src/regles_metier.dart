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

/// Les 8 types du moteur Glisser-déposer (docs/moteurs/glisser-deposer.md).
const _typesGlisser = {'T06', 'T09', 'T11', 'T12', 'T13', 'T14', 'T15', 'T16'};

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

  // Langue imposée : T12 (règle de la langue arabe) et T15 (lettres liées)
  // en arabe, T16 (syllabes) jamais en arabe.
  if ((type == 'T12' || type == 'T15') && langue != 'ar') {
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
    case 'T13' || 'T14':
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
