// Convertit le parcours d'arabe 1re année T1 écrit au format neutre
// « brouillon-contenu » (docs/contenu/contenu-ar-1-t1.json) en étapes
// edu-content/1.0, un fichier par étape dans apps/mobile/assets/content/
// (A0-08). Chaque exercice est adapté au schéma de son type : gabarit, ids
// des choix et des éléments, forme de la réponse, empreinte sha256.
//
// Règles de la conversion (session du 21 oct. 2026) :
// - aucun texte arabe n'est modifié : les harakat restent celles de la
//   source, sans ajout, retrait ni déplacement (contrôlé par le test) ;
// - T20 Tracé de lettre, retiré du MVP (décision 40), est remplacé dans la
//   séquence أَكْتُبُ de chaque lettre par un T17 Dictée au clavier réduit
//   d'un mot court de l'étape (table [dictees]), avec un id nouveau ;
// - le statut de la source est gardé (x01 et x02 de ar-1-t1-u1-e01 restent
//   valides, leurs textes ne changent pas), tout le reste est en brouillon.
//
// Usage, depuis la racine du dépôt :
//   dart run tool/convertir_contenu.dart
//
// Testé par test/convertir_contenu_test.dart (flutter test à la racine) et,
// pour la validation edu-content/1.0 des fichiers produits, par
// apps/mobile/test/contenu_embarque_test.dart.
import 'dart:convert';
import 'dart:io';

/// Source neutre, écrite à la main (parcours de la démo).
const cheminSource = 'docs/contenu/contenu-ar-1-t1.json';

/// Dossier des étapes embarquées (déclaré dans apps/mobile/pubspec.yaml).
const dossierSortie = 'apps/mobile/assets/content';

/// Date de la conversion, portée par le bloc generation.
const dateConversion = '2026-10-21';

void main() {
  final racine = File.fromUri(Platform.script).parent.parent.path;
  final source = jsonDecode(
    File('$racine/$cheminSource').readAsStringSync(),
  ) as Map<String, dynamic>;
  final etapes = convertirParcours(source);
  for (final MapEntry(key: id, value: etape) in etapes.entries) {
    final fichier = File('$racine/${cheminEtape(id)}')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(texteEtape(etape));
    final n = (etape['exercices'] as List).length;
    stdout.writeln('${fichier.path} : $n exercices');
  }
  stdout.writeln('${etapes.length} étapes converties.');
}

/// Chemin du fichier d'une étape, relatif à la racine du dépôt
/// (`apps/mobile/assets/content/ar/1/ar-1-t1-u1-e01.json`).
String cheminEtape(String id) {
  final parties = id.split('-');
  return '$dossierSortie/${parties[0]}/${parties[1]}/$id.json';
}

/// Texte du fichier d'une étape : JSON indenté de deux espaces, sans
/// échappement des caractères non ASCII, terminé par un saut de ligne.
String texteEtape(Map<String, dynamic> etape) =>
    '${const JsonEncoder.withIndent('  ').convert(etape)}\n';

/// Convertit tout le parcours : id d'étape vers étape edu-content/1.0,
/// dans l'ordre de la source.
Map<String, Map<String, dynamic>> convertirParcours(
  Map<String, dynamic> source, {
  String date = dateConversion,
}) {
  if (source['format'] != 'brouillon-contenu') {
    throw FormatException('format inattendu : ${source['format']}');
  }
  final resultat = <String, Map<String, dynamic>>{};
  for (final bloc in (source['etapes'] as List).cast<Map<String, dynamic>>()) {
    final etape = convertirEtape(bloc, date: date);
    resultat[(etape['etape'] as Map)['id'] as String] = etape;
  }
  return resultat;
}

/// Convertit une étape de la source (bloc `etape` et `exercices`).
Map<String, dynamic> convertirEtape(
  Map<String, dynamic> bloc, {
  String date = dateConversion,
}) {
  final etape = bloc['etape'] as Map<String, dynamic>;
  final id = etape['id'] as String;
  final titre = etape['titre'] as String;
  final sources = (bloc['exercices'] as List).cast<Map<String, dynamic>>();
  final idsPris = sources.map((x) => x['id'] as String).toSet();

  final exercices = <Map<String, dynamic>>[];
  final parSequence = <String, List<String>>{};
  for (final x in sources) {
    final Map<String, dynamic> converti;
    if (x['type'] == 'T20') {
      converti = dicteeDeRemplacement(
        x,
        idEtape: id,
        titreEtape: titre,
        idLibre: prochainId(id, idsPris),
      );
      idsPris.add(converti['id'] as String);
    } else {
      converti = convertirExercice(x);
    }
    exercices.add(converti);
    parSequence
        .putIfAbsent(x['seq'] as String, () => [])
        .add(converti['id'] as String);
  }

  final sequences = [
    for (final s in (etape['sequences'] as List).cast<Map<String, dynamic>>())
      {
        'id': s['id'],
        'titre': s['titre'],
        'exercices':
            parSequence[(s['id'] as String).split('-').last] ?? const [],
      },
  ];

  return {
    'generation': {
      'id': 'gen-$id-${date.replaceAll('-', '')}-01',
      'schema': 'edu-content/1.0',
      'date': date,
      'modele': 'manuel',
      'version_prompt': 'aucun',
      'auteur': 'Lamjed CHIHAOUI, converti par tool/convertir_contenu.dart',
    },
    'etape': {
      for (final champ in [
        'id',
        'matiere',
        'niveau',
        'trimestre',
        'unite',
        'ordre',
        'langue',
        'titre',
      ])
        champ: etape[champ],
      'sequences': sequences,
    },
    'exercices': exercices,
  };
}

/// Premier id `<etape>-xNN` libre après le plus grand numéro pris.
String prochainId(String idEtape, Set<String> pris) {
  var max = 0;
  for (final id in pris) {
    final n = int.tryParse(id.split('-x').last);
    if (n != null && n > max) max = n;
  }
  return '$idEtape-x${(max + 1).toString().padLeft(2, '0')}';
}

/// Convertit un exercice (tout type sauf T20).
Map<String, dynamic> convertirExercice(Map<String, dynamic> x) {
  final type = x['type'] as String;
  final donnees = x['donnees'] as Map<String, dynamic>;
  final reponse = x['reponse'] as Map<String, dynamic>;
  final (gabarit, donneesEdu, reponseEdu) = switch (type) {
    'T01' => convertirQcm(x['gabarit'] as String?, donnees, reponse),
    'T02' => ('vrai-faux-texte', convertirVraiFaux(donnees), reponse),
    'T03' => (
      'ecoute-image',
      {
        'ecoute': {'texte': donnees['audio']},
        'choix': choix(donnees['choix'] as List),
        'melanger': true,
      },
      reponse,
    ),
    'T07' => convertirToucherMots(donnees, reponse),
    'T09' => convertirAssociation(donnees),
    'T11' => convertirTri(donnees),
    'T13' => convertirOrdre(donnees, reponse),
    'T15' => convertirMot(donnees, reponse),
    'T18' => convertirFormeLettre(donnees, reponse),
    'T19' => convertirLettreVocalisee(donnees, reponse),
    _ => throw FormatException('type $type non pris en charge (${x['id']})'),
  };
  final feedbacks = x['feedbacks'] as Map<String, dynamic>;
  if (feedbacks.values.any((v) => v == null)) {
    throw FormatException('feedback manquant dans ${x['id']}');
  }
  final exercice = <String, dynamic>{
    'id': x['id'],
    'type': type,
    'gabarit': gabarit,
    'competence': x['competence'],
    'critere': 'C1',
    'niveau_critere': 'minimal',
    'langue': 'ar',
    'consigne': {'texte': x['consigne']},
    'donnees': donneesEdu,
    'reponse': reponseEdu,
    'feedbacks': feedbacks,
  };
  return terminer(exercice, statut: x['statut'] as String);
}

/// Ajoute l'empreinte, le statut et la version.
Map<String, dynamic> terminer(
  Map<String, dynamic> exercice, {
  required String statut,
}) => {
  ...exercice,
  'empreinte': empreinte(exercice),
  'statut': statut,
  'version': 1,
};

/// Choix du moteur Choix : `image` (emoji dans la source) devient `emoji`.
List<Map<String, dynamic>> choix(List source) => [
  for (final c in source.cast<Map<String, dynamic>>())
    {
      'id': c['id'],
      if (c['texte'] != null) 'texte': c['texte'],
      if (c['image'] != null) 'emoji': c['image'],
    },
];

/// T01 : le support rassemble l'image (emoji), le texte (une ou plusieurs
/// lignes), le mot écouté (`audio`) et le mot affiché en grand (`mot`).
(String, Map<String, dynamic>, Map<String, dynamic>) convertirQcm(
  String? gabarit,
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) {
  final support = <String, dynamic>{};
  final texte = donnees['texte'];
  if (texte is List) support['texte'] = texte.join('\n');
  if (texte is String) support['texte'] = texte;
  if (donnees['mot'] != null) support['texte'] = donnees['mot'];
  if (donnees['image'] != null) support['emoji'] = donnees['image'];
  if (donnees['audio'] != null) {
    support['ecoute'] = {'texte': donnees['audio']};
  }
  return (
    gabarit ?? 'qcm-texte',
    {
      if (support.isNotEmpty) 'support': support,
      'choix': choix(donnees['choix'] as List),
      'melanger': true,
    },
    reponse,
  );
}

/// T02 : l'affirmation seule. Le mot à écouter de la source (`audio`)
/// n'existe pas dans le moteur Vrai ou faux : il est laissé de côté, le mot
/// figure déjà dans l'affirmation (question notée au compte rendu).
Map<String, dynamic> convertirVraiFaux(Map<String, dynamic> donnees) => {
  'affirmation': donnees['affirmation'],
};

/// T07 : la phrase est la suite des mots séparés par une espace, la réponse
/// garde les index.
(String, Map<String, dynamic>, Map<String, dynamic>) convertirToucherMots(
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) {
  final indices = (reponse['indices'] as List).cast<int>();
  return (
    'toucher-mots',
    {
      'texte': (donnees['mots'] as List).join(' '),
      'plusieurs': indices.length > 1,
    },
    {'mots': indices},
  );
}

/// T09 : chaque paire de la source donne un mot à gauche (g1...) et son
/// image à droite (d1...), la réponse relie les deux.
(String, Map<String, dynamic>, Map<String, dynamic>) convertirAssociation(
  Map<String, dynamic> donnees,
) {
  final paires = (donnees['paires'] as List).cast<Map<String, dynamic>>();
  return (
    'association-mot-image',
    {
      'gauche': [
        for (var i = 0; i < paires.length; i++)
          {'id': 'g${i + 1}', 'texte': paires[i]['texte']},
      ],
      'droite': [
        for (var i = 0; i < paires.length; i++)
          {'id': 'd${i + 1}', 'emoji': paires[i]['image']},
      ],
      'melanger': true,
    },
    {
      'paires': [
        for (var i = 0; i < paires.length; i++)
          {'gauche': 'g${i + 1}', 'droite': 'd${i + 1}'},
      ],
    },
  );
}

/// T11 : catégories k1..., éléments e1..., classement d'après la catégorie
/// portée par chaque élément de la source.
(String, Map<String, dynamic>, Map<String, dynamic>) convertirTri(
  Map<String, dynamic> donnees,
) {
  final categories = (donnees['categories'] as List)
      .cast<Map<String, dynamic>>();
  final elements = (donnees['elements'] as List).cast<Map<String, dynamic>>();
  final idCategorie = {
    for (var i = 0; i < categories.length; i++)
      categories[i]['id'] as String: 'k${i + 1}',
  };
  return (
    'tri-bacs',
    {
      'categories': [
        for (var i = 0; i < categories.length; i++)
          {'id': 'k${i + 1}', 'titre': categories[i]['texte']},
      ],
      'elements': [
        for (var i = 0; i < elements.length; i++)
          {'id': 'e${i + 1}', 'texte': elements[i]['texte']},
      ],
      'melanger': true,
    },
    {
      'classement': [
        for (var i = 0; i < elements.length; i++)
          {
            'element': 'e${i + 1}',
            'categorie': idCategorie[elements[i]['categorie']]!,
          },
      ],
    },
  );
}

/// T13 : mots e1..., ordre attendu d'après les textes.
(String, Map<String, dynamic>, Map<String, dynamic>) convertirOrdre(
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) {
  final mots = donnees['mots'] as List;
  return (
    'ordre-mots',
    {
      'elements': [
        for (var i = 0; i < mots.length; i++)
          {'id': 'e${i + 1}', 'texte': mots[i]},
      ],
      'melanger': true,
    },
    {'ordre': idsParTexte(mots, reponse['ordre'] as List)},
  );
}

/// T15 : tuiles e1..., mot entendu, ordre attendu d'après les textes. Les
/// tuiles gardent leurs harakat (texte de la source inchangé). L'image de
/// la source n'a pas de place dans le schéma de T15 (question notée).
(String, Map<String, dynamic>, Map<String, dynamic>) convertirMot(
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) {
  final tuiles = donnees['tuiles'] as List;
  return (
    'mot-lettres',
    {
      'elements': [
        for (var i = 0; i < tuiles.length; i++)
          {'id': 'e${i + 1}', 'texte': tuiles[i]},
      ],
      'ecoute': {'texte': donnees['audio']},
      'melanger': true,
    },
    {'ordre': idsParTexte(tuiles, reponse['ordre'] as List)},
  );
}

/// Ids e1... des textes de [ordre] parmi [textes]. Un texte répété prend
/// à chaque fois le premier élément encore libre qui le porte.
List<String> idsParTexte(List textes, List ordre) {
  final pris = <int>{};
  final ids = <String>[];
  for (final t in ordre) {
    var trouve = -1;
    for (var i = 0; i < textes.length; i++) {
      if (textes[i] == t && !pris.contains(i)) {
        trouve = i;
        break;
      }
    }
    if (trouve < 0) {
      throw FormatException('« $t » absent des éléments $textes');
    }
    pris.add(trouve);
    ids.add('e${trouve + 1}');
  }
  return ids;
}

const _tatweel = 'ـ';

/// T18 : la lettre est celle des formes (sans tatweel), la position se lit
/// sur la forme attendue : `ب` isolée, `بـ` début, `ـبـ` milieu, `ـب` fin.
/// Les formes gardent leur ordre (melanger faux).
(String, Map<String, dynamic>, Map<String, dynamic>) convertirFormeLettre(
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) {
  final formes = (donnees['choix'] as List).cast<Map<String, dynamic>>();
  final bon = (reponse['choix'] as List).single;
  final forme = formes.firstWhere((c) => c['id'] == bon)['texte'] as String;
  final lettre = forme.replaceAll(_tatweel, '');
  if (lettre.runes.length != 1) {
    throw FormatException('forme de lettre inattendue « $forme »');
  }
  final avant = forme.startsWith(_tatweel);
  final apres = forme.endsWith(_tatweel);
  final position = avant && apres
      ? 'milieu'
      : avant
      ? 'fin'
      : apres
      ? 'debut'
      : 'isolee';
  return (
    'forme-lettre',
    {
      'lettre': lettre,
      'position': position,
      'mot': donnees['mot'],
      'choix': [
        for (final c in formes) {'id': c['id'], 'texte': c['texte']},
      ],
      'melanger': false,
    },
    reponse,
  );
}

/// Nom de chaque haraka d'après son signe (schéma edu-content/1.0).
const nomsHarakat = {'َ': 'fatha', 'ُ': 'damma', 'ِ': 'kasra', 'ْ': 'soukoun'};

/// T19 (forme lettre vocalisée) : la haraka demandée est celle que porte la
/// bonne réponse.
(String, Map<String, dynamic>, Map<String, dynamic>) convertirLettreVocalisee(
  Map<String, dynamic> donnees,
  Map<String, dynamic> reponse,
) {
  final lettres = (donnees['choix'] as List).cast<Map<String, dynamic>>();
  final bon = (reponse['choix'] as List).single;
  final texte = lettres.firstWhere((c) => c['id'] == bon)['texte'] as String;
  final runes = texte.runes.toList();
  final haraka = runes.length == 2
      ? nomsHarakat[String.fromCharCode(runes[1])]
      : null;
  if (haraka == null) {
    throw FormatException('lettre vocalisée inattendue « $texte »');
  }
  return (
    'lettre-vocalisee',
    {
      'haraka': haraka,
      'choix': [
        for (final c in lettres) {'id': c['id'], 'texte': c['texte']},
      ],
      'melanger': true,
    },
    reponse,
  );
}

/// Dictée qui remplace le T20 de chaque lettre : un mot court de l'étape
/// qui commence par la lettre, et son emoji. Les lettres du clavier réduit
/// sont celles du mot et [lettresEnTrop] lettres en trop.
const dictees = {
  'ب': (mot: 'بَابٌ', emoji: '🚪'),
  'ل': (mot: 'لَبَنٌ', emoji: '🥛'),
  'م': (mot: 'مَوْزٌ', emoji: '🍌'),
  'ر': (mot: 'رُزٌّ', emoji: '🍚'),
  'د': (mot: 'دِيكٌ', emoji: '🐓'),
  'ف': (mot: 'فَرَسٌ', emoji: '🐎'),
};

/// Lettres en trop du clavier réduit (4 à 6 attendues par le validateur) :
/// d'abord les lettres du trimestre, puis quelques lettres fréquentes.
const lettresEnTrop = 5;
const reserveLettres = ['ب', 'ل', 'م', 'ر', 'د', 'ف', 'ت', 'ن', 'س', 'ك'];

/// Alphabet du clavier arabe du moteur (même ordre que le clavier complet).
const alphabetClavier = 'ابتثجحخدذرزسشصضطظعغفقكلمنهويةىءأإآؤئ';

bool _estHaraka(int r) => r >= 0x064B && r <= 0x0652;

/// Lettres nues d'un mot vocalisé, dans l'ordre.
List<String> lettresNues(String mot) => [
  for (final r in mot.runes)
    if (!_estHaraka(r)) String.fromCharCode(r),
];

/// Le T17 qui remplace un T20 : textes nouveaux, en brouillon, écrits
/// d'après l'exemple T17-dictee.json du catalogue.
Map<String, dynamic> dicteeDeRemplacement(
  Map<String, dynamic> trace, {
  required String idEtape,
  required String titreEtape,
  required String idLibre,
}) {
  final lettre = (trace['donnees'] as Map)['lettre'] as String;
  final dictee = dictees[lettre];
  if (dictee == null) {
    throw FormatException('aucune dictée prévue pour la lettre « $lettre »');
  }
  final mot = dictee.mot;
  final nues = lettresNues(mot);
  final touches = {...nues};
  for (final l in reserveLettres) {
    if (touches.length >= nues.toSet().length + lettresEnTrop) break;
    touches.add(l);
  }
  final clavier = [
    for (final l in alphabetClavier.split(''))
      if (touches.contains(l)) l,
  ].join();
  // Nom de la lettre, au génitif, lu dans le titre « حَرْفُ الْبَاءِ ».
  final nomLettre = titreEtape.split(' ').last;
  final epele = nues.join(' ثُمَّ ');
  final exercice = <String, dynamic>{
    'id': idLibre,
    'type': 'T17',
    'gabarit': 'dictee-mot',
    'competence': 'ar-ecriture-dictee',
    'critere': 'C1',
    'niveau_critere': 'minimal',
    'langue': 'ar',
    'consigne': {
      'texte': {
        'masculin': 'اِسْتَمِعْ وَاكْتُبِ الْكَلِمَةَ.',
        'feminin': 'اِسْتَمِعِي وَاكْتُبِي الْكَلِمَةَ.',
      },
    },
    'donnees': {
      'ecoute': {'texte': mot},
      'emoji': dictee.emoji,
      'harakat': false,
      'clavier': 'reduit',
      'lettres': clavier,
    },
    'reponse': {'texte': mot},
    'normalisation': ['harakat_ignorees'],
    'feedbacks': {
      'reussite': {
        'masculin': 'إِجَابَتُكَ صَحِيحَةٌ: $mot تُكْتَبُ $epele.',
        'feminin': 'إِجَابَتُكِ صَحِيحَةٌ: $mot تُكْتَبُ $epele.',
      },
      'indice': 'الْكَلِمَةُ تَبْدَأُ بِحَرْفِ $nomLettre.',
      'explication': '$mot: $epele.',
    },
  };
  return terminer(exercice, statut: 'brouillon');
}

/// Empreinte d'un exercice (schema/README.md) : `sha256:` puis le hash du
/// JSON canonique de type, consigne, donnees et reponse (clés triées, sans
/// espace, UTF-8 sans échappement des caractères non ASCII).
String empreinte(Map<String, dynamic> exercice) {
  final canonique = jsonCanonique({
    for (final champ in ['type', 'consigne', 'donnees', 'reponse'])
      champ: exercice[champ],
  });
  return 'sha256:${sha256Hex(utf8.encode(canonique))}';
}

/// JSON compact aux clés triées, à tous les niveaux.
String jsonCanonique(Object? valeur) => jsonEncode(_trier(valeur));

Object? _trier(Object? valeur) {
  if (valeur is Map) {
    final cles = valeur.keys.map((k) => k as String).toList()..sort();
    return {for (final k in cles) k: _trier(valeur[k])};
  }
  if (valeur is List) return [for (final v in valeur) _trier(v)];
  return valeur;
}

// SHA-256 (FIPS 180-4), en Dart pur pour ne pas ajouter de dépendance au
// workspace. Contrôlé par les vecteurs de test connus et par les empreintes
// déjà écrites dans ar-1-t1-u1-e01.json.
const _k = <int>[
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

const _masque = 0xFFFFFFFF;

int _rotr(int x, int n) => ((x >>> n) | (x << (32 - n))) & _masque;

/// Hash SHA-256 de [message], en hexadécimal minuscule.
String sha256Hex(List<int> message) {
  final h = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];
  final bits = message.length * 8;
  final octets = [...message, 0x80];
  while (octets.length % 64 != 56) {
    octets.add(0);
  }
  for (var i = 7; i >= 0; i--) {
    octets.add((bits >> (8 * i)) & 0xff);
  }
  final w = List<int>.filled(64, 0);
  for (var debut = 0; debut < octets.length; debut += 64) {
    for (var i = 0; i < 16; i++) {
      final j = debut + 4 * i;
      w[i] =
          (octets[j] << 24) |
          (octets[j + 1] << 16) |
          (octets[j + 2] << 8) |
          octets[j + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & _masque;
    }
    var a = h[0], b = h[1], c = h[2], d = h[3];
    var e = h[4], f = h[5], g = h[6], hh = h[7];
    for (var i = 0; i < 64; i++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e & _masque) & g);
      final t1 = (hh + s1 + ch + _k[i] + w[i]) & _masque;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & _masque;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) & _masque;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & _masque;
    }
    h[0] = (h[0] + a) & _masque;
    h[1] = (h[1] + b) & _masque;
    h[2] = (h[2] + c) & _masque;
    h[3] = (h[3] + d) & _masque;
    h[4] = (h[4] + e) & _masque;
    h[5] = (h[5] + f) & _masque;
    h[6] = (h[6] + g) & _masque;
    h[7] = (h[7] + hh) & _masque;
  }
  return h.map((v) => v.toRadixString(16).padLeft(8, '0')).join();
}
