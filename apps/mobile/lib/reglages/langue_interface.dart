import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stockage_reglages.dart';

/// Langue de l'interface (enfant et parent). Les exercices, eux, gardent la
/// langue de leur matière.
enum LangueInterface {
  ar,
  fr;

  Locale get locale => Locale(name);
}

/// Langue du premier lancement : la première langue arabe ou française de la
/// liste de l'appareil, sinon l'arabe.
///
/// `[es, fr]` donne le français, `[es, en]` donne l'arabe.
LangueInterface langueParDefaut(List<Locale> localesAppareil) {
  for (final locale in localesAppareil) {
    final langue = LangueInterface.values.asNameMap()[locale.languageCode];
    if (langue != null) return langue;
  }
  return LangueInterface.ar;
}

/// Langues préférées de l'appareil (surchargé dans les tests).
final localesAppareilProvider = Provider<List<Locale>>(
  (ref) => WidgetsBinding.instance.platformDispatcher.locales,
);

final langueInterfaceProvider =
    NotifierProvider<LangueInterfaceNotifier, LangueInterface>(
      LangueInterfaceNotifier.new,
    );

class LangueInterfaceNotifier extends Notifier<LangueInterface> {
  @override
  LangueInterface build() {
    final stockage = ref.watch(stockageReglagesProvider);
    final enregistree = LangueInterface.values
        .asNameMap()[stockage.lireLangue()];
    if (enregistree != null) return enregistree;

    // Premier lancement : on enregistre tout de suite le choix de l'appareil
    // pour qu'il ne change plus si la langue de l'appareil change ensuite.
    final langue = langueParDefaut(ref.watch(localesAppareilProvider));
    unawaited(stockage.ecrireLangue(langue.name));
    return langue;
  }

  /// Change la langue de l'interface et la mémorise.
  Future<void> choisir(LangueInterface langue) {
    state = langue;
    return ref.read(stockageReglagesProvider).ecrireLangue(langue.name);
  }
}
