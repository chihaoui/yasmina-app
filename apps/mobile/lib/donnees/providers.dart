import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_yasmina.dart';

/// Surchargé dans `main()` par la base SQLite de l'appareil et dans les
/// tests par une base en mémoire.
final baseYasminaProvider = Provider<BaseYasmina>(
  (ref) => throw UnimplementedError('baseYasminaProvider non surchargé'),
);
