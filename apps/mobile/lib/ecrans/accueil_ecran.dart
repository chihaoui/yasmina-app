import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../dev/menu_dev.dart';
import '../l10n/app_localizations.dart';
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
        title: TitreAvecMenuDev(
          child: Text(textes.appTitre, key: const ValueKey('accueil_titre')),
        ),
        actions: const [BoutonReglages()],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        children: [
          YasminaBulle(
            texte: textes.accueilBonjour(profil.prenom),
            cleTexte: const ValueKey('accueil_bonjour'),
          ),
          const SizedBox(height: EspacesYasmina.space4),
          Text(
            textes.accueilBienvenue,
            key: const ValueKey('accueil_bienvenue'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: EspacesYasmina.space8),
          // Séquence de test du tour 1 (A1-22) : les exercices s'enchaînent
          // sans carte, le parcours vient en A3.
          BoutonYasmina(
            key: const ValueKey('accueil_jouer'),
            libelle: textes.accueilJouer,
            icone: Icons.play_arrow_rounded,
            onPressed: () => context.push('/sequence'),
          ),
          const SizedBox(height: EspacesYasmina.space8),
          Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textes.accueilExempleExercice,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: EspacesYasmina.space6),
                  // Exemple d'exercice d'arabe : il reste en arabe et de
                  // droite à gauche, même dans une interface en français.
                  const Center(child: CarteDemo(langue: 'ar')),
                ],
              ),
            ),
          ),
          const SizedBox(height: EspacesYasmina.space8),
          // Toujours visible, même avec un seul profil.
          BoutonYasmina(
            key: const ValueKey('profil_changer'),
            libelle: textes.profilChanger,
            icone: Icons.switch_account_rounded,
            variante: VarianteBouton.alt,
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}
