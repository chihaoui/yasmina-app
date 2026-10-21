import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../composants/carte_matiere.dart';
import '../dev/menu_dev.dart';
import '../l10n/app_localizations.dart';
import '../parcours/matieres.dart';
import '../parcours/parcours.dart';
import '../parcours/progression.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Écran d'accueil de l'enfant choisi : Yasmina, puis le choix de la
/// matière selon son niveau (A3-01). Seules les matières qui ont un
/// parcours embarqué s'ouvrent, les autres portent « bientôt ». Il suit la
/// langue de l'interface.
class AccueilEcran extends ConsumerWidget {
  const AccueilEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final id = ref.watch(profilActifProvider);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final profil = profils.where((p) => p.id == id).firstOrNull;
    if (profil == null) return const EcranChargement();
    final catalogue = ref.watch(catalogueParcoursProvider).value;
    final faites = ref.watch(etapesFaitesProvider(profil.id)).value ?? {};
    return Scaffold(
      appBar: AppBar(
        title: TitreAvecMenuDev(
          child: Text(textes.appTitre, key: const ValueKey('accueil_titre')),
        ),
        actions: const [BoutonReglages()],
      ),
      // Écran court : tout est construit (tests et lecteurs d'écran).
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            for (final matiere in Matiere.pourNiveau(profil.niveau))
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: EspacesYasmina.space3,
                ),
                child: _carteMatiere(
                  context,
                  textes,
                  matiere,
                  catalogue?.pour(matiere: matiere.cle, niveau: profil.niveau),
                  faites,
                ),
              ),
            const SizedBox(height: EspacesYasmina.space6),
            // Séquence de test du tour 1 (A1-22) : les exercices s'enchaînent
            // sans carte.
            BoutonYasmina(
              key: const ValueKey('accueil_jouer'),
              libelle: textes.accueilJouer,
              icone: Icons.play_arrow_rounded,
              variante: VarianteBouton.alt,
              onPressed: () => context.push('/sequence'),
            ),
            const SizedBox(height: EspacesYasmina.space6),
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
      ),
    );
  }

  Widget _carteMatiere(
    BuildContext context,
    AppLocalizations textes,
    Matiere matiere,
    Parcours? parcours,
    Set<String> faites,
  ) {
    final disponible = parcours != null && parcours.etapes.isNotEmpty;
    return CarteMatiere(
      key: ValueKey('matiere_${matiere.code}'),
      nom: matiere.nom(textes),
      icone: matiere.icone,
      couleur: matiere.couleur(context.couleurs),
      libelleBientot: textes.matiereBientot,
      avancement: disponible
          ? textes.matiereEtapesFaites(
              parcours.etapes.where((e) => faites.contains(e.id)).length,
              parcours.etapes.length,
            )
          : null,
      onTap: disponible ? () => context.push('/matiere/${matiere.code}') : null,
    );
  }
}
