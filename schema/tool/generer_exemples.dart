// Copie les exemples de schema/exemples/ dans lib/src/exemples_generes.dart,
// pour que l'app, l'aperçu web et les tests les lisent sans asset ni
// dart:io (web compris).
// Usage, depuis schema/ : dart run tool/generer_exemples.dart
import 'dart:io';

const _sortie = 'lib/src/exemples_generes.dart';

void main() {
  final dossier = Directory('exemples');
  final fichiers =
      dossier
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final code = StringBuffer()
    ..writeln(
      '// Fichier généré par tool/generer_exemples.dart. Ne pas modifier à '
      'la main.',
    )
    ..writeln('// Source de vérité : schema/exemples/**/*.json')
    ..writeln()
    ..writeln(
      '/// Texte exact de chaque exemple, par chemin relatif à '
      'schema/exemples/',
    )
    ..writeln('/// (par exemple `choix/T01-qcm-scene.json`).')
    ..writeln('const Map<String, String> exemplesEduContent = {');
  for (final fichier in fichiers) {
    final chemin = fichier.path
        .substring(dossier.path.length + 1)
        .replaceAll(r'\', '/');
    final texte = fichier.readAsStringSync();
    if (texte.contains("'''")) {
      stderr.writeln(
        "$chemin contient ''' : impossible de l'insérer tel quel.",
      );
      exit(1);
    }
    code
      ..writeln("  '$chemin': r'''")
      ..write(texte)
      ..writeln("''',");
  }
  code.writeln('};');

  File(_sortie).writeAsStringSync(code.toString());
  final format = Process.runSync(Platform.resolvedExecutable, [
    'format',
    _sortie,
  ]);
  if (format.exitCode != 0) {
    stderr.writeln('dart format a échoué : ${format.stderr}');
    exit(1);
  }
  stdout.writeln('$_sortie régénéré (${fichiers.length} exemples).');
}
