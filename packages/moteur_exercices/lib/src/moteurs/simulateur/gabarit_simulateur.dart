import 'package:flutter/material.dart';

import '../../composants/bouton_yasmina.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Un objet de l'expérience : une icône, un nom, l'issue réelle (`a` ou
/// `b`).
class ObjetExperience {
  const ObjetExperience({
    required this.id,
    required this.emoji,
    required this.libelle,
    required this.issue,
  });

  final String id;
  final String emoji;
  final String libelle;

  /// `a` ou `b`, l'issue observée.
  final String issue;
}

/// Une issue possible de l'expérience (flotte ou coule, s'allume ou pas).
class IssueExperience {
  const IssueExperience({required this.libelle, this.emoji});

  factory IssueExperience.depuisJson(Map<String, dynamic> json) =>
      IssueExperience(
        libelle: json['libelle'] as String,
        emoji: json['emoji'] as String?,
      );

  final String libelle;
  final String? emoji;
}

/// T57 Simulateur d'expérience (docs/moteurs/simulateur.md), et T34 Flotte
/// ou coule qui en est une instance (décor `eau`) : prédire, observer,
/// expliquer. L'enfant prédit l'issue de chaque objet (deux issues
/// possibles), puis lance l'observation : le simulateur montre les issues
/// réelles, compare, et l'exercice se termine (mode automatique). Juste si
/// toutes les prédictions sont bonnes. L'explication vient du feedback.
class GabaritSimulateur implements GabaritReponse {
  const GabaritSimulateur();

  @override
  ModeValidation get validation => ModeValidation.automatique;

  @override
  ControleurSimulateur creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final resultats = {
      for (final r
          in (reponse['resultats'] as List).cast<Map<String, dynamic>>())
        r['objet'] as String: r['issue'] as String,
    };
    final issues = (donnees['issues'] as Map).cast<String, dynamic>();
    return ControleurSimulateur(
      config: config,
      objets: [
        for (final o
            in (donnees['objets'] as List).cast<Map<String, dynamic>>())
          ObjetExperience(
            id: o['id'] as String,
            emoji: o['emoji'] as String,
            libelle: o['libelle'] as String,
            issue: resultats[o['id']] ?? 'a',
          ),
      ],
      issueA: IssueExperience.depuisJson(issues['a'] as Map<String, dynamic>),
      issueB: IssueExperience.depuisJson(issues['b'] as Map<String, dynamic>),
      decor: donnees['decor'] as String? ?? 'aucun',
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneSimulateur(controleur as ControleurSimulateur);
}

/// Étape de l'expérience.
enum EtapeExperience { predire, observer }

/// Les prédictions, puis l'observation.
class ControleurSimulateur extends ControleurReponse {
  ControleurSimulateur({
    required this.config,
    required this.objets,
    required this.issueA,
    required this.issueB,
    required this.decor,
  });

  final ConfigExercice config;
  final List<ObjetExperience> objets;
  final IssueExperience issueA;
  final IssueExperience issueB;

  /// `eau` (cuve, les objets flottent ou coulent), `circuit` (lampe allumée
  /// ou éteinte), `aucun` (cartes seules).
  final String decor;

  final _predictions = <String, String>{};
  EtapeExperience _etape = EtapeExperience.predire;

  EtapeExperience get etape =>
      affichage == AffichageReponse.revelee ? EtapeExperience.observer : _etape;

  /// Objet → issue prédite. Les issues réelles quand la réponse est
  /// révélée sans observation (aperçu) : après l'observation, les
  /// prédictions de l'enfant restent affichées avec leur verdict.
  Map<String, String> get predictions =>
      affichage == AffichageReponse.revelee && _etape == EtapeExperience.predire
      ? {for (final o in objets) o.id: o.issue}
      : _predictions;

  String? prediction(String objet) => predictions[objet];

  IssueExperience issue(String code) => code == 'a' ? issueA : issueB;

  /// L'enfant prédit [issueCode] pour [objet] (tant qu'il n'a pas observé).
  void predire(String objet, String issueCode) {
    if (!modifiable || _etape != EtapeExperience.predire) return;
    _predictions[objet] = issueCode;
    reponseModifiee();
  }

  bool get toutPredit => objets.every((o) => _predictions.containsKey(o.id));

  bool estJuste(String objet) =>
      predictions[objet] == objets.firstWhere((o) => o.id == objet).issue;

  /// Lance l'observation : les issues réelles s'affichent, l'exercice se
  /// termine (juste si toutes les prédictions sont bonnes).
  void observer() {
    if (!modifiable || _etape != EtapeExperience.predire || !toutPredit) {
      return;
    }
    _etape = EtapeExperience.observer;
    notifyListeners();
    terminer(juste: objets.every((o) => estJuste(o.id)));
  }

  @override
  bool get complete => toutPredit;

  @override
  Object? get reponse => {
    'predictions': [
      for (final o in objets)
        if (_predictions[o.id] case final i?) {'objet': o.id, 'issue': i},
    ],
  };

  @override
  bool corriger() => objets.every((o) => estJuste(o.id));

  @override
  void vider() {
    _predictions.clear();
    _etape = EtapeExperience.predire;
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String observer, String prediction, String observation}) _libellesSimulateur(
  String langue,
) => switch (langue) {
  'ar' => (
    observer: 'لَاحِظْ',
    prediction: 'تَوَقُّعِي',
    observation: 'الْمُلَاحَظَةُ',
  ),
  'en' => (
    observer: 'Observe',
    prediction: 'my guess',
    observation: 'observation',
  ),
  _ => (
    observer: 'Observer',
    prediction: 'ma prédiction',
    observation: 'observation',
  ),
};

/// Les objets avec leurs deux issues à prédire, le bouton Observer, puis le
/// décor de l'observation.
class _ZoneSimulateur extends StatelessWidget {
  const _ZoneSimulateur(this.controleur);

  final ControleurSimulateur controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesSimulateur(langue);
    final services = ServicesExercice.of(context);
    final styleNom = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    final styleIssue = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.contentOption : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final observation = controleur.etape == EtapeExperience.observer;

        Widget choixIssue(ObjetExperience o, String code) {
          final issue = controleur.issue(code);
          final choisie = controleur.prediction(o.id) == code;
          final (fond, bord) = !choisie
              ? (c.tile, c.line)
              : observation
              ? (controleur.estJuste(o.id)
                    ? (c.oliveSoft, c.olive)
                    : (c.coralSoft, c.coral))
              : (c.blueSoft, c.blue);
          return Expanded(
            child: Semantics(
              button: true,
              enabled: modifiable && !observation,
              selected: choisie,
              label: '${o.libelle}, ${issue.libelle}',
              excludeSemantics: true,
              child: Material(
                key: ValueKey('issue_${o.id}_$code'),
                color: fond,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                  side: BorderSide(
                    color: bord,
                    width: TraitsYasmina.borderThick,
                  ),
                ),
                child: InkWell(
                  onTap: modifiable && !observation
                      ? () {
                          controleur.predire(o.id, code);
                          services.vibration.legere();
                        }
                      : null,
                  borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: EspacesYasmina.targetMin,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(EspacesYasmina.space2),
                        child: Text(
                          [?issue.emoji, issue.libelle].join(' '),
                          textAlign: TextAlign.center,
                          style: styleIssue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            if (observation)
              _Decor(
                key: ValueKey(revelee ? 'simulateur_reponse' : 'observation'),
                controleur: controleur,
                libelleObservation: l.observation,
              ),
            for (final o in controleur.objets)
              Row(
                key: ValueKey('objet_${o.id}'),
                spacing: EspacesYasmina.space2,
                children: [
                  SizedBox(
                    width: EspacesYasmina.targetMin + EspacesYasmina.space8,
                    child: Column(
                      children: [
                        Text(o.emoji, style: StylesYasmina.contentWord),
                        Text(
                          o.libelle,
                          style: styleNom,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  choixIssue(o, 'a'),
                  choixIssue(o, 'b'),
                  if (observation)
                    Text(
                      controleur.estJuste(o.id) ? '✔' : '✘',
                      key: ValueKey('verdict_${o.id}'),
                      style: styleIssue.copyWith(
                        color: controleur.estJuste(o.id)
                            ? c.oliveText
                            : c.coralText,
                      ),
                    ),
                ],
              ),
            if (!observation)
              BoutonYasmina(
                key: const ValueKey('simulateur_observer'),
                libelle: l.observer,
                icone: Icons.visibility_rounded,
                onPressed: modifiable && controleur.toutPredit
                    ? () {
                        services.audio.jouerSon(SonInterface.depot);
                        controleur.observer();
                      }
                    : null,
              ),
            if (apercu && revelee)
              Text(
                'juste',
                key: const ValueKey('simulateur_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(color: c.oliveText),
              ),
          ],
        );
      },
    );
  }
}

/// Le décor de l'observation : la cuve d'eau (les objets de l'issue `a`
/// flottent, ceux de l'issue `b` coulent), le circuit (une lampe allumée
/// pour `a`, éteinte pour `b`), ou les issues écrites.
class _Decor extends StatelessWidget {
  const _Decor({
    super.key,
    required this.controleur,
    required this.libelleObservation,
  });

  final ControleurSimulateur controleur;
  final String libelleObservation;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final flottent = controleur.objets.where((o) => o.issue == 'a').toList();
    final coulent = controleur.objets.where((o) => o.issue == 'b').toList();
    Widget rangee(List<ObjetExperience> objets) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final o in objets)
          Text(
            o.emoji,
            key: ValueKey('observe_${o.id}'),
            style: StylesYasmina.contentWord,
          ),
      ],
    );
    return Semantics(
      label: libelleObservation,
      child: switch (controleur.decor) {
        'eau' => Container(
          // Deux rangées d'objets (l'air, l'eau) et leurs marges.
          height:
              TaillesYasmina.yasminaHome +
              EspacesYasmina.space8 +
              EspacesYasmina.space8,
          decoration: BoxDecoration(
            color: c.tile,
            borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
            border: Border.all(color: c.line, width: TraitsYasmina.borderThin),
          ),
          child: Column(
            children: [
              // L'air, puis la surface de l'eau où flottent les objets a.
              const Spacer(),
              rangee(flottent),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.blueSoft,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(RayonsYasmina.radiusLg),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: c.blue,
                        width: TraitsYasmina.borderThick,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: rangee(coulent),
                        ),
                      ),
                      const SizedBox(height: EspacesYasmina.space2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        'circuit' => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final o in controleur.objets)
              Column(
                key: ValueKey('observe_${o.id}'),
                children: [
                  Text(o.emoji, style: StylesYasmina.contentWord),
                  Icon(
                    o.issue == 'a' ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: o.issue == 'a' ? c.sun : c.muted,
                    size: TaillesYasmina.iconListen + EspacesYasmina.space4,
                  ),
                ],
              ),
          ],
        ),
        _ => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final o in controleur.objets)
              Column(
                key: ValueKey('observe_${o.id}'),
                children: [
                  Text(o.emoji, style: StylesYasmina.contentWord),
                  Text(
                    controleur.issue(o.issue).libelle,
                    style: StylesYasmina.latinLabel.copyWith(color: c.ink),
                  ),
                ],
              ),
          ],
        ),
      },
    );
  }
}
