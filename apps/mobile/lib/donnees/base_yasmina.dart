import 'package:drift/drift.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../profils/avatar.dart';

part 'base_yasmina.g.dart';

/// Base locale de l'app (SQLite). Schéma dans base_yasmina.drift.
///
/// Migrations : à chaque changement de schéma, augmenter [schemaVersion],
/// lancer `dart run drift_dev make-migrations` dans apps/mobile (instantané
/// dans drift_schemas/ et test de migration), puis écrire l'étape dans
/// [migration] avec `stepByStep`.
@DriftDatabase(include: {'base_yasmina.drift'})
class BaseYasmina extends _$BaseYasmina {
  BaseYasmina(super.executeur);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrateur) => migrateur.createAll(),
    onUpgrade: (migrateur, de, vers) async {
      // Version 1 : aucune migration. À partir de la v2, utiliser les étapes
      // générées par make-migrations (stepByStep).
      throw UnsupportedError('Migration $de vers $vers non prévue.');
    },
    beforeOpen: (details) async {
      // Indispensable pour ON DELETE CASCADE (progression liée aux profils).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Réinitialisation complète (menu développeur) : toutes les données
  /// locales sont effacées, le schéma reste.
  Future<void> toutEffacer() => transaction(() async {
    await delete(historiqueNiveaux).go();
    await delete(profils).go();
  });
}
