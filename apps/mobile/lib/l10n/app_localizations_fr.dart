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

  @override
  String get accueilJouer => 'Jouer';

  @override
  String get sequenceTitre => 'Mes exercices';

  @override
  String sequenceNombreExercices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n exercices',
      one: '1 exercice',
      zero: 'Aucun exercice',
    );
    return '$_temp0';
  }

  @override
  String sequenceProgression(int i, int n) {
    return 'Exercice $i sur $n';
  }

  @override
  String get sequenceFinTitre => 'C\'est fini ! Tous les exercices sont faits.';

  @override
  String sequenceBilan(int reussis, int total) {
    return '$reussis réussis sur $total';
  }

  @override
  String get sequenceRetour => 'Retour à l\'accueil';

  @override
  String get sequenceAucune => 'Aucun exercice pour l\'instant.';

  @override
  String get matiereArabe => 'Arabe';

  @override
  String get matiereMaths => 'Maths';

  @override
  String get matiereEveil => 'Éveil scientifique';

  @override
  String get matiereFrancais => 'Français';

  @override
  String get matiereAnglais => 'Anglais';

  @override
  String get matiereBientot => 'Bientôt';

  @override
  String matiereEtapesFaites(int faites, int total) {
    return '$faites sur $total';
  }

  @override
  String carteTrimestre(int n) {
    return 'Trimestre $n';
  }

  @override
  String carteUnite(int n) {
    return 'Unité $n';
  }

  @override
  String get carteBientot => 'Cette matière arrive bientôt.';

  @override
  String get etapeOuverte => 'À faire';

  @override
  String get etapeFaite => 'Faite';

  @override
  String get etapeVerrouillee => 'Verrouillée';

  @override
  String get etapeVerrouilleeMessage => 'Termine d\'abord l\'étape précédente.';

  @override
  String get introBulle => 'C\'est parti !';

  @override
  String get introCommencer => 'Commencer';

  @override
  String get introRejouer => 'Rejouer';

  @override
  String get resultatTitre => 'Étape terminée !';

  @override
  String get resultatSuivante => 'Étape suivante débloquée !';

  @override
  String get resultatRetourCarte => 'Retour à la carte';

  @override
  String get introReprendre => 'Reprendre';

  @override
  String get espaceParentOuvrir => 'Espace parent';

  @override
  String get bienvenueBulle =>
      'Bienvenue ! Un parent ajoute le premier enfant depuis l\'espace parent.';

  @override
  String get parentTitre => 'Espace parent';

  @override
  String get parentPorteTitre => 'Espace réservé aux parents';

  @override
  String get parentPorteAide => 'Pour entrer, réponds à cette opération.';

  @override
  String parentPorteQuestion(int a, int b) {
    return '$a × $b = ?';
  }

  @override
  String get parentPorteReponse => 'Réponse';

  @override
  String get parentPorteEntrer => 'Entrer';

  @override
  String get parentPorteFaux => 'Ce n\'est pas la bonne réponse.';

  @override
  String get parentQuitter => 'Quitter l\'espace parent';

  @override
  String get parentEnfants => 'Enfants';

  @override
  String get parentAjouterEnfant => 'Ajouter un enfant';

  @override
  String get parentLimite => '5 profils au maximum sur cet appareil';

  @override
  String get parentProgression => 'Progression';

  @override
  String get parentAucuneProgression => 'Aucun enfant pour l\'instant.';

  @override
  String get parentBientot => 'bientôt';

  @override
  String parentEtapesFaites(int faites, int total) {
    return '$faites / $total étapes faites';
  }

  @override
  String parentEtapeFaite(int reussis, int total) {
    return 'faite, $reussis / $total réussis';
  }

  @override
  String parentEtapeEnCours(int index, int total) {
    return 'en cours, exercice $index / $total';
  }

  @override
  String get parentLangue => 'Langue de l\'application';

  @override
  String get parentLangueAide =>
      'Les exercices gardent la langue de leur matière.';

  @override
  String get parentSons => 'Sons des effets';

  @override
  String get parentSonsAide =>
      'Sons du feedback, à volume bas. Rien en mode silencieux.';

  @override
  String get parentAbonnement => 'Abonnement';

  @override
  String get parentAbonnementBientot =>
      'Statut simulé (menu développeur). Les offres arrivent bientôt.';
}
