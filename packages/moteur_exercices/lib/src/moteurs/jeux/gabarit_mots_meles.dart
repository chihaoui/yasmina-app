import 'dart:async';
import 'dart:math' as math;

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
/// toucher les lettres une à une, ou glisser le doigt le long du mot. Une
/// lettre qui ne prolonge plus le début d'un mot restant (dans un sens ou
/// l'autre) passe en rouge, puis la sélection se vide avec l'effet
/// d'erreur. Les erreurs ne font pas perdre. En arabe, lettres isolées et
/// lecture de droite à gauche (`sens`).
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

/// La grille, la sélection en cours (lettres touchées ou survolées dans
/// l'ordre), la lettre fausse, les mots trouvés.
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

  final _selection = <(int, int)>[];
  final _trouves = <String>{};
  (int, int)? _fausse;
  (int, int)? _derniereGlissee;
  Timer? _minuterie;

  /// Position du doigt au début d'une glissade (le geste n'est reconnu
  /// qu'après un petit déplacement : la première case est celle du départ).
  Offset? departGlissade;

  /// Un mot vient d'être trouvé (son `depot`), remis à `false` par la zone.
  bool motVientDEtreTrouve = false;

  /// Une lettre fausse vient d'être touchée (son `essaiFaux`, secousse),
  /// remis à `false` par la zone.
  bool erreurVientDArriver = false;

  /// Nombre d'erreurs depuis le début (déclenche la secousse).
  int erreurs = 0;

  /// Lettres sélectionnées, dans l'ordre.
  List<(int, int)> get selection => List.unmodifiable(_selection);

  Set<String> get trouves => affichage == AffichageReponse.revelee
      ? {for (final m in mots) m.id}
      : Set.unmodifiable(_trouves);

  bool estTrouve(String id) => trouves.contains(id);

  bool caseTrouvee(int l, int c) =>
      mots.any((m) => trouves.contains(m.id) && m.cases.contains((l, c)));

  bool caseSelectionnee(int l, int c) => _selection.contains((l, c));

  bool caseFausse(int l, int c) => _fausse == (l, c);

  /// Le début d'un mot restant, lu dans un sens ou dans l'autre, commence
  /// par [candidate].
  Iterable<MotCache> _prolonges(List<(int, int)> candidate) =>
      mots.where((m) => !_trouves.contains(m.id)).where((m) {
        if (candidate.length > m.cases.length) return false;
        bool prefixe(List<(int, int)> cases) {
          for (var k = 0; k < candidate.length; k++) {
            if (cases[k] != candidate[k]) return false;
          }
          return true;
        }

        return prefixe(m.cases) || prefixe(m.cases.reversed.toList());
      });

  /// Toucher la case (l, c) : la lettre s'ajoute à la sélection si elle
  /// prolonge le début d'un mot restant, sinon elle passe en faux et la
  /// sélection se vide après un instant. Un mot complet est trouvé.
  void toucher(int l, int c) {
    if (!modifiable || _fausse != null) return;
    final case_ = (l, c);
    if (_selection.contains(case_)) return;
    final candidate = [..._selection, case_];
    final possibles = _prolonges(candidate).toList();
    if (possibles.isEmpty) {
      _fausse = case_;
      erreurs++;
      erreurVientDArriver = true;
      notifyListeners();
      _minuterie = Timer(MouvementsYasmina.dureeFaux, effacerSelection);
      return;
    }
    _selection.add(case_);
    final complet = possibles
        .where((m) => m.cases.length == candidate.length)
        .firstOrNull;
    if (complet != null) {
      _trouves.add(complet.id);
      _selection.clear();
      motVientDEtreTrouve = true;
      reponseModifiee();
      if (_trouves.length == mots.length) terminer(juste: true);
      return;
    }
    notifyListeners();
  }

  /// Le doigt glisse sur la case (l, c) : comme un toucher, une seule fois
  /// par case survolée.
  void glisserSur(int l, int c) {
    if ((l, c) == _derniereGlissee) return;
    _derniereGlissee = (l, c);
    toucher(l, c);
  }

  /// Le doigt se lève : la prochaine glissade repart de zéro.
  void finDeGlissade() {
    _derniereGlissee = null;
    departGlissade = null;
  }

  /// Vide la sélection et la lettre fausse (fin de l'effet d'erreur).
  void effacerSelection() {
    _minuterie = null;
    if (_fausse == null && _selection.isEmpty) return;
    _fausse = null;
    _selection.clear();
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
    _selection.clear();
    _fausse = null;
    _derniereGlissee = null;
    _trouves.clear();
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

/// La grille de lettres (de gauche à droite par index de colonne), touchée
/// ou parcourue au doigt, puis la liste des mots, barrés quand ils sont
/// trouvés.
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
        if (controleur.erreurVientDArriver) {
          controleur.erreurVientDArriver = false;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.essaiFaux);
        }
        final modifiable = controleur.modifiable;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final apercu = config.mode != ModeExercice.enfant;
        final colonnes = controleur.grille.first.length;
        final lignes = controleur.grille.length;
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
                  const pas = EspacesYasmina.space1;
                  // Case sous le doigt, `null` dans un écart ou hors de la
                  // grille.
                  (int, int)? caseA(Offset p) {
                    final k = (p.dx / (cote + pas)).floor();
                    final l = (p.dy / (cote + pas)).floor();
                    if (k < 0 || k >= colonnes || l < 0 || l >= lignes) {
                      return null;
                    }
                    if (p.dx - k * (cote + pas) > cote ||
                        p.dy - l * (cote + pas) > cote) {
                      return null;
                    }
                    return (l, k);
                  }

                  void glisser(Offset p) {
                    if (!modifiable) return;
                    final case_ = caseA(p);
                    if (case_ != null) {
                      controleur.glisserSur(case_.$1, case_.$2);
                    }
                  }

                  return Secousse(
                    declencheur: controleur.erreurs,
                    child: GestureDetector(
                      key: const ValueKey('grille_geste'),
                      behavior: HitTestBehavior.translucent,
                      onPanDown: (d) =>
                          controleur.departGlissade = d.localPosition,
                      onPanStart: (d) {
                        // La case du départ d'abord, puis celle du doigt.
                        if (controleur.departGlissade case final depart?) {
                          glisser(depart);
                        }
                        glisser(d.localPosition);
                      },
                      onPanUpdate: (d) => glisser(d.localPosition),
                      onPanEnd: (_) => controleur.finDeGlissade(),
                      onPanCancel: controleur.finDeGlissade,
                      child: Column(
                        key: ValueKey(revelee ? 'jeux_reponse' : 'grille'),
                        spacing: pas,
                        children: [
                          for (final (l, ligne) in controleur.grille.indexed)
                            Row(
                              spacing: pas,
                              children: [
                                for (final (k, lettre) in ligne.indexed)
                                  SizedBox(
                                    width: cote,
                                    height: cote,
                                    child: CaseGrille(
                                      key: ValueKey('case_${l}_$k'),
                                      lettre: lettre,
                                      style: styleLettre,
                                      etat: controleur.caseFausse(l, k)
                                          ? EtatCase.fausse
                                          : controleur.caseSelectionnee(l, k)
                                          ? EtatCase.selectionnee
                                          : controleur.caseTrouvee(l, k)
                                          ? EtatCase.trouvee
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
                      ),
                    ),
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

/// Secousse douce (effet d'erreur, jamais la couleur seule) : l'enfant est
/// déplacé de quelques pixels de gauche à droite à chaque changement de
/// [declencheur]. Aucun mouvement si l'appareil demande moins
/// d'animations.
class Secousse extends StatefulWidget {
  const Secousse({super.key, required this.declencheur, required this.child});

  /// Change à chaque erreur : une nouvelle secousse part.
  final int declencheur;
  final Widget child;

  @override
  State<Secousse> createState() => _SecousseState();
}

class _SecousseState extends State<Secousse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: MouvementsYasmina.dureeSecousse,
  );

  @override
  void didUpdateWidget(Secousse ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.declencheur != widget.declencheur &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controleur.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controleur,
      builder: (context, enfant) {
        final t = _controleur.value;
        final dx = _controleur.isAnimating
            ? math.sin(t * math.pi * MouvementsYasmina.secousses) *
                  MouvementsYasmina.amplitudeSecousse *
                  (1 - t)
            : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: enfant);
      },
      child: widget.child,
    );
  }
}

/// Une case de la grille : `tile`, bordure `line`, `radius-sm`.
class CaseGrille extends StatelessWidget {
  const CaseGrille({
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
