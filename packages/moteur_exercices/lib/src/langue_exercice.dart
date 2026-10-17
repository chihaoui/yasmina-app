import 'package:flutter/widgets.dart';

/// Frontière entre l'interface de l'app et un exercice.
///
/// Tout ce qui est en dessous suit la langue de l'exercice (champ `langue` du
/// JSON) : sens d'écriture et locale, quelle que soit la langue de
/// l'interface. Ce widget ne lit jamais la locale ambiante de l'app.
class LangueExercice extends StatelessWidget {
  const LangueExercice({super.key, required this.langue, required this.child});

  /// Code de langue de l'exercice : `ar`, `fr` ou `en`.
  final String langue;

  final Widget child;

  /// Sens d'écriture d'une langue d'exercice.
  static TextDirection directionDe(String langue) =>
      langue == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    // Le Directionality est placé sous Localizations.override, qui pose le
    // sien : c'est donc toujours celui de l'exercice qui s'applique.
    final contenu = Directionality(
      textDirection: directionDe(langue),
      child: child,
    );
    // Sans Localizations au-dessus (test nu, widget isolé), pas de locale à
    // remplacer.
    if (Localizations.maybeLocaleOf(context) == null) return contenu;
    return Localizations.override(
      context: context,
      locale: Locale(langue),
      child: contenu,
    );
  }
}
