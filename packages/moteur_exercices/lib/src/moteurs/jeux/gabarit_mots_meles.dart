import 'dart:async';

import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/mouvements_yasmina.dart';
import '../../theme/theme_yasmina.dart';

/// Un mot caché : ses cases, de la première à la dernière lettre.
class MotCache {
  const MotCache({required this.id, required this.texte, required this.cases});

  final String id;

  /// Texte affiché dans la liste (avec ses harakat).
  final String texte;

  /// Cases (ligne, colonne) dans l'ordre de lecture.
  final List<(int, int)> cases;
}

/// T38 Mots mêlés, automatique et noté (docs/moteurs/revision-jeux.md) :
/// toucher la première puis la dernière lettre d'un mot. En arabe, lettres
/// isolées et lecture de droite à gauche (`sens`).
class GabaritMotsMeles implements GabaritReponse {
  const GabaritMotsMeles();

  @override
  ModeValidation get validation => ModeValidation.automatique;

  @override
  ControleurMotsMeles creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final grille = [
      for (final ligne in (donnees['grille'] as List).cast<String>())
        [for (final r in ligne.runes) String.fromCharCode(r)],
    ];
    final droiteGauche = donnees['sens'] == null
        ? config.langue == 'ar'
        : donnees['sens'] == 'droite-gauche';
    return ControleurMotsMeles(
      config: config,
      grille: grille,
      droiteGauche: droiteGauche,
      mots: [
        for (final m in (donnees['mots'] as List).cast<Map<String, dynamic>>())
          MotCache(
            id: m['id'] as String,
            texte: m['texte'] as String,
            cases: [
              for (var k = 0; k < _lettres(m['texte'] as String); k++)
                m['direction'] == 'ligne'
                    ? (
                        m['ligne'] as int,
                        (m['colonne'] as int) + (droiteGauche ? -k : k),
                      )
                    : ((m['ligne'] as int) + k, m['colonne'] as int),
            ],
          ),
      ],
    );
  }

  /// Nombre de lettres d'un mot, harakat exclues.
  static int _lettres(String texte) => texte.runes
      .where((r) => !((r >= 0x064B && r <= 0x0652) || r == 0x0670))
      .length;

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneMotsMeles(controleur as ControleurMotsMeles);
}

/// La grille, la première lettre touchée, les mots trouvés.
class ControleurMotsMeles extends ControleurReponse {
  ControleurMotsMeles({
    required this.config,
    required this.grille,
    required this.mots,
    required this.droiteGauche,
  });

  final ConfigExercice config;
  final List<List<String>> grille;
  final List<MotCache> mots;
  final bool droiteGauche;

  (int, int)? _premiere;
  final _trouves = <String>{};
  final _fausses = <(int, int)>{};
  Timer? _minuterie;

  /// Un mot vient d'être trouvé (son `depot`), remis à `false` par la zone.
  bool motVientDEtreTrouve = false;

  (int, int)? get premiere => _premiere;

  Set<String> get trouves => affichage == AffichageReponse.revelee
      ? {for (final m in mots) m.id}
      : Set.unmodifiable(_trouves);

  bool estTrouve(String id) => trouves.contains(id);

  bool caseTrouvee(int l, int c) =>
      mots.any((m) => trouves.contains(m.id) && m.cases.contains((l, c)));

  bool caseFausse(int l, int c) => _fausses.contains((l, c));

  /// Toucher la case (l, c) : première lettre, puis dernière lettre d'un
  /// mot (dans un sens ou dans l'autre).
  void toucher(int l, int c) {
    if (!modifiable || _fausses.isNotEmpty) return;
    final premiere = _premiere;
    if (premiere == null) {
      _premiere = (l, c);
      notifyListeners();
      return;
    }
    _premiere = null;
    final bouts = {premiere, (l, c)};
    final mot = mots
        .where((m) => !_trouves.contains(m.id))
        .where((m) => {m.cases.first, m.cases.last}.containsAll(bouts))
        .where((m) => bouts.length == 2 || m.cases.length == 1)
        .firstOrNull;
    if (mot != null) {
      _trouves.add(mot.id);
      motVientDEtreTrouve = true;
      reponseModifiee();
      if (_trouves.length == mots.length) terminer(juste: true);
      return;
    }
    _fausses.addAll(bouts);
    notifyListeners();
    _minuterie = Timer(MouvementsYasmina.dureeFaux, effacerFausses);
  }

  void effacerFausses() {
    _minuterie = null;
    if (_fausses.isEmpty) return;
    _fausses.clear();
    notifyListeners();
  }

  @override
  bool get complete => _trouves.length == mots.length;

  @override
  Object? get reponse => {'mots': (_trouves.toList()..sort())};

  @override
  bool corriger() => true;

  @override
  void vider() {
    _minuterie?.cancel();
    _minuterie = null;
    _premiere = null;
    _trouves.clear();
    _fausses.clear();
    reponseModifiee();
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }
}

/// État visuel d'une case de la grille.
enum EtatCase { repos, selectionnee, trouvee, fausse }

/// La grille de lettres (de gauche à droite par index de colonne), puis la
/// liste des mots, barrés quand ils sont trouvés.
class _ZoneMotsMeles extends StatelessWidget {
  const _ZoneMotsMeles(this.controleur);

  final ControleurMotsMeles controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final services = ServicesExercice.of(context);
    final styleLettre = ThemeYasmina.pourLangue(
      StylesYasmina.contentOption,
      langue,
    ).copyWith(color: c.ink);
    final styleMot = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.contentOption : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        if (controleur.motVientDEtreTrouve) {
          controleur.motVientDEtreTrouve = false;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
        }
        final modifiable = controleur.modifiable;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final apercu = config.mode != ModeExercice.enfant;
        final colonnes = controleur.grille.first.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, contraintes) {
                  final cote =
                      (contraintes.maxWidth -
                          (colonnes - 1) * EspacesYasmina.space1) /
                      colonnes;
                  return Column(
                    key: ValueKey(revelee ? 'jeux_reponse' : 'grille'),
                    spacing: EspacesYasmina.space1,
                    children: [
                      for (final (l, ligne) in controleur.grille.indexed)
                        Row(
                          spacing: EspacesYasmina.space1,
                          children: [
                            for (final (k, lettre) in ligne.indexed)
                              SizedBox(
                                width: cote,
                                height: cote,
                                child: _CaseGrille(
                                  key: ValueKey('case_${l}_$k'),
                                  lettre: lettre,
                                  style: styleLettre,
                                  etat: controleur.caseTrouvee(l, k)
                                      ? EtatCase.trouvee
                                      : controleur.caseFausse(l, k)
                                      ? EtatCase.fausse
                                      : controleur.premiere == (l, k)
                                      ? EtatCase.selectionnee
                                      : EtatCase.repos,
                                  libelle: '$lettre ${l + 1} ${k + 1}',
                                  onTap: modifiable
                                      ? () => controleur.toucher(l, k)
                                      : null,
                                ),
                              ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
            Wrap(
              key: const ValueKey('mots'),
              alignment: WrapAlignment.center,
              spacing: EspacesYasmina.space4,
              runSpacing: EspacesYasmina.space2,
              children: [
                for (final m in controleur.mots)
                  Text(
                    m.texte,
                    key: ValueKey('mot_${m.id}'),
                    style: controleur.estTrouve(m.id)
                        ? styleMot.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: c.muted,
                          )
                        : styleMot,
                  ),
              ],
            ),
            if (apercu && revelee)
              Text(
                'juste',
                key: const ValueKey('jeux_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(color: c.oliveText),
              ),
          ],
        );
      },
    );
  }
}

/// Une case de la grille : `tile`, bordure `line`, `radius-sm`.
class _CaseGrille extends StatelessWidget {
  const _CaseGrille({
    super.key,
    required this.lettre,
    required this.style,
    required this.etat,
    required this.libelle,
    this.onTap,
  });

  final String lettre;
  final TextStyle style;
  final EtatCase etat;
  final String libelle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, bord) = switch (etat) {
      EtatCase.repos => (c.tile, c.line),
      EtatCase.selectionnee => (c.blueSoft, c.blue),
      EtatCase.trouvee => (c.oliveSoft, c.olive),
      EtatCase.fausse => (c.coralSoft, c.coral),
    };
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: libelle,
      excludeSemantics: true,
      child: Material(
        color: fond,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
          side: BorderSide(color: bord, width: TraitsYasmina.borderThin),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
          child: Center(child: Text(lettre, style: style)),
        ),
      ),
    );
  }
}
