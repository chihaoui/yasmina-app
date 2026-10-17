import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Bouton des réglages, présent sur les écrans racine (la langue doit
/// pouvoir changer dès le premier lancement).
class BoutonReglages extends StatelessWidget {
  const BoutonReglages({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.settings),
    tooltip: AppLocalizations.of(context).reglagesOuvrir,
    onPressed: () => context.push('/reglages'),
  );
}

/// Écran d'attente pendant la lecture de la base.
class EcranChargement extends StatelessWidget {
  const EcranChargement({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
