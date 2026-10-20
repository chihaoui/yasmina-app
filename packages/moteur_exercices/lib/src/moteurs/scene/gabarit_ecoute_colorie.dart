import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/couleurs_coloriage.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Un objet à colorier : une grande icône et son nom en sous-titre.
class ObjetColoriage {
  const ObjetColoriage({
    required this.id,
    required this.emoji,
    required this.libelle,
  });

  final String id;
  final String emoji;
  final String libelle;
}

/// T54 Écoute et colorie (docs/moteurs/scene-image.md §14) : l'enfant écoute
/// (« Colour the ball red »), touche une couleur de la palette, puis l'objet
/// à colorier : l'objet prend la couleur. Les objets sont de grandes icônes
/// avec leur nom en sous-titre. Juste si chaque objet a la couleur attendue,
/// ni plus ni moins.
class GabaritEcouteColorie implements GabaritReponse {
  const GabaritEcouteColorie();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurColoriage creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurColoriage(
      config: config,
      objets: [
        for (final o
            in (donnees['objets'] as List).cast<Map<String, dynamic>>())
          ObjetColoriage(
            id: o['id'] as String,
            emoji: o['emoji'] as String,
            libelle: o['libelle'] as String,
          ),
      ],
      couleurs: (donnees['couleurs'] as List).cast<String>(),
      ecoute: (donnees['ecoute'] as Map<String, dynamic>)['texte'] as String,
      attendu: {
        for (final c
            in (reponse['coloriages'] as List).cast<Map<String, dynamic>>())
          c['objet'] as String: c['couleur'] as String,
      },
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneEcouteColorie(controleur as ControleurColoriage);
}

/// La couleur choisie et la couleur de chaque objet.
class ControleurColoriage extends ControleurReponse {
  ControleurColoriage({
    required this.config,
    required this.objets,
    required this.couleurs,
    required this.ecoute,
    required this.attendu,
  });

  final ConfigExercice config;
  final List<ObjetColoriage> objets;
  final List<String> couleurs;

  /// La consigne entendue, jamais affichée.
  final String ecoute;

  /// Objet → couleur attendue.
  final Map<String, String> attendu;

  String? _couleurChoisie;
  final _coloriages = <String, String>{};

  String? get couleurChoisie => _couleurChoisie;

  /// Objet → couleur, tel que colorié (la bonne réponse quand elle est
  /// révélée).
  Map<String, String> get coloriages =>
      affichage == AffichageReponse.revelee ? attendu : _coloriages;

  String? couleurDe(String objet) => coloriages[objet];

  /// Toucher une couleur de la palette : elle devient la couleur en main
  /// (la même touchée à nouveau la lâche).
  void choisirCouleur(String id) {
    if (!modifiable) return;
    _couleurChoisie = _couleurChoisie == id ? null : id;
    notifyListeners();
  }

  /// Toucher un objet : il prend la couleur en main. Sans couleur en main,
  /// un objet colorié redevient blanc. `true` si l'objet a changé.
  bool toucherObjet(String id) {
    if (!modifiable) return false;
    final couleur = _couleurChoisie;
    if (couleur == null) {
      if (_coloriages.remove(id) == null) return false;
    } else {
      _coloriages[id] = couleur;
    }
    reponseModifiee();
    return true;
  }

  bool estJuste(String objet) => _coloriages[objet] == attendu[objet];

  /// Après le 1er essai faux : les coloriages faux s'effacent.
  @override
  void retirerFaux() {
    _coloriages.removeWhere((o, c) => attendu[o] != c);
    reponseModifiee();
  }

  @override
  bool get complete => _coloriages.isNotEmpty;

  @override
  Object? get reponse => {
    'coloriages': [
      for (final o in objets)
        if (_coloriages[o.id] case final c?) {'objet': o.id, 'couleur': c},
    ],
  };

  @override
  bool corriger() => mapEquals(_coloriages, attendu);

  @override
  void vider() {
    _couleurChoisie = null;
    _coloriages.clear();
    reponseModifiee();
  }

  @override
  String? get ecouteOuverture => ecoute;
}

/// Écouter, les objets en grand avec leur nom, puis la palette.
class _ZoneEcouteColorie extends StatelessWidget {
  const _ZoneEcouteColorie(this.controleur);

  final ControleurColoriage controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    final styleNom = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final fini = affichage == AffichageReponse.juste || revelee;
        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : fini
            ? 'juste'
            : faux
            ? 'faux'
            : null;

        Widget objetW(ObjetColoriage o) {
          final couleur = controleur.couleurDe(o.id);
          final teinte = couleur == null
              ? null
              : CouleursColoriage.de(couleur, inconnue: c.line);
          final bord = couleur == null
              ? c.line
              : fini
              ? c.olive
              : affichage == AffichageReponse.faux && !controleur.estJuste(o.id)
              ? c.coral
              : teinte!;
          return Semantics(
            button: true,
            enabled: modifiable,
            label: couleur == null
                ? o.libelle
                : '${o.libelle}, ${CouleursColoriage.nom(couleur, langue)}',
            excludeSemantics: true,
            child: Material(
              key: ValueKey('objet_${o.id}'),
              // design-ok : teinte translucide de la couleur de coloriage.
              color: teinte?.withValues(alpha: 0.35) ?? c.tile,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
                side: BorderSide(color: bord, width: TraitsYasmina.borderThick),
              ),
              child: InkWell(
                onTap: modifiable
                    ? () {
                        if (controleur.toucherObjet(o.id)) {
                          services.vibration.legere();
                          services.audio.jouerSon(SonInterface.depot);
                        }
                      }
                    : null,
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: EspacesYasmina.space4,
                    vertical: EspacesYasmina.space2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(o.emoji, style: StylesYasmina.letterHero),
                      Text(o.libelle, style: styleNom),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        Widget couleurW(String id) {
          final choisie = controleur.couleurChoisie == id;
          return Semantics(
            button: true,
            enabled: modifiable,
            selected: choisie,
            label: CouleursColoriage.nom(id, langue),
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('couleur_$id'),
              behavior: HitTestBehavior.opaque,
              onTap: modifiable ? () => controleur.choisirCouleur(id) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: EspacesYasmina.space1,
                children: [
                  Container(
                    width: EspacesYasmina.targetMin,
                    height: EspacesYasmina.targetMin,
                    decoration: BoxDecoration(
                      color: CouleursColoriage.de(id, inconnue: c.line),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: choisie ? c.blue : c.line,
                        width: choisie
                            ? TraitsYasmina.focusRing
                            : TraitsYasmina.borderThin,
                      ),
                    ),
                  ),
                  Text(CouleursColoriage.nom(id, langue), style: styleNom),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Center(
              child: BoutonEcouter(
                key: const ValueKey('colorie_ecouter'),
                libelle: libelles.ecouter,
                onPressed: () =>
                    controleur.demanderAudio(controleur.ecoute, langue: langue),
              ),
            ),
            Wrap(
              key: ValueKey(revelee ? 'scene_reponse' : 'objets'),
              alignment: WrapAlignment.center,
              spacing: EspacesYasmina.space3,
              runSpacing: EspacesYasmina.space3,
              children: [for (final o in controleur.objets) objetW(o)],
            ),
            Wrap(
              key: const ValueKey('palette'),
              alignment: WrapAlignment.center,
              spacing: EspacesYasmina.space4,
              runSpacing: EspacesYasmina.space2,
              children: [for (final id in controleur.couleurs) couleurW(id)],
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('scene_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: faux ? c.coralText : c.oliveText,
                ),
              ),
          ],
        );
      },
    );
  }
}
