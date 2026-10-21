import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../composants/progression_sequences.dart';
import '../l10n/app_localizations.dart';
import '../parcours/matieres.dart';
import '../parcours/parcours.dart';
import '../parcours/progression.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Intro d'une étape (A3-02) : Yasmina, la lettre et ses formes (ou 🏆),
/// les séquences avec leur nombre d'exercices, puis Commencer (Rejouer si
/// l'étape est faite).
class EtapeIntroEcran extends ConsumerWidget {
  const EtapeIntroEcran({super.key, required this.code, required this.etapeId});

  final String code;
  final String etapeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final matiere = Matiere.parCode(code);
    final id = ref.watch(profilActifProvider);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final profil = profils.where((p) => p.id == id).firstOrNull;
    final catalogue = ref.watch(catalogueParcoursProvider).value;
    if (matiere == null || profil == null || catalogue == null) {
      return const EcranChargement();
    }
    final etape = catalogue
        .pour(matiere: matiere.cle, niveau: profil.niveau)
        ?.etape(etapeId);
    if (etape == null) return const EcranChargement();
    final faite =
        ref.watch(etapesFaitesProvider(profil.id)).value?.contains(etapeId) ??
        false;
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    final sens = LangueExercice.directionDe(etape.langue);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          etape.titre,
          key: const ValueKey('intro_titre'),
          textDirection: sens,
        ),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        children: [
          YasminaBulle(
            texte: textes.introBulle,
            cleTexte: const ValueKey('intro_bulle'),
          ),
          const SizedBox(height: EspacesYasmina.space6),
          Text(
            etape.estDefi ? '🏆' : etape.lettre,
            key: const ValueKey('intro_lettre'),
            textAlign: TextAlign.center,
            textDirection: sens,
            style: ThemeYasmina.pourLangue(
              StylesYasmina.letterHero,
              etape.langue,
            ).copyWith(color: c.blue),
          ),
          if (etape.formes.isNotEmpty) ...[
            const SizedBox(height: EspacesYasmina.space4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: EspacesYasmina.space2,
              runSpacing: EspacesYasmina.space2,
              textDirection: sens,
              children: [
                for (final forme in etape.formes)
                  Card(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: EspacesYasmina.space4,
                        vertical: EspacesYasmina.space1,
                      ),
                      child: Text(
                        forme,
                        textDirection: sens,
                        style: ThemeYasmina.pourLangue(
                          StylesYasmina.contentOption,
                          etape.langue,
                        ).copyWith(color: c.ink),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: EspacesYasmina.space6),
          for (var s = 0; s < etape.sequences.length; s++)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: EspacesYasmina.space2,
              ),
              child: Card(
                key: ValueKey('intro_sequence_$s'),
                child: ListTile(
                  leading: SizedBox.square(
                    dimension: TaillesYasmina.iconMd,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ProgressionSequences.couleurSequence(
                          c,
                          s,
                          defi: etape.estDefi,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  title: Text(
                    etape.sequences[s].titre,
                    textDirection: sens,
                    style: ThemeYasmina.pourLangue(
                      StylesYasmina.prompt,
                      etape.langue,
                    ).copyWith(color: c.ink),
                  ),
                  subtitle: Text(
                    textes.sequenceNombreExercices(
                      etape.sequences[s].exercices.length,
                    ),
                    style: theme.bodySmall,
                  ),
                ),
              ),
            ),
          const SizedBox(height: EspacesYasmina.space6),
          BoutonYasmina(
            key: const ValueKey('intro_commencer'),
            libelle: faite ? textes.introRejouer : textes.introCommencer,
            icone: Icons.play_arrow_rounded,
            onPressed: () =>
                context.push('/matiere/$code/etape/$etapeId/jouer'),
          ),
        ],
      ),
    );
  }
}
