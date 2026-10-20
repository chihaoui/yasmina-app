import 'dart:math';

import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../composants/bouton_yasmina.dart';
import '../../forme_adresse.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'carte_revision.dart';

/// Une flashcard : recto, verso, et le mot à entendre.
class Flashcard {
  const Flashcard({
    required this.id,
    required this.recto,
    required this.verso,
    this.ecoute,
  });

  factory Flashcard.depuisJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] as String,
    recto: FaceCarte.depuisJson(json['recto'] as Map<String, dynamic>),
    verso: FaceCarte.depuisJson(json['verso'] as Map<String, dynamic>),
    ecoute: (json['ecoute'] as Map<String, dynamic>?)?['texte'] as String?,
  );

  final String id;
  final FaceCarte recto;
  final FaceCarte verso;
  final String? ecoute;
}

/// T36 Flashcards, sans note (docs/moteurs/revision-jeux.md) : une carte à
/// la fois, retournée au toucher, puis « je savais » ou « à revoir » (la
/// carte revient en fin de paquet, une fois). Continuer dès que toutes les
/// cartes demandées sont vues.
class GabaritFlashcards implements GabaritReponse {
  const GabaritFlashcards();

  @override
  ModeValidation get validation => ModeValidation.sansNote;

  @override
  ControleurFlashcards creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurFlashcards(
      config: config,
      cartes: [
        for (final c
            in (donnees['cartes'] as List).cast<Map<String, dynamic>>())
          Flashcard.depuisJson(c),
      ],
      requises: (reponse['cartes'] as List).cast<String>().toSet(),
      melanger: donnees['melanger'] as bool? ?? true,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneFlashcards(controleur as ControleurFlashcards);
}

/// Le paquet, la carte courante et les cartes vues.
class ControleurFlashcards extends ControleurReponse {
  ControleurFlashcards({
    required this.config,
    required List<Flashcard> cartes,
    required this.requises,
    bool melanger = true,
  }) : cartes = {for (final c in cartes) c.id: c},
       _paquet = [for (final c in cartes) c.id] {
    if (melanger) {
      _paquet.shuffle(config.graine == null ? null : Random(config.graine));
    }
  }

  final ConfigExercice config;
  final Map<String, Flashcard> cartes;
  final Set<String> requises;

  final List<String> _paquet;
  int _index = 0;
  bool _retournee = false;
  final _vues = <String>{};
  final _aRevoir = <String>[];

  /// Cartes du paquet dans l'ordre, celles « à revoir » ajoutées en fin.
  List<String> get paquet => List.unmodifiable(_paquet);

  /// Carte courante, `null` quand le paquet est fini.
  Flashcard? get courante =>
      _index < _paquet.length ? cartes[_paquet[_index]] : null;

  int get position => _index < _paquet.length ? _index + 1 : _paquet.length;

  bool get retournee =>
      _retournee || affichage == AffichageReponse.revelee || courante == null;

  bool get finie => _index >= _paquet.length;

  Set<String> get vues => Set.unmodifiable(_vues);

  List<String> get aRevoir => List.unmodifiable(_aRevoir);

  void retourner() {
    if (!modifiable || finie || _retournee) return;
    _retournee = true;
    notifyListeners();
  }

  /// Auto-évaluation de la carte courante, puis carte suivante. Une carte
  /// « à revoir » revient en fin de paquet, une seule fois.
  void evaluer({required bool su}) {
    if (!modifiable || finie || !_retournee) return;
    final id = _paquet[_index];
    _vues.add(id);
    if (!su && !_aRevoir.contains(id)) {
      _aRevoir.add(id);
      _paquet.add(id);
    }
    _index++;
    _retournee = false;
    reponseModifiee();
  }

  @override
  bool get complete => requises.every(_vues.contains);

  @override
  Object? get reponse => {
    'cartes': (_vues.toList()..sort()),
    'a_revoir': List.of(_aRevoir),
  };

  @override
  bool corriger() => complete;

  @override
  void vider() {
    _paquet.removeRange(cartes.length, _paquet.length);
    _index = 0;
    _retournee = false;
    _vues.clear();
    _aRevoir.clear();
    reponseModifiee();
  }
}

/// Le compteur, la carte, Écouter, puis les deux boutons.
class _ZoneFlashcards extends StatelessWidget {
  const _ZoneFlashcards(this.controleur);

  final ControleurFlashcards controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final l = libellesJeux(
      langue,
      feminin: config.formeAdresse == FormeAdresse.feminin,
    );
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final carte =
            controleur.courante ?? controleur.cartes[controleur.paquet.last]!;
        final retournee = controleur.retournee;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${controleur.position} / ${controleur.paquet.length}',
                key: const ValueKey('cartes_compteur'),
                textAlign: TextAlign.center,
                style: ThemeYasmina.pourLangue(
                  StylesYasmina.latinLabel,
                  langue,
                ).copyWith(color: c.muted),
              ),
            ),
            KeyedSubtree(
              key: ValueKey(revelee ? 'jeux_reponse' : 'carte'),
              child: CarteRevision(
                face: retournee ? carte.verso : carte.recto,
                etat: retournee
                    ? (controleur.finie || revelee
                          ? EtatCarte.trouvee
                          : EtatCarte.retournee)
                    : EtatCarte.cachee,
                grande: true,
                libelle: l.carteN(controleur.position),
                onTap: modifiable && !controleur.finie && !retournee
                    ? controleur.retourner
                    : null,
              ),
            ),
            if (carte.ecoute case final ecoute?)
              Center(
                child: BoutonEcouter(
                  key: const ValueKey('carte_ecouter'),
                  libelle: libelles.ecouter,
                  onPressed: () =>
                      controleur.demanderAudio(ecoute, langue: langue),
                ),
              ),
            Row(
              spacing: EspacesYasmina.space3,
              children: [
                Expanded(
                  child: BoutonYasmina(
                    key: const ValueKey('carte_su'),
                    libelle: l.jeSavais,
                    variante: VarianteBouton.alt,
                    icone: Icons.check_rounded,
                    onPressed: modifiable && !controleur.finie && retournee
                        ? () => controleur.evaluer(su: true)
                        : null,
                  ),
                ),
                Expanded(
                  child: BoutonYasmina(
                    key: const ValueKey('carte_a_revoir'),
                    libelle: l.aRevoir,
                    variante: VarianteBouton.alt,
                    icone: Icons.replay_rounded,
                    onPressed: modifiable && !controleur.finie && retournee
                        ? () => controleur.evaluer(su: false)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
