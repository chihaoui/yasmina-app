import 'package:flutter/material.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Les écrans de développement sont des outils internes : toujours en
/// français et de gauche à droite, quelle que soit la langue de
/// l'interface, avec la luminosité courante.
class CadreDev extends StatelessWidget {
  const CadreDev({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeYasmina.theme(
      langue: 'fr',
      luminosite: Theme.of(context).brightness,
    );
    return Localizations.override(
      context: context,
      locale: const Locale('fr'),
      child: Theme(data: theme, child: child),
    );
  }
}
