import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';
import '../profils/avatar.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Écran d'accueil de l'enfant choisi. Il suit la langue de l'interface, et
/// la carte d'exercice garde la langue de sa matière.
class AccueilEcran extends ConsumerWidget {
  const AccueilEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final id = ref.watch(profilActifProvider);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final profil = profils.where((p) => p.id == id).firstOrNull;
    if (profil == null) return const EcranChargement();
    return Scaffold(
      appBar: AppBar(
        title: Text(textes.appTitre, key: const ValueKey('accueil_titre')),
        actions: const [BoutonReglages()],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Row(
            children: [
              AvatarVisuel(profil.avatar, taille: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  textes.accueilBonjour(profil.prenom),
                  key: const ValueKey('accueil_bonjour'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          // Toujours visible, même avec un seul profil.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('profil_changer'),
              icon: const Icon(Icons.switch_account),
              label: Text(textes.profilChanger),
              onPressed: () => context.go('/'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            textes.accueilBienvenue,
            key: const ValueKey('accueil_bienvenue'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textes.accueilExempleExercice,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  // Exemple d'exercice d'arabe : il reste en arabe et de
                  // droite à gauche, même dans une interface en français.
                  const Center(child: CarteDemo(langue: 'ar')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
