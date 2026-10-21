import 'package:drift/drift.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../profils/avatar.dart';
import 'base_yasmina.steps.dart';

part 'base_yasmina.g.dart';

/// Base locale de l'app (SQLite). Schéma dans base_yasmina.drift.
///
/// Migrations : à chaque changement de schéma, augmenter [schemaVersion],
/// lancer `dart run drift_dev make-migrations` dans apps/mobile (instantané
/// dans drift_schemas/, classes de test dans test/drift/.../generated/ et
/// étapes dans base_yasmina.steps.dart), écrire l'étape dans [migration]
/// avec `stepByStep`, puis compléter test/drift/base_yasmina/schema_test.dart
/// (le gabarit migration_test.dart généré n'est pas gardé). Si `dart run`
/// reste bloqué sur pub (réseau), lancer l'instantané précompilé :
/// `dart --packages=../../.dart_tool/package_config.json
/// ../../.dart_tool/pub/bin/drift_dev/drift_dev.dart-3.13.5.snapshot
/// make-migrations`, de même pour build_runner.
@DriftDatabase(include: {'base_yasmina.drift'})
class BaseYasmina extends _$BaseYasmina {
  BaseYasmina(super.executeur);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrateur) => migrateur.createAll(),
    // Étapes générées par make-migrations (base_yasmina.steps.dart).
    onUpgrade: stepByStep(
      // v2 (21 oct. 2026, A3-03) : progression locale, résultats par
      // exercice et état par étape. Les profils sont gardés tels quels.
      from1To2: (migrateur, schema) async {
        await migrateur.createTable(schema.resultatsExercices);
        await migrateur.createIndex(schema.resultatsExercicesUnique);
        await migrateur.createIndex(schema.resultatsExercicesEtape);
        await migrateur.createTable(schema.etatsEtapes);
        await migrateur.createIndex(schema.etatsEtapesUnique);
      },
    ),
    beforeOpen: (details) async {
      // Indispensable pour ON DELETE CASCADE (progression liée aux profils).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Réinitialisation complète (menu développeur) : toutes les données
  /// locales sont effacées, le schéma reste.
  Future<void> toutEffacer() => transaction(() async {
    await delete(resultatsExercices).go();
    await delete(etatsEtapes).go();
    await delete(historiqueNiveaux).go();
    await delete(profils).go();
  });
}
