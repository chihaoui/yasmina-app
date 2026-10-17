import 'package:apercu_web/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  testWidgets("l'aperçu web affiche la carte du moteur", (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: ApercuApp()));
    expect(find.byType(CadreTelephone), findsOneWidget);
    expect(find.byType(CarteDemo), findsOneWidget);
    expect(find.text('يَاسْمِينَة'), findsOneWidget);
  });
}
