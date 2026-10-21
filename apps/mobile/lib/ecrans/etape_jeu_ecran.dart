import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../composants/progression_sequences.dart';
import '../donnees/base_yasmina.dart' show ProfilEnfant;
import '../l10n/app_localizations.dart';
import '../parcours/matieres.dart';
import '../parcours/parcours.dart';
import '../parcours/progression.dart';
import '../plateforme/services_plateforme.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Une étape jouée (A3-02) : ses séquences s'enchaînent dans le lecteur
/// (mode enfant, forme d'adresse du profil, services réels), avec la barre
/// des séquences en haut. Chaque exercice fini est enregistré (A3-03) : une
/// partie quittée reprend au même exercice. À la fin, l'étape est faite,
/// Yasmina fait le bilan et renvoie à la carte.
class EtapeJeuEcran extends ConsumerStatefulWidget {
  const EtapeJeuEcran({super.key, required this.code, required this.etapeId});

  final String code;
  final String etapeId;

  @override
  ConsumerState<EtapeJeuEcran> createState() => _EtapeJeuEcranState();
}

class _EtapeJeuEcranState extends ConsumerState<EtapeJeuEcran> {
  /// Index de l'exercice en cours (égal au nombre d'exercices à la fin),
  /// `null` tant que la partie n'est pas ouverte dans la base.
  int? _index;

  /// Exercices réussis dans cette partie (repris de la base à l'ouverture).
  var _reussis = 0;

  /// Dernier résultat émis par le lecteur pour l'exercice en cours.
  Resultat? _resultat;

  /// L'étape suivante vient de s'ouvrir grâce à cette partie.
  var _suivanteDebloquee = false;

  /// Ouvre (ou reprend) la partie dans la base, une seule fois.
  Future<void> _ouvrir(ProfilEnfant profil, Etape etape) async {
    final etat = await ref
        .read(depotProgressionProvider)
        .commencerEtape(profil.id, etape.id, total: etape.nombreExercices);
    if (!mounted) return;
    setState(() {
      _index = etat.indexReprise;
      _reussis = etat.reussis;
    });
  }

  void _surEvenement(EvenementExercice e) {
    if (e is Resultat) _resultat = e;
  }

  Future<void> _suivant(
    ProfilEnfant profil,
    Parcours parcours,
    Etape etape,
    ExerciceAJouer courant,
  ) async {
    final depot = ref.read(depotProgressionProvider);
    final index = _index!;
    final resultat = _resultat;
    _resultat = null;
    final reussi = resultat != null && resultat.issue != IssueExercice.explique;
    if (reussi) _reussis++;
    await depot.enregistrerExercice(
      profil.id,
      etapeId: etape.id,
      sequenceId: etape.sequences[courant.sequence].id,
      exerciceId: courant.id,
      essais: resultat?.essais ?? 0,
      reussi: reussi,
      revele: resultat?.issue == IssueExercice.explique,
      indexSuivant: index + 1,
    );
    if (index + 1 >= etape.nombreExercices) {
      final faites = ref.read(etapesFaitesProvider(profil.id)).value ?? {};
      final suivante = parcours.suivante(etape.id);
      _suivanteDebloquee =
          !faites.contains(etape.id) &&
          suivante != null &&
          !faites.contains(suivante.id);
      await depot.terminerEtape(
        profil.id,
        etape.id,
        reussis: _reussis,
        total: etape.nombreExercices,
      );
    }
    if (mounted) setState(() => _index = index + 1);
  }

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final matiere = Matiere.parCode(widget.code);
    final id = ref.watch(profilActifProvider);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final profil = profils.where((p) => p.id == id).firstOrNull;
    final catalogue = ref.watch(catalogueParcoursProvider).value;
    if (matiere == null || profil == null || catalogue == null) {
      return const EcranChargement();
    }
    final parcours = catalogue.pour(
      matiere: matiere.cle,
      niveau: profil.niveau,
    );
    final etape = parcours?.etape(widget.etapeId);
    if (parcours == null || etape == null) return const EcranChargement();
    final index = _index;
    if (index == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _index == null) _ouvrir(profil, etape);
      });
      return const EcranChargement();
    }
    final deroule = etape.deroule;
    final n = deroule.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          etape.titre,
          key: const ValueKey('jeu_titre'),
          textDirection: LangueExercice.directionDe(etape.langue),
        ),
      ),
      body: n == 0 || index >= n
          ? _fin(context, textes, n)
          : _exercice(context, textes, profil, parcours, etape, deroule, index),
    );
  }

  Widget _exercice(
    BuildContext context,
    AppLocalizations textes,
    ProfilEnfant profil,
    Parcours parcours,
    Etape etape,
    List<ExerciceAJouer> deroule,
    int index,
  ) {
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    final n = deroule.length;
    final courant = deroule[index];
    final sens = LangueExercice.directionDe(etape.langue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            EspacesYasmina.space6,
            EspacesYasmina.space4,
            EspacesYasmina.space6,
            EspacesYasmina.space2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: EspacesYasmina.space2,
            children: [
              ProgressionSequences(
                key: const ValueKey('jeu_progression'),
                sequences: [for (final e in deroule) e.sequence],
                courant: index,
                defi: etape.estDefi,
                libelle: textes.sequenceProgression(index + 1, n),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      etape.sequences[courant.sequence].titre,
                      key: const ValueKey('jeu_sequence'),
                      textDirection: sens,
                      style: ThemeYasmina.pourLangue(
                        StylesYasmina.option,
                        etape.langue,
                      ).copyWith(color: c.muted),
                    ),
                  ),
                  Text(
                    textes.sequenceProgression(index + 1, n),
                    key: const ValueKey('jeu_compteur'),
                    style: theme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: LecteurExercice(
            // Un lecteur neuf par exercice.
            key: ValueKey('jeu_exercice_$index'),
            exercice: courant.exercice,
            config: ConfigExercice(
              langue: etape.langue,
              formeAdresse: profil.formeAdresse,
            ),
            services: ref.watch(servicesExerciceProvider),
            onEvenement: _surEvenement,
            onContinuer: () => _suivant(profil, parcours, etape, courant),
          ),
        ),
      ],
    );
  }

  Widget _fin(BuildContext context, AppLocalizations textes, int n) {
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
      children: [
        YasminaBulle(
          texte: textes.resultatTitre,
          sousTitre: textes.sequenceBilan(_reussis, n),
          humeur: HumeurYasmina.bravo,
          cleTexte: const ValueKey('etape_resultat'),
        ),
        if (_suivanteDebloquee) ...[
          const SizedBox(height: EspacesYasmina.space6),
          Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
              child: Row(
                children: [
                  Icon(Icons.lock_open_rounded, color: c.olive),
                  const SizedBox(width: EspacesYasmina.space3),
                  Expanded(
                    child: Text(
                      textes.resultatSuivante,
                      key: const ValueKey('etape_suivante'),
                      style: theme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: EspacesYasmina.space8),
        BoutonYasmina(
          key: const ValueKey('etape_retour_carte'),
          libelle: textes.resultatRetourCarte,
          icone: Icons.map_rounded,
          variante: VarianteBouton.vert,
          onPressed: () => context.go('/matiere/${widget.code}'),
        ),
      ],
    );
  }
}
