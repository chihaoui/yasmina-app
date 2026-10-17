import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';
import 'package:yasmina/main.dart';
import 'package:yasmina/reglages/stockage_reglages.dart';

void main() {
  testWidgets("l'app mobile affiche la carte du moteur", (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockageReglagesProvider.overrideWithValue(StockageMemoire('ar')),
        ],
        child: const YasminaApp(),
      ),
    );
    expect(find.byType(CarteDemo), findsOneWidget);
    expect(find.text('ياسمينة'), findsOneWidget);
  });
}
