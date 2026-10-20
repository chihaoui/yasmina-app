import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'cadre_dev.dart';
import 'menu_dev.dart';
import 'pastille_dev.dart';

/// Une ligne de la liste de l'atelier.
sealed class LigneAtelier {
  const LigneAtelier();
}

/// En-tête d'un moteur, avec ses types jouables sur le total.
class EnTeteMoteur extends LigneAtelier {
  const EnTeteMoteur(
    this.moteur, {
    required this.jouables,
    required this.total,
  });

  final Moteur moteur;
  final int jouables;
  final int total;
}

/// Un type, avec ses exemples.
class LigneType extends LigneAtelier {
  const LigneType(this.type, this.exemples);

  final TypeExercice type;
  final List<ExempleType> exemples;

  int get enErreur => exemples.where((e) => !e.estValide).length;
}

/// En-tête des exemples sans type connu.
class EnTeteNonRattaches extends LigneAtelier {
  const EnTeteNonRattaches();
}

/// Exemple sans type connu.
class LigneNonRattache extends LigneAtelier {
  const LigneNonRattache(this.exemple);

  final ExempleType exemple;
}

/// Contenu de l'atelier : les moteurs dans l'ordre de développement
/// (décision 34), chacun suivi de ses types, puis les exemples non
/// rattachés.
List<LigneAtelier> contenuAtelier(CatalogueExemples catalogue) => [
  for (final moteur in Moteur.values) ...[
    EnTeteMoteur(
      moteur,
      jouables: typesDuMoteur(moteur)
          .where((t) => t.etat == EtatType.jouable)
          .length,
      total: typesDuMoteur(moteur).length,
    ),
    for (final type in typesDuMoteur(moteur))
      LigneType(type, catalogue.exemplesDuType(type.id)),
  ],
  if (catalogue.nonRattaches.isNotEmpty) ...[
    const EnTeteNonRattaches(),
    for (final e in catalogue.nonRattaches) LigneNonRattache(e),
  ],
];

/// L'atelier : les 52 types groupés par moteur, chacun ouvrable seul.
class AtelierEcran extends ConsumerWidget {
  const AtelierEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lignes = contenuAtelier(ref.watch(catalogueExemplesProvider));
    return CadreDev(
      child: Builder(
        builder: (context) {
          final c = context.couleurs;
          final textes = Theme.of(context).textTheme;
          Widget enTete(String texte, Key cle) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              EspacesYasmina.space6,
              EspacesYasmina.space8,
              EspacesYasmina.space6,
              EspacesYasmina.space2,
            ),
            child: Text(texte, key: cle, style: textes.titleMedium),
          );
          return Scaffold(
            appBar: AppBar(
              title: const Text('Atelier', key: ValueKey('atelier_titre')),
            ),
            body: ListView.builder(
              itemCount: lignes.length,
              itemBuilder: (context, i) => switch (lignes[i]) {
                EnTeteMoteur(:final moteur, :final jouables, :final total) =>
                  enTete(
                    '${moteur.nom} · $jouables / $total jouables',
                    ValueKey('atelier_moteur_${moteur.name}'),
                  ),
                final LigneType ligne => ListTile(
                  key: ValueKey('atelier_type_${ligne.type.id}'),
                  title: Text('${ligne.type.id}  ${ligne.type.nom}'),
                  subtitle: Text.rich(
                    TextSpan(
                      text:
                          'Lot ${ligne.type.lot} · '
                          '${_exemples(ligne.exemples.length)}',
                      children: [
                        if (ligne.enErreur > 0)
                          TextSpan(
                            text: ' · ${ligne.enErreur} en erreur',
                            style: TextStyle(color: c.coralText),
                          ),
                      ],
                    ),
                  ),
                  trailing: PastilleEtat(ligne.type.etat),
                  onTap: () => context.push('/dev/atelier/${ligne.type.id}'),
                ),
                EnTeteNonRattaches() => enTete(
                  'Exemples non rattachés',
                  const ValueKey('atelier_non_rattaches'),
                ),
                LigneNonRattache(:final exemple) => ListTile(
                  title: Text(exemple.chemin),
                  subtitle: Text(
                    exemple.erreurs.isEmpty
                        ? 'Préfixe Txx absent ou type hors du registre.'
                        : exemple.erreurs.join('\n'),
                    style: TextStyle(color: c.coralText),
                  ),
                ),
              },
            ),
          );
        },
      ),
    );
  }

  static String _exemples(int n) => switch (n) {
    0 => 'aucun exemple',
    1 => '1 exemple',
    _ => '$n exemples',
  };
}
