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
/// des séquences en haut. À la fin, l'étape est enregistrée comme faite,
/// Yasmina fait le bilan et renvoie à la carte.
class EtapeJeuEcran extends ConsumerStatefulWidget {
  const EtapeJeuEcran({super.key, required this.code, required this.etapeId});

  final String code;
  final String etapeId;

  @override
  ConsumerState<EtapeJeuEcran> createState() => _EtapeJeuEcranState();
}

class _EtapeJeuEcranState extends ConsumerState<EtapeJeuEcran> {
  /// Index de l'exercice en cours (égal au nombre d'exercices à la fin).
  var _index = 0;

  /// Issue de chaque exercice fini, dans l'ordre.
  final _issues = <IssueExercice>[];

  /// L'étape suivante vient de s'ouvrir grâce à cette partie.
  var _suivanteDebloquee = false;

  int get _reussis => _issues.where((i) => i != IssueExercice.explique).length;

  void _surEvenement(EvenementExercice e) {
    if (e is Resultat) _issues.add(e.issue);
  }

  Future<void> _suivant(
    ProfilEnfant profil,
    Parcours parcours,
    Etape etape,
  ) async {
    final fini = _index + 1 >= etape.nombreExercices;
    if (fini) {
      final faites = ref.read(etapesFaitesProvider(profil.id)).value ?? {};
      final suivante = parcours.suivante(etape.id);
      _suivanteDebloquee =
          !faites.contains(etape.id) &&
          suivante != null &&
          !faites.contains(suivante.id);
      await ref
          .read(depotProgressionProvider)
          .terminerEtape(
            profil.id,
            ResultatEtape(
              etapeId: etape.id,
              reussis: _reussis,
              total: etape.nombreExercices,
            ),
          );
    }
    if (mounted) setState(() => _index++);
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
      body: n == 0 || _index >= n
          ? _resultat(context, textes, parcours, etape, n)
          : _exercice(context, textes, profil, parcours, etape, deroule, n),
    );
  }

  Widget _exercice(
    BuildContext context,
    AppLocalizations textes,
    ProfilEnfant profil,
    Parcours parcours,
    Etape etape,
    List<ExerciceAJouer> deroule,
    int n,
  ) {
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    final courant = deroule[_index];
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
                courant: _index,
                defi: etape.estDefi,
                libelle: textes.sequenceProgression(_index + 1, n),
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
                    textes.sequenceProgression(_index + 1, n),
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
            key: ValueKey('jeu_exercice_$_index'),
            exercice: courant.exercice,
            config: ConfigExercice(
              langue: etape.langue,
              formeAdresse: profil.formeAdresse,
            ),
            services: ref.watch(servicesExerciceProvider),
            onEvenement: _surEvenement,
            onContinuer: () => _suivant(profil, parcours, etape),
          ),
        ),
      ],
    );
  }

  Widget _resultat(
    BuildContext context,
    AppLocalizations textes,
    Parcours parcours,
    Etape etape,
    int n,
  ) {
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
