import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/donnees/base_yasmina.dart';

import 'generated/schema.dart';

void main() {
  test("la base créée par l'app correspond à l'instantané v1", () async {
    // Échoue si le schéma change sans nouvelle version : augmenter
    // schemaVersion et lancer `dart run drift_dev make-migrations`.
    final verificateur = SchemaVerifier(GeneratedHelper());
    final base = BaseYasmina(NativeDatabase.memory());
    addTearDown(base.close);
    await verificateur.migrateAndValidate(base, 1);
  });
}
