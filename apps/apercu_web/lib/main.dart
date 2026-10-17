import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  runApp(const ProviderScope(child: ApercuApp()));
}

class ApercuApp extends StatelessWidget {
  const ApercuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Aperçu Yasmina',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFE0E0E0),
        body: Center(
          child: CadreTelephone(child: CarteDemo(langue: 'ar')),
        ),
      ),
    );
  }
}

/// Cadre de téléphone simple autour de l'exercice joué.
class CadreTelephone extends StatelessWidget {
  const CadreTelephone({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 740,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: Colors.white,
          child: Center(child: child),
        ),
      ),
    );
  }
}
