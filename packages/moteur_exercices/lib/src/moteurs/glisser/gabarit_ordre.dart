import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../choix/selection_choix.dart';
import 'controleur_glisser.dart';
import 'tuile_glissable.dart';
import 'zone_depot.dart';

/// Types à ordre du moteur Glisser-déposer : T13 mots, T14 images, T15
/// lettres et T16 syllabes d'un mot (docs/moteurs/glisser-deposer.md §2).
class GabaritOrdre implements GabaritReponse {
  const GabaritOrdre(this.type);

  final String type;

  @override
  ModeValidation get validation => ModeValidation.verifier;

  bool get _mot => type == 'T15' || type == 'T16';

  @override
  ControleurOrdre creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurOrdre(
      config: config,
      elements: [
        for (final e
            in (donnees['elements'] as List).cast<Map<String, dynamic>>())
          Proposition.depuisJson(e),
      ],
      attendu: (reponse['ordre'] as List).cast<String>(),
      exigeTous: !_mot,
      ecoute: (donnees['ecoute'] as Map<String, dynamic>?)?['texte'] as String?,
      melanger: donnees['melanger'] as bool? ?? true,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneOrdre(
        controleur as ControleurOrdre,
        mot: _mot,
        grand: _mot || type == 'T14',
      );
}

/// Ligne de réponse (T13, T14) ou zone du mot (T15, T16), puis la réserve.
class _ZoneOrdre extends StatelessWidget {
  const _ZoneOrdre(this.controleur, {required this.mot, required this.grand});

  final ControleurOrdre controleur;

  /// Les éléments posés s'affichent liés en un seul mot (T15, T16).
  final bool mot;

  /// Tuiles en content-word (lettres, syllabes, grandes images).
  final bool grand;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final apercu = config.mode != ModeExercice.enfant;
        void deposer(String id, String cible) {
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
          controleur.poser(id, cible);
        }

        String? motEtat(String id) {
          if (!apercu) return null;
          return switch (controleur.etatDe(id)) {
            EtatGlissable.juste => 'juste',
            EtatGlissable.faux => 'faux',
            _ => null,
          };
        }

        Widget tuile(String id, {bool posee = false, bool fantome = false}) {
          final e = controleur.element(id);
          if (fantome) {
            return Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TuileGlissable(
                key: ValueKey('place_$id'),
                id: id,
                etat: EtatGlissable.repos,
                texte: e.texte,
                emoji: e.emoji,
                grand: grand,
              ),
            );
          }
          return TuileGlissable(
            key: ValueKey('${posee ? 'pose' : 'element'}_$id'),
            id: id,
            etat: controleur.etatDe(id),
            texte: e.texte,
            emoji: e.emoji,
            grand: grand,
            libelleAccessibilite: e.texte == null
                ? libelles.image(controleur.numero(id))
                : null,
            motEtat: motEtat(id),
            onToucher: controleur.modifiable
                ? () {
                    if (posee) {
                      // Seul le dernier de la ligne se retire au toucher.
                      if (controleur.ordre.last == id) controleur.retirer(id);
                    } else {
                      controleur.basculerAttente(id);
                    }
                  }
                : null,
          );
        }

        final ordre = controleur.ordre;
        final juste =
            ordre.isNotEmpty &&
            (controleur.affichage == AffichageReponse.juste ||
                controleur.affichage == AffichageReponse.revelee);

        // Contenu de la ligne : le mot lié, ou les tuiles posées (chacune
        // est une cible : un dépôt dessus s'insère avant elle).
        final Widget contenu;
        if (mot) {
          final texte = controleur.motConstruit;
          contenu = Text(
            texte.isEmpty ? ' ' : texte,
            key: const ValueKey('mot_construit'),
            textAlign: TextAlign.center,
            style: ThemeYasmina.pourLangue(StylesYasmina.contentWord, langue)
                .copyWith(
                  color: switch (controleur.affichage) {
                    AffichageReponse.faux when !controleur.corriger() =>
                      c.coralText,
                    _ => c.ink,
                  },
                ),
          );
        } else {
          // La case suivante, en fin de ligne : un dépôt s'y ajoute (le
          // dépôt sur une tuile posée s'insère avant elle).
          final resteAPoser =
              controleur.modifiable &&
              ordre.length < controleur.elements.length;
          contenu = Wrap(
            spacing: EspacesYasmina.space2,
            runSpacing: EspacesYasmina.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (i, id) in ordre.indexed)
                DragTarget<String>(
                  key: ValueKey('avant_$id'),
                  onWillAcceptWithDetails: (d) =>
                      controleur.modifiable && d.data != id,
                  onAcceptWithDetails: (d) => deposer(d.data, '$i'),
                  builder: (context, candidats, _) => Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: candidats.isEmpty ? 0 : EspacesYasmina.space4,
                    ),
                    child: tuile(id, posee: true),
                  ),
                ),
              if (resteAPoser)
                ZoneDepot(
                  key: const ValueKey('ligne_fin'),
                  libelle: libelles.verifier,
                  enLigne: true,
                  onDepot: (id) => deposer(id, 'fin'),
                  onToucher: () {
                    if (controleur.enAttente == null) return;
                    services.vibration.legere();
                    services.audio.jouerSon(SonInterface.depot);
                    controleur.poserAttente('fin');
                  },
                  child: const SizedBox(
                    width: EspacesYasmina.targetMin,
                    height: EspacesYasmina.targetMin,
                  ),
                ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space6,
          children: [
            if (controleur.ecoute case final ecoute?)
              Center(
                child: BoutonEcouter(
                  key: const ValueKey('ordre_ecouter'),
                  libelle: libelles.ecouter,
                  onPressed: () =>
                      controleur.demanderAudio(ecoute, langue: langue),
                ),
              ),
            ZoneDepot(
              key: const ValueKey('ligne'),
              libelle: mot ? libelles.ecouter : libelles.verifier,
              etat: juste ? EtatDepot.juste : EtatDepot.repos,
              onDepot: controleur.modifiable
                  ? (id) => deposer(id, 'fin')
                  : null,
              onToucher: controleur.modifiable
                  ? () {
                      if (controleur.enAttente != null) {
                        services.vibration.legere();
                        services.audio.jouerSon(SonInterface.depot);
                        controleur.poserAttente('fin');
                      } else if (mot) {
                        controleur.retirerDernier();
                      }
                    }
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: TaillesYasmina.choiceMinHeight,
                ),
                child: Center(child: contenu),
              ),
            ),
            Wrap(
              key: const ValueKey('reserve'),
              spacing: EspacesYasmina.space2,
              runSpacing: EspacesYasmina.space2,
              children: [
                for (final e in controleur.elements)
                  tuile(e.id, fantome: controleur.estPose(e.id)),
              ],
            ),
          ],
        );
      },
    );
  }
}
