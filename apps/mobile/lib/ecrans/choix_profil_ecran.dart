import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../donnees/base_yasmina.dart';
import '../l10n/app_localizations.dart';
import '../profils/avatar.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';
import 'profil_formulaire_ecran.dart';

/// « Qui joue ? » : un profil par carte, sans mot de passe. Sans profil, le
/// formulaire de création s'affiche directement.
class ChoixProfilEcran extends ConsumerWidget {
  const ChoixProfilEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(profilsProvider)
        .when(
          data: (profils) =>
              profils.isEmpty ? const ProfilFormulaireEcran() : _Choix(profils),
          loading: () => const EcranChargement(),
          error: (erreur, _) => Scaffold(body: Center(child: Text('$erreur'))),
        );
  }
}

class _Choix extends StatelessWidget {
  const _Choix(this.profils);

  final List<ProfilEnfant> profils;

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final limiteAtteinte = profils.length >= DepotProfils.maxProfils;
    return Scaffold(
      appBar: AppBar(
        title: Text(textes.profilsTitre, key: const ValueKey('profils_titre')),
        actions: const [BoutonReglages()],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [for (final p in profils) _CarteProfil(p)],
          ),
          const SizedBox(height: 32),
          if (limiteAtteinte)
            Text(
              textes.profilsLimite,
              key: const ValueKey('profils_limite'),
              textAlign: TextAlign.center,
            )
          else
            Center(
              child: FilledButton.icon(
                key: const ValueKey('profils_ajouter'),
                icon: const Icon(Icons.add),
                label: Text(textes.profilsAjouter),
                onPressed: () => context.push('/profils/nouveau'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarteProfil extends ConsumerWidget {
  const _CarteProfil(this.profil);

  final ProfilEnfant profil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('profil_${profil.id}'),
        onTap: () {
          ref.read(profilActifProvider.notifier).choisir(profil.id);
          context.go('/accueil');
        },
        child: SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 4),
            child: Column(
              children: [
                AvatarVisuel(profil.avatar, taille: 72),
                const SizedBox(height: 8),
                Text(
                  profil.prenom,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  key: ValueKey('profil_modifier_${profil.id}'),
                  icon: const Icon(Icons.edit),
                  tooltip: textes.profilModifierInfobulle(profil.prenom),
                  onPressed: () => context.push('/profils/${profil.id}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
