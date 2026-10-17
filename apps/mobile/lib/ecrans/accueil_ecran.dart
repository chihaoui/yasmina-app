import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';

/// Écran d'accueil (interface enfant). Il suit la langue de l'interface, et
/// la carte d'exercice garde la langue de sa matière.
class AccueilEcran extends StatelessWidget {
  const AccueilEcran({super.key});

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(textes.appTitre, key: const ValueKey('accueil_titre')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: textes.reglagesOuvrir,
            onPressed: () => context.push('/reglages'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Text(
            textes.accueilBienvenue,
            key: const ValueKey('accueil_bienvenue'),
            style: Theme.of(context).textTheme.headlineSmall,
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
