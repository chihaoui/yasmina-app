import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Avatars au choix, liste fixe. Les noms sont les codes stockés en base :
/// ne jamais les renommer ni en retirer sans migration des données.
enum Avatar {
  fleur(Icons.local_florist, Color(0xFFC2185B)),
  soleil(Icons.wb_sunny, Color(0xFFE65100)),
  lune(Icons.nightlight_round, Color(0xFF3949AB)),
  etoile(Icons.star, Color(0xFF8E24AA)),
  arbre(Icons.park, Color(0xFF2E7D32)),
  bateau(Icons.sailing, Color(0xFF0277BD)),
  chat(Icons.pets, Color(0xFF6D4C41)),
  nuage(Icons.cloud, Color(0xFF00838F));

  const Avatar(this.icone, this.couleur);

  /// Visuel provisoire, en attendant les illustrations.
  final IconData icone;
  final Color couleur;

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

/// Avatar affiché (placeholder : disque de couleur et icône). Seul ce widget
/// changera à l'arrivée des illustrations, les codes en base restent.
class AvatarVisuel extends StatelessWidget {
  const AvatarVisuel(this.avatar, {super.key, this.taille = 64});

  final Avatar avatar;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: avatar.nom(AppLocalizations.of(context)),
      child: ExcludeSemantics(
        child: Container(
          width: taille,
          height: taille,
          decoration: BoxDecoration(
            color: avatar.couleur,
            shape: BoxShape.circle,
          ),
          child: Icon(avatar.icone, color: Colors.white, size: taille * 0.55),
        ),
      ),
    );
  }
}
