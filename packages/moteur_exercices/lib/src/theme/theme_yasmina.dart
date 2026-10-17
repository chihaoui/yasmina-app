import 'package:flutter/material.dart';

import 'jetons_yasmina.g.dart';

/// Thème Material de l'app et de l'aperçu web, construit uniquement à partir
/// des jetons générés depuis docs/design-system/tokens.json.
///
/// Seul endroit, avec les jetons, où des valeurs visuelles sont écrites :
/// ailleurs, les widgets passent par le thème, [CouleursYasmina] et les
/// classes de jetons (garde-fou de tool/verifier.sh).
abstract final class ThemeYasmina {
  /// Thème de l'interface en [langue] (`ar` : famille kid, sinon latin).
  /// Le contenu des exercices garde sa police (LangueExercice).
  static ThemeData theme({
    required String langue,
    required Brightness luminosite,
  }) {
    final c = luminosite == Brightness.dark
        ? CouleursYasmina.sombre
        : CouleursYasmina.clair;
    final textes = textTheme(langue, c);

    final rayonMd = BorderRadius.circular(RayonsYasmina.radiusMd);
    final rayonXl = BorderRadius.circular(RayonsYasmina.radiusXl);
    final trait = BorderSide(color: c.line, width: TraitsYasmina.borderThick);
    const cibleMin = Size(EspacesYasmina.targetMin, EspacesYasmina.targetMin);

    return ThemeData(
      useMaterial3: true,
      brightness: luminosite,
      colorScheme: ColorScheme(
        brightness: luminosite,
        primary: c.blue,
        onPrimary: c.onAccent,
        primaryContainer: c.blueSoft,
        onPrimaryContainer: c.ink,
        secondary: c.olive,
        onSecondary: c.onAccent,
        secondaryContainer: c.blueSoft,
        onSecondaryContainer: c.ink,
        error: c.coral,
        onError: c.onAccent,
        errorContainer: c.coralSoft,
        onErrorContainer: c.ink,
        surface: c.surface,
        onSurface: c.ink,
        onSurfaceVariant: c.muted,
        surfaceContainerLowest: c.surface,
        surfaceContainerLow: c.surface,
        surfaceContainer: c.surface,
        surfaceContainerHigh: c.surface,
        surfaceContainerHighest: c.tile,
        outline: c.line,
        outlineVariant: c.line,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: c.screen,
      canvasColor: c.screen,
      dividerColor: c.line,
      textTheme: textes,
      iconTheme: IconThemeData(color: c.ink),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textes.titleLarge,
        iconTheme: IconThemeData(color: c.ink),
        actionsIconTheme: IconThemeData(color: c.ink),
        shape: Border(
          bottom: BorderSide(color: c.line, width: TraitsYasmina.borderThin),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radius2xl),
          side: BorderSide(color: c.line, width: TraitsYasmina.borderThin),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.blue,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.line,
          disabledForegroundColor: c.muted,
          minimumSize: cibleMin,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: EspacesYasmina.padButtonX,
            vertical: EspacesYasmina.padButtonY,
          ),
          shape: RoundedRectangleBorder(borderRadius: rayonXl),
          textStyle: textes.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.blue,
          minimumSize: cibleMin,
          shape: RoundedRectangleBorder(borderRadius: rayonMd),
          textStyle: textes.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.blue,
          minimumSize: cibleMin,
          side: BorderSide(color: c.blue, width: TraitsYasmina.borderThick),
          shape: RoundedRectangleBorder(borderRadius: rayonMd),
          textStyle: textes.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.ink,
          minimumSize: cibleMin,
          shape: RoundedRectangleBorder(borderRadius: rayonMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.tile,
        labelStyle: textes.bodyLarge!.copyWith(color: c.muted),
        floatingLabelStyle: textes.bodyLarge!.copyWith(color: c.blue),
        helperStyle: textes.bodySmall,
        counterStyle: textes.bodySmall,
        errorStyle: textes.bodySmall!.copyWith(color: c.coralText),
        border: OutlineInputBorder(borderRadius: rayonMd, borderSide: trait),
        enabledBorder: OutlineInputBorder(
          borderRadius: rayonMd,
          borderSide: trait,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rayonMd,
          borderSide: BorderSide(
            color: c.blue,
            width: TraitsYasmina.borderThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: rayonMd,
          borderSide: BorderSide(
            color: c.coral,
            width: TraitsYasmina.borderThick,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: rayonMd,
          borderSide: BorderSide(
            color: c.coral,
            width: TraitsYasmina.borderThick,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.tile,
        selectedColor: c.blueSoft,
        disabledColor: c.line,
        checkmarkColor: c.blue,
        labelStyle: textes.labelLarge!.copyWith(color: c.ink),
        side: WidgetStateBorderSide.resolveWith(
          (etats) => BorderSide(
            color: etats.contains(WidgetState.selected) ? c.blue : c.line,
            width: TraitsYasmina.borderThick,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusPill),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (etats) => etats.contains(WidgetState.selected) ? c.blue : c.muted,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.ink,
        textColor: c.ink,
        titleTextStyle: textes.bodyLarge,
        subtitleTextStyle: textes.bodySmall,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: rayonXl,
          side: BorderSide(color: c.line, width: TraitsYasmina.borderThin),
        ),
        titleTextStyle: textes.titleMedium,
        contentTextStyle: textes.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: textes.bodyLarge!.copyWith(color: c.screen),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.blue),
      dividerTheme: DividerThemeData(
        color: c.line,
        thickness: TraitsYasmina.borderThin,
      ),
      focusColor: c.blueSoft,
    );
  }

  /// Rôles Material reliés aux styles du design system. Interface arabe en
  /// famille kid, interface française en famille latin.
  static TextTheme textTheme(String langue, CouleursYasmina c) {
    final arabe = langue == 'ar';
    final base = Typography.material2021().black.apply(
      fontFamily: arabe
          ? StylesYasmina.option.fontFamily
          : StylesYasmina.latinBody.fontFamily,
      fontFamilyFallback: arabe
          ? StylesYasmina.option.fontFamilyFallback
          : StylesYasmina.latinBody.fontFamilyFallback,
      bodyColor: c.ink,
      displayColor: c.ink,
    );
    TextStyle encre(TextStyle style) => style.copyWith(color: c.ink);
    TextStyle discret(TextStyle style) => style.copyWith(color: c.muted);

    if (arabe) {
      return base.copyWith(
        headlineSmall: encre(StylesYasmina.bubble),
        titleLarge: encre(StylesYasmina.titleBar),
        titleMedium: encre(StylesYasmina.prompt),
        bodyLarge: encre(StylesYasmina.option),
        bodyMedium: encre(StylesYasmina.option),
        labelLarge: encre(StylesYasmina.option),
        bodySmall: discret(StylesYasmina.option),
      );
    }
    final bulleLatine = pourLangue(StylesYasmina.bubble, langue);
    return base.copyWith(
      headlineSmall: encre(bulleLatine),
      titleLarge: encre(StylesYasmina.latinPrompt),
      titleMedium: encre(StylesYasmina.latinPrompt),
      bodyLarge: encre(StylesYasmina.latinBody),
      bodyMedium: encre(StylesYasmina.latinBody),
      labelLarge: encre(StylesYasmina.latinLabel),
      bodySmall: discret(StylesYasmina.caption),
    );
  }

  /// [style] dans la famille de [langue] : inchangé en arabe (kid ou
  /// content), famille latin sinon (français, anglais).
  static TextStyle pourLangue(TextStyle style, String langue) => langue == 'ar'
      ? style
      : style.copyWith(
          fontFamily: StylesYasmina.latinBody.fontFamily,
          fontFamilyFallback: StylesYasmina.latinBody.fontFamilyFallback,
        );

  /// Langue du texte à cet endroit de l'arbre : celle de l'exercice sous un
  /// LangueExercice, sinon celle de l'interface (arabe par défaut).
  static String langueDe(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode ?? 'ar';
}

/// Accès court aux couleurs du thème : `context.couleurs.blue`.
extension ContexteYasmina on BuildContext {
  CouleursYasmina get couleurs =>
      Theme.of(this).extension<CouleursYasmina>() ?? CouleursYasmina.clair;
}
