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
/// et l'écrit. Clavier arabe du moteur en arabe, clavier système en
/// français et en anglais. Comparaison selon `normalisation`.
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
    return ControleurDictee(
      config: config,
      ecoute: (donnees['ecoute'] as Map<String, dynamic>)['texte'] as String,
      emoji: donnees['emoji'] as String?,
      harakat: donnees['harakat'] as bool? ?? false,
      minuscules: donnees['casse'] == 'minuscules',
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
  });

  final ConfigExercice config;
  final String ecoute;
  final String? emoji;

  /// Rangée de harakat sur le clavier arabe.
  final bool harakat;

  /// Clavier système en minuscules (latin).
  final bool minuscules;
  final String attendu;
  final List<String> normalisation;

  String _saisie = '';

  /// Texte écrit (le mot attendu quand la réponse est révélée).
  String get saisie =>
      affichage == AffichageReponse.revelee ? attendu : _saisie;

  bool get clavierDuMoteur => config.langue == 'ar';

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

/// Lettres du clavier arabe du moteur, trois rangées dans l'ordre
/// alphabétique (question 1 de texte-questions.md), hamza et ses formes,
/// ta marbouta et alif maqsura compris.
const rangeesClavierArabe = [
  ['ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر'],
  ['ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف'],
  ['ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي', 'ة', 'ى'],
  ['ء', 'أ', 'إ', 'آ', 'ؤ', 'ئ'],
];

/// Rangée de harakat (sur ◌), si `harakat`.
const rangeeHarakat = ['َ', 'ُ', 'ِ', 'ْ', 'ّ', 'ً', 'ٌ', 'ٍ'];

/// Cercle pointillé qui porte une haraka sur une touche (U+25CC).
const _porteur = '◌';

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

        Widget touche(String texte, {String? affiche, VoidCallback? action}) =>
            Semantics(
              button: true,
              enabled: action != null,
              label: texte,
              excludeSemantics: true,
              child: Material(
                key: ValueKey('touche_$texte'),
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: EspacesYasmina.targetMin,
                      minHeight: EspacesYasmina.targetMin,
                    ),
                    child: Center(
                      child: Text(affiche ?? texte, style: styleTouche),
                    ),
                  ),
                ),
              ),
            );

        final champ = DecoratedBox(
          decoration: BoxDecoration(
            color: c.tile,
            borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
            border: Border.all(color: bord, width: TraitsYasmina.borderThick),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TaillesYasmina.choiceMinHeight,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: EspacesYasmina.space4,
                vertical: EspacesYasmina.space2,
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
                  : TextField(
                      key: const ValueKey('dictee_champ'),
                      controller: _champ,
                      enabled: modifiable,
                      autocorrect: false,
                      enableSuggestions: false,
                      textAlign: TextAlign.center,
                      style: styleMot,
                      textCapitalization: controleur.minuscules
                          ? TextCapitalization.none
                          : TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: false,
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
            if (affichage == AffichageReponse.revelee &&
                !controleur.clavierDuMoteur)
              const SizedBox.shrink(),
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
              Column(
                key: const ValueKey('clavier'),
                spacing: EspacesYasmina.space1,
                children: [
                  for (final rangee in rangeesClavierArabe)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: EspacesYasmina.space1,
                      runSpacing: EspacesYasmina.space1,
                      children: [
                        for (final lettre in rangee)
                          touche(
                            lettre,
                            action: modifiable
                                ? () => controleur.ajouter(lettre)
                                : null,
                          ),
                      ],
                    ),
                  if (controleur.harakat)
                    Wrap(
                      key: const ValueKey('clavier_harakat'),
                      alignment: WrapAlignment.center,
                      spacing: EspacesYasmina.space1,
                      runSpacing: EspacesYasmina.space1,
                      children: [
                        for (final h in rangeeHarakat)
                          touche(
                            h,
                            affiche: '$_porteur$h',
                            action: modifiable
                                ? () => controleur.ajouter(h)
                                : null,
                          ),
                      ],
                    ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: EspacesYasmina.space1,
                    children: [
                      if (controleur.attendu.contains(' '))
                        touche(
                          ' ',
                          affiche: '␣',
                          action: modifiable
                              ? () => controleur.ajouter(' ')
                              : null,
                        ),
                      Semantics(
                        button: true,
                        enabled: modifiable && controleur.saisie.isNotEmpty,
                        label: libelles.effacer,
                        excludeSemantics: true,
                        child: Material(
                          key: const ValueKey('touche_effacer'),
                          color: c.tile,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              RayonsYasmina.radiusMd,
                            ),
                            side: BorderSide(
                              color: c.line,
                              width: TraitsYasmina.borderThin,
                            ),
                          ),
                          child: InkWell(
                            onTap: modifiable && controleur.saisie.isNotEmpty
                                ? controleur.effacer
                                : null,
                            borderRadius: BorderRadius.circular(
                              RayonsYasmina.radiusMd,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: EspacesYasmina.targetMin,
                                minHeight: EspacesYasmina.targetMin,
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: EspacesYasmina.space3,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: EspacesYasmina.space1,
                                  children: [
                                    Icon(
                                      Icons.backspace_outlined,
                                      color: c.ink,
                                      size: TaillesYasmina.iconMd,
                                    ),
                                    Text(libelles.effacer, style: styleTouche),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
