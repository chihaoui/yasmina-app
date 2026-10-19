import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ecrans/accueil_ecran.dart';
import '../ecrans/choix_profil_ecran.dart';
import '../ecrans/demarrage_ecran.dart';
import '../ecrans/profil_formulaire_ecran.dart';
import '../dev/menu_dev.dart';
import '../dev/menu_dev_ecran.dart';
import '../ecrans/reglages_ecran.dart';
import '../profils/profil_actif.dart';

/// Routes de l'app. Un routeur par ProviderScope (pas d'état partagé entre
/// tests).
final routeurProvider = Provider<GoRouter>((ref) {
  final menuDev = ref.watch(menuDevDisponibleProvider);
  final routeur = GoRouter(
    initialLocation: '/demarrage',
    redirect: (context, state) {
      // Menu développeur : jamais en release (CLAUDE.md §7).
      if (!menuDev && state.uri.path.startsWith('/dev')) return '/';
      // L'accueil exige un profil choisi.
      if (state.matchedLocation == '/accueil' &&
          ref.read(profilActifProvider) == null) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/demarrage',
        builder: (context, state) => const DemarrageEcran(),
      ),
      GoRoute(path: '/', builder: (context, state) => const ChoixProfilEcran()),
      GoRoute(
        path: '/profils/nouveau',
        builder: (context, state) => const ProfilFormulaireEcran(),
      ),
      GoRoute(
        path: '/profils/:id',
        builder: (context, state) => ProfilFormulaireEcran(
          profilId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/accueil',
        builder: (context, state) => const AccueilEcran(),
      ),
      GoRoute(
        path: '/reglages',
        builder: (context, state) => const ReglagesEcran(),
      ),
      if (menuDev)
        GoRoute(
          path: '/dev',
          builder: (context, state) => const MenuDevEcran(),
        ),
    ],
  );
  ref.onDispose(routeur.dispose);
  return routeur;
});
