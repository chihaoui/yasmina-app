// Copie edu-content-1.0.schema.json dans lib/src/schema_genere.dart, pour que
// le validateur lise le schéma sans dart:io (web compris).
// Usage, depuis schema/ : dart run tool/generer_schema.dart
import 'dart:io';

void main() {
  final texte = File('edu-content-1.0.schema.json').readAsStringSync();
  if (texte.contains("'''")) {
    stderr.writeln(
      "Le schéma contient ''' : impossible de l'insérer tel quel.",
    );
    exit(1);
  }
  File('lib/src/schema_genere.dart').writeAsStringSync('''
// Fichier généré par tool/generer_schema.dart. Ne pas modifier à la main.
// Source de vérité : schema/edu-content-1.0.schema.json

/// Texte exact de schema/edu-content-1.0.schema.json.
const String texteSchemaEduContent = r\'\'\'
$texte\'\'\';
''');
  stdout.writeln('lib/src/schema_genere.dart régénéré.');
}
