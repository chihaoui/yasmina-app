import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  Future<void> afficher(WidgetTester tester, String langue) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: CarteDemo(langue: langue)),
      ),
    );
  }

  TextDirection directionDu(WidgetTester tester) {
    return Directionality.of(
      tester.element(find.byKey(const ValueKey('carte_demo_nom'))),
    );
  }

  testWidgets('arabe : texte arabe, de droite à gauche', (tester) async {
    await afficher(tester, 'ar');
    expect(find.text('ياسمينة'), findsOneWidget);
    expect(directionDu(tester), TextDirection.rtl);
  });

  testWidgets('français : texte français, de gauche à droite', (tester) async {
    await afficher(tester, 'fr');
    expect(find.text('Yasmina'), findsOneWidget);
    expect(directionDu(tester), TextDirection.ltr);
  });
}
