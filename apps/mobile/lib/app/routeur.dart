import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ecrans/accueil_ecran.dart';
import '../ecrans/reglages_ecran.dart';

/// Routes de l'app. Un routeur par ProviderScope (pas d'état partagé entre
/// tests).
final routeurProvider = Provider<GoRouter>((ref) {
  final routeur = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AccueilEcran()),
      GoRoute(
        path: '/reglages',
        builder: (context, state) => const ReglagesEcran(),
      ),
    ],
  );
  ref.onDispose(routeur.dispose);
  return routeur;
});
