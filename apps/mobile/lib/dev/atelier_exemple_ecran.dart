import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import 'atelier_type_ecran.dart';
import 'cadre_dev.dart';
import 'menu_dev.dart';
import 'zone_lecteur.dart';

/// Un exemple ouvert : résumé, choix du mode, zone du lecteur et JSON
/// formaté.
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

  @override
  Widget build(BuildContext context) {
    final type = typeParId(widget.idType);
    final exemple = ref
        .watch(catalogueExemplesProvider)
        .exemplesDuType(widget.idType)
        .where((e) => e.fichier == widget.fichier)
        .firstOrNull;
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
                      const SizedBox(height: EspacesYasmina.space4),
                      ZoneLecteur(type: type, exemple: exemple, mode: _mode),
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
