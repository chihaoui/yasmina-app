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
  String get accueilBienvenue => 'On apprend ensemble.';

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

  @override
  String get avatarFleur => 'Fleur';

  @override
  String get avatarSoleil => 'Soleil';

  @override
  String get avatarLune => 'Lune';

  @override
  String get avatarEtoile => 'Étoile';

  @override
  String get avatarArbre => 'Arbre';

  @override
  String get avatarBateau => 'Bateau';

  @override
  String get avatarChat => 'Chat';

  @override
  String get avatarNuage => 'Nuage';

  @override
  String get profilsTitre => 'Qui joue ?';

  @override
  String get profilsAjouter => 'Ajouter un enfant';

  @override
  String get profilsLimite => '5 profils au maximum sur cet appareil';

  @override
  String profilModifierInfobulle(String prenom) {
    return 'Modifier le profil de $prenom';
  }

  @override
  String get profilNouveauTitre => 'Nouveau profil';

  @override
  String get profilModifierTitre => 'Modifier le profil';

  @override
  String get profilPrenom => 'Prénom ou pseudo';

  @override
  String get profilPrenomVide => 'Il faut un prénom ou un pseudo.';

  @override
  String get profilPrenomExiste =>
      'Ce prénom est déjà utilisé sur cet appareil.';

  @override
  String get profilNiveau => 'Année scolaire';

  @override
  String get niveau1 => '1re année';

  @override
  String get niveau2 => '2e année';

  @override
  String get niveau3 => '3e année';

  @override
  String get niveau4 => '4e année';

  @override
  String get niveau5 => '5e année';

  @override
  String get niveau6 => '6e année';

  @override
  String get profilNiveauAide =>
      'Changer d\'année garde la trace des années précédentes.';

  @override
  String get profilAvatar => 'Avatar';

  @override
  String get profilFormeAdresse => 'On s\'adresse à l\'enfant';

  @override
  String get formeMasculin => 'au masculin';

  @override
  String get formeFeminin => 'au féminin';

  @override
  String get profilEnregistrer => 'Enregistrer';

  @override
  String get profilSupprimer => 'Supprimer le profil';

  @override
  String profilSupprimerQuestion(String prenom) {
    return 'Supprimer définitivement le profil de $prenom ? Toutes ses données seront effacées.';
  }

  @override
  String get annuler => 'Annuler';

  @override
  String get supprimer => 'Supprimer';

  @override
  String accueilBonjour(String prenom) {
    return 'Bonjour $prenom !';
  }

  @override
  String get profilChanger => 'Changer d\'enfant';
}
