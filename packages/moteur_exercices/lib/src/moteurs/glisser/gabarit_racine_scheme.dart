import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../composants/bouton_yasmina.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../choix/selection_choix.dart';
import 'controleur_glisser.dart';
import 'tuile_glissable.dart';
import 'zone_depot.dart';

/// Signes combinants de chaque haraka d'un emplacement de schème (T56),
/// mêmes noms que le schéma edu-content/1.0 (`harakaScheme`).
const harakatScheme = <String, String>{
  'fatha': 'َ',
  'damma': 'ُ',
  'kasra': 'ِ',
  'soukoun': 'ْ',
  'fathatan': 'ً',
  'dammatan': 'ٌ',
  'kasratan': 'ٍ',
  'shadda-fatha': 'َّ',
  'shadda-damma': 'ُّ',
  'shadda-kasra': 'ِّ',
};

/// T56 Racine et schème (arabe seulement) : l'enfant glisse des lettres
/// nues dans des emplacements, un par lettre attendue
/// (docs/moteurs/glisser-deposer.md §2). Forme racine : les lettres posées
/// s'affichent isolées, séparées (ك ت ب). Forme schème : elles se lient,
/// chacune avec la haraka de son emplacement (فَاعِلٌ).
class GabaritRacineScheme implements GabaritReponse {
  const GabaritRacineScheme();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurRacineScheme creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurRacineScheme(
      config: config,
      elements: [
        for (final e
            in (donnees['lettres'] as List).cast<Map<String, dynamic>>())
          Proposition.depuisJson(e),
      ],
      attendu: (reponse['ordre'] as List).cast<String>(),
      mot: donnees['mot'] as String,
      scheme: donnees['forme'] == 'scheme',
      harakat: [
        for (final e
            in (donnees['emplacements'] as List).cast<Map<String, dynamic>>())
          harakatScheme[e['haraka']] ?? '',
      ],
      ecoute: (donnees['ecoute'] as Map<String, dynamic>?)?['texte'] as String?,
      melanger: donnees['melanger'] as bool? ?? true,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneRacineScheme(controleur as ControleurRacineScheme);
}

/// Ligne de lettres à capacité fixe (un emplacement par lettre attendue).
class ControleurRacineScheme extends ControleurOrdre {
  ControleurRacineScheme({
    required super.config,
    required super.elements,
    required super.attendu,
    required this.mot,
    required this.scheme,
    required this.harakat,
    super.ecoute,
    super.melanger,
  }) : super(exigeTous: true, capacite: harakat.length);

  /// Le mot vocalisé dont on cherche la racine ou le schème.
  final String mot;

  /// Forme schème (lettres liées avec leurs harakat) ou racine (lettres
  /// isolées).
  final bool scheme;

  /// Signes combinants de chaque emplacement, dans l'ordre (vides pour une
  /// racine).
  final List<String> harakat;

  /// Nombre d'emplacements encore vides.
  int get vides => harakat.length - ordre.length;

  @override
  String get motConstruit => scheme
      ? [
          for (final (i, id) in ordre.indexed)
            '${element(id).texte ?? ''}${i < harakat.length ? harakat[i] : ''}',
        ].join()
      : [for (final id in ordre) element(id).texte ?? ''].join(' ');
}

/// Le mot, la ligne des emplacements (lettres posées, puis les
/// emplacements vides), puis la réserve de lettres.
class _ZoneRacineScheme extends StatelessWidget {
  const _ZoneRacineScheme(this.controleur);

  final ControleurRacineScheme controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final services = ServicesExercice.of(context);
    final styleMot = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final apercu = config.mode != ModeExercice.enfant;
        final modifiable = controleur.modifiable;
        void deposer(String id) {
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
          controleur.poser(id, 'fin');
        }

        void poserAttente() {
          if (controleur.enAttente == null) return;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
          controleur.poserAttente('fin');
        }

        String? motEtat(String id) {
          if (!apercu) return null;
          return switch (controleur.etatDe(id)) {
            EtatGlissable.juste => 'juste',
            EtatGlissable.faux => 'faux',
            _ => null,
          };
        }

        Widget tuile(String id, {bool fantome = false}) {
          final e = controleur.element(id);
          if (fantome) {
            return Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TuileGlissable(
                key: ValueKey('place_$id'),
                id: id,
                etat: EtatGlissable.repos,
                texte: e.texte,
                grand: true,
              ),
            );
          }
          return TuileGlissable(
            key: ValueKey('element_$id'),
            id: id,
            etat: controleur.etatDe(id),
            texte: e.texte,
            grand: true,
            motEtat: motEtat(id),
            onToucher: modifiable ? () => controleur.basculerAttente(id) : null,
          );
        }

        final juste =
            controleur.ordre.isNotEmpty &&
            (controleur.affichage == AffichageReponse.juste ||
                controleur.affichage == AffichageReponse.revelee);
        final texte = controleur.motConstruit;
        // La ligne reçoit un dépôt tant qu'il reste un emplacement vide.
        final recoit = modifiable && !controleur.pleine;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space6,
          children: [
            Text(
              controleur.mot,
              key: const ValueKey('racine_mot'),
              textAlign: TextAlign.center,
              style: styleMot,
            ),
            if (controleur.ecoute case final ecoute?)
              Center(
                child: BoutonEcouter(
                  key: const ValueKey('ordre_ecouter'),
                  libelle: libelles.ecouter,
                  onPressed: () =>
                      controleur.demanderAudio(ecoute, langue: langue),
                ),
              ),
            ZoneDepot(
              key: const ValueKey('ligne'),
              libelle: controleur.mot,
              etat: juste ? EtatDepot.juste : EtatDepot.repos,
              onDepot: recoit ? deposer : null,
              // Le toucher de la ligne pose l'élément en attente, rien
              // d'autre : la dernière lettre se retire par Effacer.
              onToucher: modifiable
                  ? () {
                      if (controleur.enAttente != null && recoit) {
                        poserAttente();
                      }
                    }
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: TaillesYasmina.choiceMinHeight,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: EspacesYasmina.space2,
                  children: [
                    if (texte.isNotEmpty)
                      Text(
                        texte,
                        key: const ValueKey('mot_construit'),
                        textAlign: TextAlign.center,
                        style: styleMot.copyWith(
                          color: switch (controleur.affichage) {
                            AffichageReponse.faux when !controleur.corriger() =>
                              c.coralText,
                            _ => c.ink,
                          },
                        ),
                      ),
                    // Les emplacements encore vides : le premier reçoit le
                    // dépôt (les autres montrent ce qui reste à poser).
                    for (var i = 0; i < controleur.vides; i++)
                      ZoneDepot(
                        key: ValueKey(
                          'emplacement_${controleur.ordre.length + i}',
                        ),
                        libelle: '${controleur.ordre.length + i + 1}',
                        enLigne: true,
                        onDepot: recoit && i == 0 ? deposer : null,
                        onToucher: recoit && i == 0 ? poserAttente : null,
                        child: const SizedBox(
                          width: EspacesYasmina.targetMin,
                          height: EspacesYasmina.targetMin,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            BoutonEffacer(
              key: const ValueKey('ordre_effacer'),
              libelle: libelles.effacer,
              onPressed: modifiable && controleur.ordre.isNotEmpty
                  ? controleur.retirerDernier
                  : null,
            ),
            Wrap(
              key: const ValueKey('reserve'),
              spacing: EspacesYasmina.space2,
              runSpacing: EspacesYasmina.space2,
              children: [
                for (final e in controleur.elements)
                  tuile(e.id, fantome: controleur.estPose(e.id)),
              ],
            ),
          ],
        );
      },
    );
  }
}
