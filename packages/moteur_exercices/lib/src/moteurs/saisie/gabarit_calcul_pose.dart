import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'pave_numerique.dart';

/// T48 Calcul posé (docs/moteurs/saisie-numerique.md) : addition ou
/// soustraction en colonnes, le résultat s'écrit chiffre par chiffre des
/// unités vers les dizaines. `sens` et `chiffres` viennent du JSON.
class GabaritCalculPose implements GabaritReponse {
  const GabaritCalculPose();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurCalcul creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurCalcul(
      config: config,
      a: donnees['a'] as int,
      b: donnees['b'] as int,
      addition: donnees['operation'] == 'addition',
      unitesADroite: donnees['sens'] != 'gauche-droite',
      orientaux: donnees['chiffres'] == 'orientaux',
      retenues: donnees['retenues'] as bool? ?? false,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneCalcul(controleur as ControleurCalcul);
}

/// Les cases du résultat, remplies des unités vers les dizaines.
class ControleurCalcul extends ControleurReponse {
  ControleurCalcul({
    required this.config,
    required this.a,
    required this.b,
    required this.addition,
    required this.unitesADroite,
    required this.orientaux,
    required this.retenues,
  }) : resultat = addition ? a + b : a - b {
    colonnes = '${math.max(math.max(a, b), resultat)}'.length;
    _cases = List<int?>.filled(colonnes, null);
    _retenues = List<bool>.filled(colonnes, false);
  }

  final ConfigExercice config;
  final int a;
  final int b;
  final bool addition;
  final int resultat;

  /// Colonne des unités à droite (`droite-gauche`) ou à gauche.
  final bool unitesADroite;
  final bool orientaux;

  /// Cases de retenue au-dessus des colonnes (aide, hors correction).
  final bool retenues;

  /// Nombre de colonnes (chiffres du plus grand nombre).
  late final int colonnes;
  late List<int?> _cases;
  late List<bool> _retenues;
  int _remplies = 0;

  /// Chiffre de la colonne [i] (0 : unités), `null` si vide. La bonne
  /// réponse quand elle est révélée.
  int? chiffre(int i) {
    if (affichage == AffichageReponse.revelee) {
      final texte = '$resultat';
      return i < texte.length ? int.parse(texte[texte.length - 1 - i]) : null;
    }
    return _cases[i];
  }

  /// Colonne qui recevra le prochain chiffre, `null` si tout est rempli.
  int? get colonneActive =>
      modifiable && _remplies < colonnes ? _remplies : null;

  bool retenue(int i) => _retenues[i];

  void ajouter(int chiffre) {
    if (!modifiable || _remplies >= colonnes) return;
    _cases[_remplies] = chiffre;
    _remplies++;
    reponseModifiee();
  }

  void effacer() {
    if (!modifiable || _remplies == 0) return;
    _remplies--;
    _cases[_remplies] = null;
    reponseModifiee();
  }

  /// Pose ou retire la retenue de la colonne [i] (toujours 1).
  void basculerRetenue(int i) {
    if (!modifiable) return;
    _retenues[i] = !_retenues[i];
    notifyListeners();
  }

  /// Nombre formé par les cases (les cases vides valent 0).
  int get valeur {
    var v = 0;
    for (var i = colonnes - 1; i >= 0; i--) {
      v = v * 10 + (_cases[i] ?? 0);
    }
    return v;
  }

  @override
  bool get complete => _remplies > 0;

  @override
  Object? get reponse => {'valeur': valeur};

  @override
  bool corriger() => valeur == resultat;

  @override
  void vider() {
    _cases = List<int?>.filled(colonnes, null);
    _retenues = List<bool>.filled(colonnes, false);
    _remplies = 0;
    reponseModifiee();
  }
}

/// Le calcul en colonnes (de gauche à droite, le sens du JSON décide où
/// sont les unités), puis le pavé.
class _ZoneCalcul extends StatelessWidget {
  const _ZoneCalcul(this.controleur);

  final ControleurCalcul controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final style = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    final styleRetenue = ThemeYasmina.pourLangue(
      StylesYasmina.contentOption,
      langue,
    ).copyWith(color: c.muted);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final juste = affichage == AffichageReponse.juste || revelee;
        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : juste
            ? 'juste'
            : faux
            ? 'faux'
            : null;
        String ch(String t) =>
            afficherChiffres(t, orientaux: controleur.orientaux);
        // Colonnes dans l'ordre d'affichage, de gauche à droite.
        final n = controleur.colonnes;
        final ordre = controleur.unitesADroite
            ? [for (var i = n - 1; i >= 0; i--) i]
            : [for (var i = 0; i < n; i++) i];
        String? chiffreDe(int nombre, int colonne) {
          final t = '$nombre';
          return colonne < t.length ? t[t.length - 1 - colonne] : null;
        }

        Widget cellule(
          Widget? enfant, {
          Key? key,
          Color? bord,
          VoidCallback? onTap,
        }) => SizedBox(
          key: key,
          width: EspacesYasmina.targetMin,
          height: EspacesYasmina.targetMin,
          child: bord == null
              ? Center(child: enfant)
              : Material(
                  color: c.tile,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                    side: BorderSide(
                      color: bord,
                      width: TraitsYasmina.borderThick,
                    ),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                    child: Center(child: enfant),
                  ),
                ),
        );
        final signe = Text(controleur.addition ? '+' : '−', style: style);
        // Le signe du côté opposé aux unités.
        Widget ligne(List<Widget> cellules, {Widget? debut}) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: EspacesYasmina.space2,
          children: [
            if (controleur.unitesADroite) cellule(debut),
            ...cellules,
            if (!controleur.unitesADroite) cellule(debut),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Semantics(
                label:
                    '${controleur.a} ${controleur.addition ? '+' : '−'} '
                    '${controleur.b}',
                child: Column(
                  key: ValueKey(revelee ? 'calcul_reponse' : 'calcul'),
                  spacing: EspacesYasmina.space2,
                  children: [
                    if (controleur.retenues)
                      ligne([
                        for (final i in ordre)
                          cellule(
                            Text(
                              controleur.retenue(i) ? ch('1') : '',
                              style: styleRetenue,
                            ),
                            key: ValueKey('retenue_$i'),
                            bord: c.line,
                            onTap: modifiable
                                ? () => controleur.basculerRetenue(i)
                                : null,
                          ),
                      ]),
                    ligne([
                      for (final i in ordre)
                        cellule(
                          Text(
                            ch(chiffreDe(controleur.a, i) ?? ''),
                            style: style,
                          ),
                          key: ValueKey('a_$i'),
                        ),
                    ]),
                    ligne([
                      for (final i in ordre)
                        cellule(
                          Text(
                            ch(chiffreDe(controleur.b, i) ?? ''),
                            style: style,
                          ),
                          key: ValueKey('b_$i'),
                        ),
                    ], debut: signe),
                    Divider(color: c.ink, thickness: TraitsYasmina.borderThick),
                    ligne([
                      for (final i in ordre)
                        cellule(
                          Text(
                            controleur.chiffre(i) == null
                                ? ''
                                : ch('${controleur.chiffre(i)}'),
                            style: style,
                          ),
                          key: ValueKey('case_$i'),
                          bord: juste
                              ? c.olive
                              : faux
                              ? c.coral
                              : controleur.colonneActive == i
                              ? c.blue
                              : c.line,
                        ),
                    ]),
                  ],
                ),
              ),
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('calcul_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: faux ? c.coralText : c.oliveText,
                ),
              ),
            PaveNumerique(
              orientaux: controleur.orientaux,
              libelleEffacer: libelles.effacer,
              onChiffre: modifiable ? controleur.ajouter : null,
              onEffacer: modifiable && controleur.complete
                  ? controleur.effacer
                  : null,
            ),
          ],
        );
      },
    );
  }
}
