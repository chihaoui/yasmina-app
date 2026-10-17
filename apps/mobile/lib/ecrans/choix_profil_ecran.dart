import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../composants/carte_profil.dart';
import '../donnees/base_yasmina.dart';
import '../l10n/app_localizations.dart';
import '../profils/depot_profils.dart';
import '../profils/libelles.dart';
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

class _Choix extends ConsumerWidget {
  const _Choix(this.profils);

  final List<ProfilEnfant> profils;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final limiteAtteinte = profils.length >= DepotProfils.maxProfils;
    return Scaffold(
      appBar: AppBar(
        title: Text(textes.profilsTitre, key: const ValueKey('profils_titre')),
        actions: const [BoutonReglages()],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        children: [
          _Grille(
            enfants: [
              for (final p in profils)
                CarteProfil(
                  key: ValueKey('profil_${p.id}'),
                  prenom: p.prenom,
                  niveau: libelleNiveau(textes, p.niveau),
                  avatar: p.avatar,
                  onTap: () {
                    ref.read(profilActifProvider.notifier).choisir(p.id);
                    context.go('/accueil');
                  },
                  action: BoutonIcone(
                    key: ValueKey('profil_modifier_${p.id}'),
                    icone: Icons.edit_rounded,
                    libelle: textes.profilModifierInfobulle(p.prenom),
                    onPressed: () => context.push('/profils/${p.id}'),
                  ),
                ),
              if (!limiteAtteinte)
                CarteAjoutProfil(
                  key: const ValueKey('profils_ajouter'),
                  libelle: textes.profilsAjouter,
                  onTap: () => context.push('/profils/nouveau'),
                ),
            ],
          ),
          if (limiteAtteinte) ...[
            const SizedBox(height: EspacesYasmina.space8),
            Text(
              textes.profilsLimite,
              key: const ValueKey('profils_limite'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Grille de 3 colonnes dont chaque ligne prend la hauteur de sa plus haute
/// carte.
class _Grille extends StatelessWidget {
  const _Grille({required this.enfants});

  static const _colonnes = 3;

  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final lignes = [
      for (var i = 0; i < enfants.length; i += _colonnes)
        enfants.sublist(i, (i + _colonnes).clamp(0, enfants.length)),
    ];
    return Column(
      spacing: EspacesYasmina.space3,
      children: [
        for (final ligne in lignes)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: EspacesYasmina.space3,
              children: [
                for (var i = 0; i < _colonnes; i++)
                  Expanded(
                    child: i < ligne.length ? ligne[i] : const SizedBox(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
