import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../parcours/matieres.dart';
import '../parcours/parcours.dart';
import '../parcours/progression.dart';
import '../parcours/progression_exemple.dart';
import '../profils/avatar.dart';
import '../profils/depot_profils.dart';

/// Menu développeur disponible : en debug et en profile, jamais en release
/// (CLAUDE.md §7). Surchargé dans les tests pour simuler la release.
final menuDevDisponibleProvider = Provider<bool>(
  (ref) => kDebugMode || kProfileMode,
);

/// Le « logo » des écrans racine (titre de la barre du haut) : un appui long
/// ouvre le menu développeur, seulement s'il est disponible.
class TitreAvecMenuDev extends ConsumerWidget {
  const TitreAvecMenuDev({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(menuDevDisponibleProvider)) return child;
    return GestureDetector(
      onLongPress: () => context.push('/dev'),
      child: child,
    );
  }
}

/// Profils de test de CLAUDE.md §7, en 1re année.
const _profilsDeTest = [
  (
    prenom: 'Lina',
    forme: FormeAdresse.feminin,
    avatar: Avatar.fleur,
    exemple: true,
  ),
  (
    prenom: 'Yassine',
    forme: FormeAdresse.masculin,
    avatar: Avatar.bateau,
    exemple: false,
  ),
];

/// Crée Lina (avec une progression d'exemple sur le parcours d'arabe 1re,
/// CLAUDE.md §7) et Yassine (vierge), sans doublon, et renvoie le bilan à
/// afficher.
Future<String> creerProfilsDeTest(
  DepotProfils depot, {
  DepotProgression? progression,
  CatalogueParcours? catalogue,
}) async {
  var crees = 0;
  final remarques = <String>[];
  for (final p in _profilsDeTest) {
    try {
      final profil = await depot.creer(
        prenom: p.prenom,
        niveau: 1,
        avatar: p.avatar,
        formeAdresse: p.forme,
      );
      crees++;
      if (p.exemple && progression != null) {
        await ecrireProgressionExemple(
          progression,
          profil.id,
          catalogue?.pour(matiere: Matiere.arabe.cle, niveau: 1),
        );
      }
    } on PrenomDejaUtilise {
      remarques.add('${p.prenom} existe déjà.');
    } on LimiteProfilsAtteinte {
      remarques.add(
        '${p.prenom} non créé : ${DepotProfils.maxProfils} profils au maximum.',
      );
    }
  }
  final bilan = switch (crees) {
    0 => 'Aucun profil créé.',
    1 => '1 profil créé.',
    _ => '$crees profils créés.',
  };
  return [bilan, ...remarques].join(' ');
}

/// Exemples de schema/exemples/, lus et validés au premier accès. Surchargé
/// dans les tests par des exemples en erreur.
final catalogueExemplesProvider = Provider<CatalogueExemples>(
  (ref) => CatalogueExemples(),
);
