import 'package:flutter/widgets.dart';

import '../langue_exercice.dart';
import '../theme/jetons_yasmina.g.dart';

/// Widget de démonstration : vérifie que le même code s'affiche
/// dans l'app mobile et dans l'aperçu web.
///
/// Tout le contenu suit la langue reçue, sens d'écriture compris (via
/// [LangueExercice]).
class CarteDemo extends StatelessWidget {
  const CarteDemo({super.key, required this.langue});

  /// Code de langue : `ar` ou `fr`.
  final String langue;

  static const _textes = {
    'ar': (nom: 'يَاسْمِينَة', message: 'مَرْحَبًا! هَيَّا نَتَعَلَّمُ مَعًا.'),
    'fr': (nom: 'Yasmina', message: 'Bonjour ! On apprend ensemble.'),
  };

  @override
  Widget build(BuildContext context) {
    final textes = _textes[langue] ?? _textes['ar']!;
    final arabe = langue == 'ar';
    return LangueExercice(
      langue: langue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textes.nom,
            key: const ValueKey('carte_demo_nom'),
            style: arabe
                ? StylesYasmina.contentWord
                : StylesYasmina.latinPrompt,
          ),
          const SizedBox(height: EspacesYasmina.space2),
          Text(
            textes.message,
            key: const ValueKey('carte_demo_message'),
            textAlign: TextAlign.center,
            style: arabe
                ? StylesYasmina.contentSentence
                : StylesYasmina.latinBody,
          ),
        ],
      ),
    );
  }
}
