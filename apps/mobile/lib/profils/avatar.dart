import 'package:flutter/material.dart';

import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';

/// Avatars au choix, liste fixe. Les noms sont les codes stockés en base :
/// ne jamais les renommer ni en retirer sans migration des données.
enum Avatar {
  fleur(Icons.local_florist),
  soleil(Icons.wb_sunny),
  lune(Icons.nightlight_round),
  etoile(Icons.star),
  arbre(Icons.park),
  bateau(Icons.sailing),
  chat(Icons.pets),
  nuage(Icons.cloud);

  const Avatar(this.icone);

  /// Visuel provisoire, en attendant les illustrations.
  final IconData icone;

  /// Nom affiché et lu par les lecteurs d'écran.
  String nom(AppLocalizations textes) => switch (this) {
    fleur => textes.avatarFleur,
    soleil => textes.avatarSoleil,
    lune => textes.avatarLune,
    etoile => textes.avatarEtoile,
    arbre => textes.avatarArbre,
    bateau => textes.avatarBateau,
    chat => textes.avatarChat,
    nuage => textes.avatarNuage,
  };
}

/// Avatar affiché (placeholder de la démo : disque blue-soft et icône blue,
/// pareil pour tous). Seul ce widget changera à l'arrivée des illustrations,
/// les codes en base restent.
class AvatarVisuel extends StatelessWidget {
  const AvatarVisuel(
    this.avatar, {
    super.key,
    this.taille = TaillesYasmina.avatarCard,
  });

  final Avatar avatar;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Semantics(
      image: true,
      label: avatar.nom(AppLocalizations.of(context)),
      child: ExcludeSemantics(
        child: Container(
          width: taille,
          height: taille,
          decoration: BoxDecoration(color: c.blueSoft, shape: BoxShape.circle),
          child: Icon(avatar.icone, color: c.blue, size: taille / 2),
        ),
      ),
    );
  }
}
