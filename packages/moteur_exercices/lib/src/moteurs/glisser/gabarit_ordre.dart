import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../composants/bouton_yasmina.dart';
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
/// lettres et T16 syllabes d'un mot, T62 éléments d'une frise
/// (docs/moteurs/glisser-deposer.md §2).
class GabaritOrdre implements GabaritReponse {
  const GabaritOrdre(this.type);

  final String type;

  @override
  ModeValidation get validation => ModeValidation.verifier;

  bool get _mot => type == 'T15' || type == 'T16';

  /// La ligne de réponse est une frise chronologique (T62).
  bool get _frise => type == 'T62';

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
          Proposition(
            id: e['id'] as String,
            texte: e['texte'] as String?,
            emoji: e['emoji'] as String?,
            // Date d'un élément de frise (T62).
            detail: e['date'] as String?,
          ),
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
        frise: _frise,
      );
}

/// Ligne de réponse (T13, T14), zone du mot (T15, T16) ou frise (T62),
/// puis la réserve.
class _ZoneOrdre extends StatelessWidget {
  const _ZoneOrdre(
    this.controleur, {
    required this.mot,
    required this.grand,
    this.frise = false,
  });

  final ControleurOrdre controleur;

  /// Les éléments posés s'affichent liés en un seul mot (T15, T16).
  final bool mot;

  /// Tuiles en content-word (lettres, syllabes, grandes images).
  final bool grand;

  /// Les éléments posés se placent sur une frise à cases fixes (T62).
  final bool frise;

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

        Widget tuile(
          String id, {
          bool posee = false,
          bool fantome = false,
          bool compacte = false,
        }) {
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
          // Sur la frise, une case étroite : l'emoji (sinon le texte) et la
          // date, le texte reste le libellé lu.
          return TuileGlissable(
            key: ValueKey('${posee ? 'pose' : 'element'}_$id'),
            id: id,
            etat: controleur.etatDe(id),
            texte: compacte && e.emoji != null ? null : e.texte,
            emoji: e.emoji,
            detail: e.detail,
            grand: grand,
            libelleAccessibilite:
                e.texte ?? libelles.image(controleur.numero(id)),
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
            // Posée et glissée hors de la ligne : revient dans la réserve.
            onSorti: controleur.modifiable && posee
                ? () => controleur.retirer(id)
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
        } else if (frise) {
          // Une case par élément sur une ligne du temps, dans le sens
          // d'écriture : les éléments posés dans l'ordre, puis la case
          // suivante (seule à recevoir un dépôt), puis les cases vides.
          final n = controleur.elements.length;
          final resteAPoser = controleur.modifiable && ordre.length < n;
          Widget case_(int i) {
            final Widget enfant;
            if (i < ordre.length) {
              final id = ordre[i];
              enfant = DragTarget<String>(
                key: ValueKey('avant_$id'),
                onWillAcceptWithDetails: (d) =>
                    controleur.modifiable && d.data != id,
                onAcceptWithDetails: (d) => deposer(d.data, '$i'),
                builder: (context, candidats, _) =>
                    tuile(id, posee: true, compacte: true),
              );
            } else {
              final suivante = i == ordre.length && resteAPoser;
              enfant = ZoneDepot(
                key: ValueKey(suivante ? 'ligne_fin' : 'frise_case_$i'),
                libelle: '${i + 1}',
                enLigne: true,
                onDepot: suivante ? (id) => deposer(id, 'fin') : null,
                onToucher: suivante
                    ? () {
                        if (controleur.enAttente == null) return;
                        services.vibration.legere();
                        services.audio.jouerSon(SonInterface.depot);
                        controleur.poserAttente('fin');
                      }
                    : null,
                child: const SizedBox(
                  width: EspacesYasmina.targetMin,
                  height: EspacesYasmina.targetMin,
                ),
              );
            }
            return Center(child: enfant);
          }

          contenu = LayoutBuilder(
            key: const ValueKey('frise'),
            builder: (context, contraintes) {
              final largeurCase = math.max(
                EspacesYasmina.targetMin + EspacesYasmina.space2,
                contraintes.maxWidth / n,
              );
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < n; i++)
                          SizedBox(width: largeurCase, child: case_(i)),
                      ],
                    ),
                    CustomPaint(
                      size: Size(largeurCase * n, EspacesYasmina.space8),
                      painter: _LigneDuTemps(
                        cases: n,
                        couleur: c.line,
                        sens: Directionality.of(context),
                      ),
                    ),
                  ],
                ),
              );
            },
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
              // Le toucher de la zone pose l'élément en attente, rien
              // d'autre : la dernière lettre se retire par Effacer.
              onToucher: controleur.modifiable
                  ? () {
                      if (controleur.enAttente != null) {
                        services.vibration.legere();
                        services.audio.jouerSon(SonInterface.depot);
                        controleur.poserAttente('fin');
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
            if (mot)
              BoutonEffacer(
                key: const ValueKey('ordre_effacer'),
                libelle: libelles.effacer,
                onPressed: controleur.modifiable && ordre.isNotEmpty
                    ? controleur.retirerDernier
                    : null,
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

/// Ligne du temps de la frise (T62) : un trait sous les cases, un repère
/// au milieu de chaque case et une flèche dans le sens d'écriture.
class _LigneDuTemps extends CustomPainter {
  const _LigneDuTemps({
    required this.cases,
    required this.couleur,
    required this.sens,
  });

  final int cases;
  final Color couleur;
  final TextDirection sens;

  @override
  void paint(Canvas canvas, Size size) {
    final trait = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThick
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), trait);
    final largeurCase = size.width / cases;
    for (var i = 0; i < cases; i++) {
      final x = largeurCase * (i + 1 / 2);
      canvas.drawLine(
        Offset(x, y - EspacesYasmina.space2),
        Offset(x, y + EspacesYasmina.space2),
        trait,
      );
    }
    // Flèche à la fin de la ligne, dans le sens de lecture.
    final fin = sens == TextDirection.rtl ? 0.0 : size.width;
    final recul = sens == TextDirection.rtl
        ? EspacesYasmina.space3
        : -EspacesYasmina.space3;
    canvas.drawLine(
      Offset(fin, y),
      Offset(fin + recul, y - EspacesYasmina.space2),
      trait,
    );
    canvas.drawLine(
      Offset(fin, y),
      Offset(fin + recul, y + EspacesYasmina.space2),
      trait,
    );
  }

  @override
  bool shouldRepaint(_LigneDuTemps ancien) =>
      ancien.cases != cases || ancien.couleur != couleur || ancien.sens != sens;
}
