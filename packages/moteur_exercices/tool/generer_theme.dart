// Génère les jetons du design system à partir de
// docs/design-system/tokens.json (source de vérité, copiée de l'artefact
// « Design system Yasmina ») :
// - lib/src/theme/jetons_yasmina.g.dart (couleurs clair et sombre, styles de
//   texte, espacements, rayons, traits, tailles, ombres)
// - assets/yasmina/*.svg (la mascotte, copiée telle quelle)
//
// Usage, depuis packages/moteur_exercices :
//   dart run tool/generer_theme.dart              régénère les fichiers
//   dart run tool/generer_theme.dart --verifier   échoue s'ils ne sont pas à jour
import 'dart:convert';
import 'dart:io';

const _sortieDart = 'lib/src/theme/jetons_yasmina.g.dart';
const _dossierSvg = 'assets/yasmina';

/// Familles CSS de tokens.json reliées aux polices embarquées
/// (PolicesYasmina). Les autres (Tahoma, serif...) n'existent que sur le web.
const _policesEmbarquees = {
  'Baloo Bhaijaan 2': 'PolicesYasmina.interfaceArabe',
  'Noto Naskh Arabic': 'PolicesYasmina.contenuArabe',
  'Andika': 'PolicesYasmina.latin',
};

void main(List<String> arguments) {
  final paquet = File.fromUri(Platform.script).parent.parent;
  final racine = paquet.parent.parent;
  final designSystem = Directory('${racine.path}/docs/design-system');
  final verifier = arguments.contains('--verifier');

  try {
    final jetons = jsonDecode(
      File('${designSystem.path}/tokens.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final code = _formater(genererJetons(jetons));
    final attendus = <String, List<int>>{
      _sortieDart: utf8.encode(code),
      for (final svg in _svgSources(designSystem))
        '$_dossierSvg/${_nom(svg)}': svg.readAsBytesSync(),
    };

    if (verifier) {
      final ecarts = [
        for (final MapEntry(key: chemin, value: contenu) in attendus.entries)
          if (!_identique(File('${paquet.path}/$chemin'), contenu)) chemin,
        for (final present in _svgPresents(paquet))
          if (!attendus.containsKey('$_dossierSvg/${_nom(present)}'))
            '$_dossierSvg/${_nom(present)} (absent de docs/design-system)',
      ];
      if (ecarts.isNotEmpty) {
        stderr
          ..writeln('Jetons du design system pas à jour : ${ecarts.join(', ')}')
          ..writeln(
            'Lancer, dans packages/moteur_exercices : '
            'dart run tool/generer_theme.dart',
          );
        exit(1);
      }
      stdout.writeln('Jetons du design system à jour.');
      return;
    }

    for (final present in _svgPresents(paquet)) {
      present.deleteSync();
    }
    for (final MapEntry(key: chemin, value: contenu) in attendus.entries) {
      File('${paquet.path}/$chemin')
        ..createSync(recursive: true)
        ..writeAsBytesSync(contenu);
    }
    stdout.writeln('${attendus.length} fichiers régénérés.');
  } on FormatException catch (e) {
    stderr.writeln('Erreur dans tokens.json : ${e.message}');
    exit(1);
  }
}

List<File> _svgSources(Directory designSystem) =>
    _svgDe(Directory('${designSystem.path}/yasmina'));

List<File> _svgPresents(Directory paquet) =>
    _svgDe(Directory('${paquet.path}/$_dossierSvg'));

List<File> _svgDe(Directory dossier) => dossier.existsSync()
    ? (dossier.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.svg'),
      )).toList()
    : <File>[];

String _nom(File fichier) => fichier.uri.pathSegments.last;

bool _identique(File fichier, List<int> contenu) {
  if (!fichier.existsSync()) return false;
  final actuel = fichier.readAsBytesSync();
  if (actuel.length != contenu.length) return false;
  for (var i = 0; i < actuel.length; i++) {
    if (actuel[i] != contenu[i]) return false;
  }
  return true;
}

/// Passe le code par `dart format` (fichier temporaire), pour que le fichier
/// généré respecte le contrôle de formatage de verifier.sh.
String _formater(String code) {
  final dossier = Directory.systemTemp.createTempSync('jetons_yasmina');
  try {
    final fichier = File('${dossier.path}/jetons_yasmina.g.dart')
      ..writeAsStringSync(code);
    final dart = Platform.resolvedExecutable;
    final resultat = Process.runSync(dart, ['format', fichier.path]);
    if (resultat.exitCode != 0) {
      throw FormatException('dart format a échoué : ${resultat.stderr}');
    }
    return fichier.readAsStringSync();
  } finally {
    dossier.deleteSync(recursive: true);
  }
}

/// Code Dart des jetons. Public pour les tests.
String genererJetons(Map<String, dynamic> jetons) {
  final couleurs = _liste(jetons, ['color', 'tokens']);
  final familles = (jetons['type'] as Map)['families'] as Map;
  final groupes = _liste(jetons, ['type', 'groups']);

  final b = StringBuffer()
    ..writeln(
      '// Fichier généré par tool/generer_theme.dart. Ne pas modifier à la main.',
    )
    ..writeln('// Source de vérité : docs/design-system/tokens.json')
    ..writeln()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln("import '../polices.dart';")
    ..writeln();

  // Couleurs.
  final noms = [for (final c in couleurs) _camel(c['name'] as String)];
  b
    ..writeln('/// Couleurs du design system, une valeur par thème.')
    ..writeln('class CouleursYasmina extends ThemeExtension<CouleursYasmina> {')
    ..writeln('  const CouleursYasmina({')
    ..writeAll([for (final n in noms) '    required this.$n,\n'])
    ..writeln('  });')
    ..writeln();
  for (final c in couleurs) {
    b
      ..writeln('  /// ${_commentaire(c['usage'])}')
      ..writeln('  final Color ${_camel(c['name'] as String)};')
      ..writeln();
  }
  for (final (theme, nomDart) in [('light', 'clair'), ('dark', 'sombre')]) {
    b.writeln('  static const $nomDart = CouleursYasmina(');
    for (final c in couleurs) {
      final valeur = (c['value'] as Map)[theme];
      if (valeur is! String) {
        throw FormatException('couleur ${c['name']} sans valeur « $theme ».');
      }
      b.writeln('    ${_camel(c['name'] as String)}: ${_couleur(valeur)},');
    }
    b
      ..writeln('  );')
      ..writeln();
  }
  b
    ..writeln('  @override')
    ..writeln('  CouleursYasmina copyWith({')
    ..writeAll([for (final n in noms) '    Color? $n,\n'])
    ..writeln('  }) => CouleursYasmina(')
    ..writeAll([for (final n in noms) '    $n: $n ?? this.$n,\n'])
    ..writeln('  );')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
      '  CouleursYasmina lerp(covariant CouleursYasmina? other, double t) {',
    )
    ..writeln('    if (other == null) return this;')
    ..writeln('    return CouleursYasmina(')
    ..writeAll([
      for (final n in noms) '      $n: Color.lerp($n, other.$n, t)!,\n',
    ])
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}')
    ..writeln();

  // Styles de texte.
  b
    ..writeln('/// Styles de texte. La couleur vient du thème (ink ou muted).')
    ..writeln('abstract final class StylesYasmina {');
  for (final groupe in groupes) {
    final famille = groupe['family'] as String;
    final polices = _polices(familles[famille], famille);
    for (final style in groupe['styles'] as List) {
      b
        ..writeln('  /// ${_commentaire(style['usage'])} Famille $famille.')
        ..writeln(
          '  static const ${_camel(style['name'] as String)} = TextStyle(',
        )
        ..writeln('    fontFamily: ${polices.first},')
        ..writeln('    fontFamilyFallback: [${polices.skip(1).join(', ')}],')
        ..writeln('    fontSize: ${_px(style['fontSize'])},')
        ..writeln('    height: ${_nombre(style['lineHeight'])},')
        ..writeln('    fontWeight: FontWeight.w${style['fontWeight']},')
        ..writeln('  );')
        ..writeln();
    }
  }
  b
    ..writeln('}')
    ..writeln();

  // Dimensions.
  for (final (cle, classe, doc) in [
    ('spacing', 'EspacesYasmina', 'Espacements et marges internes (px).'),
    ('radius', 'RayonsYasmina', 'Rayons des coins (px).'),
    ('border', 'TraitsYasmina', 'Épaisseurs de trait (px).'),
    ('size', 'TaillesYasmina', 'Tailles fixes de composants (px).'),
  ]) {
    b
      ..writeln('/// $doc')
      ..writeln('abstract final class $classe {');
    for (final jeton in _liste(jetons, [cle, 'tokens'])) {
      b
        ..writeln('  /// ${_commentaire(jeton['usage'])}')
        ..writeln(
          '  static const double ${_camel(jeton['name'] as String)} = '
          '${_px(jeton['value'])};',
        );
    }
    b
      ..writeln('}')
      ..writeln();
  }

  // Ombres.
  b
    ..writeln('/// Ombres fonctionnelles (relief de touche).')
    ..writeln('abstract final class OmbresYasmina {');
  for (final jeton in _liste(jetons, ['shadow', 'tokens'])) {
    b
      ..writeln('  /// ${_commentaire(jeton['usage'])}')
      ..writeln(
        '  static const ${_camel(jeton['name'] as String)} = '
        '${_ombre(jeton['value'] as String)};',
      );
  }
  b.writeln('}');
  return b.toString();
}

List<Map<String, dynamic>> _liste(Map<String, dynamic> jetons, List<String> c) {
  Object? valeur = jetons;
  for (final cle in c) {
    valeur = (valeur as Map?)?[cle];
  }
  if (valeur is! List) throw FormatException('${c.join('.')} absent.');
  return valeur.cast<Map<String, dynamic>>();
}

/// `blue-soft` devient `blueSoft`, `seq-1` devient `seq1`.
String _camel(String nom) {
  final parties = nom.split('-');
  return parties.first +
      parties.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String _commentaire(Object? texte) =>
    (texte as String? ?? '').replaceAll('\n', ' ');

String _couleur(String hexa) {
  final m = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(hexa);
  if (m == null) throw FormatException('couleur « $hexa » invalide.');
  return 'Color(0xFF${m.group(1)!.toUpperCase()})';
}

String _px(Object? valeur) {
  final m = RegExp(r'^(\d+(?:\.\d+)?)px$').firstMatch('$valeur');
  if (m == null) throw FormatException('dimension « $valeur » invalide.');
  return _nombre(double.parse(m.group(1)!));
}

String _nombre(Object? valeur) {
  if (valeur is! num) throw FormatException('nombre « $valeur » invalide.');
  final d = valeur.toDouble();
  return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
}

/// Polices embarquées d'une pile CSS, dans l'ordre (première = famille).
List<String> _polices(Object? pile, String famille) {
  if (pile is! String) throw FormatException('famille $famille absente.');
  final polices = [
    for (final nom in pile.split(','))
      ?_policesEmbarquees[nom.trim().replaceAll('"', '')],
  ];
  if (polices.isEmpty) {
    throw FormatException('famille $famille sans police embarquée.');
  }
  return polices;
}

/// `0 5px 0 rgba(0,0,0,0.18)` devient un BoxShadow.
String _ombre(String css) {
  final m = RegExp(
    r'^(-?\d+)(?:px)? (-?\d+)(?:px)? (\d+)(?:px)? '
    r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)$',
  ).firstMatch(css.trim());
  if (m == null) throw FormatException('ombre « $css » non reconnue.');
  final alpha = (double.parse(m.group(7)!) * 255).round();
  String hexa(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
  final couleur =
      '0x${hexa(alpha)}${hexa(int.parse(m.group(4)!))}'
      '${hexa(int.parse(m.group(5)!))}${hexa(int.parse(m.group(6)!))}';
  return 'BoxShadow(color: Color($couleur), '
      'offset: Offset(${m.group(1)}, ${m.group(2)}), '
      'blurRadius: ${m.group(3)})';
}
