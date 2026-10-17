// Garde-fou du design system : aucune couleur, taille de texte, rayon,
// espacement ou épaisseur écrit en dur dans les widgets. Tout passe par
// ThemeYasmina et les jetons générés depuis docs/design-system/tokens.json.
//
// Usage, depuis la racine du dépôt : dart run tool/garde_design.dart
//
// Parcourt lib/ de packages/moteur_exercices, apps/mobile et apps/apercu_web,
// sauf les fichiers générés (*.g.dart, lib/l10n/) et lib/src/theme/ (seule
// autorité). Exception possible, sur la ligne signalée :
// `// design-ok : raison`.
import 'dart:io';

const _dossiers = [
  'packages/moteur_exercices/lib',
  'apps/mobile/lib',
  'apps/apercu_web/lib',
];

const _exception = 'design-ok';

/// Nombre littéral non nul (0 n'est pas une valeur de design).
final _nombre = RegExp(r'(?<![\w.])(?!0(?:\.0+)?(?![\d.]))\d+(?:\.\d+)?');

/// Règles qui portent sur une seule ligne.
final _reglesLigne = <(RegExp, String)>[
  (RegExp(r'Color\(0x'), 'couleur en dur'),
  (RegExp(r'Color\.from(?:ARGB|RGBO)\('), 'couleur en dur'),
  (RegExp(r'\bColors\.(?!transparent\b)\w+'), 'couleur Material en dur'),
  (RegExp(r'fontSize:\s*\d'), 'taille de texte en dur'),
  (RegExp(r'circular\(\s*\d'), 'rayon en dur'),
];

/// Appels dont les arguments (sur une ou plusieurs lignes) ne doivent pas
/// contenir de nombre, ou seulement pour certains paramètres.
final _reglesAppel = <(RegExp, RegExp?, String)>[
  (RegExp(r'\bEdgeInsets(?:Directional)?\.\w+\('), null, 'espacement en dur'),
  (
    RegExp(r'\bSizedBox(?:\.\w+)?\('),
    RegExp(r'\b(?:width|height|dimension):\s*$'),
    'dimension en dur',
  ),
  (
    RegExp(r'\b(?:BorderSide|Border\.all)\('),
    RegExp(r'\bwidth:\s*$'),
    'épaisseur en dur',
  ),
];

void main() {
  final racine = File.fromUri(Platform.script).parent.parent.path;
  final problemes = <String>[];
  for (final dossier in _dossiers) {
    final repertoire = Directory('$racine/$dossier');
    if (!repertoire.existsSync()) continue;
    for (final fichier in repertoire.listSync(recursive: true)) {
      if (fichier is! File || !fichier.path.endsWith('.dart')) continue;
      final relatif = fichier.path.substring(racine.length + 1);
      if (relatif.endsWith('.g.dart') ||
          relatif.contains('/lib/l10n/') ||
          relatif.contains('/lib/src/theme/')) {
        continue;
      }
      problemes.addAll(analyser(relatif, fichier.readAsStringSync()));
    }
  }
  if (problemes.isNotEmpty) {
    stderr
      ..writeln(
        'Valeurs de design en dur : passer par ThemeYasmina et les jetons, '
        'ou justifier avec « // $_exception : raison ».',
      )
      ..writeAll(problemes.map((p) => '  $p\n'));
    exit(1);
  }
  stdout.writeln('Aucune valeur de design en dur.');
}

/// Problèmes d'un fichier, sous la forme `chemin:ligne : motif : code`.
List<String> analyser(String chemin, String source) {
  final lignes = source.split('\n');
  final debuts = <int>[0];
  for (var i = 0; i < source.length; i++) {
    if (source.codeUnitAt(i) == 0x0A) debuts.add(i + 1);
  }
  int ligneDe(int position) {
    var n = 0;
    while (n + 1 < debuts.length && debuts[n + 1] <= position) {
      n++;
    }
    return n;
  }

  final trouves = <int, String>{};
  void signaler(int position, String motif) {
    final n = ligneDe(position);
    final ligne = lignes[n];
    if (ligne.contains(_exception) || ligne.trimLeft().startsWith('//')) {
      return;
    }
    trouves.putIfAbsent(n, () => '$chemin:${n + 1} : $motif : ${ligne.trim()}');
  }

  for (final (motif, message) in _reglesLigne) {
    for (final m in motif.allMatches(source)) {
      signaler(m.start, message);
    }
  }
  for (final (appel, parametre, message) in _reglesAppel) {
    for (final m in appel.allMatches(source)) {
      final fin = _finParenthese(source, m.end);
      final arguments = source.substring(m.end, fin);
      for (final n in _nombre.allMatches(arguments)) {
        final avant = arguments.substring(0, n.start);
        if (parametre == null || parametre.hasMatch(avant)) {
          signaler(m.end + n.start, message);
        }
      }
    }
  }
  return [for (final n in trouves.keys.toList()..sort()) trouves[n]!];
}

/// Position de la parenthèse fermante qui répond à celle ouverte juste avant
/// [debut].
int _finParenthese(String source, int debut) {
  var profondeur = 1;
  for (var i = debut; i < source.length; i++) {
    final c = source[i];
    if (c == '(') profondeur++;
    if (c == ')' && --profondeur == 0) return i;
  }
  return source.length;
}
