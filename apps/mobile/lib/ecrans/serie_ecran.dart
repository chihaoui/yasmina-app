import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../dev/menu_dev.dart' show catalogueExemplesProvider;
import '../donnees/base_yasmina.dart' show ProfilEnfant;
import '../l10n/app_localizations.dart';
import '../plateforme/services_plateforme.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import '../sequences/sequence_test.dart';
import 'commun.dart';

/// Une série jouée : les exercices s'enchaînent dans le lecteur (mode
/// enfant, forme d'adresse du profil, services réels), avec la progression
/// en haut. À la fin, Yasmina fait le bilan et renvoie à l'accueil. Rien
/// n'est enregistré : la progression locale vient en A3.
class SerieEcran extends ConsumerStatefulWidget {
  const SerieEcran({super.key, required this.idSerie});

  final String idSerie;

  @override
  ConsumerState<SerieEcran> createState() => _SerieEcranState();
}

class _SerieEcranState extends ConsumerState<SerieEcran> {
  /// Index de l'exercice en cours (égal au nombre d'exercices à la fin).
  var _index = 0;

  /// Issue de chaque exercice fini, dans l'ordre.
  final _issues = <IssueExercice>[];

  void _surEvenement(EvenementExercice e) {
    if (e is Resultat) _issues.add(e.issue);
  }

  void _suivant() => setState(() => _index++);

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final id = ref.watch(profilActifProvider);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final profil = profils.where((p) => p.id == id).firstOrNull;
    final sequence = ref.watch(sequenceTestProvider).value;
    if (profil == null || sequence == null) return const EcranChargement();
    final serie = sequence.serie(widget.idSerie);
    final exemples =
        serie?.jouables(ref.watch(catalogueExemplesProvider)) ??
        const <ExempleType>[];
    final theme = Theme.of(context).textTheme;
    final n = exemples.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          serie?.titre.pour(langue) ?? widget.idSerie,
          key: const ValueKey('serie_titre'),
        ),
      ),
      body: n == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
                child: Text(
                  textes.sequenceAucune,
                  key: const ValueKey('sequence_aucune'),
                  textAlign: TextAlign.center,
                  style: theme.bodyLarge,
                ),
              ),
            )
          : _index >= n
          ? _fin(context, textes, n)
          : _exercice(context, textes, theme, exemples[_index], n, profil),
    );
  }

  Widget _exercice(
    BuildContext context,
    AppLocalizations textes,
    TextTheme theme,
    ExempleType exemple,
    int n,
    ProfilEnfant profil,
  ) {
    final c = context.couleurs;
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
              Text(
                textes.sequenceProgression(_index + 1, n),
                key: const ValueKey('serie_progression'),
                style: theme.bodyMedium!.copyWith(color: c.muted),
              ),
              // La barre suit le sens de l'interface (CLAUDE.md §5).
              LinearProgressIndicator(
                value: _index / n,
                minHeight: EspacesYasmina.space2,
                color: c.blue,
                backgroundColor: c.blueSoft,
                borderRadius: BorderRadius.circular(RayonsYasmina.radiusSm),
              ),
            ],
          ),
        ),
        Expanded(
          child: LecteurExercice(
            // Un lecteur neuf par exercice.
            key: ValueKey('serie_exercice_$_index'),
            exercice: exemple.exercice!,
            config: ConfigExercice(
              langue: exemple.langue!,
              formeAdresse: profil.formeAdresse,
            ),
            services: ref.watch(servicesExerciceProvider),
            onEvenement: _surEvenement,
            onContinuer: _suivant,
          ),
        ),
      ],
    );
  }

  Widget _fin(BuildContext context, AppLocalizations textes, int n) {
    // Réussi : juste au 1er ou au 2e essai, ou type sans note terminé.
    final reussis = _issues.where((i) => i != IssueExercice.explique).length;
    return ListView(
      padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
      children: [
        YasminaBulle(
          texte: textes.sequenceFinTitre,
          sousTitre: textes.sequenceBilan(reussis, n),
          humeur: HumeurYasmina.bravo,
          cleTexte: const ValueKey('serie_fin'),
        ),
        const SizedBox(height: EspacesYasmina.space8),
        BoutonYasmina(
          key: const ValueKey('serie_retour'),
          libelle: textes.sequenceRetour,
          icone: Icons.home_rounded,
          variante: VarianteBouton.vert,
          onPressed: () => context.go('/accueil'),
        ),
      ],
    );
  }
}
