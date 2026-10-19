import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  test('audio factice : textes dits et voix disponibles par langue', () async {
    final services = ServicesFactices(voix: {'fr'});
    expect(await services.audio.voixDisponible('fr'), isTrue);
    expect(await services.audio.voixDisponible('ar'), isFalse);
    await services.audio.dire('Bonjour', langue: 'fr');
    await services.audio.arreter();
    expect(services.audioFactice.dits.single, (texte: 'Bonjour', langue: 'fr'));
    expect(services.audioFactice.arrets, 1);
    await services.audio.jouerSon(SonInterface.juste);
    expect(services.audioFactice.sons, [SonInterface.juste]);
  });

  test('vibration et assets factices', () async {
    final services = ServicesFactices();
    await services.vibration.legere();
    expect(services.vibrationFactice.legeres, 1);
    final assets = AssetsFactices({'images/a.png': Uint8List(3)});
    expect(await assets.lire('images/a.png'), hasLength(3));
    expect(await assets.lire('images/b.png'), isNull);
  });

  testWidgets('ServicesExercice.of lit les services posés au-dessus', (
    tester,
  ) async {
    final services = ServicesFactices();
    late ServicesExercice lus;
    await tester.pumpWidget(
      PorteurServices(
        services: services,
        child: Builder(
          builder: (context) {
            lus = ServicesExercice.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(lus, same(services));
  });
}
