import 'package:flutter/widgets.dart';

/// Widget de démonstration : vérifie que le même code s'affiche
/// dans l'app mobile et dans l'aperçu web.
///
/// Tout le contenu suit la langue reçue, sens d'écriture compris.
class CarteDemo extends StatelessWidget {
  const CarteDemo({super.key, required this.langue});

  /// Code de langue : `ar` ou `fr`.
  final String langue;

  static const _textes = {
    'ar': (nom: 'ياسمينة', message: 'مرحبا! هيا نتعلم معا.'),
    'fr': (nom: 'Yasmina', message: 'Bonjour ! On apprend ensemble.'),
  };

  bool get _estArabe => langue == 'ar';

  @override
  Widget build(BuildContext context) {
    final textes = _textes[langue] ?? _textes['ar']!;
    return Directionality(
      textDirection: _estArabe ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textes.nom,
            key: const ValueKey('carte_demo_nom'),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            textes.message,
            key: const ValueKey('carte_demo_message'),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
