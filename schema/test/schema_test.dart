import 'dart:convert';

import 'package:edu_content/edu_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le schéma embarqué se décode et annonce edu-content/1.0', () {
    final schema = jsonDecode(texteSchemaEduContent) as Map<String, dynamic>;
    expect(schema[r'$schema'], contains('2020-12'));
    expect(schema['title'], versionSchemaEduContent);
    expect(
      schema[r'$defs']['generation']['properties']['schema']['const'],
      versionSchemaEduContent,
    );
  });
}
