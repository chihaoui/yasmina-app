import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// Nom de l'app et de la mascotte.
  ///
  /// In fr, this message translates to:
  /// **'Yasmina'**
  String get appTitre;

  /// Ligne sous la bulle de Yasmina sur l'accueil (interface enfant). La bulle porte déjà le bonjour.
  ///
  /// In fr, this message translates to:
  /// **'On apprend ensemble.'**
  String get accueilBienvenue;

  /// Titre de la carte qui montre un exercice dans la langue de sa matière.
  ///
  /// In fr, this message translates to:
  /// **'Exemple d\'exercice'**
  String get accueilExempleExercice;

  /// Titre de l'écran des réglages.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get reglagesTitre;

  /// Infobulle et libellé d'accessibilité du bouton des réglages.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get reglagesOuvrir;

  /// Titre du réglage de la langue de l'interface.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get reglageLangue;

  /// Aide sous le réglage de la langue.
  ///
  /// In fr, this message translates to:
  /// **'Les exercices gardent la langue de leur matière.'**
  String get reglageLangueAide;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Fleur'**
  String get avatarFleur;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Soleil'**
  String get avatarSoleil;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Lune'**
  String get avatarLune;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Étoile'**
  String get avatarEtoile;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Arbre'**
  String get avatarArbre;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Bateau'**
  String get avatarBateau;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Chat'**
  String get avatarChat;

  /// Nom d'un avatar, lu par les lecteurs d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Nuage'**
  String get avatarNuage;

  /// Titre de l'écran de choix du profil.
  ///
  /// In fr, this message translates to:
  /// **'Qui joue ?'**
  String get profilsTitre;

  /// Bouton de création d'un profil.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un enfant'**
  String get profilsAjouter;

  /// Message affiché à la place du bouton quand 5 profils existent.
  ///
  /// In fr, this message translates to:
  /// **'5 profils au maximum sur cet appareil'**
  String get profilsLimite;

  /// Infobulle du bouton crayon sur une carte de profil.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil de {prenom}'**
  String profilModifierInfobulle(String prenom);

  /// Titre du formulaire de création.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau profil'**
  String get profilNouveauTitre;

  /// Titre du formulaire de modification.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profilModifierTitre;

  /// Libellé du champ prénom.
  ///
  /// In fr, this message translates to:
  /// **'Prénom ou pseudo'**
  String get profilPrenom;

  /// Erreur : prénom vide.
  ///
  /// In fr, this message translates to:
  /// **'Il faut un prénom ou un pseudo.'**
  String get profilPrenomVide;

  /// Erreur : prénom déjà porté par un autre profil.
  ///
  /// In fr, this message translates to:
  /// **'Ce prénom est déjà utilisé sur cet appareil.'**
  String get profilPrenomExiste;

  /// Titre du choix du niveau.
  ///
  /// In fr, this message translates to:
  /// **'Année scolaire'**
  String get profilNiveau;

  /// Niveau 1.
  ///
  /// In fr, this message translates to:
  /// **'1re année'**
  String get niveau1;

  /// Niveau 2.
  ///
  /// In fr, this message translates to:
  /// **'2e année'**
  String get niveau2;

  /// Niveau 3.
  ///
  /// In fr, this message translates to:
  /// **'3e année'**
  String get niveau3;

  /// Niveau 4.
  ///
  /// In fr, this message translates to:
  /// **'4e année'**
  String get niveau4;

  /// Niveau 5.
  ///
  /// In fr, this message translates to:
  /// **'5e année'**
  String get niveau5;

  /// Niveau 6.
  ///
  /// In fr, this message translates to:
  /// **'6e année'**
  String get niveau6;

  /// Aide sous le choix du niveau, en modification.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'année garde la trace des années précédentes.'**
  String get profilNiveauAide;

  /// Titre du choix de l'avatar.
  ///
  /// In fr, this message translates to:
  /// **'Avatar'**
  String get profilAvatar;

  /// Titre du choix de la forme d'adresse (accord des messages).
  ///
  /// In fr, this message translates to:
  /// **'On s\'adresse à l\'enfant'**
  String get profilFormeAdresse;

  /// Forme d'adresse masculine.
  ///
  /// In fr, this message translates to:
  /// **'au masculin'**
  String get formeMasculin;

  /// Forme d'adresse féminine.
  ///
  /// In fr, this message translates to:
  /// **'au féminin'**
  String get formeFeminin;

  /// Bouton du formulaire de profil.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get profilEnregistrer;

  /// Bouton de suppression, en modification.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le profil'**
  String get profilSupprimer;

  /// Question du dialogue de confirmation de suppression.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement le profil de {prenom} ? Toutes ses données seront effacées.'**
  String profilSupprimerQuestion(String prenom);

  /// Bouton d'annulation d'un dialogue.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// Bouton de confirmation de suppression.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get supprimer;

  /// Salutation de l'enfant sur l'accueil.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {prenom} !'**
  String accueilBonjour(String prenom);

  /// Bouton de l'accueil qui ramène au choix du profil.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'enfant'**
  String get profilChanger;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
