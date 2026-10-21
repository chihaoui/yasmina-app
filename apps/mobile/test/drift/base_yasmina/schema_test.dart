import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/donnees/base_yasmina.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

void main() {
  test("la base créée par l'app correspond à l'instantané v2", () async {
    // Échoue si le schéma change sans nouvelle version : augmenter
    // schemaVersion et lancer `dart run drift_dev make-migrations`.
    final verificateur = SchemaVerifier(GeneratedHelper());
    final base = BaseYasmina(NativeDatabase.memory());
    addTearDown(base.close);
    await verificateur.migrateAndValidate(base, 2);
  });

  test('migration v1 vers v2 : les profils et leur historique sont gardés, '
      'les tables de progression apparaissent vides', () async {
    final verificateur = SchemaVerifier(GeneratedHelper());
    final schema = await verificateur.schemaAt(1);
    final ancienne = v1.DatabaseAtV1(schema.newConnection());
    // Le schéma généré n'a pas de companions : SQL direct.
    await ancienne.customStatement(
      "INSERT INTO profils (prenom, niveau, avatar, forme_adresse, cree_le, "
      "modifie_le) VALUES ('Lina', 1, 'fleur', 'feminin', "
      "'2026-10-17T09:00:00.000Z', '2026-10-17T09:00:00.000Z')",
    );
    await ancienne.customStatement(
      'INSERT INTO historique_niveaux (profil_id, niveau, debut) '
      "VALUES (1, 1, '2026-10-17T09:00:00.000Z')",
    );
    await ancienne.close();

    final base = BaseYasmina(schema.newConnection());
    addTearDown(base.close);
    await verificateur.migrateAndValidate(base, 2);
    final profils = await base.select(base.profils).get();
    expect(profils.single.prenom, 'Lina');
    expect(await base.select(base.historiqueNiveaux).get(), hasLength(1));
    expect(await base.select(base.etatsEtapes).get(), isEmpty);
    expect(await base.select(base.resultatsExercices).get(), isEmpty);
  });
}
