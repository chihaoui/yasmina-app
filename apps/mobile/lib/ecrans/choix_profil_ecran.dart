import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../composants/carte_profil.dart';
import '../dev/menu_dev.dart';
import '../donnees/base_yasmina.dart';
import '../l10n/app_localizations.dart';
import '../profils/depot_profils.dart';
import '../profils/libelles.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// « Qui joue ? » : un profil par carte, sans mot de passe. Les profils se
/// créent et se modifient dans l'espace parent (décision 28) : sans profil,
/// Yasmina y invite.
class ChoixProfilEcran extends ConsumerWidget {
  const ChoixProfilEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(profilsProvider)
        .when(
          data: (profils) =>
              profils.isEmpty ? const _Bienvenue() : _Choix(profils),
          loading: () => const EcranChargement(),
          error: (erreur, _) => Scaffold(body: Center(child: Text('$erreur'))),
        );
  }
}

/// Premier lancement, aucun profil : la porte parentale pour créer le
/// premier enfant.
class _Bienvenue extends StatelessWidget {
  const _Bienvenue();

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TitreAvecMenuDev(
          child: Text(textes.appTitre, key: const ValueKey('bienvenue_titre')),
        ),
        actions: const [BoutonEspaceParent()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YasminaBulle(
              texte: textes.bienvenueBulle,
              cleTexte: const ValueKey('bienvenue_bulle'),
            ),
            const SizedBox(height: EspacesYasmina.space8),
            BoutonYasmina(
              key: const ValueKey('bienvenue_parent'),
              libelle: textes.espaceParentOuvrir,
              icone: Icons.lock_outline_rounded,
              onPressed: () => context.push('/parent'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choix extends ConsumerWidget {
  const _Choix(this.profils);

  final List<ProfilEnfant> profils;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TitreAvecMenuDev(
          child: Text(
            textes.profilsTitre,
            key: const ValueKey('profils_titre'),
          ),
        ),
        actions: const [BoutonEspaceParent()],
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
                ),
            ],
          ),
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
