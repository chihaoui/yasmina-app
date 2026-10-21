import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';

/// Bouton de l'espace parent (porte parentale), présent sur les écrans
/// racine : profils, langue et réglages y vivent (décisions 27, 28, 35), la
/// langue doit pouvoir changer dès le premier lancement.
class BoutonEspaceParent extends StatelessWidget {
  const BoutonEspaceParent({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: EspacesYasmina.space2),
    child: BoutonIcone(
      key: const ValueKey('espace_parent_ouvrir'),
      icone: Icons.lock_outline_rounded,
      libelle: AppLocalizations.of(context).espaceParentOuvrir,
      onPressed: () => context.push('/parent'),
    ),
  );
}

/// Écran d'attente pendant la lecture de la base.
class EcranChargement extends StatelessWidget {
  const EcranChargement({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
