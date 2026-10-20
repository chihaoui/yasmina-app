import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'comparaison.dart';

/// T17 Dictée au clavier (docs/moteurs/texte.md) : l'enfant écoute un mot
/// et l'écrit. Clavier arabe du moteur en arabe (complet, ou réduit aux
/// lettres du mot et à quelques lettres en trop : `clavier` et `lettres`),
/// clavier système en français et en anglais. Comparaison selon
/// `normalisation`.
class GabaritDictee implements GabaritReponse {
  const GabaritDictee();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurDictee creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final lettres = donnees['lettres'] as String?;
    return ControleurDictee(
      config: config,
      ecoute: (donnees['ecoute'] as Map<String, dynamic>)['texte'] as String,
      emoji: donnees['emoji'] as String?,
      harakat: donnees['harakat'] as bool? ?? false,
      minuscules: donnees['casse'] == 'minuscules',
      reduit: donnees['clavier'] == 'reduit' && lettres != null,
      lettresReduites: lettres == null
          ? const []
          : [for (final r in lettres.runes) String.fromCharCode(r)],
      attendu: reponse['texte'] as String,
      normalisation:
          (exercice['normalisation'] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneDictee(controleur as ControleurDictee);
}

/// La saisie de l'enfant.
class ControleurDictee extends ControleurReponse {
  ControleurDictee({
    required this.config,
    required this.ecoute,
    required this.attendu,
    required this.normalisation,
    this.emoji,
    this.harakat = false,
    this.minuscules = false,
    this.reduit = false,
    this.lettresReduites = const [],
  });

  final ConfigExercice config;
  final String ecoute;
  final String? emoji;

  /// Rangée de harakat sur le clavier arabe.
  final bool harakat;

  /// Clavier système en minuscules (latin).
  final bool minuscules;

  /// Clavier arabe réduit aux lettres de [lettresReduites] (1re et 2e).
  final bool reduit;

  /// Lettres du clavier réduit, telles que données par le contenu.
  final List<String> lettresReduites;
  final String attendu;
  final List<String> normalisation;

  String _saisie = '';

  /// Texte écrit (le mot attendu quand la réponse est révélée).
  String get saisie =>
      affichage == AffichageReponse.revelee ? attendu : _saisie;

  bool get clavierDuMoteur => config.langue == 'ar';

  /// Touches de lettres du clavier arabe, dans l'ordre alphabétique du
  /// clavier complet (le clavier réduit ne trahit pas l'ordre du mot).
  List<String> get touchesLettres {
    if (!reduit) return lettresClavierArabe;
    final voulues = lettresReduites.toSet();
    return [
      for (final l in lettresClavierArabe)
        if (voulues.contains(l)) l,
      // Une lettre hors du clavier complet (rare) reste proposée.
      for (final l in lettresReduites)
        if (!lettresClavierArabe.contains(l)) l,
    ];
  }

  void ecrire(String texte) {
    if (!modifiable || texte == _saisie) return;
    _saisie = texte;
    reponseModifiee();
  }

  /// Ajoute [caractere] à la fin (touche du clavier du moteur).
  void ajouter(String caractere) => ecrire(_saisie + caractere);

  /// Retire le dernier caractère (rune), haraka comprise.
  void effacer() {
    if (_saisie.isEmpty) return;
    final runes = _saisie.runes.toList()..removeLast();
    ecrire(String.fromCharCodes(runes));
  }

  @override
  bool get complete => _saisie.trim().isNotEmpty;

  @override
  Object? get reponse => {'texte': _saisie};

  @override
  bool corriger() => comparerTextes(_saisie, attendu, normalisation);

  @override
  void vider() {
    _saisie = '';
    reponseModifiee();
  }

  @override
  String? get ecouteOuverture => ecoute;
}

/// Lettres du clavier arabe complet du moteur, dans l'ordre alphabétique
/// (question 1 de texte-questions.md), hamza et ses formes, ta marbouta et
/// alif maqsura compris. Disposées en grille à largeur calculée (environ 7
/// touches par rangée).
const lettresClavierArabe = [
  'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', //
  'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', //
  'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي', 'ة', 'ى', //
  'ء', 'أ', 'إ', 'آ', 'ؤ', 'ئ',
];

/// Rangée de harakat (sur ◌), si `harakat`.
const rangeeHarakat = ['َ', 'ُ', 'ِ', 'ْ', 'ّ', 'ً', 'ٌ', 'ٍ'];

/// Cercle pointillé qui porte une haraka sur une touche (U+25CC).
const _porteur = '◌';

/// Touches par rangée au plus (docs/moteurs/texte.md §10).
const _touchesParRangeeMax = 7;

/// Répartit [n] touches en rangées équilibrées d'au plus [parRangeeMax]
/// touches : nombre de touches par rangée.
int touchesParRangee(int n, int parRangeeMax) {
  if (n <= 0) return 1;
  final rangees = (n / parRangeeMax).ceil();
  return (n / rangees).ceil();
}

/// Écouter, le champ, puis le clavier du moteur (arabe) ou un champ de
/// saisie système (latin).
class _ZoneDictee extends StatefulWidget {
  const _ZoneDictee(this.controleur);

  final ControleurDictee controleur;

  @override
  State<_ZoneDictee> createState() => _ZoneDicteeState();
}

class _ZoneDicteeState extends State<_ZoneDictee> {
  late final _champ = TextEditingController(text: widget.controleur.saisie);
  final _focus = FocusNode(debugLabel: 'dictee');

  ControleurDictee get controleur => widget.controleur;

  @override
  void initState() {
    super.initState();
    controleur.addListener(_synchroniser);
  }

  @override
  void dispose() {
    controleur.removeListener(_synchroniser);
    _champ.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Le champ système suit le contrôleur (vidage, réponse révélée).
  void _synchroniser() {
    if (_champ.text != controleur.saisie) {
      _champ.text = controleur.saisie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final styleMot = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    final styleTouche = ThemeYasmina.pourLangue(
      StylesYasmina.contentOption,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
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
        final revelee = affichage == AffichageReponse.revelee;

        /// Une touche de [largeur] sur [hauteur] (au moins `target-min`).
        Widget touche(
          String texte, {
          required double largeur,
          String? affiche,
          Widget? enfant,
          VoidCallback? action,
          Key? cle,
        }) => Semantics(
          button: true,
          enabled: action != null,
          label: texte,
          excludeSemantics: true,
          child: SizedBox(
            width: largeur,
            height: EspacesYasmina.targetMin,
            child: Material(
              key: cle ?? ValueKey('touche_$texte'),
              color: c.tile,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                side: BorderSide(
                  color: c.line,
                  width: TraitsYasmina.borderThin,
                ),
              ),
              child: InkWell(
                onTap: action,
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
                child: Center(
                  child: enfant ?? Text(affiche ?? texte, style: styleTouche),
                ),
              ),
            ),
          ),
        );

        /// Grille de touches à largeur calculée : rangées équilibrées
        /// d'environ 7 touches, chacune d'au moins `target-min`.
        Widget grille(
          List<String> touches, {
          required double largeurDisponible,
          String Function(String)? affiche,
          Key? cle,
        }) {
          const ecart = EspacesYasmina.space1;
          final parRangeeMax = math.max(
            1,
            math.min(
              _touchesParRangeeMax,
              ((largeurDisponible + ecart) / (EspacesYasmina.targetMin + ecart))
                  .floor(),
            ),
          );
          final parRangee = touchesParRangee(touches.length, parRangeeMax);
          final largeur =
              (largeurDisponible - (parRangee - 1) * ecart) / parRangee;
          return Column(
            key: cle,
            spacing: ecart,
            children: [
              for (var debut = 0; debut < touches.length; debut += parRangee)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: ecart,
                  children: [
                    for (final lettre in touches.sublist(
                      debut,
                      math.min(debut + parRangee, touches.length),
                    ))
                      touche(
                        lettre,
                        largeur: largeur,
                        affiche: affiche?.call(lettre),
                        action: modifiable
                            ? () => controleur.ajouter(lettre)
                            : null,
                      ),
                  ],
                ),
            ],
          );
        }

        final champ = DecoratedBox(
          decoration: BoxDecoration(
            color: c.tile,
            borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
            border: Border.all(color: bord, width: TraitsYasmina.borderThick),
          ),
          child: SizedBox(
            height: TaillesYasmina.choiceMinHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: EspacesYasmina.space4,
              ),
              child: controleur.clavierDuMoteur
                  ? Center(
                      child: Semantics(
                        textField: true,
                        value: controleur.saisie,
                        child: Text(
                          controleur.saisie.isEmpty ? ' ' : controleur.saisie,
                          key: const ValueKey('dictee_saisie'),
                          textAlign: TextAlign.center,
                          style: styleMot,
                        ),
                      ),
                    )
                  // Champ système : il prend toute la case (tout toucher
                  // dedans ouvre le clavier), le curseur est visible, et
                  // il reçoit le focus à l'ouverture pour que le clavier
                  // de l'appareil s'affiche sans attendre.
                  : TextField(
                      key: const ValueKey('dictee_champ'),
                      controller: _champ,
                      focusNode: _focus,
                      autofocus: modifiable,
                      enabled: modifiable,
                      autocorrect: false,
                      enableSuggestions: false,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: c.blue,
                      style: styleMot,
                      textCapitalization: controleur.minuscules
                          ? TextCapitalization.none
                          : TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        isCollapsed: true,
                      ),
                      onChanged: controleur.ecrire,
                    ),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            if (controleur.emoji case final emoji?)
              Text(
                emoji,
                key: const ValueKey('dictee_emoji'),
                textAlign: TextAlign.center,
                style: StylesYasmina.letterHero,
              ),
            Center(
              child: BoutonEcouter(
                key: const ValueKey('dictee_ecouter'),
                libelle: libelles.ecouter,
                onPressed: () =>
                    controleur.demanderAudio(controleur.ecoute, langue: langue),
              ),
            ),
            KeyedSubtree(
              key: ValueKey(revelee ? 'dictee_reponse' : 'dictee_zone'),
              child: champ,
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('dictee_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: affichage == AffichageReponse.faux
                      ? c.coralText
                      : c.oliveText,
                ),
              ),
            if (controleur.clavierDuMoteur)
              LayoutBuilder(
                builder: (context, contraintes) {
                  final largeur = contraintes.maxWidth;
                  return Column(
                    key: ValueKey(
                      controleur.reduit ? 'clavier_reduit' : 'clavier',
                    ),
                    spacing: EspacesYasmina.space2,
                    children: [
                      grille(
                        controleur.touchesLettres,
                        largeurDisponible: largeur,
                        cle: const ValueKey('clavier_lettres'),
                      ),
                      if (controleur.harakat)
                        grille(
                          rangeeHarakat,
                          largeurDisponible: largeur,
                          affiche: (h) => '$_porteur$h',
                          cle: const ValueKey('clavier_harakat'),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: EspacesYasmina.space1,
                        children: [
                          if (controleur.attendu.contains(' '))
                            touche(
                              ' ',
                              largeur: EspacesYasmina.targetMin * 2,
                              affiche: '␣',
                              action: modifiable
                                  ? () => controleur.ajouter(' ')
                                  : null,
                            ),
                          touche(
                            libelles.effacer,
                            cle: const ValueKey('touche_effacer'),
                            largeur: EspacesYasmina.targetMin * 2,
                            enfant: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: EspacesYasmina.space1,
                              children: [
                                Icon(
                                  Icons.backspace_outlined,
                                  color: c.ink,
                                  size: TaillesYasmina.iconMd,
                                ),
                                Flexible(
                                  child: Text(
                                    libelles.effacer,
                                    style: styleTouche,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            action: modifiable && controleur.saisie.isNotEmpty
                                ? controleur.effacer
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
