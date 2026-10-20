import 'dart:convert';

import 'package:edu_content/edu_content.dart';

/// Exemple réel de schema/exemples/trace/.
Map<String, dynamic> exempleTrace(String fichier) =>
    jsonDecode(exemplesEduContent['trace/$fichier']!) as Map<String, dynamic>;
