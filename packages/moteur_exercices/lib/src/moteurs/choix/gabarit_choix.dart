import 'dart:math';

import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'grille_choix.dart';
import 'selection_choix.dart';

/// Support affiché au-dessus des propositions (T01, T45, T61 par son
/// texte) : texte sur une ou plusieurs lignes, emoji en grand, mot à
/// écouter. Chaque partie est facultative et combinable.
class SupportChoix {
  const SupportChoix({this.texte, this.emoji, this.ecoute});

  static SupportChoix? depuisJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return SupportChoix(
      texte: json['texte'] as String?,
      emoji: json['emoji'] as String?,
      ecoute: (json['ecoute'] as Map<String, dynamic>?)?['texte'] as String?,
    );
  }

  final String? texte;
  final String? emoji;

  /// Texte dit par la synthèse vocale, jamais affiché.
  final String? ecoute;
}

/// Comment la zone d'un type à grille se présente (docs/moteurs/choix.md
/// §3 et §8). Les règles de correction ne changent pas.
class PresentationChoix {
  const PresentationChoix({
    this.pleineLargeur = false,
    this.barrer = false,
    this.grand = false,
    this.texteLong = false,
    this.supportEnMot = false,
  });

  /// Phrases sur toute la largeur (T45, T61).
  final bool pleineLargeur;

  /// Tuile touchée barrée (T45).
  final bool barrer;

  /// Tuiles en content-word (T18, T19 lettre vocalisée).
  final bool grand;

  /// Support : texte long à lire (content-sentence en arabe, latin-body
  /// sinon, décision 38) au lieu d'un texte court (latin-prompt).
  final bool texteLong;

  /// Support : un mot seul en grand (qcm-contraire).
  final bool supportEnMot;
}

/// Réponse des types à grille du moteur Choix : un ensemble d'id de
/// propositions (T01, T03, T04, T05, T18, T19 lettre vocalisée, T24, T45,
/// T55, T61).
class ControleurChoix extends ControleurReponse {
  ControleurChoix({
    required this.config,
    required this.selection,
    this.support,
    this.ecoute,
    this.mot,
    this.suite = const [],
    this.presentation = const PresentationChoix(),
  });

  final ConfigExercice config;
  final SelectionChoix selection;
  final SupportChoix? support;

  /// T03, T55 : mot entendu (jamais affiché).
  final String? ecoute;

  /// T18 : le mot où la lettre prend la forme demandée.
  final String? mot;

  /// T24 : la suite, suivie d'une case « ? ».
  final List<Proposition> suite;

  final PresentationChoix presentation;

  @override
  bool get complete => selection.complete;

  @override
  Object? get reponse => {'choix': selection.ids};

  @override
  bool corriger() => selection.juste;

  @override
  void vider() {
    selection.vider();
    reponseModifiee();
  }

  @override
  String? get ecouteOuverture => ecoute ?? support?.ecoute;
}

/// Gabarit des types à grille du moteur Choix. [type] choisit la lecture
/// des données et la présentation.
class GabaritChoix implements GabaritReponse {
  const GabaritChoix(this.type);

  final String type;

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurChoix creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final gabarit = exercice['gabarit'] as String?;
    final propositions = [
      for (final c in (donnees['choix'] as List).cast<Map<String, dynamic>>())
        Proposition.depuisJson(c),
    ];
    final attendus = (reponse['choix'] as List).cast<String>();
    final multiple = const {'T05', 'T45', 'T61'}.contains(type);
    final selection = SelectionChoix(
      propositions: propositions,
      attendus: attendus,
      multiple: multiple,
      melanger: donnees['melanger'] as bool? ?? true,
      aleatoire: config.graine == null ? null : Random(config.graine),
    );
    return switch (type) {
      'T03' || 'T55' => ControleurChoix(
        config: config,
        selection: selection,
        ecoute: (donnees['ecoute'] as Map<String, dynamic>)['texte'] as String,
      ),
      'T18' => ControleurChoix(
        config: config,
        selection: selection,
        mot: donnees['mot'] as String?,
        presentation: const PresentationChoix(grand: true),
      ),
      'T19' => ControleurChoix(
        config: config,
        selection: selection,
        presentation: const PresentationChoix(grand: true),
      ),
      'T24' => ControleurChoix(
        config: config,
        selection: selection,
        suite: [
          for (final (i, e)
              in (donnees['suite'] as List)
                  .cast<Map<String, dynamic>>()
                  .indexed)
            Proposition.depuisJson(e, id: 's$i'),
        ],
      ),
      'T45' => ControleurChoix(
        config: config,
        selection: selection,
        support: SupportChoix.depuisJson(
          donnees['support'] as Map<String, dynamic>?,
        ),
        presentation: const PresentationChoix(
          pleineLargeur: true,
          barrer: true,
          texteLong: true,
        ),
      ),
      'T61' => ControleurChoix(
        config: config,
        selection: selection,
        support: SupportChoix(texte: donnees['texte'] as String),
        presentation: const PresentationChoix(
          pleineLargeur: true,
          texteLong: true,
        ),
      ),
      // T01, T04, T05 : support facultatif.
      _ => ControleurChoix(
        config: config,
        selection: selection,
        support: SupportChoix.depuisJson(
          donnees['support'] as Map<String, dynamic>?,
        ),
        presentation: PresentationChoix(
          supportEnMot: gabarit == 'qcm-contraire',
        ),
      ),
    };
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      ZoneChoix(controleur as ControleurChoix);
}

/// Zone de réponse des types à grille : support, puis grille.
class ZoneChoix extends StatelessWidget {
  const ZoneChoix(this.controleur, {super.key});

  final ControleurChoix controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final arabe = langue == 'ar';
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final presentation = controleur.presentation;
    final support = controleur.support;
    final ecoute = controleur.ecoute ?? support?.ecoute;

    TextStyle styleSupport() {
      if (presentation.supportEnMot) return StylesYasmina.contentWord;
      if (arabe) return StylesYasmina.contentSentence;
      // Texte court lu par l'enfant en latin-prompt, texte long à lire en
      // latin-body (décision 38, aucun nouveau jeton).
      return presentation.texteLong
          ? StylesYasmina.latinBody
          : StylesYasmina.latinPrompt;
    }

    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: EspacesYasmina.space6,
        children: [
          if (support?.emoji case final emoji?)
            Text(
              emoji,
              key: const ValueKey('choix_support_emoji'),
              textAlign: TextAlign.center,
              style: StylesYasmina.contentWord,
            ),
          if (support?.texte case final texte?)
            Text(
              texte,
              key: const ValueKey('choix_support_texte'),
              textAlign: presentation.texteLong
                  ? TextAlign.start
                  : TextAlign.center,
              style: ThemeYasmina.pourLangue(
                styleSupport(),
                langue,
              ).copyWith(color: c.ink),
            ),
          if (controleur.mot case final mot?)
            Text(
              mot,
              key: const ValueKey('choix_mot'),
              textAlign: TextAlign.center,
              style: StylesYasmina.contentWord.copyWith(color: c.ink),
            ),
          if (ecoute != null)
            Center(
              child: BoutonEcouter(
                key: const ValueKey('choix_ecouter'),
                libelle: libelles.ecouter,
                onPressed: () =>
                    controleur.demanderAudio(ecoute, langue: langue),
              ),
            ),
          if (controleur.suite.isNotEmpty)
            SuiteAffichee(
              suite: controleur.suite,
              choisi: controleur.selection.ids.isEmpty
                  ? null
                  : controleur.selection.propositions.firstWhere(
                      (p) => p.id == controleur.selection.ids.single,
                    ),
            ),
          GrilleChoix(
            selection: controleur.selection,
            controleur: controleur,
            libelles: libelles,
            mode: config.mode,
            pleineLargeur: presentation.pleineLargeur,
            barrer: presentation.barrer,
            grand: presentation.grand,
          ),
        ],
      ),
    );
  }
}

/// T24 : la suite sur une ligne, suivie d'une case « ? » qui montre
/// l'élément choisi. Suit le sens d'écriture de l'exercice.
class SuiteAffichee extends StatelessWidget {
  const SuiteAffichee({super.key, required this.suite, this.choisi});

  final List<Proposition> suite;

  /// Proposition choisie, affichée dans la case, `null` : « ? ».
  final Proposition? choisi;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    Widget element(Proposition p, {bool inconnue = false}) {
      final texte = p.emoji ?? p.texte ?? '';
      return DecoratedBox(
        decoration: BoxDecoration(
          color: inconnue ? c.blueSoft : c.tile,
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
          border: Border.all(
            color: inconnue ? c.blue : c.line,
            width: TraitsYasmina.borderThick,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: EspacesYasmina.space2,
            vertical: EspacesYasmina.space1,
          ),
          child: Text(
            texte,
            style: StylesYasmina.contentOption.copyWith(color: c.ink),
          ),
        ),
      );
    }

    return Wrap(
      key: const ValueKey('choix_suite'),
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: EspacesYasmina.space2,
      runSpacing: EspacesYasmina.space2,
      children: [
        for (final p in suite) element(p),
        KeyedSubtree(
          key: const ValueKey('choix_suite_inconnue'),
          child: choisi == null
              ? element(const Proposition(id: '?', texte: '?'), inconnue: true)
              : element(choisi!, inconnue: true),
        ),
      ],
    );
  }
}
