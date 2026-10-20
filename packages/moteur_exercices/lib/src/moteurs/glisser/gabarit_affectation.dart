import 'package:flutter/material.dart';

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

/// Types à affectation du moteur Glisser-déposer : T06 trous, T09 paires,
/// T11 et T12 bacs (docs/moteurs/glisser-deposer.md §2).
class GabaritAffectation implements GabaritReponse {
  const GabaritAffectation(this.type);

  final String type;

  @override
  ModeValidation get validation => ModeValidation.verifier;

  static List<Proposition> _liste(Map<String, dynamic> donnees, String champ) =>
      [
        for (final e in (donnees[champ] as List).cast<Map<String, dynamic>>())
          Proposition.depuisJson(e),
      ];

  @override
  ControleurAffectation creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final melanger = donnees['melanger'] as bool? ?? true;
    switch (type) {
      case 'T06':
        final texte = donnees['texte'] as String;
        final trous = RegExp(r'\{(t[1-9])\}')
            .allMatches(texte)
            .map((m) => m.group(1)!)
            .toList();
        return ControleurTrous(
          config: config,
          texte: texte,
          elements: _liste(donnees, 'etiquettes'),
          cibles: [for (final t in trous) Proposition(id: t)],
          attendu: {
            for (final r
                in (reponse['trous'] as List).cast<Map<String, dynamic>>())
              r['etiquette'] as String: r['trou'] as String,
          },
          melanger: melanger,
        );
      case 'T09':
        return ControleurAffectation(
          config: config,
          elements: _liste(donnees, 'gauche'),
          cibles: _liste(donnees, 'droite'),
          attendu: {
            for (final p
                in (reponse['paires'] as List).cast<Map<String, dynamic>>())
              p['gauche'] as String: p['droite'] as String,
          },
          forme: FormeAffectation.paires,
          melanger: melanger,
        );
      default:
        return ControleurAffectation(
          config: config,
          elements: _liste(donnees, 'elements'),
          cibles: [
            for (final k
                in (donnees['categories'] as List).cast<Map<String, dynamic>>())
              Proposition(
                id: k['id'] as String,
                texte: k['titre'] as String,
                emoji: k['emoji'] as String?,
              ),
          ],
          attendu: {
            for (final r
                in (reponse['classement'] as List).cast<Map<String, dynamic>>())
              r['element'] as String: r['categorie'] as String,
          },
          forme: FormeAffectation.bacs,
          melanger: melanger,
        );
    }
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      switch (controleur) {
        ControleurTrous() => _ZoneTrous(controleur),
        final ControleurAffectation c when c.forme == FormeAffectation.paires =>
          _ZonePaires(c),
        final ControleurAffectation c => _ZoneBacs(c, tableau: type == 'T12'),
        _ => throw ArgumentError.value(controleur, 'controleur'),
      };
}

/// T06 : affectation des étiquettes aux trous d'un texte.
class ControleurTrous extends ControleurAffectation {
  ControleurTrous({
    required super.config,
    required this.texte,
    required super.elements,
    required super.cibles,
    required super.attendu,
    super.melanger,
  }) : super(forme: FormeAffectation.trous);

  /// Texte avec les trous `{t1}`...
  final String texte;

  /// Étiquette posée dans [trou], `null` si vide.
  Proposition? etiquetteDans(String trou) => elementsSur(trou).firstOrNull;
}

/// Outils communs aux zones : tuiles de la réserve, dépôt avec son et
/// vibration, libellés.
class _Outils {
  _Outils(this.context, this.controleur)
    : libelles = LibellesLecteur.pour(
        controleur.config.langue,
        controleur.config.formeAdresse,
      ),
      services = ServicesExercice.of(context);

  final BuildContext context;
  final ControleurGlisser controleur;
  final LibellesLecteur libelles;
  final ServicesExercice services;

  bool get apercu => controleur.config.mode != ModeExercice.enfant;

  /// Dépôt de [id] sur [cible] : vibration légère et son `depot`.
  void deposer(String id, String cible) {
    services.vibration.legere();
    services.audio.jouerSon(SonInterface.depot);
    controleur.poser(id, cible);
  }

  /// Toucher de [cible] : l'élément en attente s'y pose (même retour
  /// qu'un dépôt).
  void poserAttente(String cible) {
    if (controleur.enAttente == null) return;
    services.vibration.legere();
    services.audio.jouerSon(SonInterface.depot);
    controleur.poserAttente(cible);
  }

  String? motEtat(String id) {
    if (!apercu) return null;
    return switch (controleur.etatDe(id)) {
      EtatGlissable.juste => 'juste',
      EtatGlissable.faux => 'faux',
      _ => null,
    };
  }

  /// Tuile de l'élément [id], posée ou dans la réserve. [fantome] : la
  /// place vide gardée dans la réserve quand l'élément est posé.
  Widget tuile(String id, {bool grand = false, bool fantome = false}) {
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
      key: ValueKey('element_$id'),
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
              // Posé : revient dans la réserve. Sinon : attente.
              if (controleur.estPose(id)) {
                controleur.retirer(id);
              } else {
                controleur.basculerAttente(id);
              }
            }
          : null,
      // Posé et glissé hors de toute cible : revient dans la réserve.
      onSorti: controleur.modifiable && controleur.estPose(id)
          ? () => controleur.retirer(id)
          : null,
    );
  }

  /// La réserve : chaque élément à sa place, invisible s'il est posé.
  Widget reserve({bool grand = false}) => Wrap(
    key: const ValueKey('reserve'),
    spacing: EspacesYasmina.space2,
    runSpacing: EspacesYasmina.space2,
    children: [
      for (final e in controleur.elements)
        tuile(e.id, grand: grand, fantome: controleur.estPose(e.id)),
    ],
  );

  EtatDepot etatCible({required bool juste}) =>
      juste &&
          controleur.affichage != AffichageReponse.saisie &&
          controleur.affichage != AffichageReponse.faux
      ? EtatDepot.juste
      : EtatDepot.repos;
}

/// T06 : le texte avec ses trous en cibles, puis les étiquettes.
class _ZoneTrous extends StatelessWidget {
  const _ZoneTrous(this.controleur);

  final ControleurTrous controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = controleur.config.langue;
    final arabe = langue == 'ar';
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final o = _Outils(context, controleur);
        final long = controleur.texte.length > 80;
        final style = ThemeYasmina.pourLangue(
          arabe
              ? StylesYasmina.contentSentence
              : long
              ? StylesYasmina.latinBody
              : StylesYasmina.latinPrompt,
          langue,
        ).copyWith(color: c.ink);
        final morceaux = <Widget>[];
        var reste = controleur.texte;
        final trou = RegExp(r'\{(t[1-9])\}');
        while (reste.isNotEmpty) {
          final m = trou.firstMatch(reste);
          final avant = m == null ? reste : reste.substring(0, m.start);
          for (final mot in avant.split(' ')) {
            if (mot.isNotEmpty) morceaux.add(Text(mot, style: style));
          }
          if (m == null) break;
          final id = m.group(1)!;
          final posee = controleur.etiquetteDans(id);
          morceaux.add(
            ZoneDepot(
              key: ValueKey('cible_$id'),
              libelle: id,
              enLigne: true,
              etat: o.etatCible(
                juste: posee != null && controleur.estJuste(posee.id),
              ),
              onDepot: controleur.modifiable ? (e) => o.deposer(e, id) : null,
              onToucher: controleur.modifiable
                  ? () => o.poserAttente(id)
                  : null,
              child: posee == null
                  ? SizedBox(
                      width: EspacesYasmina.targetMin,
                      child: Text(' ', style: style),
                    )
                  : o.tuile(posee.id),
            ),
          );
          reste = reste.substring(m.end);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space6,
          children: [
            Wrap(
              key: const ValueKey('texte_trous'),
              spacing: EspacesYasmina.space1,
              runSpacing: EspacesYasmina.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: morceaux,
            ),
            o.reserve(),
          ],
        );
      },
    );
  }
}

/// T09 : deux colonnes, les éléments à glisser au début de ligne, les
/// cibles à la fin. Un élément posé s'affiche sous sa cible.
class _ZonePaires extends StatelessWidget {
  const _ZonePaires(this.controleur);

  final ControleurAffectation controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = controleur.config.langue;
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final o = _Outils(context, controleur);
        final styleCible = ThemeYasmina.pourLangue(
          langue == 'ar'
              ? StylesYasmina.contentOption
              : StylesYasmina.latinPrompt,
          langue,
        ).copyWith(color: c.ink);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: EspacesYasmina.space4,
          children: [
            Expanded(
              child: Column(
                key: const ValueKey('reserve'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: EspacesYasmina.space3,
                children: [
                  for (final e in controleur.elements)
                    o.tuile(e.id, fantome: controleur.estPose(e.id)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: EspacesYasmina.space3,
                children: [
                  for (final cible in controleur.cibles)
                    ZoneDepot(
                      key: ValueKey('cible_${cible.id}'),
                      libelle:
                          cible.texte ??
                          o.libelles.image(
                            controleur.cibles.indexOf(cible) + 1,
                          ),
                      etat: o.etatCible(
                        juste: controleur
                            .elementsSur(cible.id)
                            .any((e) => controleur.estJuste(e.id)),
                      ),
                      onDepot: controleur.modifiable
                          ? (e) => o.deposer(e, cible.id)
                          : null,
                      onToucher: controleur.modifiable
                          ? () => o.poserAttente(cible.id)
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: EspacesYasmina.space2,
                        children: [
                          if (cible.emoji case final emoji?)
                            Text(emoji, style: StylesYasmina.contentWord),
                          if (cible.texte case final texte?)
                            Text(
                              texte,
                              textAlign: TextAlign.center,
                              style: styleCible,
                            ),
                          for (final e in controleur.elementsSur(cible.id))
                            o.tuile(e.id),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// T11 et T12 : la réserve au-dessus, les bacs (ou colonnes du tableau)
/// en dessous, les éléments posés s'empilent dans leur bac.
class _ZoneBacs extends StatelessWidget {
  const _ZoneBacs(this.controleur, {required this.tableau});

  final ControleurAffectation controleur;
  final bool tableau;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = controleur.config.langue;
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final o = _Outils(context, controleur);
        final styleTitre = ThemeYasmina.pourLangue(
          langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
          langue,
        ).copyWith(color: c.ink);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space6,
          children: [
            o.reserve(),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: EspacesYasmina.space3,
                children: [
                  for (final bac in controleur.cibles)
                    Expanded(
                      child: ZoneDepot(
                        key: ValueKey('cible_${bac.id}'),
                        libelle: bac.texte ?? bac.id,
                        etat: o.etatCible(
                          juste:
                              controleur.elementsSur(bac.id).isNotEmpty &&
                              controleur
                                  .elementsSur(bac.id)
                                  .every((e) => controleur.estJuste(e.id)),
                        ),
                        onDepot: controleur.modifiable
                            ? (e) => o.deposer(e, bac.id)
                            : null,
                        onToucher: controleur.modifiable
                            ? () => o.poserAttente(bac.id)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: EspacesYasmina.space2,
                          children: [
                            Text(
                              [
                                if (!tableau && bac.emoji != null) bac.emoji,
                                bac.texte,
                              ].join(' '),
                              key: ValueKey('titre_${bac.id}'),
                              textAlign: TextAlign.center,
                              style: styleTitre,
                            ),
                            if (tableau)
                              Divider(
                                color: c.line,
                                height: TraitsYasmina.borderThin,
                              ),
                            for (final e in controleur.elementsSur(bac.id))
                              o.tuile(e.id),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
