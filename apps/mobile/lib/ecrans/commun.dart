import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';

/// Bouton des réglages, présent sur les écrans racine (la langue doit
/// pouvoir changer dès le premier lancement).
class BoutonReglages extends StatelessWidget {
  const BoutonReglages({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: EspacesYasmina.space2),
    child: BoutonIcone(
      icone: Icons.settings_rounded,
      libelle: AppLocalizations.of(context).reglagesOuvrir,
      onPressed: () => context.push('/reglages'),
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
