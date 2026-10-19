import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'cadre_dev.dart';
import 'menu_dev.dart';
import 'pastille_dev.dart';

/// Un type de l'atelier : ses exemples (gabarit, langue, consigne, statut),
/// ouvrables même quand le type est à venir.
class AtelierTypeEcran extends ConsumerWidget {
  const AtelierTypeEcran({super.key, required this.idType});

  final String idType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = typeParId(idType);
    final exemples = ref
        .watch(catalogueExemplesProvider)
        .exemplesDuType(idType);
    return CadreDev(
      child: Builder(
        builder: (context) {
          final textes = Theme.of(context).textTheme;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                type == null ? idType : '${type.id}  ${type.nom}',
                key: const ValueKey('atelier_type_titre'),
              ),
            ),
            body: type == null
                ? Center(child: Text('Type $idType absent du registre.'))
                : ListView(
                    padding: const EdgeInsetsDirectional.all(
                      EspacesYasmina.space6,
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Moteur ${type.moteur.nom} · lot ${type.lot}',
                              style: textes.bodyLarge,
                            ),
                          ),
                          PastilleEtat(type.etat),
                        ],
                      ),
                      const SizedBox(height: EspacesYasmina.space4),
                      if (exemples.isEmpty)
                        Text(
                          'Aucun exemple pour l\'instant.',
                          key: const ValueKey('atelier_aucun_exemple'),
                          style: textes.bodySmall,
                        ),
                      for (final exemple in exemples)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: EspacesYasmina.space4,
                          ),
                          child: CarteExemple(
                            exemple: exemple,
                            onTap: () => context.push(
                              '/dev/atelier/$idType/${exemple.fichier}',
                            ),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// Résumé d'un exemple : fichier, gabarit, langue, statut et consigne.
class CarteExemple extends StatelessWidget {
  const CarteExemple({super.key, required this.exemple, this.onTap});

  final ExempleType exemple;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final textes = Theme.of(context).textTheme;
    final langue = exemple.langue;
    final consigne = exemple.consigne;
    return Card(
      key: ValueKey('atelier_exemple_${exemple.fichier}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: EspacesYasmina.space2,
            children: [
              Text(exemple.fichier, style: textes.titleMedium),
              Text(
                'Gabarit : ${exemple.gabarit ?? '?'} · '
                'langue : ${langue ?? '?'}',
                style: textes.bodySmall,
              ),
              if (exemple.estValide)
                Text(
                  'Valide',
                  key: ValueKey('statut_${exemple.fichier}'),
                  style: StylesYasmina.latinLabel.copyWith(color: c.oliveText),
                )
              else
                Text(
                  'En erreur :\n${exemple.erreurs.join('\n')}',
                  key: ValueKey('statut_${exemple.fichier}'),
                  style: textes.bodyMedium!.copyWith(color: c.coralText),
                ),
              if (consigne != null && langue != null)
                // La consigne garde la langue de l'exercice (sens et police).
                LangueExercice(
                  langue: langue,
                  child: Text(
                    consigne,
                    key: ValueKey('consigne_${exemple.fichier}'),
                    style: ThemeYasmina.pourLangue(
                      langue == 'ar'
                          ? StylesYasmina.contentOption
                          : StylesYasmina.latinPrompt,
                      langue,
                    ).copyWith(color: c.ink),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
