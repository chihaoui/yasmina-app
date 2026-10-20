import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../plateforme/services.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../glisser/zone_depot.dart';
import 'materiel.dart';

/// T27 Blocs base 10 (docs/moteurs/manipulables.md) : l'enfant glisse des
/// barres de dix et des cubes d'unités de la réserve vers le plateau (ou
/// les touche), et retire un bloc posé en le touchant.
class GabaritBlocs implements GabaritReponse {
  const GabaritBlocs();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurBlocs creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurBlocs(
      config: config,
      cible: donnees['cible'] as int,
      canonique: donnees['canonique'] as bool? ?? true,
      attenduDizaines: reponse['dizaines'] as int,
      attenduUnites: reponse['unites'] as int,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneBlocs(controleur as ControleurBlocs);
}

/// Dizaines et unités posées sur le plateau.
class ControleurBlocs extends ControleurReponse {
  ControleurBlocs({
    required this.config,
    required this.cible,
    required this.canonique,
    required this.attenduDizaines,
    required this.attenduUnites,
  });

  final ConfigExercice config;
  final int cible;

  /// Exactement les dizaines et unités du nombre (9 unités au plus).
  final bool canonique;
  final int attenduDizaines;
  final int attenduUnites;

  /// Au plus 9 barres, et 9 cubes en mode canonique.
  static const maxDizaines = 9;
  static const maxUnitesCanonique = 9;
  static const maxUnitesLibre = 99;

  int _dizaines = 0;
  int _unites = 0;

  bool get _revelee => affichage == AffichageReponse.revelee;

  int get dizaines => _revelee ? attenduDizaines : _dizaines;
  int get unites => _revelee ? attenduUnites : _unites;

  int get maxUnites => canonique ? maxUnitesCanonique : maxUnitesLibre;

  /// Ajoute un bloc de [sorte] (`dizaine` ou `unite`), `false` si le
  /// plateau le refuse.
  bool ajouter(String sorte) {
    if (!modifiable) return false;
    if (sorte == 'dizaine') {
      if (_dizaines >= maxDizaines) return false;
      _dizaines++;
    } else {
      if (_unites >= maxUnites) return false;
      _unites++;
    }
    reponseModifiee();
    return true;
  }

  void retirer(String sorte) {
    if (!modifiable) return;
    if (sorte == 'dizaine' && _dizaines > 0) _dizaines--;
    if (sorte == 'unite' && _unites > 0) _unites--;
    reponseModifiee();
  }

  @override
  bool get complete => _dizaines + _unites > 0;

  @override
  Object? get reponse => {'dizaines': _dizaines, 'unites': _unites};

  @override
  bool corriger() => canonique
      ? _dizaines == attenduDizaines && _unites == attenduUnites
      : _dizaines * 10 + _unites == cible;

  /// Tout revient à l'état de départ (manipulables.md §6).
  @override
  void vider() {
    _dizaines = 0;
    _unites = 0;
    reponseModifiee();
  }
}

/// Libellés propres au type, dans la langue de l'exercice.
({String dizaine, String unite, String dizaines, String unites, String plateau})
_libellesBlocs(String langue) => switch (langue) {
  'ar' => (
    dizaine: 'عَشَرَةٌ',
    unite: 'وَحْدَةٌ',
    dizaines: 'الْعَشَرَاتُ',
    unites: 'الْوَحَدَاتُ',
    plateau: 'اللَّوْحَةُ',
  ),
  'en' => (
    dizaine: 'ten',
    unite: 'one',
    dizaines: 'tens',
    unites: 'ones',
    plateau: 'board',
  ),
  _ => (
    dizaine: 'dizaine',
    unite: 'unité',
    dizaines: 'dizaines',
    unites: 'unités',
    plateau: 'plateau',
  ),
};

/// La réserve (une barre, un cube) au début de ligne, le plateau, puis le
/// compte en clair.
class _ZoneBlocs extends StatelessWidget {
  const _ZoneBlocs(this.controleur);

  final ControleurBlocs controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesBlocs(langue);
    final services = ServicesExercice.of(context);
    final styleCompte = ThemeYasmina.pourLangue(
      langue == 'ar' ? StylesYasmina.option : StylesYasmina.latinLabel,
      langue,
    ).copyWith(color: c.ink);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final etat = switch (affichage) {
          AffichageReponse.juste ||
          AffichageReponse.revelee => EtatMateriel.juste,
          AffichageReponse.faux when !controleur.corriger() =>
            EtatMateriel.faux,
          _ => EtatMateriel.repos,
        };
        final motEtat = !apercu
            ? null
            : switch (etat) {
                EtatMateriel.juste => 'juste',
                EtatMateriel.faux => 'faux',
                EtatMateriel.repos => null,
              };
        void ajouter(String sorte) {
          if (!controleur.ajouter(sorte)) return;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
        }

        final plateau = ZoneDepot(
          key: ValueKey(
            affichage == AffichageReponse.revelee
                ? 'manipulables_reponse'
                : 'plateau',
          ),
          libelle: l.plateau,
          etat: etat == EtatMateriel.juste ? EtatDepot.juste : EtatDepot.repos,
          onDepot: modifiable ? ajouter : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TaillesYasmina.yasminaHome,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: EspacesYasmina.space4,
              children: [
                Expanded(
                  child: Wrap(
                    key: const ValueKey('dizaines'),
                    spacing: EspacesYasmina.space1,
                    runSpacing: EspacesYasmina.space1,
                    children: [
                      for (var i = 0; i < controleur.dizaines; i++)
                        Pose(
                          key: ValueKey('dizaine_$i'),
                          libelle: l.dizaine,
                          onToucher: modifiable
                              ? () => controleur.retirer('dizaine')
                              : null,
                          child: Bloc(dizaine: true, etat: etat),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Wrap(
                    key: const ValueKey('unites'),
                    spacing: EspacesYasmina.space1,
                    runSpacing: EspacesYasmina.space1,
                    children: [
                      for (var i = 0; i < controleur.unites; i++)
                        Pose(
                          key: ValueKey('unite_$i'),
                          libelle: l.unite,
                          onToucher: modifiable
                              ? () => controleur.retirer('unite')
                              : null,
                          child: Bloc(dizaine: false, etat: etat),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: EspacesYasmina.space4,
              children: [
                Column(
                  key: const ValueKey('reserve'),
                  spacing: EspacesYasmina.space3,
                  children: [
                    ReserveGlissable(
                      key: const ValueKey('reserve_dizaine'),
                      donnee: 'dizaine',
                      libelle: l.dizaine,
                      onToucher: modifiable ? () => ajouter('dizaine') : null,
                      child: const Bloc(dizaine: true),
                    ),
                    ReserveGlissable(
                      key: const ValueKey('reserve_unite'),
                      donnee: 'unite',
                      libelle: l.unite,
                      onToucher: modifiable ? () => ajouter('unite') : null,
                      child: const Bloc(dizaine: false),
                    ),
                  ],
                ),
                Expanded(child: plateau),
              ],
            ),
            Text(
              '${l.dizaines}: ${controleur.dizaines} ${langue == 'ar' ? 'وَ' : ''}'
              '${l.unites}: ${controleur.unites}',
              key: const ValueKey('blocs_compte'),
              textAlign: TextAlign.center,
              style: styleCompte,
            ),
            motEtatMateriel(context, motEtat, faux: etat == EtatMateriel.faux),
          ],
        );
      },
    );
  }
}
