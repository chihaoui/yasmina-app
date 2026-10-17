import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profil qui joue en ce moment (id), en mémoire seulement : le choix se
/// refait à chaque ouverture de l'app.
final profilActifProvider = NotifierProvider<ProfilActifNotifier, int?>(
  ProfilActifNotifier.new,
);

class ProfilActifNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void choisir(int id) => state = id;

  void oublier() => state = null;
}
