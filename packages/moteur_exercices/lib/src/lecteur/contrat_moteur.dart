import 'dart:async';

import 'package:flutter/widgets.dart';

import 'config_exercice.dart';
import 'deroule_exercice.dart';
import 'evenements.dart';

/// Affichage imposé par le lecteur à la zone de réponse.
enum AffichageReponse {
  /// L'enfant répond : la zone est modifiable.
  saisie,

  /// Réponse juste : les éléments choisis passent en « juste ».
  juste,

  /// 1er essai faux : les éléments choisis passent en « faux », un instant.
  faux,

  /// Bonne réponse montrée (2e essai faux, « afficher la réponse »).
  revelee,
}

/// Contrat entre le lecteur et un moteur, fourni par le moteur pour chaque
/// type qu'il sait jouer (docs/moteurs/choix.md).
///
/// Le lecteur porte tout ce qui est commun : consigne et son audio,
/// Yasmina, bouton principal, feedback en 3 temps, libellés, modes et
/// événements. Le moteur ne porte que la zone de réponse et sa correction.
///
/// Types à plusieurs étapes (T35 Histoire à choix, T57 Simulateur) : les
/// étapes s'enchaînent dans la zone (navigation interne, sans Vérifier).
/// Le contrôleur garde l'étape courante et les choix faits, la zone
/// affiche l'étape suivante à chaque choix, et à la dernière étape elle
/// appelle [ControleurReponse.terminer]. Le lecteur ne voit qu'une fin.
abstract interface class GabaritReponse {
  /// Comment le type se termine ([ModeValidation.verifier] en général).
  ModeValidation get validation;

  /// Contrôleur de la réponse, à partir de l'exercice edu-content/1.0.
  ControleurReponse creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  );

  /// Zone de réponse. Elle écoute le contrôleur et lit les services par
  /// `ServicesExercice.of(context)`.
  Widget construire(BuildContext context, ControleurReponse controleur);
}

/// État de la réponse d'une zone. La zone appelle [reponseModifiee] quand
/// l'enfant change sa réponse.
abstract class ControleurReponse extends ChangeNotifier {
  /// Réponse complète : Vérifier devient actif (Continuer en mode sans
  /// note).
  bool get complete;

  /// Réponse courante, sérialisable en JSON (événement reponseDonnee).
  Object? get reponse;

  /// Corrige la réponse courante, sans rien afficher.
  bool corriger();

  /// Vide la réponse (après le 1er essai faux, Rejouer).
  void vider();

  AffichageReponse _affichage = AffichageReponse.saisie;

  /// Affichage voulu par le lecteur. Hors saisie, la zone est verrouillée.
  AffichageReponse get affichage => _affichage;

  bool get modifiable => _affichage == AffichageReponse.saisie;

  void montrer(AffichageReponse affichage) {
    if (_affichage == affichage) return;
    _affichage = affichage;
    notifyListeners();
  }

  /// À appeler par la zone quand la réponse change.
  void reponseModifiee() => notifyListeners();

  final _fins = StreamController<bool>.broadcast(sync: true);
  final _demandesAudio = StreamController<DemandeAudio>.broadcast(sync: true);

  /// Audio demandé par la zone (mot à écouter, choix avec audio) : le
  /// lecteur le fait dire par le service injecté et émet l'événement.
  Stream<DemandeAudio> get demandesAudio => _demandesAudio.stream;

  /// Fait dire [texte] dans [langue] (origine `ecoute` par défaut).
  void demanderAudio(
    String texte, {
    required String langue,
    OrigineAudio origine = OrigineAudio.ecoute,
  }) {
    if (!_demandesAudio.isClosed) {
      _demandesAudio.add(DemandeAudio(texte, langue: langue, origine: origine));
    }
  }

  /// Texte à faire entendre une fois à l'ouverture, après la consigne (mot
  /// de T03 et T55, support écouté de T01, mot de T19). `null` : rien.
  String? get ecouteOuverture => null;

  /// Mode automatique : fins signalées par la zone (juste ou non).
  Stream<bool> get fins => _fins.stream;

  /// Mode automatique : l'exercice est fini (tout trouvé, chrono écoulé,
  /// dernière étape). Le lecteur affiche alors le feedback et Continuer.
  void terminer({required bool juste}) {
    if (!_fins.isClosed) _fins.add(juste);
  }

  @override
  @mustCallSuper
  void dispose() {
    _fins.close();
    _demandesAudio.close();
    super.dispose();
  }
}
