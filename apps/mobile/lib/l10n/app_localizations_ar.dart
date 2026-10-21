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

  @override
  String get accueilJouer => 'هَيَّا نَلْعَبْ';

  @override
  String get sequenceTitre => 'تَمَارِينِي';

  @override
  String sequenceNombreExercices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n تَمْرِينًا',
      many: '$n تَمْرِينًا',
      few: '$n تَمَارِينَ',
      two: 'تَمْرِينَانِ',
      one: 'تَمْرِينٌ وَاحِدٌ',
      zero: 'لَا تَمَارِينَ',
    );
    return '$_temp0';
  }

  @override
  String sequenceProgression(int i, int n) {
    return 'التَّمْرِينُ $i مِنْ $n';
  }

  @override
  String get sequenceFinTitre => 'اِنْتَهَتِ التَّمَارِينُ كُلُّهَا!';

  @override
  String sequenceBilan(int reussis, int total) {
    return '$reussis مِنْ $total صَحِيحَةٌ';
  }

  @override
  String get sequenceRetour => 'الْعَوْدَةُ إِلَى الْبِدَايَةِ';

  @override
  String get sequenceAucune => 'لَا تَمَارِينَ بَعْدُ.';

  @override
  String get matiereArabe => 'الْعَرَبِيَّةُ';

  @override
  String get matiereMaths => 'الرِّيَاضِيَّاتُ';

  @override
  String get matiereEveil => 'الْإِيقَاظُ الْعِلْمِيُّ';

  @override
  String get matiereFrancais => 'الْفَرَنْسِيَّةُ';

  @override
  String get matiereAnglais => 'الْإِنْجِلِيزِيَّةُ';

  @override
  String get matiereBientot => 'قَرِيبًا';

  @override
  String matiereEtapesFaites(int faites, int total) {
    return '$faites مِنْ $total';
  }

  @override
  String carteTrimestre(int n) {
    return 'الثُّلَاثِيُّ $n';
  }

  @override
  String carteUnite(int n) {
    return 'الْوَحْدَةُ $n';
  }

  @override
  String get carteBientot => 'سَتَصِلُ هَذِهِ الْمَادَّةُ قَرِيبًا.';

  @override
  String get etapeOuverte => 'جَاهِزَةٌ';

  @override
  String get etapeFaite => 'مُنْجَزَةٌ';

  @override
  String get etapeVerrouillee => 'مُغْلَقَةٌ';

  @override
  String get etapeVerrouilleeMessage =>
      'لَا بُدَّ مِنْ إِكْمَالِ الْمَرْحَلَةِ السَّابِقَةِ أَوَّلًا.';

  @override
  String get introBulle => 'هَيَّا بِنَا!';

  @override
  String get introCommencer => 'هَيَّا نَبْدَأُ';

  @override
  String get introRejouer => 'هَيَّا نُعِيدُ';

  @override
  String get resultatTitre => 'اِنْتَهَتِ الْمَرْحَلَةُ!';

  @override
  String get resultatSuivante => 'فُتِحَتِ الْمَرْحَلَةُ التَّالِيَةُ!';

  @override
  String get resultatRetourCarte => 'الْعَوْدَةُ إِلَى الْخَرِيطَةِ';

  @override
  String get introReprendre => 'هَيَّا نُكْمِلُ';

  @override
  String get espaceParentOuvrir => 'فَضَاءُ الْأَوْلِيَاءِ';

  @override
  String get bienvenueBulle =>
      'مَرْحَبًا! يُضِيفُ الْوَلِيُّ الطِّفْلَ الْأَوَّلَ مِنْ فَضَاءِ الْأَوْلِيَاءِ.';

  @override
  String get parentTitre => 'فضاء الأولياء';

  @override
  String get parentPorteTitre => 'مساحة مخصصة للأولياء';

  @override
  String get parentPorteAide => 'للدخول، أجب عن هذه العملية.';

  @override
  String parentPorteQuestion(int a, int b) {
    return '$a × $b = ?';
  }

  @override
  String get parentPorteReponse => 'الجواب';

  @override
  String get parentPorteEntrer => 'دخول';

  @override
  String get parentPorteFaux => 'الجواب غير صحيح.';

  @override
  String get parentQuitter => 'الخروج من فضاء الأولياء';

  @override
  String get parentEnfants => 'الأطفال';

  @override
  String get parentAjouterEnfant => 'إضافة طفل';

  @override
  String get parentLimite => 'خمسة ملفات على الأكثر في هذا الجهاز';

  @override
  String get parentProgression => 'التقدم';

  @override
  String get parentAucuneProgression => 'لا أطفال بعد.';

  @override
  String get parentBientot => 'قريبا';

  @override
  String parentEtapesFaites(int faites, int total) {
    return '$faites / $total مراحل منجزة';
  }

  @override
  String parentEtapeFaite(int reussis, int total) {
    return 'منجزة، $reussis / $total صحيحة';
  }

  @override
  String parentEtapeEnCours(int index, int total) {
    return 'جارية، التمرين $index / $total';
  }

  @override
  String get parentLangue => 'لغة التطبيق';

  @override
  String get parentLangueAide => 'تبقى التمارين بلغة مادتها.';

  @override
  String get parentSons => 'أصوات المؤثرات';

  @override
  String get parentSonsAide =>
      'أصوات التغذية الراجعة بصوت منخفض. لا شيء في الوضع الصامت.';

  @override
  String get parentAbonnement => 'الاشتراك';

  @override
  String get parentAbonnementBientot =>
      'الحالة محاكاة (قائمة المطور). العروض قريبا.';
}
