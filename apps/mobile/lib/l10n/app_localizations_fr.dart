// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitre => 'Yasmina';

  @override
  String get accueilBienvenue => 'Bonjour ! On apprend ensemble.';

  @override
  String get accueilExempleExercice => 'Exemple d\'exercice';

  @override
  String get reglagesTitre => 'Réglages';

  @override
  String get reglagesOuvrir => 'Ouvrir les réglages';

  @override
  String get reglageLangue => 'Langue de l\'application';

  @override
  String get reglageLangueAide =>
      'Les exercices gardent la langue de leur matière.';
}
