import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/reglages/langue_interface.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

void main() {
  group('langueParDefaut', () {
    final cas = {
      'appareil en arabe': ([const Locale('ar', 'TN')], LangueInterface.ar),
      'appareil en français': ([const Locale('fr', 'FR')], LangueInterface.fr),
      'appareil en espagnol': ([const Locale('es', 'ES')], LangueInterface.ar),
      'liste vide': (<Locale>[], LangueInterface.ar),
      'espagnol puis français': (
        [const Locale('es'), const Locale('fr')],
        LangueInterface.fr,
      ),
      'espagnol puis anglais': (
        [const Locale('es'), const Locale('en')],
        LangueInterface.ar,
      ),
      'anglais, arabe puis français': (
        [const Locale('en'), const Locale('ar'), const Locale('fr')],
        LangueInterface.ar,
      ),
    };
    cas.forEach((nom, valeurs) {
      test(nom, () => expect(langueParDefaut(valeurs.$1), valeurs.$2));
    });
  });

  group('langueInterfaceProvider', () {
    ProviderContainer conteneur(
      StockageReglages stockage, {
      List<Locale> appareil = const [Locale('ar')],
    }) {
      final c = ProviderContainer(
        overrides: [
          stockageReglagesProvider.overrideWithValue(stockage),
          localesAppareilProvider.overrideWithValue(appareil),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test("la langue enregistrée l'emporte sur l'appareil", () {
      final c = conteneur(StockageMemoire('fr'));
      expect(c.read(langueInterfaceProvider), LangueInterface.fr);
    });

    test('premier lancement : langue de l\'appareil, enregistrée aussitôt', () {
      final stockage = StockageMemoire();
      final c = conteneur(
        stockage,
        appareil: const [Locale('es'), Locale('fr')],
      );
      expect(c.read(langueInterfaceProvider), LangueInterface.fr);
      expect(stockage.lireLangue(), 'fr');
    });

    test('valeur enregistrée inconnue : retour à la règle par défaut', () {
      final c = conteneur(StockageMemoire('de'));
      expect(c.read(langueInterfaceProvider), LangueInterface.ar);
    });

    test('le choix est mémorisé entre deux lancements', () async {
      final stockage = StockageMemoire();
      final premier = conteneur(stockage, appareil: const [Locale('ar')]);
      expect(premier.read(langueInterfaceProvider), LangueInterface.ar);
      await premier
          .read(langueInterfaceProvider.notifier)
          .choisir(LangueInterface.fr);
      expect(premier.read(langueInterfaceProvider), LangueInterface.fr);

      final second = conteneur(stockage, appareil: const [Locale('ar')]);
      expect(second.read(langueInterfaceProvider), LangueInterface.fr);
    });
  });
}
