import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../forme_adresse.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/mouvements_yasmina.dart';
import 'carte_revision.dart';

/// Une carte du memory : sa paire et sa face.
class CarteMemory {
  const CarteMemory({
    required this.id,
    required this.paire,
    required this.face,
  });

  final String id;
  final String paire;
  final FaceCarte face;
}

/// T37 Memory, automatique et noté (docs/moteurs/revision-jeux.md) :
/// retourner deux cartes, garder les paires. Juste si les essais ne
/// dépassent pas `essais_max` (deux fois le nombre de paires par défaut).
class GabaritMemory implements GabaritReponse {
  const GabaritMemory();

  @override
  ModeValidation get validation => ModeValidation.automatique;

  @override
  ControleurMemory creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final paires = (donnees['paires'] as List).cast<Map<String, dynamic>>();
    return ControleurMemory(
      config: config,
      cartes: [
        for (final p in paires) ...[
          CarteMemory(
            id: '${p['id']}a',
            paire: p['id'] as String,
            face: FaceCarte.depuisJson(p['a'] as Map<String, dynamic>),
          ),
          CarteMemory(
            id: '${p['id']}b',
            paire: p['id'] as String,
            face: FaceCarte.depuisJson(p['b'] as Map<String, dynamic>),
          ),
        ],
      ],
      nombrePaires: paires.length,
      essaisMax: donnees['essais_max'] as int? ?? paires.length * 2,
      melanger: donnees['melanger'] as bool? ?? true,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneMemory(controleur as ControleurMemory);
}

/// Les cartes, celles retournées, les paires trouvées et les essais.
class ControleurMemory extends ControleurReponse {
  ControleurMemory({
    required this.config,
    required List<CarteMemory> cartes,
    required this.nombrePaires,
    required this.essaisMax,
    bool melanger = true,
  }) : cartes = melanger
           ? (List.of(cartes)..shuffle(
               config.graine == null ? null : math.Random(config.graine),
             ))
           : List.unmodifiable(cartes);

  final ConfigExercice config;

  /// Cartes dans l'ordre d'affichage.
  final List<CarteMemory> cartes;
  final int nombrePaires;
  final int essaisMax;

  final _retournees = <String>[];
  final _trouvees = <String>{};
  int _essais = 0;
  Timer? _minuterie;

  /// Dernière paire trouvée (son `depot`), remise à `null` par la zone.
  bool paireVientDEtreTrouvee = false;

  CarteMemory carte(String id) => cartes.firstWhere((c) => c.id == id);

  bool estRetournee(String id) => _retournees.contains(id);

  bool estTrouvee(String id) => _trouvees.contains(carte(id).paire);

  Set<String> get trouvees => Set.unmodifiable(_trouvees);

  int get essais => _essais;

  /// Deux cartes fausses sont montrées un instant.
  bool get enAttente => _retournees.length == 2;

  void retourner(String id) {
    if (!modifiable || enAttente || estRetournee(id) || estTrouvee(id)) {
      return;
    }
    _retournees.add(id);
    if (_retournees.length < 2) {
      notifyListeners();
      return;
    }
    _essais++;
    final (a, b) = (carte(_retournees[0]), carte(_retournees[1]));
    if (a.paire == b.paire) {
      _trouvees.add(a.paire);
      _retournees.clear();
      paireVientDEtreTrouvee = true;
      reponseModifiee();
      if (_trouvees.length == nombrePaires) {
        terminer(juste: _essais <= essaisMax);
      }
      return;
    }
    notifyListeners();
    _minuterie = Timer(MouvementsYasmina.dureeFaux, cacher);
  }

  /// Referme les deux cartes fausses.
  void cacher() {
    _minuterie = null;
    if (!enAttente) return;
    _retournees.clear();
    notifyListeners();
  }

  @override
  bool get complete => _trouvees.length == nombrePaires;

  @override
  Object? get reponse => {
    'paires': (_trouvees.toList()..sort()),
    'essais': _essais,
  };

  @override
  bool corriger() => _essais <= essaisMax;

  @override
  void vider() {
    _minuterie?.cancel();
    _minuterie = null;
    _retournees.clear();
    _trouvees.clear();
    _essais = 0;
    reponseModifiee();
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }
}

/// Colonnes de la grille du memory (revision-jeux.md §3 : 3 × 2 en 1re,
/// 3 × 4 en 2e et 3e, 3 × 6 en 4e et 5e, 3 × 8 en 6e).
const colonnesMemory = 3;

/// La grille de cartes, trois par ligne, cartes de taille fixe (même
/// hauteur face cachée et face visible, texte ajusté).
class _ZoneMemory extends StatelessWidget {
  const _ZoneMemory(this.controleur);

  final ControleurMemory controleur;

  @override
  Widget build(BuildContext context) {
    final config = controleur.config;
    final l = libellesJeux(
      config.langue,
      feminin: config.formeAdresse == FormeAdresse.feminin,
    );
    final services = ServicesExercice.of(context);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        if (controleur.paireVientDEtreTrouvee) {
          controleur.paireVientDEtreTrouvee = false;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
        }
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final fini =
            affichage == AffichageReponse.juste ||
            affichage == AffichageReponse.revelee;
        final cartes = controleur.cartes;
        return LayoutBuilder(
          builder: (context, contraintes) {
            final largeur =
                (contraintes.maxWidth -
                    (colonnesMemory - 1) * EspacesYasmina.space2) /
                colonnesMemory;
            Widget carte(int i) {
              final carte = cartes[i];
              final trouvee = controleur.estTrouvee(carte.id) || fini;
              final retournee = controleur.estRetournee(carte.id);
              final etat = trouvee
                  ? EtatCarte.trouvee
                  : retournee
                  ? (controleur.enAttente
                        ? EtatCarte.fausse
                        : EtatCarte.retournee)
                  : EtatCarte.cachee;
              return SizedBox(
                width: largeur,
                height: TaillesYasmina.choiceMinHeight,
                child: CarteRevision(
                  key: ValueKey('carte_${carte.id}'),
                  face: carte.face,
                  etat: etat,
                  libelle: l.carteN(i + 1),
                  fixe: true,
                  motEtat: apercu && trouvee && fini ? 'juste' : null,
                  onTap: controleur.modifiable && !trouvee && !retournee
                      ? () => controleur.retourner(carte.id)
                      : null,
                ),
              );
            }

            return Column(
              key: ValueKey(revelee ? 'jeux_reponse' : 'memory'),
              spacing: EspacesYasmina.space2,
              children: [
                for (
                  var debut = 0;
                  debut < cartes.length;
                  debut += colonnesMemory
                )
                  Row(
                    spacing: EspacesYasmina.space2,
                    children: [
                      for (
                        var i = debut;
                        i < math.min(debut + colonnesMemory, cartes.length);
                        i++
                      )
                        carte(i),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
