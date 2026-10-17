import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasmina/l10n/app_localizations.dart';
import 'package:yasmina/profils/avatar.dart';

void main() {
  test('8 avatars, codes stables, icônes et couleurs toutes différentes', () {
    expect(Avatar.values.map((a) => a.name), [
      'fleur',
      'soleil',
      'lune',
      'etoile',
      'arbre',
      'bateau',
      'chat',
      'nuage',
    ]);
    expect(Avatar.values.map((a) => a.icone).toSet(), hasLength(8));
    expect(Avatar.values.map((a) => a.couleur).toSet(), hasLength(8));
  });

  for (final langue in ['ar', 'fr']) {
    test('chaque avatar a un nom en $langue', () async {
      final textes = await AppLocalizations.delegate.load(Locale(langue));
      final noms = Avatar.values.map((a) => a.nom(textes)).toSet();
      expect(noms, hasLength(8));
    });
  }

  testWidgets("l'avatar est annoncé par son nom", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: AvatarVisuel(Avatar.nuage)),
      ),
    );
    expect(find.bySemanticsLabel('Nuage'), findsOneWidget);
  });
}
