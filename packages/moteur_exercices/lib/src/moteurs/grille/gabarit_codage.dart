import 'package:flutter/material.dart';

import '../../composants/bouton_yasmina.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Les quatre déplacements, tels qu'écrits dans le JSON.
enum Pas {
  haut('haut', '↑', 0, -1),
  bas('bas', '↓', 0, 1),
  gauche('gauche', '←', -1, 0),
  droite('droite', '→', 1, 0);

  const Pas(this.nom, this.fleche, this.dx, this.dy);

  final String nom;
  final String fleche;
  final int dx;
  final int dy;

  static Pas depuisNom(String nom) => values.firstWhere((p) => p.nom == nom);
}

/// T60 Codage de déplacement (docs/moteurs/grille-graphiques.md) : une
/// grille, un départ (la fleur), un but (le puits), des obstacles. L'enfant
/// compose un programme de flèches (touches), retire la dernière, puis le
/// joue : la fleur avance pas à pas. Juste si elle arrive au but sans sortir
/// ni heurter un obstacle (tout chemin qui arrive est accepté).
class GabaritCodage implements GabaritReponse {
  const GabaritCodage();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurCodage creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    PositionGrille lire(Map<String, dynamic> m) =>
        (m['ligne'] as int, m['colonne'] as int);
    return ControleurCodage(
      config: config,
      lignes: donnees['lignes'] as int,
      colonnes: donnees['colonnes'] as int,
      depart: lire(donnees['depart'] as Map<String, dynamic>),
      but: lire(donnees['but'] as Map<String, dynamic>),
      obstacles: {
        for (final o
            in (donnees['obstacles'] as List? ?? const [])
                .cast<Map<String, dynamic>>())
          lire(o),
      },
      emojiDepart: donnees['emoji_depart'] as String? ?? '🌸',
      emojiBut: donnees['emoji_but'] as String? ?? '🪣',
      maxPas: donnees['max_pas'] as int? ?? 12,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneCodage(controleur as ControleurCodage);
}

typedef PositionGrille = (int, int);

/// Le programme et sa lecture.
class ControleurCodage extends ControleurReponse {
  ControleurCodage({
    required this.config,
    required this.lignes,
    required this.colonnes,
    required this.depart,
    required this.but,
    required this.obstacles,
    required this.emojiDepart,
    required this.emojiBut,
    required this.maxPas,
  }) : _position = depart;

  final ConfigExercice config;
  final int lignes;
  final int colonnes;
  final PositionGrille depart;
  final PositionGrille but;
  final Set<PositionGrille> obstacles;
  final String emojiDepart;
  final String emojiBut;
  final int maxPas;

  final _programme = <Pas>[];
  PositionGrille _position;
  int _joues = 0;
  bool _joue = false;
  bool _bloque = false;

  /// Le programme écrit (un chemin juste quand la réponse est révélée).
  List<Pas> get programme =>
      affichage == AffichageReponse.revelee ? cheminRevele : _programme;

  /// Position courante de la fleur (le but quand la réponse est révélée).
  PositionGrille get position =>
      affichage == AffichageReponse.revelee ? but : _position;

  /// Nombre de pas déjà joués.
  int get joues =>
      affichage == AffichageReponse.revelee ? programme.length : _joues;

  /// Le programme a été joué jusqu'au bout.
  bool get joue => _joue;

  /// La fleur a heurté un bord ou un obstacle pendant la lecture.
  bool get bloque => _bloque;

  /// Un chemin juste pour la réponse révélée : vertical puis horizontal, en
  /// contournant au besoin par l'autre ordre.
  List<Pas> get cheminRevele {
    List<Pas>? essai(bool verticalDAbord) {
      final chemin = <Pas>[];
      var (l, k) = depart;
      void vertical() {
        while (l != but.$1) {
          chemin.add(l < but.$1 ? Pas.bas : Pas.haut);
          l += l < but.$1 ? 1 : -1;
          if (obstacles.contains((l, k))) throw StateError('obstacle');
        }
      }

      void horizontal() {
        while (k != but.$2) {
          chemin.add(k < but.$2 ? Pas.droite : Pas.gauche);
          k += k < but.$2 ? 1 : -1;
          if (obstacles.contains((l, k))) throw StateError('obstacle');
        }
      }

      try {
        if (verticalDAbord) {
          vertical();
          horizontal();
        } else {
          horizontal();
          vertical();
        }
        return chemin;
      } on StateError {
        return null;
      }
    }

    return essai(true) ?? essai(false) ?? const [];
  }

  void ajouter(Pas pas) {
    if (!modifiable || _joue || _programme.length >= maxPas) return;
    _programme.add(pas);
    reponseModifiee();
  }

  void retirerDernier() {
    if (!modifiable || _joue || _programme.isEmpty) return;
    _programme.removeLast();
    reponseModifiee();
  }

  /// Joue le pas suivant du programme. `false` quand il n'y en a plus ou
  /// que la fleur est bloquée.
  bool jouerPas() {
    if (!modifiable || _joues >= _programme.length || _bloque) {
      _joue = true;
      notifyListeners();
      return false;
    }
    final pas = _programme[_joues];
    final suivante = (_position.$1 + pas.dy, _position.$2 + pas.dx);
    _joues++;
    if (suivante.$1 < 0 ||
        suivante.$1 >= lignes ||
        suivante.$2 < 0 ||
        suivante.$2 >= colonnes ||
        obstacles.contains(suivante)) {
      _bloque = true;
      _joue = true;
    } else {
      _position = suivante;
      if (_joues == _programme.length) _joue = true;
    }
    notifyListeners();
    return !_joue;
  }

  /// Remet la fleur au départ pour rejouer ou corriger le programme.
  void revenir() {
    if (!modifiable) return;
    _position = depart;
    _joues = 0;
    _joue = false;
    _bloque = false;
    notifyListeners();
  }

  /// Vérifier devient actif une fois le programme joué jusqu'au bout.
  @override
  bool get complete => _joue && _programme.isNotEmpty;

  @override
  Object? get reponse => {
    'chemin': [for (final p in _programme) p.nom],
  };

  @override
  bool corriger() => _joue && !_bloque && _position == but;

  @override
  void vider() {
    _programme.clear();
    _position = depart;
    _joues = 0;
    _joue = false;
    _bloque = false;
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String jouer, String revenir, String Function(Pas p) pas}) _libellesCodage(
  String langue,
) => switch (langue) {
  'ar' => (
    jouer: 'شَغِّلْ',
    revenir: 'اِرْجِعْ',
    pas: (p) => switch (p) {
      Pas.haut => 'أَعْلَى',
      Pas.bas => 'أَسْفَلَ',
      Pas.gauche => 'يَسَارًا',
      Pas.droite => 'يَمِينًا',
    },
  ),
  'en' => (jouer: 'Run', revenir: 'Back', pas: (p) => p.nom),
  _ => (jouer: 'Jouer', revenir: 'Revenir', pas: (p) => p.nom),
};

/// La grille, le programme, les quatre flèches, Jouer et Revenir.
class _ZoneCodage extends StatefulWidget {
  const _ZoneCodage(this.controleur);

  final ControleurCodage controleur;

  @override
  State<_ZoneCodage> createState() => _ZoneCodageState();
}

class _ZoneCodageState extends State<_ZoneCodage> {
  ControleurCodage get controleur => widget.controleur;

  /// Joue le programme pas à pas, un pas par demi-seconde.
  Future<void> _jouer(ServicesExercice services) async {
    final disable = MediaQuery.disableAnimationsOf(context);
    while (mounted && controleur.jouerPas()) {
      services.audio.jouerSon(SonInterface.depot);
      if (!disable) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    if (mounted) services.vibration.legere();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesCodage(langue);
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    final styleFleche = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final juste = affichage == AffichageReponse.juste || revelee;
        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : juste
            ? 'juste'
            : faux
            ? 'faux'
            : null;
        final programme = controleur.programme;
        final peutEcrire = modifiable && !controleur.joue;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // La grille ne se retourne pas avec la langue : les flèches
            // gardent leur sens.
            Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, contraintes) {
                  final cote = contraintes.maxWidth / controleur.colonnes;
                  return Column(
                    key: ValueKey(revelee ? 'grille_reponse' : 'grille'),
                    children: [
                      for (var li = 0; li < controleur.lignes; li++)
                        Row(
                          children: [
                            for (var k = 0; k < controleur.colonnes; k++)
                              Container(
                                key: ValueKey('case_${li}_$k'),
                                width: cote,
                                height: cote,
                                decoration: BoxDecoration(
                                  color: controleur.obstacles.contains((li, k))
                                      ? c.muted
                                      : c.tile,
                                  border: Border.all(
                                    color: c.line,
                                    width: TraitsYasmina.borderThin,
                                  ),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    child: Text(
                                      controleur.position == (li, k)
                                          ? controleur.emojiDepart
                                          : controleur.but == (li, k)
                                          ? controleur.emojiBut
                                          : '',
                                      key: controleur.position == (li, k)
                                          ? const ValueKey('fleur')
                                          : null,
                                      style: StylesYasmina.contentWord,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
            // Le programme, de gauche à droite.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                key: const ValueKey('programme'),
                constraints: const BoxConstraints(
                  minHeight: TaillesYasmina.choiceMinHeight,
                ),
                padding: const EdgeInsets.all(EspacesYasmina.space2),
                decoration: BoxDecoration(
                  color: c.tile,
                  borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
                  border: Border.all(
                    color: juste
                        ? c.olive
                        : faux
                        ? c.coral
                        : c.line,
                    width: TraitsYasmina.borderThick,
                  ),
                ),
                child: Wrap(
                  spacing: EspacesYasmina.space1,
                  children: [
                    for (final (i, p) in programme.indexed)
                      Text(
                        p.fleche,
                        key: ValueKey('pas_$i'),
                        style: styleFleche.copyWith(
                          color: i < controleur.joues ? c.blue : c.ink,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: EspacesYasmina.space2,
              children: [
                for (final p in Pas.values)
                  Semantics(
                    button: true,
                    enabled: peutEcrire,
                    label: l.pas(p),
                    excludeSemantics: true,
                    child: Material(
                      key: ValueKey('fleche_${p.nom}'),
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
                        onTap: peutEcrire ? () => controleur.ajouter(p) : null,
                        borderRadius: BorderRadius.circular(
                          RayonsYasmina.radiusMd,
                        ),
                        child: SizedBox(
                          width: EspacesYasmina.targetMin,
                          height: EspacesYasmina.targetMin,
                          child: Center(
                            child: Text(p.fleche, style: styleFleche),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              spacing: EspacesYasmina.space2,
              children: [
                Expanded(
                  child: BoutonYasmina(
                    key: const ValueKey('codage_effacer'),
                    libelle: libelles.effacer,
                    variante: VarianteBouton.alt,
                    icone: Icons.backspace_outlined,
                    onPressed: peutEcrire && programme.isNotEmpty
                        ? controleur.retirerDernier
                        : null,
                  ),
                ),
                Expanded(
                  child: controleur.joue
                      ? BoutonYasmina(
                          key: const ValueKey('codage_revenir'),
                          libelle: l.revenir,
                          variante: VarianteBouton.alt,
                          icone: Icons.replay_rounded,
                          onPressed: modifiable ? controleur.revenir : null,
                        )
                      : BoutonYasmina(
                          key: const ValueKey('codage_jouer'),
                          libelle: l.jouer,
                          icone: Icons.play_arrow_rounded,
                          onPressed: modifiable && programme.isNotEmpty
                              ? () => _jouer(services)
                              : null,
                        ),
                ),
              ],
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('grille_mot_etat'),
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
