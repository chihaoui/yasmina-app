import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

void main() {
  enregistrerLicencesPolices();
  runApp(const ProviderScope(child: ApercuApp()));
}

/// Exemples de schema/exemples/ joués par l'aperçu (même source que l'app
/// et les tests), dans l'ordre du catalogue.
final catalogueApercuProvider = Provider<CatalogueExemples>(
  (ref) => CatalogueExemples(),
);

/// Services de l'aperçu web : factices jusqu'à l'implémentation web
/// (A0-15). Aucune voix, aucun son : le lecteur reste jouable.
final servicesApercuProvider = Provider<ServicesExercice>(
  (ref) => ServicesFactices(),
);

class ApercuApp extends StatelessWidget {
  const ApercuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Même thème que l'app mobile, clair ou sombre selon le système.
    return MaterialApp(
      title: 'Aperçu Yasmina',
      debugShowCheckedModeBanner: false,
      // Localisation Material (champ de saisie système de T17), interface
      // de l'aperçu en français.
      locale: const Locale('fr'),
      supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeYasmina.theme(langue: 'fr', luminosite: Brightness.light),
      darkTheme: ThemeYasmina.theme(langue: 'fr', luminosite: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const ApercuExercice(),
    );
  }
}

/// Un exemple du catalogue joué dans un cadre de téléphone, en mode aperçu
/// (afficher la réponse, rejouer). Le choix de l'exemple, en français,
/// tient lieu de page hôte en attendant le chargement d'un JSON (A0-15).
class ApercuExercice extends ConsumerStatefulWidget {
  const ApercuExercice({super.key});

  @override
  ConsumerState<ApercuExercice> createState() => _ApercuExerciceState();
}

class _ApercuExerciceState extends ConsumerState<ApercuExercice> {
  String? _chemin;
  FormeAdresse _forme = FormeAdresse.masculin;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final jouables = ref
        .watch(catalogueApercuProvider)
        .tous
        .where(
          (e) =>
              e.estValide &&
              typeParId(e.idType ?? '')?.etat == EtatType.jouable,
        )
        .toList();
    final exemple =
        jouables.where((e) => e.chemin == _chemin).firstOrNull ??
        jouables.firstOrNull;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: EspacesYasmina.space4,
            children: [
              Wrap(
                spacing: EspacesYasmina.space3,
                runSpacing: EspacesYasmina.space2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownMenu<String>(
                    key: const ValueKey('apercu_exemple'),
                    initialSelection: exemple?.chemin,
                    label: const Text('Exemple'),
                    dropdownMenuEntries: [
                      for (final e in jouables)
                        DropdownMenuEntry(
                          value: e.chemin,
                          label: '${e.idType}  ${e.fichier}',
                        ),
                    ],
                    onSelected: (chemin) => setState(() => _chemin = chemin),
                  ),
                  SegmentedButton<FormeAdresse>(
                    key: const ValueKey('apercu_forme'),
                    segments: const [
                      ButtonSegment(
                        value: FormeAdresse.masculin,
                        label: Text('Masculin'),
                      ),
                      ButtonSegment(
                        value: FormeAdresse.feminin,
                        label: Text('Féminin'),
                      ),
                    ],
                    selected: {_forme},
                    onSelectionChanged: (choix) =>
                        setState(() => _forme = choix.single),
                  ),
                ],
              ),
              CadreTelephone(
                child: exemple == null
                    ? const Text('Aucun exemple jouable.')
                    : LecteurExercice(
                        key: ValueKey('${exemple.chemin}_${_forme.name}'),
                        exercice: exemple.exercice!,
                        config: ConfigExercice(
                          langue: exemple.langue!,
                          formeAdresse: _forme,
                          mode: ModeExercice.apercu,
                        ),
                        services: ref.watch(servicesApercuProvider),
                      ),
              ),
            ],
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
            child: child,
          ),
        ),
      ),
    );
  }
}
