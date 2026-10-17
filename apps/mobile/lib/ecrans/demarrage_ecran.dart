import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Ouverture de l'app : un seul profil ouvre directement l'accueil, sinon
/// l'écran de choix (qui affiche la création si aucun profil n'existe).
class DemarrageEcran extends ConsumerStatefulWidget {
  const DemarrageEcran({super.key});

  @override
  ConsumerState<DemarrageEcran> createState() => _DemarrageEcranState();
}

class _DemarrageEcranState extends ConsumerState<DemarrageEcran> {
  @override
  void initState() {
    super.initState();
    _decider();
  }

  Future<void> _decider() async {
    final profils = await ref.read(depotProfilsProvider).lister();
    if (!mounted) return;
    if (profils.length == 1) {
      ref.read(profilActifProvider.notifier).choisir(profils.single.id);
      context.go('/accueil');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) => const EcranChargement();
}
