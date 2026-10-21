import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

// Le catalogue des exemples est aussi celui de l'atelier.
import '../dev/menu_dev.dart' show catalogueExemplesProvider;
import '../l10n/app_localizations.dart';
import '../sequences/sequence_test.dart';

/// Les séries de la séquence de test (A1-22) : l'enfant en choisit une, puis
/// les exercices s'enchaînent sans carte. L'écran suit la langue de
/// l'interface, chaque exercice garde la langue de sa matière.
class SequenceEcran extends ConsumerWidget {
  const SequenceEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final catalogue = ref.watch(catalogueExemplesProvider);
    final sequence = ref.watch(sequenceTestProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          textes.sequenceTitre,
          key: const ValueKey('sequence_titre'),
        ),
      ),
      body: switch (sequence) {
        AsyncData(:final value) => _series(
          context,
          textes,
          langue,
          catalogue,
          value,
        ),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
            child: Text(
              '$error',
              key: const ValueKey('sequence_erreur'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _series(
    BuildContext context,
    AppLocalizations textes,
    String langue,
    CatalogueExemples catalogue,
    SequenceTest sequence,
  ) {
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    if (sequence.series.isEmpty) {
      return Center(
        child: Text(
          textes.sequenceAucune,
          key: const ValueKey('sequence_aucune'),
          style: theme.bodyLarge,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
      children: [
        for (final serie in sequence.series)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: EspacesYasmina.space4,
            ),
            child: _CarteSerie(
              serie: serie,
              titre: serie.titre.pour(langue),
              nombre: serie.jouables(catalogue).length,
              textes: textes,
              couleurs: c,
            ),
          ),
      ],
    );
  }
}

class _CarteSerie extends StatelessWidget {
  const _CarteSerie({
    required this.serie,
    required this.titre,
    required this.nombre,
    required this.textes,
    required this.couleurs,
  });

  final SerieTest serie;
  final String titre;
  final int nombre;
  final AppLocalizations textes;
  final CouleursYasmina couleurs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Card(
      key: ValueKey('serie_${serie.id}'),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          titre,
          key: ValueKey('serie_titre_${serie.id}'),
          style: theme.titleMedium,
        ),
        subtitle: Text(
          textes.sequenceNombreExercices(nombre),
          style: theme.bodyMedium!.copyWith(color: couleurs.muted),
        ),
        trailing: Icon(
          Icons.play_circle_fill_rounded,
          color: nombre == 0 ? couleurs.muted : couleurs.blue,
          size: TaillesYasmina.iconListen,
        ),
        // Une série vide (exemples retirés du catalogue) ne s'ouvre pas.
        onTap: nombre == 0 ? null : () => context.push('/sequence/${serie.id}'),
      ),
    );
  }
}
