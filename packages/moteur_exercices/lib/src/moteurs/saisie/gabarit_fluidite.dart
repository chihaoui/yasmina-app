import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../composants/bouton_yasmina.dart';
import '../../composants/tuile_choix.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/mouvements_yasmina.dart';
import '../../theme/theme_yasmina.dart';
import 'pave_numerique.dart';

/// Une question de fluidité : son énoncé, sa réponse, ses options.
class QuestionFluidite {
  const QuestionFluidite({
    required this.enonce,
    required this.reponse,
    required this.options,
  });

  /// Énoncé de gauche à droite : « 7 + ? = 10 », « 3 + 4 = ? ».
  final String enonce;
  final int reponse;

  /// Trois réponses proposées, la bonne comprise, mélangées.
  final List<int> options;
}

/// T50 Fluidité chronométrée (docs/moteurs/saisie-numerique.md §14, « bats
/// ton record ») : l'enfant lance le chronomètre, puis répond au plus vite à
/// des questions de calcul mental (compléments à 10, additions,
/// soustractions) en touchant l'une des trois réponses proposées. Sans
/// note : à la fin du temps, le score s'affiche et Continuer s'active. Sans
/// chronomètre (`chrono: false`), un nombre fixe de questions.
class GabaritFluidite implements GabaritReponse {
  const GabaritFluidite();

  @override
  ModeValidation get validation => ModeValidation.sansNote;

  @override
  ControleurFluidite creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurFluidite(
      config: config,
      exercice: donnees['exercice'] as String? ?? 'complement',
      cible: donnees['cible'] as int? ?? 10,
      max: donnees['max'] as int? ?? 10,
      duree: donnees['duree'] as int? ?? 30,
      chrono: donnees['chrono'] as bool? ?? true,
      questions: donnees['questions'] as int? ?? 10,
      orientaux: donnees['chiffres'] == 'orientaux',
      questionsMin: reponse['questions_min'] as int? ?? 1,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneFluidite(controleur as ControleurFluidite);
}

/// Le chronomètre, la question courante, le score.
class ControleurFluidite extends ControleurReponse {
  ControleurFluidite({
    required this.config,
    required this.exercice,
    required this.cible,
    required this.max,
    required this.duree,
    required this.chrono,
    required this.questions,
    required this.orientaux,
    required this.questionsMin,
  }) : _hasard = Random(config.graine);

  final ConfigExercice config;

  /// `complement` (à [cible]), `addition` ou `soustraction` (jusqu'à [max]).
  final String exercice;
  final int cible;
  final int max;

  /// Durée du chronomètre en secondes.
  final int duree;

  /// Chronomètre actif (sinon [questions] questions, sans temps).
  final bool chrono;
  final int questions;
  final bool orientaux;

  /// Questions répondues au moins pour que Continuer s'active.
  final int questionsMin;

  final Random _hasard;
  Timer? _minuterie;
  bool _demarre = false;
  bool _fini = false;
  int _restant = 0;
  int _justes = 0;
  int _total = 0;
  QuestionFluidite? _question;
  int? _fausse;

  /// La partie a commencé.
  bool get demarre => _demarre;

  /// Le temps est écoulé ou toutes les questions sont posées.
  bool get fini => _fini;

  /// Secondes restantes.
  int get restant => _restant;
  int get justes => _justes;
  int get total => _total;
  QuestionFluidite? get question => _question;

  /// Option fausse qui vient d'être touchée (marquée un instant).
  int? get fausse => _fausse;

  /// Une réponse juste ou fausse vient d'être donnée (sons), remis à `null`
  /// par la zone.
  bool? reponseVientDEtreDonnee;

  /// Borne haute des réponses (compléments : la cible).
  int get borne => exercice == 'complement' ? cible : max;

  QuestionFluidite _tirer() {
    final int a;
    final int b;
    final int reponse;
    final String enonce;
    switch (exercice) {
      case 'addition':
        a = _hasard.nextInt(max + 1);
        b = _hasard.nextInt(max - a + 1);
        reponse = a + b;
        enonce = '$a + $b = ?';
      case 'soustraction':
        a = _hasard.nextInt(max + 1);
        b = _hasard.nextInt(a + 1);
        reponse = a - b;
        enonce = '$a − $b = ?';
      default:
        a = _hasard.nextInt(cible + 1);
        reponse = cible - a;
        enonce = '$a + ? = $cible';
    }
    final options = <int>{reponse};
    while (options.length < 3) {
      options.add(_hasard.nextInt(borne + 1));
    }
    final liste = options.toList()..shuffle(_hasard);
    return QuestionFluidite(enonce: enonce, reponse: reponse, options: liste);
  }

  void demarrer() {
    if (!modifiable || _demarre) return;
    _demarre = true;
    _restant = duree;
    _question = _tirer();
    if (chrono) {
      _minuterie = Timer.periodic(const Duration(seconds: 1), (_) {
        _restant--;
        if (_restant <= 0) {
          _terminer();
        } else {
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void _terminer() {
    _minuterie?.cancel();
    _minuterie = null;
    _fini = true;
    _question = null;
    _fausse = null;
    reponseModifiee();
  }

  /// Arrête la partie avant la fin (bouton Stop).
  void arreter() {
    if (!_demarre || _fini) return;
    _terminer();
  }

  /// Touche l'option [valeur] de la question courante.
  void repondre(int valeur) {
    final q = _question;
    if (!modifiable || q == null || _fausse != null || _fini) return;
    _total++;
    if (valeur == q.reponse) {
      _justes++;
      reponseVientDEtreDonnee = true;
      _question = _tirer();
    } else {
      reponseVientDEtreDonnee = false;
      _fausse = valeur;
      Timer(MouvementsYasmina.dureeFaux, () {
        if (_fini) return;
        _fausse = null;
        _question = _tirer();
        notifyListeners();
      });
    }
    if (!chrono && _total >= questions) {
      _terminer();
      return;
    }
    reponseModifiee();
  }

  @override
  bool get complete => _fini && _total >= questionsMin;

  @override
  Object? get reponse => {'justes': _justes, 'total': _total};

  @override
  bool corriger() => true;

  @override
  void vider() {
    _minuterie?.cancel();
    _minuterie = null;
    _demarre = false;
    _fini = false;
    _restant = 0;
    _justes = 0;
    _total = 0;
    _question = null;
    _fausse = null;
    reponseModifiee();
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }
}

/// Libellés propres au type.
({
  String demarrer,
  String arreter,
  String secondes,
  String Function(int j, int t) score,
})
_libellesFluidite(String langue) => switch (langue) {
  'ar' => (
    demarrer: 'اِبْدَأْ',
    arreter: 'تَوَقَّفْ',
    secondes: 'ثَانِيَةٌ',
    score: (j, t) => 'النَّتِيجَةُ: $j مِنْ $t',
  ),
  'en' => (
    demarrer: 'Start',
    arreter: 'Stop',
    secondes: 's',
    score: (j, t) => 'Score: $j out of $t',
  ),
  _ => (
    demarrer: 'Commencer',
    arreter: 'Stop',
    secondes: 's',
    score: (j, t) => 'Score : $j sur $t',
  ),
};

/// Le bouton de départ, puis le chronomètre, la question et ses trois
/// réponses, puis le score.
class _ZoneFluidite extends StatelessWidget {
  const _ZoneFluidite(this.controleur);

  final ControleurFluidite controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesFluidite(langue);
    final services = ServicesExercice.of(context);
    final styleGrand = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    final styleOption = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    String ch(String t) => afficherChiffres(t, orientaux: controleur.orientaux);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        if (controleur.reponseVientDEtreDonnee case final juste?) {
          controleur.reponseVientDEtreDonnee = null;
          services.vibration.legere();
          services.audio.jouerSon(
            juste ? SonInterface.depot : SonInterface.essaiFaux,
          );
        }
        final modifiable = controleur.modifiable;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final question = controleur.question;
        return Column(
          key: ValueKey(revelee ? 'saisie_reponse' : 'fluidite'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            if (!controleur.demarre)
              BoutonYasmina(
                key: const ValueKey('fluidite_demarrer'),
                libelle: l.demarrer,
                icone: Icons.play_arrow_rounded,
                onPressed: modifiable ? controleur.demarrer : null,
              )
            else if (!controleur.fini) ...[
              if (controleur.chrono)
                Text(
                  '${ch('${controleur.restant}')} ${l.secondes}',
                  key: const ValueKey('fluidite_chrono'),
                  textAlign: TextAlign.center,
                  style: styleOption,
                ),
              if (question != null) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    ch(question.enonce),
                    key: const ValueKey('fluidite_question'),
                    textAlign: TextAlign.center,
                    style: styleGrand,
                  ),
                ),
                Row(
                  spacing: EspacesYasmina.space3,
                  children: [
                    for (final option in question.options)
                      Expanded(
                        child: TuileChoix(
                          key: ValueKey('option_$option'),
                          texte: ch('$option'),
                          etat: controleur.fausse == option
                              ? EtatTuile.faux
                              : EtatTuile.repos,
                          onTap: modifiable && controleur.fausse == null
                              ? () => controleur.repondre(option)
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
              BoutonYasmina(
                key: const ValueKey('fluidite_arreter'),
                libelle: l.arreter,
                variante: VarianteBouton.alt,
                icone: Icons.stop_rounded,
                onPressed: modifiable ? controleur.arreter : null,
              ),
            ] else
              Text(
                l.score(controleur.justes, controleur.total),
                key: const ValueKey('fluidite_score'),
                textAlign: TextAlign.center,
                style: styleGrand,
              ),
            if (revelee)
              // Sans note : en aperçu, « afficher la réponse » montre
              // seulement que la zone est figée.
              Text(
                'juste',
                key: const ValueKey('saisie_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(color: c.oliveText),
              ),
          ],
        );
      },
    );
  }
}
