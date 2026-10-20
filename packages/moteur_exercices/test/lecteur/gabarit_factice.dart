import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Gabarit factice pour tester le lecteur sans moteur réel : deux tuiles,
/// la tuile « A » est juste. En mode automatique, la tuile « fin » termine.
class GabaritFactice implements GabaritReponse {
  GabaritFactice([this.validation = ModeValidation.verifier, this.ecoute]);

  @override
  final ModeValidation validation;

  /// Mot à faire entendre à l'ouverture et au toucher du bouton « mot ».
  final String? ecoute;

  @override
  ControleurFactice creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) => ControleurFactice(ecoute: ecoute, langue: config.langue);

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) {
    final c = controleur as ControleurFactice;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Column(
        children: [
          for (final choix in ['A', 'B'])
            TuileChoix(
              key: ValueKey('factice_$choix'),
              etat: c.choix == choix ? EtatTuile.selectionne : EtatTuile.repos,
              texte: choix,
              onTap: c.modifiable ? () => c.choisir(choix) : null,
            ),
          if (c.ecoute case final mot?)
            TextButton(
              key: const ValueKey('factice_mot'),
              onPressed: () => c.demanderAudio(mot, langue: c.langue),
              child: const Text('mot'),
            ),
          if (validation == ModeValidation.automatique)
            for (final juste in [true, false])
              TextButton(
                key: ValueKey('factice_fin_$juste'),
                onPressed: () => c.terminer(juste: juste),
                child: Text('fin $juste'),
              ),
        ],
      ),
    );
  }
}

class ControleurFactice extends ControleurReponse {
  ControleurFactice({this.ecoute, this.langue = 'fr'});

  final String? ecoute;
  final String langue;

  @override
  String? get ecouteOuverture => ecoute;

  String? choix;

  void choisir(String valeur) {
    choix = valeur;
    reponseModifiee();
  }

  @override
  bool get complete => choix != null;

  @override
  Object? get reponse => choix;

  @override
  bool corriger() => choix == 'A';

  @override
  void vider() {
    choix = null;
    reponseModifiee();
  }
}

/// Exercice minimal, genré, pour le lecteur.
Map<String, dynamic> exerciceFactice({String langue = 'fr'}) => {
  'type': 'T99',
  'langue': langue,
  'consigne': {
    'texte': {'masculin': 'Choisis A.', 'feminin': 'Choisis A (féminin).'},
  },
  'feedbacks': {
    'reussite': 'Oui : A est juste.',
    'indice': 'Regarde la première lettre.',
    'explication': 'La bonne réponse est A.',
  },
};
