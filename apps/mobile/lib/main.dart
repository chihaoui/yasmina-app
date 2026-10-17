import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  runApp(const ProviderScope(child: YasminaApp()));
}

class YasminaApp extends StatelessWidget {
  const YasminaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Yasmina',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: CarteDemo(langue: 'ar')),
      ),
    );
  }
}
