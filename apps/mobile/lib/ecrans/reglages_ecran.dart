import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../reglages/langue_interface.dart';

/// Noms des langues, chacun écrit dans sa propre langue quelle que soit la
/// langue affichée.
const _nomsLangues = {
  LangueInterface.ar: ('الْعَرَبِيَّة', TextDirection.rtl),
  LangueInterface.fr: ('Français', TextDirection.ltr),
};

class ReglagesEcran extends ConsumerWidget {
  const ReglagesEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final langue = ref.watch(langueInterfaceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(textes.reglagesTitre)),
      body: ListView(
        children: [
          ListTile(
            title: Text(textes.reglageLangue),
            subtitle: Text(textes.reglageLangueAide),
          ),
          RadioGroup<LangueInterface>(
            groupValue: langue,
            onChanged: (choix) {
              if (choix != null) {
                ref.read(langueInterfaceProvider.notifier).choisir(choix);
              }
            },
            child: Column(
              children: [
                for (final MapEntry(key: valeur, value: (nom, sens))
                    in _nomsLangues.entries)
                  RadioListTile<LangueInterface>(
                    key: ValueKey('langue_${valeur.name}'),
                    value: valeur,
                    title: Text(nom, textDirection: sens),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
