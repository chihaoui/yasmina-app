import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

/// Rapport de contraste WCAG entre deux couleurs.
double contraste(Color a, Color b) {
  final (la, lb) = (a.computeLuminance(), b.computeLuminance());
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  final themes = {
    'clair': CouleursYasmina.clair,
    'sombre': CouleursYasmina.sombre,
  };

  themes.forEach((nom, c) {
    group('contrastes du thème $nom (texte : 4,5:1 au minimum)', () {
      final paires = {
        'ink sur screen': (c.ink, c.screen),
        'ink sur surface': (c.ink, c.surface),
        'ink sur tile': (c.ink, c.tile),
        'ink sur blue-soft': (c.ink, c.blueSoft),
        'muted sur screen': (c.muted, c.screen),
        'muted sur surface': (c.muted, c.surface),
        'muted sur tile': (c.muted, c.tile),
        'muted sur bg': (c.muted, c.bg),
        'blue sur surface': (c.blue, c.surface),
        'blue sur blue-soft': (c.blue, c.blueSoft),
        'on-accent sur blue': (c.onAccent, c.blue),
        'olive-text sur olive-soft': (c.oliveText, c.oliveSoft),
        'amber-text sur amber-soft': (c.amberText, c.amberSoft),
        'coral-text sur coral-soft': (c.coralText, c.coralSoft),
        'coral-text sur surface': (c.coralText, c.surface),
      };
      paires.forEach((paire, couleurs) {
        test(paire, () {
          expect(
            contraste(couleurs.$1, couleurs.$2),
            greaterThanOrEqualTo(4.5),
          );
        });
      });

      test('on-accent sur olive : 3:1 au minimum (grand texte gras)', () {
        expect(contraste(c.onAccent, c.olive), greaterThanOrEqualTo(3));
      });
    });
  });

  test('la mascotte et les matières ne changent pas en sombre', () {
    final (clair, sombre) = (CouleursYasmina.clair, CouleursYasmina.sombre);
    expect(sombre.yasminaPetal, clair.yasminaPetal);
    expect(sombre.yasminaInk, clair.yasminaInk);
    expect(sombre.yasminaCheek, clair.yasminaCheek);
    expect(sombre.subjectAr, clair.subjectAr);
    expect(sombre.seq1, clair.seq1);
  });

  group('ThemeData', () {
    test('couleurs du thème clair et du thème sombre en extension', () {
      for (final (luminosite, attendu) in [
        (Brightness.light, CouleursYasmina.clair),
        (Brightness.dark, CouleursYasmina.sombre),
      ]) {
        final theme = ThemeYasmina.theme(langue: 'ar', luminosite: luminosite);
        expect(theme.brightness, luminosite);
        expect(theme.extension<CouleursYasmina>(), attendu);
        expect(theme.colorScheme.primary, attendu.blue);
        expect(theme.colorScheme.onPrimary, attendu.onAccent);
        expect(theme.scaffoldBackgroundColor, attendu.screen);
      }
    });

    test('interface arabe : famille kid, styles du design system', () {
      final textes = ThemeYasmina.theme(
        langue: 'ar',
        luminosite: Brightness.light,
      ).textTheme;
      for (final style in [
        textes.titleLarge!,
        textes.titleMedium!,
        textes.bodyLarge!,
        textes.labelLarge!,
        textes.displayLarge!,
      ]) {
        expect(style.fontFamily, PolicesYasmina.interfaceArabe);
      }
      expect(textes.titleLarge!.fontSize, StylesYasmina.titleBar.fontSize);
      expect(textes.headlineSmall!.fontSize, StylesYasmina.bubble.fontSize);
      expect(textes.bodySmall!.color, CouleursYasmina.clair.muted);
    });

    test('interface française : famille latin, styles du design system', () {
      final textes = ThemeYasmina.theme(
        langue: 'fr',
        luminosite: Brightness.dark,
      ).textTheme;
      for (final style in [
        textes.headlineSmall!,
        textes.titleLarge!,
        textes.bodyLarge!,
        textes.labelLarge!,
        textes.displayLarge!,
      ]) {
        expect(style.fontFamily, PolicesYasmina.latin);
      }
      expect(textes.bodyLarge!.fontSize, StylesYasmina.latinBody.fontSize);
      expect(textes.bodyLarge!.color, CouleursYasmina.sombre.ink);
      expect(textes.bodySmall!.fontSize, StylesYasmina.caption.fontSize);
    });

    testWidgets('context.couleurs lit l\'extension du thème', (tester) async {
      late CouleursYasmina lues;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeYasmina.theme(langue: 'fr', luminosite: Brightness.dark),
          home: Builder(
            builder: (context) {
              lues = context.couleurs;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(lues, CouleursYasmina.sombre);
    });
  });
}
