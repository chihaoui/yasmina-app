import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  enregistrerLicencesPolices();
  runApp(const ProviderScope(child: ApercuApp()));
}

class ApercuApp extends StatelessWidget {
  const ApercuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Même thème que l'app mobile, clair ou sombre selon le système.
    return MaterialApp(
      title: 'Aperçu Yasmina',
      debugShowCheckedModeBanner: false,
      theme: ThemeYasmina.theme(langue: 'ar', luminosite: Brightness.light),
      darkTheme: ThemeYasmina.theme(langue: 'ar', luminosite: Brightness.dark),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: context.couleurs.bg,
          body: const Center(
            child: CadreTelephone(child: CarteDemo(langue: 'ar')),
          ),
        ),
      ),
    );
  }
}

/// Cadre de téléphone autour de l'exercice joué : un écran de
/// frame-width × frame-height sur fond screen.
class CadreTelephone extends StatelessWidget {
  const CadreTelephone({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Container(
      padding: const EdgeInsets.all(EspacesYasmina.space4),
      decoration: BoxDecoration(
        color: c.frame,
        borderRadius: BorderRadius.circular(RayonsYasmina.radiusFrameOuter),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RayonsYasmina.radiusFrameInner),
        child: ColoredBox(
          color: c.screen,
          child: SizedBox(
            width: TaillesYasmina.frameWidth,
            height: TaillesYasmina.frameHeight,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
