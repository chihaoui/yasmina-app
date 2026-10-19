import 'dart:io';

import 'package:flutter/services.dart';

/// Charge les vraies polices du moteur (fonts/) et les icônes Material dans
/// le moteur de test, pour les goldens (sinon flutter_test dessine des
/// rectangles).
Future<void> chargerPolicesMoteur() async {
  const familles = {
    'NotoNaskhArabic': ['Regular', 'SemiBold', 'Bold'],
    'BalooBhaijaan2': ['Regular', 'SemiBold', 'Bold', 'ExtraBold'],
    'Andika': ['Regular', 'Bold'],
  };
  for (final MapEntry(key: fichier, value: styles) in familles.entries) {
    final chargeur = FontLoader('packages/moteur_exercices/$fichier');
    for (final style in styles) {
      chargeur.addFont(_lire('fonts/$fichier-$style.ttf'));
    }
    await chargeur.load();
  }
  final racineFlutter = Platform.environment['FLUTTER_ROOT'];
  if (racineFlutter != null) {
    await (FontLoader('MaterialIcons')..addFont(
          _lire(
            '$racineFlutter/bin/cache/artifacts/material_fonts/'
            'MaterialIcons-Regular.otf',
          ),
        ))
        .load();
  }
}

Future<ByteData> _lire(String chemin) async =>
    ByteData.sublistView(await File(chemin).readAsBytes());
