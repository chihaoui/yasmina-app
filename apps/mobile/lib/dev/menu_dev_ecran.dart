import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../parcours/parcours.dart';
import '../parcours/progression.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'cadre_dev.dart';
import 'menu_dev.dart';
import 'reglages_dev.dart';

/// Menu développeur (CLAUDE.md §7), en français : outil interne, absent en
/// release.
class MenuDevEcran extends ConsumerWidget {
  const MenuDevEcran({super.key});

  Future<void> _creerProfils(BuildContext context, WidgetRef ref) async {
    final bilan = await creerProfilsDeTest(
      ref.read(depotProfilsProvider),
      progression: ref.read(depotProgressionProvider),
      catalogue: await ref.read(catalogueParcoursProvider.future),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(bilan)));
  }

  Future<void> _reinitialiser(BuildContext context, WidgetRef ref) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogue) => CadreDev(
        child: AlertDialog(
          title: const Text('Réinitialiser toutes les données ?'),
          content: const Text(
            'Les profils, leur historique, leur progression et les réglages '
            'de test seront effacés. La langue de l\'interface est gardée.',
          ),
          actions: [
            TextButton(
              key: const ValueKey('dev_annuler'),
              onPressed: () => Navigator.pop(dialogue, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              key: const ValueKey('dev_confirmer'),
              onPressed: () => Navigator.pop(dialogue, true),
              child: const Text('Tout effacer'),
            ),
          ],
        ),
      ),
    );
    if (confirme != true) return;
    await ref.read(depotProfilsProvider).toutEffacer();
    await ref.read(depotProgressionProvider).toutEffacer();
    ref.read(profilActifProvider.notifier).oublier();
    await ref.read(abonnementSimuleProvider.notifier).oublier();
    await ref.read(toutDebloqueProvider.notifier).choisir(false);
    await ref.read(sonsEffetsProvider.notifier).choisir(true);
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnement = ref.watch(abonnementSimuleProvider);
    final debloque = ref.watch(toutDebloqueProvider);
    return CadreDev(
      child: Builder(
        builder: (context) {
          final c = context.couleurs;
          final textes = Theme.of(context).textTheme;
          Widget titre(String texte) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              EspacesYasmina.space6,
              EspacesYasmina.space8,
              EspacesYasmina.space6,
              EspacesYasmina.space2,
            ),
            child: Text(texte, style: textes.titleMedium),
          );
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Menu développeur',
                key: ValueKey('menu_dev_titre'),
              ),
            ),
            body: ListView(
              children: [
                ListTile(
                  key: const ValueKey('dev_atelier'),
                  leading: const Icon(Icons.widgets_rounded),
                  title: const Text('Atelier'),
                  subtitle: const Text(
                    'Les 53 types, chacun ouvrable seul : exemples validés, '
                    'JSON et lecteur.',
                  ),
                  onTap: () => context.push('/dev/atelier'),
                ),
                titre('Profils et données'),
                ListTile(
                  key: const ValueKey('dev_profils_test'),
                  leading: const Icon(Icons.group_add_rounded),
                  title: const Text('Créer les profils de test'),
                  subtitle: const Text(
                    'Lina (fille, progression d\'exemple en arabe) et '
                    'Yassine (garçon, vierge), 1re année. Un profil déjà '
                    'présent est gardé.',
                  ),
                  onTap: () => _creerProfils(context, ref),
                ),
                ListTile(
                  key: const ValueKey('dev_reinitialiser'),
                  leading: Icon(
                    Icons.delete_forever_rounded,
                    color: c.coralText,
                  ),
                  title: Text(
                    'Réinitialiser toutes les données',
                    style: TextStyle(color: c.coralText),
                  ),
                  subtitle: const Text(
                    'Profils, historique et réglages de test.',
                  ),
                  onTap: () => _reinitialiser(context, ref),
                ),
                titre('Abonnement simulé'),
                RadioGroup<AbonnementSimule>(
                  groupValue: abonnement,
                  onChanged: (statut) {
                    if (statut != null) {
                      ref
                          .read(abonnementSimuleProvider.notifier)
                          .choisir(statut);
                    }
                  },
                  child: Column(
                    children: [
                      for (final statut in AbonnementSimule.values)
                        RadioListTile<AbonnementSimule>(
                          key: ValueKey('dev_abonnement_${statut.name}'),
                          value: statut,
                          title: Text(statut.libelle),
                        ),
                    ],
                  ),
                ),
                SwitchListTile(
                  key: const ValueKey('dev_tout_debloquer'),
                  title: const Text('Tout débloquer'),
                  value: debloque,
                  onChanged: (valeur) =>
                      ref.read(toutDebloqueProvider.notifier).choisir(valeur),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.all(
                    EspacesYasmina.space6,
                  ),
                  child: Text(
                    'L\'abonnement simulé et « Tout débloquer » sont '
                    'enregistrés, sans effet pour l\'instant.',
                    style: textes.bodySmall,
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
