import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// T07 Toucher les mots (docs/moteurs/texte.md) : la phrase est affichée
/// mot par mot, l'enfant touche le ou les mots demandés. Juste si
/// l'ensemble des index touchés est exactement la réponse.
class GabaritToucherMots implements GabaritReponse {
  const GabaritToucherMots();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurMots creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurMots(
      config: config,
      mots: (donnees['texte'] as String)
          .split(' ')
          .where((m) => m.isNotEmpty)
          .toList(),
      attendus: (reponse['mots'] as List).cast<int>().toSet(),
      plusieurs: donnees['plusieurs'] as bool? ?? false,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneMots(controleur as ControleurMots);
}

/// Index des mots sélectionnés dans la phrase.
class ControleurMots extends ControleurReponse {
  ControleurMots({
    required this.config,
    required this.mots,
    required this.attendus,
    required this.plusieurs,
  });

  final ConfigExercice config;

  /// Les mots de la phrase, ponctuation collée.
  final List<String> mots;
  final Set<int> attendus;
  final bool plusieurs;

  final _selection = <int>{};

  /// Mots sélectionnés (la bonne réponse quand elle est révélée).
  Set<int> get selection =>
      affichage == AffichageReponse.revelee ? attendus : _selection;

  bool estSelectionne(int i) => selection.contains(i);

  /// Ajoute ou retire le mot [i] (en sélection unique, le remplace).
  void basculer(int i) {
    if (!modifiable) return;
    if (!plusieurs) {
      final deja = _selection.contains(i);
      _selection.clear();
      if (!deja) _selection.add(i);
    } else if (!_selection.remove(i)) {
      _selection.add(i);
    }
    reponseModifiee();
  }

  @override
  bool get complete => _selection.isNotEmpty;

  @override
  Object? get reponse => {'mots': (_selection.toList()..sort())};

  @override
  bool corriger() =>
      _selection.length == attendus.length && _selection.containsAll(attendus);

  @override
  void vider() {
    _selection.clear();
    reponseModifiee();
  }
}

/// État visuel d'un mot touchable.
enum EtatMot { repos, selectionne, juste, faux }

/// Un mot de la phrase, touchable (docs/moteurs/texte.md §11) : sans
/// bordure au repos, `blue-soft` sélectionné, `olive-soft` juste,
/// `coral-soft` faux.
class MotTouchable extends StatelessWidget {
  const MotTouchable({
    super.key,
    required this.texte,
    required this.etat,
    required this.style,
    this.motEtat,
    this.onTap,
  });

  final String texte;
  final EtatMot etat;
  final TextStyle style;

  /// Mot d'état sous le mot, en aperçu.
  final String? motEtat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, bord) = switch (etat) {
      EtatMot.repos => (Colors.transparent, Colors.transparent),
      EtatMot.selectionne => (c.blueSoft, c.blue),
      EtatMot.juste => (c.oliveSoft, c.olive),
      EtatMot.faux => (c.coralSoft, c.coral),
    };
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: etat == EtatMot.selectionne,
      label: texte,
      excludeSemantics: true,
      child: Material(
        color: fond,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
          side: BorderSide(color: bord, width: TraitsYasmina.borderThick),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: EspacesYasmina.targetMin,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: EspacesYasmina.space2,
                vertical: EspacesYasmina.space1,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(texte, style: style),
                  if (motEtat != null)
                    Text(
                      motEtat!,
                      style: StylesYasmina.latinLabel.copyWith(
                        color: etat == EtatMot.faux ? c.coralText : c.oliveText,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La phrase en mots touchables, à la ligne naturellement.
class _ZoneMots extends StatelessWidget {
  const _ZoneMots(this.controleur);

  final ControleurMots controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final style = ThemeYasmina.pourLangue(
      langue == 'ar'
          ? StylesYasmina.contentSentence
          : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final apercu = config.mode != ModeExercice.enfant;
        EtatMot etatDe(int i) {
          final choisi = controleur.estSelectionne(i);
          return switch (controleur.affichage) {
            AffichageReponse.saisie =>
              choisi ? EtatMot.selectionne : EtatMot.repos,
            AffichageReponse.juste => choisi ? EtatMot.juste : EtatMot.repos,
            AffichageReponse.faux =>
              !choisi
                  ? EtatMot.repos
                  : controleur.attendus.contains(i)
                  ? EtatMot.juste
                  : EtatMot.faux,
            AffichageReponse.revelee =>
              controleur.attendus.contains(i) ? EtatMot.juste : EtatMot.repos,
          };
        }

        return Wrap(
          key: const ValueKey('mots'),
          spacing: EspacesYasmina.space2,
          runSpacing: EspacesYasmina.space2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final (i, mot) in controleur.mots.indexed)
              MotTouchable(
                key: ValueKey('mot_$i'),
                texte: mot,
                etat: etatDe(i),
                style: style,
                motEtat: !apercu
                    ? null
                    : switch (etatDe(i)) {
                        EtatMot.juste => 'juste',
                        EtatMot.faux => 'faux',
                        _ => null,
                      },
                onTap: controleur.modifiable
                    ? () => controleur.basculer(i)
                    : null,
              ),
          ],
        );
      },
    );
  }
}
