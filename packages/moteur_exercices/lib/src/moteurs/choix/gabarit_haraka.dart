import 'dart:math';

import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'gabarit_choix.dart';
import 'grille_choix.dart';
import 'selection_choix.dart';

/// Les harakat de T19 : signe combinant et nom affiché sous la tuile.
const harakat = {
  'fatha': (signe: 'َ', nom: 'فَتْحَةٌ'),
  'damma': (signe: 'ُ', nom: 'ضَمَّةٌ'),
  'kasra': (signe: 'ِ', nom: 'كَسْرَةٌ'),
  'soukoun': (signe: 'ْ', nom: 'سُكُونٌ'),
};

/// Cercle pointillé qui porte une haraka sur une tuile (U+25CC).
const porteurHaraka = '◌';

/// T19 Choisir la haraka, en deux formes (docs/moteurs/choix.md §4) :
/// - gabarit `lettre-vocalisee` : trouver la lettre qui porte la haraka
///   demandée, une grille de lettres vocalisées ([GabaritChoix]) ;
/// - autres gabarits : choisir la haraka d'une lettre dans un mot, la
///   haraka choisie s'affiche aussitôt sur la lettre.
class GabaritHaraka implements GabaritReponse {
  const GabaritHaraka();

  static const _lettreVocalisee = GabaritChoix('T19');

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurReponse creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    if (exercice['gabarit'] == 'lettre-vocalisee') {
      return _lettreVocalisee.creerControleur(exercice, config);
    }
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurHaraka(
      config: config,
      avant: donnees['avant'] as String,
      lettre: donnees['lettre'] as String,
      apres: donnees['apres'] as String,
      ecoute: (donnees['ecoute'] as Map<String, dynamic>?)?['texte'] as String?,
      selection: SelectionChoix(
        propositions: [
          // Chaque tuile montre la haraka sur ◌ (en grand) et son nom.
          for (final h in (donnees['harakat'] as List).cast<String>())
            Proposition(
              id: h,
              emoji: '$porteurHaraka${harakat[h]!.signe}',
              texte: harakat[h]!.nom,
            ),
        ],
        attendus: [reponse['haraka'] as String],
        melanger: donnees['melanger'] as bool? ?? false,
        aleatoire: config.graine == null ? null : Random(config.graine),
      ),
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      switch (controleur) {
        ControleurHaraka() => _ZoneHaraka(controleur),
        _ => _lettreVocalisee.construire(context, controleur),
      };
}

/// Réponse de T19, forme mot : la haraka choisie pour la lettre.
class ControleurHaraka extends ControleurReponse {
  ControleurHaraka({
    required this.config,
    required this.avant,
    required this.lettre,
    required this.apres,
    required this.selection,
    this.ecoute,
  });

  final ConfigExercice config;
  final String avant;
  final String lettre;
  final String apres;
  final SelectionChoix selection;

  /// Mot complet entendu (facultatif), dit après la consigne.
  final String? ecoute;

  String? get haraka => selection.ids.firstOrNull;

  @override
  bool get complete => selection.complete;

  @override
  Object? get reponse => {'haraka': haraka};

  @override
  bool corriger() => selection.juste;

  @override
  void vider() {
    selection.vider();
    reponseModifiee();
  }

  @override
  String? get ecouteOuverture => ecoute;
}

class _ZoneHaraka extends StatelessWidget {
  const _ZoneHaraka(this.controleur);

  final ControleurHaraka controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final libelles = LibellesLecteur.pour(config.langue, config.formeAdresse);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        // La haraka montrée sur la lettre : celle de l'enfant, ou la bonne
        // quand la réponse est révélée. Le mot reste une seule chaîne de
        // spans de même police : les lettres restent liées.
        final montree = controleur.affichage == AffichageReponse.revelee
            ? controleur.selection.attendus.single
            : controleur.haraka;
        final signe = montree == null ? '' : harakat[montree]!.signe;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space6,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: controleur.avant),
                  TextSpan(
                    text: '${controleur.lettre}$signe',
                    style: TextStyle(color: c.blue),
                  ),
                  TextSpan(text: controleur.apres),
                ],
              ),
              key: const ValueKey('haraka_mot'),
              textAlign: TextAlign.center,
              style: StylesYasmina.contentWord.copyWith(color: c.ink),
            ),
            if (controleur.ecoute case final ecoute?)
              Center(
                child: BoutonEcouter(
                  key: const ValueKey('haraka_ecouter'),
                  libelle: libelles.ecouter,
                  onPressed: () =>
                      controleur.demanderAudio(ecoute, langue: config.langue),
                ),
              ),
            GrilleChoix(
              selection: controleur.selection,
              controleur: controleur,
              libelles: libelles,
              mode: config.mode,
              prefixeCle: 'haraka',
            ),
          ],
        );
      },
    );
  }
}
