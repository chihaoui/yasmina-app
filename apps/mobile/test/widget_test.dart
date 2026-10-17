import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/main.dart';

void main() {
  testWidgets("l'app mobile affiche la carte du moteur", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YasminaApp()));
    expect(find.byType(CarteDemo), findsOneWidget);
    expect(find.text('ياسمينة'), findsOneWidget);
  });
}
