import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../composants/tuile_choix.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Un choix d'une étape du récit : juste (l'histoire avance) ou non (une
/// explication, puis l'enfant choisit à nouveau).
class ChoixRecit {
  const ChoixRecit({
    required this.id,
    required this.texte,
    required this.juste,
    this.pourquoi,
  });

  factory ChoixRecit.depuisJson(Map<String, dynamic> json) => ChoixRecit(
    id: json['id'] as String,
    texte: json['texte'] as String,
    juste: json['juste'] as bool? ?? false,
    pourquoi: json['pourquoi'] as String?,
  );

  final String id;
  final String texte;
  final bool juste;

  /// Pourquoi ce choix n'est pas le bon (affiché et dit).
  final String? pourquoi;
}

/// Une étape du récit : une scène en emoji, un texte, des choix.
class EtapeRecit {
  const EtapeRecit({
    required this.id,
    required this.texte,
    required this.choix,
    this.scene,
  });

  factory EtapeRecit.depuisJson(Map<String, dynamic> json) => EtapeRecit(
    id: json['id'] as String,
    texte: json['texte'] as String,
    scene: json['scene'] as String?,
    choix: [
      for (final c in (json['choix'] as List).cast<Map<String, dynamic>>())
        ChoixRecit.depuisJson(c),
    ],
  );

  final String id;
  final String texte;
  final String? scene;
  final List<ChoixRecit> choix;
}

/// T35 Histoire à choix (docs/moteurs/recit.md) : une histoire en étapes,
/// une question à chaque étape, deux ou trois choix. Le bon choix fait
/// avancer l'histoire, un mauvais choix affiche pourquoi et laisse
/// choisir à nouveau. Sans note : Continuer dès que la dernière étape est
/// passée. Les étapes s'enchaînent dans la zone (contrat du moteur).
class GabaritRecit implements GabaritReponse {
  const GabaritRecit();

  @override
  ModeValidation get validation => ModeValidation.sansNote;

  @override
  ControleurRecit creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurRecit(
      config: config,
      etapes: [
        for (final e
            in (donnees['etapes'] as List).cast<Map<String, dynamic>>())
          EtapeRecit.depuisJson(e),
      ],
      fin: donnees['fin'] as String?,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneRecit(controleur as ControleurRecit);
}

/// L'étape courante, les choix faits (le premier de chaque étape compte
/// dans la réponse), le mauvais choix affiché.
class ControleurRecit extends ControleurReponse {
  ControleurRecit({required this.config, required this.etapes, this.fin});

  final ConfigExercice config;
  final List<EtapeRecit> etapes;

  /// Texte de fin de l'histoire, affiché après la dernière étape.
  final String? fin;

  int _etape = 0;
  bool _finie = false;
  String? _mauvais;
  final _premiersChoix = <String, String>{};
  int _erreurs = 0;

  /// Index de l'étape affichée (la dernière quand la réponse est révélée).
  int get etape =>
      affichage == AffichageReponse.revelee ? etapes.length - 1 : _etape;

  EtapeRecit get etapeCourante => etapes[etape];

  /// L'histoire est finie : Continuer.
  bool get finie => affichage == AffichageReponse.revelee || _finie;

  /// Choix faux de l'étape courante, affiché avec son explication.
  ChoixRecit? get mauvais => _mauvais == null
      ? null
      : etapeCourante.choix.firstWhere((c) => c.id == _mauvais);

  /// Nombre de mauvais choix sur toute l'histoire.
  int get erreurs => _erreurs;

  /// Un choix vient d'être fait (son), remis à `null` par la zone.
  bool? choixVientDEtreFait;

  void choisir(String id) {
    if (!modifiable || _finie) return;
    final courante = etapes[_etape];
    final choix = courante.choix.firstWhere((c) => c.id == id);
    _premiersChoix.putIfAbsent(courante.id, () => id);
    if (choix.juste) {
      _mauvais = null;
      choixVientDEtreFait = true;
      if (_etape + 1 < etapes.length) {
        _etape++;
      } else {
        _finie = true;
      }
    } else {
      _erreurs++;
      _mauvais = id;
      choixVientDEtreFait = false;
    }
    reponseModifiee();
  }

  /// Après l'explication d'un mauvais choix : revenir aux choix.
  void reprendre() {
    if (!modifiable || _mauvais == null) return;
    _mauvais = null;
    notifyListeners();
  }

  @override
  bool get complete => _finie;

  @override
  Object? get reponse => {
    'choix': [
      for (final e in etapes)
        if (_premiersChoix[e.id] case final c?) {'etape': e.id, 'choix': c},
    ],
    'erreurs': _erreurs,
  };

  @override
  bool corriger() => true;

  @override
  void vider() {
    _etape = 0;
    _finie = false;
    _mauvais = null;
    _premiersChoix.clear();
    _erreurs = 0;
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String etapeN, String compris, String finDe}) _libellesRecit(String langue) =>
    switch (langue) {
      'ar' => (
        etapeN: 'الْمَرْحَلَةُ',
        compris: 'فَهِمْتُ',
        finDe: 'النِّهَايَةُ',
      ),
      'en' => (etapeN: 'Step', compris: 'I understand', finDe: 'The end'),
      _ => (etapeN: 'Étape', compris: 'Compris', finDe: 'Fin'),
    };

/// La scène, le texte de l'étape, les choix (ou l'explication du mauvais
/// choix), le compteur d'étapes.
class _ZoneRecit extends StatelessWidget {
  const _ZoneRecit(this.controleur);

  final ControleurRecit controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesRecit(langue);
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    final styleTexte = ThemeYasmina.pourLangue(
      langue == 'ar'
          ? StylesYasmina.contentSentence
          : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    final styleCompteur = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.muted);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        if (controleur.choixVientDEtreFait case final juste?) {
          controleur.choixVientDEtreFait = null;
          services.vibration.legere();
          services.audio.jouerSon(
            juste ? SonInterface.depot : SonInterface.essaiFaux,
          );
        }
        final modifiable = controleur.modifiable;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final etape = controleur.etapeCourante;
        final mauvais = controleur.mauvais;
        final finie = controleur.finie;
        return Column(
          key: ValueKey(revelee ? 'recit_reponse' : 'recit'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Text(
              '${l.etapeN} ${controleur.etape + 1} / ${controleur.etapes.length}',
              key: const ValueKey('recit_compteur'),
              textAlign: TextAlign.center,
              style: styleCompteur,
            ),
            if (etape.scene case final scene?)
              Text(
                scene,
                key: const ValueKey('recit_scene'),
                textAlign: TextAlign.center,
                style: StylesYasmina.letterHero,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: EspacesYasmina.space2,
              children: [
                Expanded(
                  child: Text(
                    finie && controleur.fin != null
                        ? controleur.fin!
                        : etape.texte,
                    key: const ValueKey('recit_texte'),
                    style: styleTexte,
                  ),
                ),
                BoutonIcone(
                  key: const ValueKey('recit_ecouter'),
                  icone: Icons.volume_up_rounded,
                  libelle: libelles.ecouter,
                  rond: true,
                  onPressed: () => controleur.demanderAudio(
                    finie && controleur.fin != null
                        ? controleur.fin!
                        : etape.texte,
                    langue: langue,
                  ),
                ),
              ],
            ),
            if (finie)
              Text(
                l.finDe,
                key: const ValueKey('recit_fin'),
                textAlign: TextAlign.center,
                style: styleTexte.copyWith(color: c.oliveText),
              )
            else if (mauvais != null) ...[
              // L'explication du mauvais choix, puis « compris » pour
              // choisir à nouveau.
              TuileChoix(
                key: ValueKey('choix_${mauvais.id}'),
                etat: EtatTuile.faux,
                texte: mauvais.texte,
                barre: true,
              ),
              if (mauvais.pourquoi case final pourquoi?)
                Text(
                  pourquoi,
                  key: const ValueKey('recit_pourquoi'),
                  style: styleTexte.copyWith(color: c.coralText),
                ),
              TuileChoix(
                key: const ValueKey('recit_compris'),
                etat: EtatTuile.repos,
                texte: l.compris,
                onTap: modifiable ? controleur.reprendre : null,
              ),
            ] else
              for (final choix in etape.choix)
                TuileChoix(
                  key: ValueKey('choix_${choix.id}'),
                  etat: EtatTuile.repos,
                  texte: choix.texte,
                  onTap: modifiable ? () => controleur.choisir(choix.id) : null,
                ),
            if (revelee)
              Text(
                'juste',
                key: const ValueKey('recit_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(color: c.oliveText),
              ),
          ],
        );
      },
    );
  }
}
