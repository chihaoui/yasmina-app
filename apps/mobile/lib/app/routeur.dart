import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dev/atelier_ecran.dart';
import '../dev/atelier_exemple_ecran.dart';
import '../dev/atelier_type_ecran.dart';
import '../dev/menu_dev.dart';
import '../dev/menu_dev_ecran.dart';
import '../ecrans/accueil_ecran.dart';
import '../ecrans/choix_profil_ecran.dart';
import '../ecrans/demarrage_ecran.dart';
import '../ecrans/profil_formulaire_ecran.dart';
import '../ecrans/reglages_ecran.dart';
import '../ecrans/sequence_ecran.dart';
import '../ecrans/serie_ecran.dart';
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
      // L'accueil et la séquence de test exigent un profil choisi.
      final chemin = state.matchedLocation;
      if ((chemin == '/accueil' || chemin.startsWith('/sequence')) &&
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
      // Séquence de test du tour 1 (A1-22) : séries, puis une série jouée.
      GoRoute(
        path: '/sequence',
        builder: (context, state) => const SequenceEcran(),
        routes: [
          GoRoute(
            path: ':serie',
            builder: (context, state) =>
                SerieEcran(idSerie: state.pathParameters['serie']!),
          ),
        ],
      ),
      if (menuDev)
        GoRoute(
          path: '/dev',
          builder: (context, state) => const MenuDevEcran(),
          routes: [
            GoRoute(
              path: 'atelier',
              builder: (context, state) => const AtelierEcran(),
              routes: [
                GoRoute(
                  path: ':type',
                  builder: (context, state) =>
                      AtelierTypeEcran(idType: state.pathParameters['type']!),
                  routes: [
                    GoRoute(
                      path: ':exemple',
                      builder: (context, state) => AtelierExempleEcran(
                        idType: state.pathParameters['type']!,
                        fichier: state.pathParameters['exemple']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
    ],
  );
  ref.onDispose(routeur.dispose);
  return routeur;
});
