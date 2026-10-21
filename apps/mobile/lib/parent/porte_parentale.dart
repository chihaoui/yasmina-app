import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Une question de la porte parentale : une multiplication à résoudre.
class QuestionPorte {
  const QuestionPorte(this.a, this.b);

  final int a;
  final int b;

  int get reponse => a * b;

  /// Vrai si [saisie] (texte du champ) est la réponse.
  bool verifier(String saisie) => int.tryParse(saisie.trim()) == reponse;
}

/// Porte parentale simple (A3-04) : une multiplication tirée entre [min] et
/// [max], comme l'exigent les stores pour les apps enfants. Configurable
/// (bornes, ou autre porte plus tard) par [porteParentaleProvider].
class PorteParentale {
  const PorteParentale({this.min = 3, this.max = 9});

  final int min;
  final int max;

  QuestionPorte tirer(Random alea) => QuestionPorte(
    min + alea.nextInt(max - min + 1),
    min + alea.nextInt(max - min + 1),
  );
}

final porteParentaleProvider = Provider<PorteParentale>(
  (ref) => const PorteParentale(),
);

/// La question posée à chaque ouverture de la porte (nouvelle question à
/// chaque visite). Surchargée dans les tests par une question fixe.
final questionPorteProvider = Provider.autoDispose<QuestionPorte>(
  (ref) => ref.watch(porteParentaleProvider).tirer(Random()),
);

/// Porte ouverte pour la session : l'espace parent reste accessible jusqu'à
/// « Quitter » ou la fermeture de l'app.
final porteOuverteProvider = NotifierProvider<PorteOuverteNotifier, bool>(
  PorteOuverteNotifier.new,
);

class PorteOuverteNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void ouvrir() => state = true;

  void fermer() => state = false;
}
