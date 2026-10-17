// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitre => 'يَاسْمِينَة';

  @override
  String get accueilBienvenue => 'هَيَّا نَتَعَلَّمُ مَعًا.';

  @override
  String get accueilExempleExercice => 'مِثَالُ تَمْرِينٍ';

  @override
  String get reglagesTitre => 'الْإِعْدَادَاتُ';

  @override
  String get reglagesOuvrir => 'اِفْتَحِ الْإِعْدَادَاتِ';

  @override
  String get reglageLangue => 'لُغَةُ التَّطْبِيقِ';

  @override
  String get reglageLangueAide => 'تَبْقَى التَّمَارِينُ بِلُغَةِ مَادَّتِهَا.';

  @override
  String get avatarFleur => 'زَهْرَةٌ';

  @override
  String get avatarSoleil => 'شَمْسٌ';

  @override
  String get avatarLune => 'قَمَرٌ';

  @override
  String get avatarEtoile => 'نَجْمَةٌ';

  @override
  String get avatarArbre => 'شَجَرَةٌ';

  @override
  String get avatarBateau => 'قَارِبٌ';

  @override
  String get avatarChat => 'قِطٌّ';

  @override
  String get avatarNuage => 'سَحَابَةٌ';

  @override
  String get profilsTitre => 'مَنْ يَلْعَبُ؟';

  @override
  String get profilsAjouter => 'إِضَافَةُ طِفْلٍ';

  @override
  String get profilsLimite =>
      'خَمْسَةُ مَلَفَّاتٍ عَلَى الْأَكْثَرِ فِي هَذَا الْجِهَازِ';

  @override
  String profilModifierInfobulle(String prenom) {
    return 'تَعْدِيلُ مَلَفِّ $prenom';
  }

  @override
  String get profilNouveauTitre => 'مَلَفٌّ جَدِيدٌ';

  @override
  String get profilModifierTitre => 'تَعْدِيلُ الْمَلَفِّ';

  @override
  String get profilPrenom => 'اِسْمُ الطِّفْلِ أَوْ لَقَبُهُ';

  @override
  String get profilPrenomVide => 'يَجِبُ كِتَابَةُ اسْمٍ.';

  @override
  String get profilPrenomExiste => 'هَذَا الِاسْمُ مُسْتَعْمَلٌ مِنْ قَبْلُ.';

  @override
  String get profilNiveau => 'السَّنَةُ الدِّرَاسِيَّةُ';

  @override
  String get niveau1 => 'السَّنَةُ الْأُولَى';

  @override
  String get niveau2 => 'السَّنَةُ الثَّانِيَةُ';

  @override
  String get niveau3 => 'السَّنَةُ الثَّالِثَةُ';

  @override
  String get niveau4 => 'السَّنَةُ الرَّابِعَةُ';

  @override
  String get niveau5 => 'السَّنَةُ الْخَامِسَةُ';

  @override
  String get niveau6 => 'السَّنَةُ السَّادِسَةُ';

  @override
  String get profilNiveauAide =>
      'يُحْفَظُ سِجِلُّ السَّنَوَاتِ السَّابِقَةِ عِنْدَ تَغْيِيرِ السَّنَةِ.';

  @override
  String get profilAvatar => 'الصُّورَةُ الرَّمْزِيَّةُ';

  @override
  String get profilFormeAdresse => 'نُخَاطِبُ الطِّفْلَ';

  @override
  String get formeMasculin => 'بِصِيغَةِ الْمُذَكَّرِ';

  @override
  String get formeFeminin => 'بِصِيغَةِ الْمُؤَنَّثِ';

  @override
  String get profilEnregistrer => 'حِفْظٌ';

  @override
  String get profilSupprimer => 'حَذْفُ الْمَلَفِّ';

  @override
  String profilSupprimerQuestion(String prenom) {
    return 'حَذْفُ مَلَفِّ $prenom نِهَائِيًّا؟ سَتُمْحَى كُلُّ بَيَانَاتِهِ.';
  }

  @override
  String get annuler => 'إِلْغَاءٌ';

  @override
  String get supprimer => 'حَذْفٌ';

  @override
  String accueilBonjour(String prenom) {
    return 'مَرْحَبًا يَا $prenom!';
  }

  @override
  String get profilChanger => 'تَغْيِيرُ الطِّفْلِ';
}
