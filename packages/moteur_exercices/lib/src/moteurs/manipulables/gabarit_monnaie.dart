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

/// Pièces du prototype, en millimes (1 dinar = 1000 millimes), dessinées
/// de façon générique par le moteur (aucune image sous droits).
const piecesTunisiennes = [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000];

/// Un dinar en millimes.
const millimesParDinar = 1000;

/// Montant en clair, dans la langue de l'exercice : « 2 د وَ700 م » en
/// arabe, « 2 D et 700 m » en français, « 2 D and 700 m » en anglais.
String formaterMontant(int millimes, String langue) {
  final dinars = millimes ~/ millimesParDinar;
  final reste = millimes % millimesParDinar;
  final (d, m, et) = switch (langue) {
    'ar' => ('د', 'م', ' وَ'),
    'en' => ('D', 'm', ' and '),
    _ => ('D', 'm', ' et '),
  };
  if (millimes == 0) return '0 $m';
  return [if (dinars > 0) '$dinars $d', if (reste > 0) '$reste $m'].join(et);
}

/// T26 Monnaie (docs/moteurs/manipulables.md §14) : l'enfant glisse des
/// pièces de la réserve dans le porte-monnaie pour former le montant
/// demandé, et glisse (ou touche) une pièce posée pour la retirer. Juste si
/// la somme vaut la cible, quelles que soient les pièces.
class GabaritMonnaie implements GabaritReponse {
  const GabaritMonnaie();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurMonnaie creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    return ControleurMonnaie(
      config: config,
      pieces: (donnees['pieces'] as List).cast<int>(),
      cible: donnees['cible'] as int,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneMonnaie(controleur as ControleurMonnaie);
}

/// Les pièces posées dans le porte-monnaie, dans l'ordre de dépôt.
class ControleurMonnaie extends ControleurReponse {
  ControleurMonnaie({
    required this.config,
    required List<int> pieces,
    required this.cible,
  }) : pieces = List.unmodifiable(
         List.of(pieces)..sort((a, b) => b.compareTo(a)),
       );

  final ConfigExercice config;

  /// Sortes de pièces de la réserve, de la plus grande à la plus petite.
  final List<int> pieces;
  final int cible;

  /// Pièces posées au plus (au-delà, le porte-monnaie refuse).
  static const maxPieces = 20;

  final _posees = <int>[];

  bool get _revelee => affichage == AffichageReponse.revelee;

  /// Pièces posées (la décomposition de la cible, par les plus grandes
  /// pièces d'abord, quand la réponse est révélée).
  List<int> get posees => _revelee ? decomposer(cible) : _posees;

  int get montant => posees.fold(0, (a, b) => a + b);

  /// La cible avec les pièces de la réserve, les plus grandes d'abord (les
  /// pièces du prototype se divisent toutes les unes les autres par
  /// paliers : l'algorithme glouton tombe juste quand c'est possible).
  List<int> decomposer(int montant) {
    final resultat = <int>[];
    var reste = montant;
    for (final p in pieces) {
      while (reste >= p) {
        resultat.add(p);
        reste -= p;
      }
    }
    return resultat;
  }

  /// Ajoute une pièce de [valeur], `false` si le porte-monnaie est plein.
  bool ajouter(int valeur) {
    if (!modifiable || _posees.length >= maxPieces) return false;
    _posees.add(valeur);
    reponseModifiee();
    return true;
  }

  /// Retire la pièce posée [index].
  void retirer(int index) {
    if (!modifiable || index < 0 || index >= _posees.length) return;
    _posees.removeAt(index);
    reponseModifiee();
  }

  @override
  bool get complete => _posees.isNotEmpty;

  @override
  Object? get reponse => {'montant': montant};

  @override
  bool corriger() => montant == cible;

  /// Tout revient à l'état de départ (manipulables.md §6).
  @override
  void vider() {
    _posees.clear();
    reponseModifiee();
  }
}

/// Libellés propres au type, dans la langue de l'exercice.
({String Function(int v) piece, String porteMonnaie, String total})
_libellesMonnaie(String langue) => switch (langue) {
  'ar' => (
    piece: (v) => 'قِطْعَةُ ${formaterMontant(v, 'ar')}',
    porteMonnaie: 'الْمِحْفَظَةُ',
    total: 'الْمَجْمُوعُ',
  ),
  'en' => (
    piece: (v) => 'coin of ${formaterMontant(v, 'en')}',
    porteMonnaie: 'purse',
    total: 'Total',
  ),
  _ => (
    piece: (v) => 'pièce de ${formaterMontant(v, 'fr')}',
    porteMonnaie: 'porte-monnaie',
    total: 'Total',
  ),
};

/// Une pièce dessinée : ronde, les millimes en `amber`, les dinars en
/// `blue`, la valeur écrite dessus (chiffres de gauche à droite).
class Piece extends StatelessWidget {
  const Piece({
    super.key,
    required this.valeur,
    this.etat = EtatMateriel.repos,
  });

  final int valeur;
  final EtatMateriel etat;

  bool get dinar => valeur >= millimesParDinar;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final (fond, bord, texte) = switch (etat) {
      EtatMateriel.juste => (c.oliveSoft, c.olive, c.oliveText),
      EtatMateriel.faux => (c.coralSoft, c.coral, c.coralText),
      EtatMateriel.repos =>
        dinar ? (c.blueSoft, c.blue, c.ink) : (c.amberSoft, c.amber, c.ink),
    };
    final style = StylesYasmina.latinLabel.copyWith(color: texte);
    // Les dinars un peu plus grands que les millimes, comme les vraies.
    final taille = dinar
        ? EspacesYasmina.targetMin + EspacesYasmina.space2
        : EspacesYasmina.targetMin;
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: fond,
        shape: BoxShape.circle,
        border: Border.all(color: bord, width: TraitsYasmina.borderThick),
      ),
      child: Center(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            dinar ? '${valeur ~/ millimesParDinar}\nد' : '$valeur\nم',
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ),
    );
  }
}

/// La réserve (une pièce par sorte) au début de ligne, le porte-monnaie,
/// puis le montant en clair.
class _ZoneMonnaie extends StatelessWidget {
  const _ZoneMonnaie(this.controleur);

  final ControleurMonnaie controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final l = _libellesMonnaie(langue);
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
        void ajouter(int valeur) {
          if (!controleur.ajouter(valeur)) return;
          services.vibration.legere();
          services.audio.jouerSon(SonInterface.depot);
        }

        final posees = controleur.posees;
        final porteMonnaie = ZoneDepot(
          key: ValueKey(
            affichage == AffichageReponse.revelee
                ? 'manipulables_reponse'
                : 'porte_monnaie',
          ),
          libelle: l.porteMonnaie,
          etat: etat == EtatMateriel.juste ? EtatDepot.juste : EtatDepot.repos,
          // Une pièce posée relâchée dans le porte-monnaie y reste (donnée
          // préfixée, ignorée) : seul un lâcher à l'extérieur la retire.
          onDepot: modifiable
              ? (donnee) {
                  if (donnee.startsWith(prefixePose)) return;
                  final valeur = int.tryParse(donnee);
                  if (valeur != null) ajouter(valeur);
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TaillesYasmina.yasminaHome,
            ),
            child: Wrap(
              key: const ValueKey('pieces_posees'),
              spacing: EspacesYasmina.space1,
              runSpacing: EspacesYasmina.space1,
              children: [
                for (final (i, v) in posees.indexed)
                  Pose(
                    key: ValueKey('piece_posee_$i'),
                    libelle: l.piece(v),
                    donnee: '$i',
                    onToucher: modifiable ? () => controleur.retirer(i) : null,
                    child: Piece(valeur: v, etat: etat),
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
                  spacing: EspacesYasmina.space2,
                  children: [
                    for (final v in controleur.pieces)
                      ReserveGlissable(
                        key: ValueKey('reserve_piece_$v'),
                        donnee: '$v',
                        libelle: l.piece(v),
                        onToucher: modifiable ? () => ajouter(v) : null,
                        child: Piece(valeur: v),
                      ),
                  ],
                ),
                Expanded(child: porteMonnaie),
              ],
            ),
            Text(
              '${l.total}: ${formaterMontant(controleur.montant, langue)}',
              key: const ValueKey('monnaie_total'),
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
