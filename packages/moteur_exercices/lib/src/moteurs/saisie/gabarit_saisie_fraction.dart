import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'pave_numerique.dart';

/// Une fraction (numérateur sur dénominateur).
class Fraction {
  const Fraction(this.numerateur, this.denominateur);

  factory Fraction.depuisJson(Map<String, dynamic> json) =>
      Fraction(json['numerateur'] as int, json['denominateur'] as int);

  final int numerateur;
  final int denominateur;

  /// Même valeur (3/4 et 6/8).
  bool equivaut(Fraction autre) =>
      denominateur != 0 &&
      autre.denominateur != 0 &&
      numerateur * autre.denominateur == autre.numerateur * denominateur;

  @override
  String toString() => '$numerateur/$denominateur';
}

/// T49 Saisie de fraction (docs/moteurs/saisie-numerique.md §14) : l'enfant
/// calcule une addition ou une soustraction de fractions et écrit le
/// résultat, numérateur puis dénominateur, sur le pavé. Une fraction
/// équivalente est acceptée si `equivalentes` (par défaut).
class GabaritSaisieFraction implements GabaritReponse {
  const GabaritSaisieFraction();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurSaisieFraction creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurSaisieFraction(
      config: config,
      termes: [
        for (final t
            in (donnees['termes'] as List).cast<Map<String, dynamic>>())
          Fraction.depuisJson(t),
      ],
      addition: donnees['operation'] != 'soustraction',
      equivalentes: donnees['equivalentes'] as bool? ?? true,
      orientaux: donnees['chiffres'] == 'orientaux',
      attendu: Fraction.depuisJson(reponse),
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneSaisieFraction(controleur as ControleurSaisieFraction);
}

/// Champ de la fraction écrite.
enum ChampFraction { numerateur, denominateur }

/// Le numérateur et le dénominateur tapés.
class ControleurSaisieFraction extends ControleurReponse {
  ControleurSaisieFraction({
    required this.config,
    required this.termes,
    required this.addition,
    required this.equivalentes,
    required this.orientaux,
    required this.attendu,
  });

  final ConfigExercice config;
  final List<Fraction> termes;
  final bool addition;

  /// Accepte une fraction équivalente (6/8 pour 3/4).
  final bool equivalentes;
  final bool orientaux;
  final Fraction attendu;

  /// Chiffres au plus par champ.
  static const chiffresMax = 2;

  String _numerateur = '';
  String _denominateur = '';
  ChampFraction _actif = ChampFraction.numerateur;

  bool get _revelee => affichage == AffichageReponse.revelee;

  String get numerateur => _revelee ? '${attendu.numerateur}' : _numerateur;
  String get denominateur =>
      _revelee ? '${attendu.denominateur}' : _denominateur;

  /// Champ qui reçoit le prochain chiffre.
  ChampFraction get actif => _actif;

  /// La fraction écrite, `null` tant qu'un champ est vide.
  Fraction? get fraction => _numerateur.isEmpty || _denominateur.isEmpty
      ? null
      : Fraction(int.parse(_numerateur), int.parse(_denominateur));

  void activer(ChampFraction champ) {
    if (!modifiable || _actif == champ) return;
    _actif = champ;
    notifyListeners();
  }

  void ajouter(int chiffre) {
    if (!modifiable) return;
    final courant = _actif == ChampFraction.numerateur
        ? _numerateur
        : _denominateur;
    if (courant.length >= chiffresMax) return;
    final nouveau = courant == '0' ? '$chiffre' : '$courant$chiffre';
    if (_actif == ChampFraction.numerateur) {
      _numerateur = nouveau;
    } else {
      _denominateur = nouveau;
    }
    reponseModifiee();
  }

  /// Retire le dernier chiffre du champ actif (ou du numérateur si le
  /// dénominateur est vide).
  void effacer() {
    if (!modifiable) return;
    if (_actif == ChampFraction.denominateur && _denominateur.isEmpty) {
      _actif = ChampFraction.numerateur;
    }
    if (_actif == ChampFraction.numerateur) {
      if (_numerateur.isEmpty) return;
      _numerateur = _numerateur.substring(0, _numerateur.length - 1);
    } else {
      _denominateur = _denominateur.substring(0, _denominateur.length - 1);
    }
    reponseModifiee();
  }

  @override
  bool get complete => fraction != null;

  @override
  Object? get reponse => {
    'numerateur': _numerateur.isEmpty ? null : int.parse(_numerateur),
    'denominateur': _denominateur.isEmpty ? null : int.parse(_denominateur),
  };

  @override
  bool corriger() {
    final f = fraction;
    if (f == null || f.denominateur == 0) return false;
    return equivalentes
        ? f.equivaut(attendu)
        : f.numerateur == attendu.numerateur &&
              f.denominateur == attendu.denominateur;
  }

  @override
  void vider() {
    _numerateur = '';
    _denominateur = '';
    _actif = ChampFraction.numerateur;
    reponseModifiee();
  }
}

/// L'opération en fractions empilées, le résultat en deux cases, le pavé.
class _ZoneSaisieFraction extends StatelessWidget {
  const _ZoneSaisieFraction(this.controleur);

  final ControleurSaisieFraction controleur;

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

        Widget barre() => Container(
          width: EspacesYasmina.targetMin,
          height: TraitsYasmina.borderThick,
          color: c.ink,
        );

        Widget fractionFixe(Fraction f) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ch('${f.numerateur}'), style: style),
            barre(),
            Text(ch('${f.denominateur}'), style: style),
          ],
        );

        Widget caseW(ChampFraction champ, String texte) {
          final actif = modifiable && controleur.actif == champ;
          final bord = juste
              ? c.olive
              : faux
              ? c.coral
              : actif
              ? c.blue
              : c.line;
          return Semantics(
            button: true,
            enabled: modifiable,
            selected: actif,
            label: champ == ChampFraction.numerateur
                ? '${libelles.numerateur} ${ch(texte)}'
                : '${libelles.denominateur} ${ch(texte)}',
            excludeSemantics: true,
            child: Material(
              key: ValueKey('case_${champ.name}'),
              color: c.tile,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                side: BorderSide(color: bord, width: TraitsYasmina.borderThick),
              ),
              child: InkWell(
                onTap: modifiable ? () => controleur.activer(champ) : null,
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                child: SizedBox(
                  width: EspacesYasmina.targetMin + EspacesYasmina.space4,
                  height: EspacesYasmina.targetMin,
                  child: Center(child: Text(ch(texte), style: style)),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // L'opération se lit de gauche à droite, même en arabe.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Semantics(
                label:
                    '${controleur.termes.first} '
                    '${controleur.addition ? '+' : '−'} '
                    '${controleur.termes.last}',
                child: Row(
                  key: ValueKey(revelee ? 'saisie_reponse' : 'fraction_saisie'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: EspacesYasmina.space3,
                  children: [
                    fractionFixe(controleur.termes.first),
                    Text(controleur.addition ? '+' : '−', style: style),
                    fractionFixe(controleur.termes.last),
                    Text('=', style: style),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: EspacesYasmina.space1,
                      children: [
                        caseW(ChampFraction.numerateur, controleur.numerateur),
                        caseW(
                          ChampFraction.denominateur,
                          controleur.denominateur,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('saisie_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: faux ? c.coralText : c.oliveText,
                ),
              ),
            PaveNumerique(
              orientaux: controleur.orientaux,
              libelleEffacer: libelles.effacer,
              onChiffre: modifiable ? controleur.ajouter : null,
              onEffacer:
                  modifiable &&
                      (controleur.numerateur.isNotEmpty ||
                          controleur.denominateur.isNotEmpty)
                  ? controleur.effacer
                  : null,
            ),
          ],
        );
      },
    );
  }
}
