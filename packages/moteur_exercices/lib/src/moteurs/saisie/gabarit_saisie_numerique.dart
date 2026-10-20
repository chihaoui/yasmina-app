import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'pave_numerique.dart';

/// T22 Saisie numérique (docs/moteurs/saisie-numerique.md) : l'enfant lit
/// et entend un court problème, tape la réponse sur le pavé. Juste à
/// `tolerance` près.
class GabaritSaisieNumerique implements GabaritReponse {
  const GabaritSaisieNumerique();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurSaisie creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurSaisie(
      config: config,
      attendu: reponse['valeur'] as int,
      tolerance: (exercice['tolerance'] as num?) ?? 0,
      chiffresMax: donnees['chiffres_max'] as int? ?? 3,
      orientaux: donnees['chiffres'] == 'orientaux',
      texte: donnees['texte'] as String?,
      emoji: donnees['emoji'] as String?,
      unite: donnees['unite'] as String?,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneSaisie(controleur as ControleurSaisie);
}

/// Les chiffres tapés.
class ControleurSaisie extends ControleurReponse {
  ControleurSaisie({
    required this.config,
    required this.attendu,
    required this.tolerance,
    required this.chiffresMax,
    required this.orientaux,
    this.texte,
    this.emoji,
    this.unite,
  });

  final ConfigExercice config;
  final int attendu;
  final num tolerance;
  final int chiffresMax;
  final bool orientaux;
  final String? texte;
  final String? emoji;
  final String? unite;

  String _chiffres = '';

  /// Chiffres tapés, en 0 à 9 (la valeur attendue quand elle est révélée).
  String get chiffres =>
      affichage == AffichageReponse.revelee ? '$attendu' : _chiffres;

  int? get valeur => _chiffres.isEmpty ? null : int.parse(_chiffres);

  void ajouter(int chiffre) {
    if (!modifiable || _chiffres.length >= chiffresMax) return;
    // Pas de zéro de tête.
    if (_chiffres == '0') _chiffres = '';
    _chiffres += '$chiffre';
    reponseModifiee();
  }

  void effacer() {
    if (!modifiable || _chiffres.isEmpty) return;
    _chiffres = _chiffres.substring(0, _chiffres.length - 1);
    reponseModifiee();
  }

  @override
  bool get complete => _chiffres.isNotEmpty;

  @override
  Object? get reponse => {'valeur': valeur};

  @override
  bool corriger() => valeur != null && (valeur! - attendu).abs() <= tolerance;

  @override
  void vider() {
    _chiffres = '';
    reponseModifiee();
  }

  /// Le problème est dit après la consigne.
  @override
  String? get ecouteOuverture => texte;
}

/// Le problème, le champ, le pavé.
class _ZoneSaisie extends StatelessWidget {
  const _ZoneSaisie(this.controleur);

  final ControleurSaisie controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final styleTexte = ThemeYasmina.pourLangue(
      langue == 'ar'
          ? StylesYasmina.contentSentence
          : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    final styleValeur = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final bord = switch (affichage) {
          AffichageReponse.juste || AffichageReponse.revelee => c.olive,
          AffichageReponse.faux when !controleur.corriger() => c.coral,
          _ => c.line,
        };
        final motEtat = !apercu
            ? null
            : switch (affichage) {
                AffichageReponse.juste || AffichageReponse.revelee => 'juste',
                AffichageReponse.faux when !controleur.corriger() => 'faux',
                _ => null,
              };
        final affiche = afficherChiffres(
          controleur.chiffres,
          orientaux: controleur.orientaux,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            if (controleur.emoji case final emoji?)
              Text(
                emoji,
                key: const ValueKey('saisie_emoji'),
                textAlign: TextAlign.center,
                style: StylesYasmina.letterHero,
              ),
            if (controleur.texte case final texte?)
              Text(
                texte,
                key: const ValueKey('saisie_texte'),
                textAlign: TextAlign.center,
                style: styleTexte,
              ),
            DecoratedBox(
              key: ValueKey(revelee ? 'saisie_reponse' : 'saisie_champ'),
              decoration: BoxDecoration(
                color: c.tile,
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
                border: Border.all(
                  color: bord,
                  width: TraitsYasmina.borderThick,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: TaillesYasmina.choiceMinHeight,
                ),
                child: Center(
                  child: Semantics(
                    textField: true,
                    value: controleur.chiffres,
                    child: Text(
                      [
                        affiche.isEmpty ? ' ' : affiche,
                        ?controleur.unite,
                      ].join(' '),
                      key: const ValueKey('saisie_valeur'),
                      textAlign: TextAlign.center,
                      style: styleValeur,
                    ),
                  ),
                ),
              ),
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('saisie_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: affichage == AffichageReponse.faux
                      ? c.coralText
                      : c.oliveText,
                ),
              ),
            PaveNumerique(
              orientaux: controleur.orientaux,
              libelleEffacer: libelles.effacer,
              onChiffre: modifiable ? controleur.ajouter : null,
              onEffacer: modifiable && controleur.chiffres.isNotEmpty
                  ? controleur.effacer
                  : null,
            ),
          ],
        );
      },
    );
  }
}
