import 'package:flutter/material.dart';

import '../../composants/tuile_choix.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// T02 Vrai ou faux (moteur Choix) : une affirmation (content-sentence en
/// arabe, latin-prompt sinon), un emoji facultatif,
/// deux tuiles Vrai et Faux en ordre fixe, libellés du lecteur dans la
/// langue de l'exercice (صَحِيحٌ et خَطَأٌ en arabe).
class GabaritVraiFaux implements GabaritReponse {
  const GabaritVraiFaux();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurVraiFaux creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurVraiFaux(
      affirmation: donnees['affirmation'] as String,
      emoji: donnees['emoji'] as String?,
      attendu: (exercice['reponse'] as Map<String, dynamic>)['valeur'] as bool,
      config: config,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneVraiFaux(controleur as ControleurVraiFaux);
}

/// Réponse de T02 : le choix de l'enfant (vrai ou faux).
class ControleurVraiFaux extends ControleurReponse {
  ControleurVraiFaux({
    required this.affirmation,
    required this.attendu,
    required this.config,
    this.emoji,
  });

  final String affirmation;
  final String? emoji;
  final bool attendu;
  final ConfigExercice config;

  bool? choix;

  void choisir(bool valeur) {
    if (!modifiable) return;
    choix = valeur;
    reponseModifiee();
  }

  @override
  bool get complete => choix != null;

  @override
  Object? get reponse => choix;

  @override
  bool corriger() => choix == attendu;

  @override
  void vider() {
    choix = null;
    reponseModifiee();
  }

  /// État de la tuile [valeur] selon l'affichage voulu par le lecteur.
  EtatTuile etatDe(bool valeur) => switch (affichage) {
    AffichageReponse.saisie =>
      choix == valeur ? EtatTuile.selectionne : EtatTuile.repos,
    AffichageReponse.juste =>
      choix == valeur ? EtatTuile.juste : EtatTuile.repos,
    AffichageReponse.faux => choix == valeur ? EtatTuile.faux : EtatTuile.repos,
    AffichageReponse.revelee =>
      valeur == attendu ? EtatTuile.juste : EtatTuile.repos,
  };
}

class _ZoneVraiFaux extends StatelessWidget {
  const _ZoneVraiFaux(this.controleur);

  final ControleurVraiFaux controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final libelles = LibellesLecteur.pour(config.langue, config.formeAdresse);
    final vibration = ServicesExercice.of(context).vibration;
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        Widget tuile(bool valeur) {
          final revelee =
              controleur.affichage == AffichageReponse.revelee &&
              valeur == controleur.attendu;
          return Expanded(
            child: TuileChoix(
              key: ValueKey('vrai_faux_$valeur'),
              etat: controleur.etatDe(valeur),
              texte: valeur ? libelles.vrai : libelles.faux,
              // Aperçu (adulte) : la bonne réponse porte un mot d'état.
              motEtat: revelee && config.mode != ModeExercice.enfant
                  ? 'bonne réponse'
                  : null,
              onTap: controleur.modifiable
                  ? () {
                      vibration.legere();
                      controleur.choisir(valeur);
                    }
                  : null,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space6,
          children: [
            if (controleur.emoji case final emoji?)
              Text(
                emoji,
                textAlign: TextAlign.center,
                style: StylesYasmina.contentWord,
              ),
            Text(
              controleur.affirmation,
              key: const ValueKey('vrai_faux_affirmation'),
              textAlign: TextAlign.center,
              style: ThemeYasmina.pourLangue(
                // Texte court lu par l'enfant : latin-prompt en français et
                // en anglais (choix.md §9).
                config.langue == 'ar'
                    ? StylesYasmina.contentSentence
                    : StylesYasmina.latinPrompt,
                config.langue,
              ).copyWith(color: c.ink),
            ),
            // Vrai puis Faux, ordre fixe : en arabe, la Row place Vrai à
            // droite (début de ligne).
            Row(
              spacing: EspacesYasmina.space3,
              children: [tuile(true), tuile(false)],
            ),
          ],
        );
      },
    );
  }
}
