import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../plateforme/services_plateforme.dart';
import 'atelier_type_ecran.dart';
import 'cadre_dev.dart';
import 'menu_dev.dart';
import 'zone_lecteur.dart';

/// Un exemple ouvert : résumé, choix du mode et de la forme d'adresse,
/// zone du lecteur (avec le journal des événements) et JSON formaté.
class AtelierExempleEcran extends ConsumerStatefulWidget {
  const AtelierExempleEcran({
    super.key,
    required this.idType,
    required this.fichier,
  });

  final String idType;
  final String fichier;

  @override
  ConsumerState<AtelierExempleEcran> createState() =>
      _AtelierExempleEcranState();
}

class _AtelierExempleEcranState extends ConsumerState<AtelierExempleEcran> {
  ModeExercice _mode = ModeExercice.enfant;
  FormeAdresse _forme = FormeAdresse.masculin;

  /// Nom de la voix manquante, dans le bandeau d'avertissement.
  static const _nomsVoix = {'ar': 'arabe', 'fr': 'française', 'en': 'anglaise'};

  @override
  Widget build(BuildContext context) {
    final type = typeParId(widget.idType);
    final exemple = ref
        .watch(catalogueExemplesProvider)
        .exemplesDuType(widget.idType)
        .where((e) => e.fichier == widget.fichier)
        .firstOrNull;
    final services = ref.watch(servicesExerciceProvider);
    final jouable =
        type?.etat == EtatType.jouable && (exemple?.estValide ?? false);
    return CadreDev(
      child: Builder(
        builder: (context) {
          final textes = Theme.of(context).textTheme;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.fichier,
                key: const ValueKey('atelier_exemple_titre'),
              ),
            ),
            body: type == null || exemple == null
                ? Center(child: Text('Exemple ${widget.fichier} introuvable.'))
                : ListView(
                    padding: const EdgeInsetsDirectional.all(
                      EspacesYasmina.space6,
                    ),
                    children: [
                      CarteExemple(exemple: exemple),
                      const SizedBox(height: EspacesYasmina.space6),
                      SegmentedButton<ModeExercice>(
                        key: const ValueKey('atelier_mode'),
                        segments: const [
                          ButtonSegment(
                            value: ModeExercice.enfant,
                            label: Text('Enfant'),
                          ),
                          ButtonSegment(
                            value: ModeExercice.apercu,
                            label: Text('Aperçu'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (choix) =>
                            setState(() => _mode = choix.single),
                      ),
                      if (jouable) ...[
                        const SizedBox(height: EspacesYasmina.space3),
                        SegmentedButton<FormeAdresse>(
                          key: const ValueKey('atelier_forme'),
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
                        _VoixAbsente(
                          services: services,
                          langue: exemple.langue!,
                          nom: _nomsVoix[exemple.langue] ?? exemple.langue!,
                        ),
                      ],
                      const SizedBox(height: EspacesYasmina.space4),
                      ZoneLecteur(
                        // Une nouvelle partie à chaque mode ou forme.
                        key: ValueKey('zone_${_mode.name}_${_forme.name}'),
                        type: type,
                        exemple: exemple,
                        mode: _mode,
                        forme: _forme,
                        services: services,
                      ),
                      const SizedBox(height: EspacesYasmina.space8),
                      Text('JSON', style: textes.titleMedium),
                      const SizedBox(height: EspacesYasmina.space2),
                      SelectableText(
                        _jsonFormate(exemple),
                        key: const ValueKey('atelier_json'),
                        style: textes.bodyMedium,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  /// JSON indenté. Les textes ne sont jamais normalisés. Un JSON illisible
  /// est montré tel quel.
  static String _jsonFormate(ExempleType exemple) => exemple.exercice == null
      ? exemple.texte
      : const JsonEncoder.withIndent('  ').convert(exemple.exercice);
}

/// Avertissement de l'atelier quand l'appareil n'a pas de voix pour la
/// langue de l'exercice. L'enfant, lui, ne voit rien : le lecteur reste
/// utilisable sans audio.
class _VoixAbsente extends StatelessWidget {
  const _VoixAbsente({
    required this.services,
    required this.langue,
    required this.nom,
  });

  final ServicesExercice services;
  final String langue;
  final String nom;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return FutureBuilder<bool>(
      future: services.audio.voixDisponible(langue),
      builder: (context, voix) {
        if (voix.data != false) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: EspacesYasmina.space3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.amberSoft,
              borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
              child: Text(
                'Aucune voix $nom sur cet appareil : la consigne ne sera pas '
                'lue. L\'exercice reste jouable.',
                key: const ValueKey('atelier_voix_absente'),
                style: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: c.amberText),
              ),
            ),
          ),
        );
      },
    );
  }
}
