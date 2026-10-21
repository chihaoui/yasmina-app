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

  /// Bouton de l'accueil qui ouvre la séquence de test (exercices enchaînés, sans carte).
  ///
  /// In fr, this message translates to:
  /// **'Jouer'**
  String get accueilJouer;

  /// Titre de l'écran des séries de la séquence de test.
  ///
  /// In fr, this message translates to:
  /// **'Mes exercices'**
  String get sequenceTitre;

  /// Nombre d'exercices d'une série.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Aucun exercice} =1{1 exercice} other{{n} exercices}}'**
  String sequenceNombreExercices(int n);

  /// Progression dans une série.
  ///
  /// In fr, this message translates to:
  /// **'Exercice {i} sur {n}'**
  String sequenceProgression(int i, int n);

  /// Bulle de Yasmina à la fin d'une série (centrée sur la tâche, jamais sur l'enfant).
  ///
  /// In fr, this message translates to:
  /// **'C\'est fini ! Tous les exercices sont faits.'**
  String get sequenceFinTitre;

  /// Sous la bulle de fin : exercices réussis (juste au 1er ou au 2e essai, ou sans note) sur le total.
  ///
  /// In fr, this message translates to:
  /// **'{reussis} réussis sur {total}'**
  String sequenceBilan(int reussis, int total);

  /// Bouton de la fin d'une série.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get sequenceRetour;

  /// Séquence ou série sans exercice jouable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun exercice pour l\'instant.'**
  String get sequenceAucune;

  /// Nom de la matière arabe sur l'accueil et la carte.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get matiereArabe;

  /// Nom de la matière maths.
  ///
  /// In fr, this message translates to:
  /// **'Maths'**
  String get matiereMaths;

  /// Nom de la matière éveil scientifique.
  ///
  /// In fr, this message translates to:
  /// **'Éveil scientifique'**
  String get matiereEveil;

  /// Nom de la matière français (à partir de la 2e année).
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get matiereFrancais;

  /// Nom de la matière anglais (à partir de la 4e année).
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get matiereAnglais;

  /// Pastille d'une matière sans contenu dans le prototype.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt'**
  String get matiereBientot;

  /// Étapes faites sur le total (carte de matière, bandeau d'unité, carte du trimestre).
  ///
  /// In fr, this message translates to:
  /// **'{faites} sur {total}'**
  String matiereEtapesFaites(int faites, int total);

  /// Trimestre affiché sur la carte.
  ///
  /// In fr, this message translates to:
  /// **'Trimestre {n}'**
  String carteTrimestre(int n);

  /// Bandeau d'une unité sur la carte du trimestre.
  ///
  /// In fr, this message translates to:
  /// **'Unité {n}'**
  String carteUnite(int n);

  /// Matière sans parcours embarqué.
  ///
  /// In fr, this message translates to:
  /// **'Cette matière arrive bientôt.'**
  String get carteBientot;

  /// État d'une étape ouverte sur la carte.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get etapeOuverte;

  /// État d'une étape terminée sur la carte (rejouable).
  ///
  /// In fr, this message translates to:
  /// **'Faite'**
  String get etapeFaite;

  /// État d'une étape pas encore ouverte.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillée'**
  String get etapeVerrouillee;

  /// Message quand l'enfant touche une étape verrouillée.
  ///
  /// In fr, this message translates to:
  /// **'Termine d\'abord l\'étape précédente.'**
  String get etapeVerrouilleeMessage;

  /// Bulle de Yasmina sur l'intro d'une étape.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get introBulle;

  /// Bouton de l'intro d'une étape.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get introCommencer;

  /// Bouton de l'intro d'une étape déjà faite.
  ///
  /// In fr, this message translates to:
  /// **'Rejouer'**
  String get introRejouer;

  /// Bulle de Yasmina sur l'écran de résultat d'une étape.
  ///
  /// In fr, this message translates to:
  /// **'Étape terminée !'**
  String get resultatTitre;

  /// Sur l'écran de résultat, quand l'étape suivante vient de s'ouvrir.
  ///
  /// In fr, this message translates to:
  /// **'Étape suivante débloquée !'**
  String get resultatSuivante;

  /// Bouton de l'écran de résultat.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la carte'**
  String get resultatRetourCarte;

  /// Bouton de l'intro d'une étape commencée et quittée en cours de route : la partie reprend au même exercice.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get introReprendre;

  /// Infobulle et libellé d'accessibilité du bouton des écrans enfant qui mène à la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Espace parent'**
  String get espaceParentOuvrir;

  /// Bulle de Yasmina au premier lancement, sans profil.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue ! Un parent ajoute le premier enfant depuis l\'espace parent.'**
  String get bienvenueBulle;

  /// Titre de l'espace parent et de sa porte (sans harakat, décision 27).
  ///
  /// In fr, this message translates to:
  /// **'Espace parent'**
  String get parentTitre;

  /// Titre de la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Espace réservé aux parents'**
  String get parentPorteTitre;

  /// Aide de la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Pour entrer, réponds à cette opération.'**
  String get parentPorteAide;

  /// Opération de la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'{a} × {b} = ?'**
  String parentPorteQuestion(int a, int b);

  /// Libellé du champ de la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Réponse'**
  String get parentPorteReponse;

  /// Bouton de la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Entrer'**
  String get parentPorteEntrer;

  /// Erreur de la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas la bonne réponse.'**
  String get parentPorteFaux;

  /// Bouton qui referme la porte parentale.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'espace parent'**
  String get parentQuitter;

  /// Section des profils dans l'espace parent.
  ///
  /// In fr, this message translates to:
  /// **'Enfants'**
  String get parentEnfants;

  /// Ligne de création d'un profil dans l'espace parent.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un enfant'**
  String get parentAjouterEnfant;

  /// Message quand 5 profils existent.
  ///
  /// In fr, this message translates to:
  /// **'5 profils au maximum sur cet appareil'**
  String get parentLimite;

  /// Section de la progression des enfants.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get parentProgression;

  /// Section progression sans profil.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enfant pour l\'instant.'**
  String get parentAucuneProgression;

  /// Matière sans parcours dans la progression.
  ///
  /// In fr, this message translates to:
  /// **'bientôt'**
  String get parentBientot;

  /// Étapes faites sur le total d'une matière.
  ///
  /// In fr, this message translates to:
  /// **'{faites} / {total} étapes faites'**
  String parentEtapesFaites(int faites, int total);

  /// État d'une étape faite : meilleure partie.
  ///
  /// In fr, this message translates to:
  /// **'faite, {reussis} / {total} réussis'**
  String parentEtapeFaite(int reussis, int total);

  /// État d'une étape commencée et pas finie.
  ///
  /// In fr, this message translates to:
  /// **'en cours, exercice {index} / {total}'**
  String parentEtapeEnCours(int index, int total);

  /// Section de la langue de l'interface.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get parentLangue;

  /// Aide sous le réglage de la langue.
  ///
  /// In fr, this message translates to:
  /// **'Les exercices gardent la langue de leur matière.'**
  String get parentLangueAide;

  /// Réglage des sons d'interface (décision 35).
  ///
  /// In fr, this message translates to:
  /// **'Sons des effets'**
  String get parentSons;

  /// Aide du réglage des sons.
  ///
  /// In fr, this message translates to:
  /// **'Sons du feedback, à volume bas. Rien en mode silencieux.'**
  String get parentSonsAide;

  /// Section de l'abonnement simulé.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement'**
  String get parentAbonnement;

  /// Pastille du statut simulé sur la carte du trimestre (essai en cours).
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit'**
  String get abonnementEssai;

  /// Pastille du statut simulé sur la carte du trimestre (abonné).
  ///
  /// In fr, this message translates to:
  /// **'Abonné'**
  String get abonnementAbonne;

  /// Bulle de Yasmina à la place de la carte quand l'essai simulé est terminé.
  ///
  /// In fr, this message translates to:
  /// **'L\'essai gratuit est terminé.'**
  String get essaiTermineTitre;

  /// Explication sous la bulle quand l'essai simulé est terminé.
  ///
  /// In fr, this message translates to:
  /// **'Un parent peut s\'abonner depuis l\'espace parent.'**
  String get essaiTermineAide;

  /// Statut simulé dans l'espace parent.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit en cours'**
  String get parentAbonnementEssai;

  /// Statut simulé dans l'espace parent.
  ///
  /// In fr, this message translates to:
  /// **'Essai terminé'**
  String get parentAbonnementEssaiTermine;

  /// Statut simulé dans l'espace parent.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement actif'**
  String get parentAbonnementAbonne;

  /// Aide de la section abonnement (décision 13).
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à 5 enfants par compte. Simulation sans paiement : choisir une offre active l\'abonnement.'**
  String get parentAbonnementAide;

  /// Offre mensuelle.
  ///
  /// In fr, this message translates to:
  /// **'10 DT par mois'**
  String get parentOffreMois;

  /// Sous-titre de l'offre mensuelle.
  ///
  /// In fr, this message translates to:
  /// **'Sans engagement'**
  String get parentOffreMoisAide;

  /// Offre trimestrielle.
  ///
  /// In fr, this message translates to:
  /// **'20 DT pour 3 mois'**
  String get parentOffreTrimestre;

  /// Sous-titre de l'offre trimestrielle.
  ///
  /// In fr, this message translates to:
  /// **'Tout le contenu du trimestre'**
  String get parentOffreTrimestreAide;

  /// Offre annuelle.
  ///
  /// In fr, this message translates to:
  /// **'50 DT pour 12 mois'**
  String get parentOffreAnnee;

  /// Sous-titre de l'offre annuelle.
  ///
  /// In fr, this message translates to:
  /// **'Été compris, la meilleure offre'**
  String get parentOffreAnneeAide;

  /// Bouton d'une offre : bascule le statut simulé sur abonné.
  ///
  /// In fr, this message translates to:
  /// **'S\'abonner'**
  String get parentSabonner;

  /// Bouton qui remet le statut simulé sur essai.
  ///
  /// In fr, this message translates to:
  /// **'Simulation : revenir à l\'essai'**
  String get parentAbonnementRetourEssai;
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
