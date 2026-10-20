@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Le hook pre-commit de tool/hooks/ (CLAUDE.md §8) refuse un commit sans
/// marqueur de ./tool/verifier.sh, ou dont l'index diffère de celui vérifié
/// vert, et l'accepte quand les empreintes concordent. Joué dans un dépôt
/// Git temporaire, avec le vrai fichier du hook.
void main() {
  late Directory depot;
  late String hook;

  ProcessResult git(List<String> arguments) => Process.runSync(
    'git',
    arguments,
    workingDirectory: depot.path,
    environment: {
      // Un commit reproductible, sans dépendre de la configuration du poste.
      'GIT_AUTHOR_NAME': 'Test',
      'GIT_AUTHOR_EMAIL': 'test@example.com',
      'GIT_COMMITTER_NAME': 'Test',
      'GIT_COMMITTER_EMAIL': 'test@example.com',
      'GIT_CONFIG_GLOBAL': '/dev/null',
      'GIT_CONFIG_NOSYSTEM': '1',
    },
  );

  String sortie(ProcessResult r) => '${r.stdout}${r.stderr}';

  File fichierMarqueur() {
    final dossierGit = git(['rev-parse', '--git-dir']).stdout.toString().trim();
    final chemin = dossierGit.startsWith('/')
        ? dossierGit
        : '${depot.path}/$dossierGit';
    return File('$chemin/verifier-vert');
  }

  void ecrire(String nom, String contenu) =>
      File('${depot.path}/$nom').writeAsStringSync(contenu);

  setUp(() {
    // `flutter test` tourne depuis la racine du workspace.
    hook = 'tool/hooks/pre-commit';
    expect(File(hook).existsSync(), isTrue, reason: '$hook absent');
    depot = Directory.systemTemp.createTempSync('yasmina_hook_');
    expect(git(['init', '-q', '-b', 'main']).exitCode, 0);
    // Le hook versionné, activé comme dans le dépôt : core.hooksPath.
    Directory('${depot.path}/tool/hooks').createSync(recursive: true);
    File(hook).copySync('${depot.path}/tool/hooks/pre-commit');
    Process.runSync('chmod', ['+x', '${depot.path}/tool/hooks/pre-commit']);
    expect(git(['config', 'core.hooksPath', 'tool/hooks']).exitCode, 0);
    ecrire('lisez-moi.md', 'Bonjour\n');
    expect(git(['add', 'lisez-moi.md', 'tool/hooks/pre-commit']).exitCode, 0);
  });

  tearDown(() => depot.deleteSync(recursive: true));

  test('sans marqueur : le commit est refusé', () {
    final r = git(['commit', '-q', '-m', 'Essai']);
    expect(r.exitCode, isNot(0));
    expect(sortie(r), contains('Commit refusé'));
    expect(sortie(r), contains('aucun passage vert'));
    expect(git(['rev-parse', '--verify', 'HEAD']).exitCode, isNot(0));
  });

  test('marqueur d\'un autre index : le commit est refusé', () {
    fichierMarqueur().writeAsStringSync(
      '0000000000000000000000000000000000000000\n',
    );
    final r = git(['commit', '-q', '-m', 'Essai']);
    expect(r.exitCode, isNot(0));
    expect(sortie(r), contains("n'est pas celui vérifié vert"));
  });

  test('marqueur de l\'index courant (git write-tree) : le commit passe, '
      'puis un fichier indexé après coup est refusé', () {
    final arbre = git(['write-tree']).stdout.toString().trim();
    expect(arbre, hasLength(40));
    fichierMarqueur().writeAsStringSync('$arbre\n');
    final r = git(['commit', '-q', '-m', 'Essai vert']);
    expect(r.exitCode, 0, reason: sortie(r));
    expect(
      git(['log', '--oneline']).stdout.toString().trim(),
      endsWith('Essai vert'),
    );
    // Même index : un amend du message reste possible.
    expect(
      git(['commit', '-q', '--amend', '-m', 'Essai vert, relu']).exitCode,
      0,
    );
    // Un fichier indexé après la vérification change l'empreinte.
    ecrire('autre.md', 'Non vérifié\n');
    expect(git(['add', 'autre.md']).exitCode, 0);
    final refuse = git(['commit', '-q', '-m', 'Essai rouge']);
    expect(refuse.exitCode, isNot(0));
    expect(sortie(refuse), contains("n'est pas celui vérifié vert"));
  });

  test('verifier.sh retire le marqueur au départ et ne l\'écrit qu\'à la '
      'fin (lecture du script)', () {
    final script = File('tool/verifier.sh').readAsStringSync();
    final retrait = script.indexOf('rm -f "\$marqueur"');
    final ecriture = script.indexOf('git write-tree > "\$marqueur"');
    final vert = script.indexOf('Tout est vert.');
    expect(retrait, greaterThan(0));
    expect(ecriture, greaterThan(retrait));
    expect(vert, greaterThan(ecriture));
    // Le marqueur n'est jamais suivi par Git : il vit dans le dossier .git.
    expect(script, contains('git rev-parse --git-dir'));
    expect(
      File('.gitignore').readAsStringSync(),
      isNot(contains('verifier-vert')),
    );
  });
}
