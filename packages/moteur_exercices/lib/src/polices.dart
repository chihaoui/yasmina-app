import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'theme/jetons_yasmina.g.dart';

/// Polices embarquées dans le moteur (licence OFL, voir fonts/README.md).
abstract final class PolicesYasmina {
  /// Contenu des exercices en arabe : naskh, le style enseigné à l'école.
  static const contenuArabe = 'packages/moteur_exercices/NotoNaskhArabic';

  /// Titres, boutons et textes de l'interface en arabe.
  static const interfaceArabe = 'packages/moteur_exercices/BalooBhaijaan2';

  /// Exercices en français et en anglais, interface en français.
  static const latin = 'packages/moteur_exercices/Andika';

  /// Style de base d'un exercice selon sa langue, avec l'autre écriture en
  /// secours pour les textes mixtes. En arabe, interligne large
  /// (content-option) pour que les harakat empilées ne touchent pas la ligne
  /// voisine.
  static TextStyle styleExercice(String langue) => langue == 'ar'
      ? TextStyle(
          fontFamily: contenuArabe,
          fontFamilyFallback: const [latin],
          height: StylesYasmina.contentOption.height,
        )
      : const TextStyle(fontFamily: latin, fontFamilyFallback: [contenuArabe]);
}

/// Ajoute les licences OFL des polices à l'écran des licences de Flutter.
/// À appeler une fois au démarrage de l'app mobile et de l'aperçu web.
void enregistrerLicencesPolices() {
  LicenseRegistry.addLicense(() async* {
    for (final famille in ['NotoNaskhArabic', 'BalooBhaijaan2', 'Andika']) {
      yield LicenseEntryWithLineBreaks(
        [famille],
        await rootBundle.loadString(
          'packages/moteur_exercices/fonts/OFL-$famille.txt',
        ),
      );
    }
  });
}
