// Génère docs/relecture/harakat.html : tous les textes arabes en statut
// brouillon (exemples de schema/exemples/, fixtures et libellés arabes des
// tests et du moteur, ARB de l'interface), groupés par type, en grand avec
// Noto Naskh Arabic (police embarquée : la page marche sans réseau), avec le
// fichier source, une case « ok » ou « à corriger » et un commentaire,
// exportables en JSON depuis la page. Les réponses sont gardées dans le
// navigateur (localStorage) entre deux ouvertures.
//
// Usage, depuis la racine du dépôt :
//   dart run tool/relecture_harakat.dart [chemin/de/sortie.html]
//
// Testé par test/relecture_harakat_test.dart (flutter test à la racine).
import 'dart:convert';
import 'dart:io';

/// Un texte arabe à relire.
class TexteARelire {
  const TexteARelire({
    required this.groupe,
    required this.source,
    required this.chemin,
    required this.texte,
  });

  /// Groupe d'affichage : type (« T01 QCM »), « Interface (ARB) »,
  /// « Libellés du moteur »...
  final String groupe;

  /// Fichier source, relatif à la racine du dépôt.
  final String source;

  /// Chemin dans le fichier (pointeur JSON, clé ARB, ligne d'un .dart).
  final String chemin;

  final String texte;

  /// Clé stable de l'entrée (export JSON, mémoire du navigateur).
  String get cle => '$source#$chemin';

  Map<String, Object?> get json => {
    'groupe': groupe,
    'source': source,
    'chemin': chemin,
    'texte': texte,
  };
}

bool _lettreArabe(int r) => r >= 0x0621 && r <= 0x064A && r != 0x0640;
bool _haraka(int r) => r >= 0x064B && r <= 0x0652 || r == 0x0670;

/// Le texte mérite une relecture : au moins une lettre arabe, et plus
/// qu'une lettre seule (formes de T18, tuiles de lettres), sauf s'il porte
/// une haraka.
bool texteARelire(String texte) {
  final runes = texte.runes.toList();
  final lettres = runes.where(_lettreArabe).length;
  if (lettres == 0) return false;
  if (lettres == 1 && !runes.any(_haraka)) return false;
  return true;
}

/// Chemins JSON dont les textes sont des lettres nues par construction
/// (grille des mots mêlés, touches du clavier réduit).
bool _cheminSansHarakat(String chemin) =>
    RegExp(r'^/donnees/grille/\d+$').hasMatch(chemin) ||
    chemin == '/donnees/lettres';

final _type = RegExp(r"type:\s*'(T\d\d)'");
final _litteral = RegExp(r"'((?:[^'\\\n]|\\.)*)'");

/// Noms des types du MVP (registre), pour le libellé des groupes. Lu dans
/// registre_types.dart pour ne pas dupliquer la liste.
Map<String, String> lireNomsTypes(Directory racine) {
  final fichier = File(
    '${racine.path}/packages/moteur_exercices/lib/src/registre/'
    'registre_types.dart',
  );
  if (!fichier.existsSync()) return const {};
  final texte = fichier.readAsStringSync();
  final noms = <String, String>{};
  // TypeExercice('T01', 'QCM', ...) ou sur plusieurs lignes, nom entre
  // apostrophes ou entre guillemets ("Trouve l'intrus").
  for (final m in RegExp(
    r'''TypeExercice\(\s*'(T\d\d)',\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)")''',
  ).allMatches(texte)) {
    noms[m.group(1)!] = (m.group(2) ?? m.group(3)!).replaceAll(r"\'", "'");
  }
  return noms;
}

/// Collecte tous les textes arabes à relire du dépôt [racine].
List<TexteARelire> collecterTextes(Directory racine) {
  final noms = lireNomsTypes(racine);
  String groupeType(String? type) =>
      type == null ? 'Tests sans type' : '$type ${noms[type] ?? ''}'.trim();
  final textes = <TexteARelire>[];

  // 1. Exemples en brouillon.
  final exemples = Directory('${racine.path}/schema/exemples');
  if (exemples.existsSync()) {
    final fichiers =
        exemples
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in fichiers) {
      final source = _relatif(racine, f);
      Object? decode;
      try {
        decode = jsonDecode(f.readAsStringSync());
      } on FormatException {
        continue;
      }
      if (decode is! Map<String, dynamic>) continue;
      if (decode['statut'] != 'brouillon') continue;
      final type = decode['type'] as String?;
      _parcourir(decode, '', (chemin, texte) {
        if (_cheminSansHarakat(chemin)) return;
        if (chemin.startsWith('/empreinte') || chemin.startsWith('/id')) {
          return;
        }
        if (!texteARelire(texte)) return;
        textes.add(
          TexteARelire(
            groupe: groupeType(type),
            source: source,
            chemin: chemin,
            texte: texte,
          ),
        );
      });
    }
  }

  // 2. Étapes embarquées en brouillon (exercices un à un).
  final contenu = Directory('${racine.path}/apps/mobile/assets/content');
  if (contenu.existsSync()) {
    final fichiers =
        contenu
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in fichiers) {
      final source = _relatif(racine, f);
      Object? decode;
      try {
        decode = jsonDecode(f.readAsStringSync());
      } on FormatException {
        continue;
      }
      if (decode is! Map<String, dynamic>) continue;
      final exercices = decode['exercices'];
      if (exercices is! List) continue;
      for (var i = 0; i < exercices.length; i++) {
        final ex = exercices[i];
        if (ex is! Map<String, dynamic> || ex['statut'] != 'brouillon') {
          continue;
        }
        _parcourir(ex, '/exercices/$i', (chemin, texte) {
          if (!texteARelire(texte)) return;
          textes.add(
            TexteARelire(
              groupe: groupeType(ex['type'] as String?),
              source: source,
              chemin: chemin,
              texte: texte,
            ),
          );
        });
      }
    }
  }

  // 3. Fixtures des tests et libellés arabes du moteur (littéraux Dart).
  for (final (dossier, groupeDefaut) in [
    ('packages/moteur_exercices/test', 'Fixtures des tests'),
    ('schema/test', 'Fixtures des tests'),
    ('apps/mobile/test', 'Fixtures des tests'),
    ('packages/moteur_exercices/lib', 'Libellés du moteur'),
    ('apps/mobile/lib/dev', 'Libellés du moteur'),
  ]) {
    final d = Directory('${racine.path}/$dossier');
    if (!d.existsSync()) continue;
    final fichiers =
        d
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  !f.path.endsWith('.g.dart') &&
                  !f.path.endsWith('exemples_generes.dart') &&
                  !f.path.endsWith('schema_genere.dart'),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in fichiers) {
      final source = _relatif(racine, f);
      final lignes = f.readAsLinesSync();
      String? typeCourant;
      final vus = <String>{};
      for (var n = 0; n < lignes.length; n++) {
        final ligne = lignes[n];
        final t = _type.firstMatch(ligne);
        if (t != null) typeCourant = t.group(1);
        for (final m in _litteral.allMatches(ligne)) {
          final texte = m.group(1)!.replaceAll(r"\'", "'");
          if (!texteARelire(texte)) continue;
          if (!vus.add(texte)) continue;
          textes.add(
            TexteARelire(
              groupe: dossier.endsWith('lib') || dossier.endsWith('dev')
                  ? groupeDefaut
                  : groupeType(typeCourant),
              source: source,
              chemin: 'ligne ${n + 1}',
              texte: texte,
            ),
          );
        }
      }
    }
  }

  // 4. ARB de l'interface arabe.
  final arb = File('${racine.path}/apps/mobile/lib/l10n/app_ar.arb');
  if (arb.existsSync()) {
    final decode = jsonDecode(arb.readAsStringSync()) as Map<String, dynamic>;
    for (final MapEntry(key: cle, value: valeur) in decode.entries) {
      if (cle.startsWith('@') || valeur is! String) continue;
      if (!texteARelire(valeur)) continue;
      textes.add(
        TexteARelire(
          groupe: 'Interface (ARB)',
          source: _relatif(racine, arb),
          chemin: cle,
          texte: valeur,
        ),
      );
    }
  }
  return textes;
}

String _relatif(Directory racine, File f) =>
    f.path.substring(racine.path.length + 1).replaceAll(r'\', '/');

void _parcourir(
  Object? valeur,
  String chemin,
  void Function(String chemin, String texte) sur,
) {
  if (valeur is String) {
    sur(chemin, valeur);
  } else if (valeur is Map) {
    valeur.forEach((k, v) => _parcourir(v, '$chemin/$k', sur));
  } else if (valeur is List) {
    for (var i = 0; i < valeur.length; i++) {
      _parcourir(valeur[i], '$chemin/$i', sur);
    }
  }
}

/// Ordre des groupes : les types par numéro, puis les autres.
int comparerGroupes(String a, String b) {
  final ta = RegExp(r'^T(\d\d)').firstMatch(a);
  final tb = RegExp(r'^T(\d\d)').firstMatch(b);
  if (ta != null && tb != null) {
    return int.parse(ta.group(1)!).compareTo(int.parse(tb.group(1)!));
  }
  if (ta != null) return -1;
  if (tb != null) return 1;
  return a.compareTo(b);
}

String _html(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// La page de relecture, autonome : police en base64, aucun lien réseau.
/// [police] : octets de NotoNaskhArabic-Regular.ttf, `null` pour une page
/// sans police embarquée (tests).
String genererHtml(
  List<TexteARelire> textes, {
  List<int>? police,
  DateTime? date,
}) {
  final groupes = <String, List<TexteARelire>>{};
  for (final t in textes) {
    groupes.putIfAbsent(t.groupe, () => []).add(t);
  }
  final nomsGroupes = groupes.keys.toList()..sort(comparerGroupes);
  final quand = (date ?? DateTime.now()).toIso8601String().substring(0, 10);
  final fontFace = police == null
      ? ''
      : '''
@font-face {
  font-family: 'Noto Naskh Arabic';
  src: url(data:font/ttf;base64,${base64Encode(police)}) format('truetype');
  font-weight: 400;
}
''';
  final b = StringBuffer()
    ..writeln('<!doctype html>')
    ..writeln('<html lang="fr">')
    ..writeln('<head>')
    ..writeln('<meta charset="utf-8">')
    ..writeln(
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
    )
    ..writeln('<title>Relecture des harakat</title>')
    ..writeln('<style>')
    ..write(fontFace)
    ..writeln('''
:root { color-scheme: light; }
body { font-family: -apple-system, "Segoe UI", sans-serif; margin: 0; background: #f6f3ee; color: #16243a; }
header { position: sticky; top: 0; background: #fff; border-bottom: 1px solid #ddd; padding: 12px 20px; display: flex; gap: 16px; align-items: center; flex-wrap: wrap; z-index: 1; }
header h1 { font-size: 18px; margin: 0; flex: 1; }
.compteurs { font-size: 14px; color: #555; }
button { font: inherit; padding: 8px 14px; border-radius: 10px; border: 1px solid #2f6fed; background: #2f6fed; color: #fff; cursor: pointer; }
button.alt { background: #fff; color: #2f6fed; }
main { padding: 16px 20px 80px; max-width: 1100px; margin: 0 auto; }
details { background: #fff; border: 1px solid #e3ded6; border-radius: 14px; margin: 12px 0; }
summary { cursor: pointer; padding: 12px 16px; font-weight: 600; }
summary .n { color: #777; font-weight: 400; margin-left: 8px; }
.entree { display: grid; grid-template-columns: 1fr 280px; gap: 12px 20px; padding: 14px 16px; border-top: 1px solid #eee; align-items: start; }
.entree.ok { background: #eef6e9; }
.entree.a-corriger { background: #fbeeea; }
.texte { font-family: 'Noto Naskh Arabic', 'Geeza Pro', serif; font-size: 34px; line-height: 1.9; direction: rtl; text-align: right; }
.source { font-size: 12px; color: #777; direction: ltr; text-align: left; word-break: break-all; margin-top: 4px; }
.verdict { display: flex; flex-direction: column; gap: 6px; font-size: 14px; }
.verdict label { display: flex; gap: 6px; align-items: center; }
textarea { width: 100%; min-height: 56px; font: inherit; font-size: 14px; border: 1px solid #ccc; border-radius: 8px; padding: 6px; box-sizing: border-box; }
@media (max-width: 700px) { .entree { grid-template-columns: 1fr; } .texte { font-size: 30px; } }
</style>
</head>
<body>
<header>
  <h1>Relecture des harakat (textes en brouillon, $quand)</h1>
  <span class="compteurs" id="compteurs"></span>
  <button class="alt" id="tout-ok" type="button">Tout ouvrir</button>
  <button id="exporter" type="button">Exporter en JSON</button>
</header>
<main>
<p>Chaque texte arabe des exemples, des fixtures et de l'interface, tel qu'il est stocké. Pour chaque ligne : « ok » ou « à corriger », et un commentaire (la bonne écriture par exemple). Les choix sont gardés dans ce navigateur et s'exportent en JSON par le bouton du haut. Page autonome, sans réseau.</p>
''');
  for (final groupe in nomsGroupes) {
    final liste = groupes[groupe]!;
    b.writeln(
      '<details open><summary>${_html(groupe)}<span class="n">'
      '${liste.length} texte${liste.length > 1 ? 's' : ''}</span></summary>',
    );
    for (final t in liste) {
      final cle = _html(t.cle);
      b.writeln('<div class="entree" data-cle="$cle">');
      b.writeln('<div>');
      b.writeln('<div class="texte" lang="ar">${_html(t.texte)}</div>');
      b.writeln(
        '<div class="source">${_html(t.source)} · ${_html(t.chemin)}</div>',
      );
      b.writeln('</div>');
      b.writeln('<div class="verdict">');
      b.writeln(
        '<label><input type="radio" name="v-$cle" value="ok"> ok</label>',
      );
      b.writeln(
        '<label><input type="radio" name="v-$cle" value="a-corriger"> '
        'à corriger</label>',
      );
      b.writeln(
        '<textarea placeholder="Commentaire ou écriture correcte"></textarea>',
      );
      b.writeln('</div>');
      b.writeln('</div>');
    }
    b.writeln('</details>');
  }
  b.writeln('</main>');
  b.writeln('<script>');
  b.writeln('const TEXTES = ${jsonEncode([for (final t in textes) t.json])};');
  b.writeln(r'''
const CLE_MEMOIRE = 'relecture-harakat';
function lireMemoire() {
  try { return JSON.parse(localStorage.getItem(CLE_MEMOIRE) || '{}'); } catch (e) { return {}; }
}
function ecrireMemoire(m) {
  try { localStorage.setItem(CLE_MEMOIRE, JSON.stringify(m)); } catch (e) { }
}
function etatDe(entree) {
  const coche = entree.querySelector('input[type=radio]:checked');
  return { verdict: coche ? coche.value : null, commentaire: entree.querySelector('textarea').value };
}
function rafraichir() {
  const entrees = document.querySelectorAll('.entree');
  let ok = 0, corriger = 0;
  entrees.forEach(e => {
    const v = etatDe(e).verdict;
    e.classList.toggle('ok', v === 'ok');
    e.classList.toggle('a-corriger', v === 'a-corriger');
    if (v === 'ok') ok++;
    if (v === 'a-corriger') corriger++;
  });
  document.getElementById('compteurs').textContent =
    entrees.length + ' textes, ' + ok + ' ok, ' + corriger + ' à corriger, ' + (entrees.length - ok - corriger) + ' non lus';
}
function sauver() {
  const m = {};
  document.querySelectorAll('.entree').forEach(e => { m[e.dataset.cle] = etatDe(e); });
  ecrireMemoire(m);
  rafraichir();
}
(function restaurer() {
  const m = lireMemoire();
  document.querySelectorAll('.entree').forEach(e => {
    const etat = m[e.dataset.cle];
    if (!etat) return;
    if (etat.verdict) {
      const r = e.querySelector('input[value="' + etat.verdict + '"]');
      if (r) r.checked = true;
    }
    e.querySelector('textarea').value = etat.commentaire || '';
  });
  rafraichir();
})();
document.addEventListener('change', sauver);
document.addEventListener('input', sauver);
document.getElementById('tout-ok').addEventListener('click', () => {
  document.querySelectorAll('details').forEach(d => d.open = true);
});
document.getElementById('exporter').addEventListener('click', () => {
  const m = lireMemoire();
  const lignes = TEXTES.map(t => {
    const etat = m[t.source + '#' + t.chemin] || {};
    return Object.assign({}, t, { verdict: etat.verdict || null, commentaire: etat.commentaire || '' });
  });
  const contenu = JSON.stringify({ date: new Date().toISOString(), textes: lignes }, null, 2);
  const url = URL.createObjectURL(new Blob([contenu], { type: 'application/json' }));
  const a = document.createElement('a');
  a.href = url;
  a.download = 'relecture-harakat-' + new Date().toISOString().slice(0, 10) + '.json';
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
});
''');
  b.writeln('</script>');
  b.writeln('</body>');
  b.writeln('</html>');
  return b.toString();
}

void main(List<String> arguments) {
  final racine = Directory(File.fromUri(Platform.script).parent.parent.path);
  final sortie = File(
    arguments.isNotEmpty
        ? arguments.first
        : '${racine.path}/docs/relecture/harakat.html',
  );
  final police = File(
    '${racine.path}/packages/moteur_exercices/fonts/'
    'NotoNaskhArabic-Regular.ttf',
  );
  final textes = collecterTextes(racine);
  sortie.parent.createSync(recursive: true);
  sortie.writeAsStringSync(
    genererHtml(
      textes,
      police: police.existsSync() ? police.readAsBytesSync() : null,
    ),
  );
  final groupes = textes.map((t) => t.groupe).toSet();
  stdout.writeln(
    '${sortie.path} : ${textes.length} textes dans ${groupes.length} groupes.',
  );
}
