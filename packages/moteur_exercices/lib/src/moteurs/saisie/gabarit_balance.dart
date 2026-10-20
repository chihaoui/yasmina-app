import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import 'pave_numerique.dart';

/// T63 Balance d'équivalence (docs/moteurs/saisie-numerique.md §14) : deux
/// plateaux de masses connues, un sac de masse inconnue sur l'un d'eux.
/// L'enfant écrit la masse du sac sur le pavé : la balance penche selon la
/// valeur écrite, et s'équilibre quand elle est juste.
class GabaritBalance implements GabaritReponse {
  const GabaritBalance();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurBalance creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurBalance(
      config: config,
      gauche: (donnees['gauche'] as List).cast<int>(),
      droite: (donnees['droite'] as List).cast<int>(),
      sacAGauche: donnees['sac'] != 'droite',
      orientaux: donnees['chiffres'] == 'orientaux',
      attendu: reponse['valeur'] as int,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneBalance(controleur as ControleurBalance);
}

/// La masse écrite pour le sac.
class ControleurBalance extends ControleurReponse {
  ControleurBalance({
    required this.config,
    required this.gauche,
    required this.droite,
    required this.sacAGauche,
    required this.orientaux,
    required this.attendu,
  });

  final ConfigExercice config;

  /// Masses connues de chaque plateau.
  final List<int> gauche;
  final List<int> droite;

  /// Plateau du sac.
  final bool sacAGauche;
  final bool orientaux;
  final int attendu;

  static const chiffresMax = 3;

  String _chiffres = '';

  String get chiffres =>
      affichage == AffichageReponse.revelee ? '$attendu' : _chiffres;

  int? get valeur => chiffres.isEmpty ? null : int.parse(chiffres);

  int get totalGauche =>
      gauche.fold(0, (a, b) => a + b) + (sacAGauche ? (valeur ?? 0) : 0);
  int get totalDroite =>
      droite.fold(0, (a, b) => a + b) + (sacAGauche ? 0 : (valeur ?? 0));

  /// Inclinaison de la balance : négative quand la gauche est plus lourde,
  /// positive quand la droite l'est, 0 à l'équilibre, bornée à 1 en valeur
  /// absolue (part de l'angle maximal).
  double get inclinaison {
    final difference = totalDroite - totalGauche;
    if (difference == 0) return 0;
    final reference = math.max(1, attendu);
    return (difference / reference).clamp(-1.0, 1.0);
  }

  void ajouter(int chiffre) {
    if (!modifiable || _chiffres.length >= chiffresMax) return;
    if (_chiffres == '0') _chiffres = '';
    _chiffres += '$chiffre';
    reponseModifiee();
  }

  void effacer() {
    if (!modifiable || _chiffres.isEmpty) return;
    _chiffres = _chiffres.substring(0, _chiffres.length - 1);
    reponseModifiee();
  }

  @override
  bool get complete => _chiffres.isNotEmpty;

  @override
  Object? get reponse => {'valeur': valeur};

  @override
  bool corriger() => valeur == attendu;

  @override
  void vider() {
    _chiffres = '';
    reponseModifiee();
  }
}

/// Libellés propres au type.
({String sac, String Function(int m) masse, String balance}) _libellesBalance(
  String langue,
) => switch (langue) {
  'ar' => (
    sac: 'الْكِيسُ',
    masse: (m) => 'كُتْلَةٌ $m',
    balance: 'الْمِيزَانُ',
  ),
  'en' => (sac: 'bag', masse: (m) => 'weight $m', balance: 'scales'),
  _ => (sac: 'le sac', masse: (m) => 'masse $m', balance: 'la balance'),
};

/// La balance dessinée, puis le pavé.
class _ZoneBalance extends StatelessWidget {
  const _ZoneBalance(this.controleur);

  final ControleurBalance controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final l = _libellesBalance(langue);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final apercu = config.mode != ModeExercice.enfant;
        final affichage = controleur.affichage;
        final revelee = affichage == AffichageReponse.revelee;
        final juste = affichage == AffichageReponse.juste || revelee;
        final faux =
            affichage == AffichageReponse.faux && !controleur.corriger();
        final motEtat = !apercu
            ? null
            : juste
            ? 'juste'
            : faux
            ? 'faux'
            : null;
        final valeur = controleur.chiffres;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            Semantics(
              label:
                  '${l.balance}, ${l.sac} '
                  '${valeur.isEmpty ? '?' : afficherChiffres(valeur, orientaux: controleur.orientaux)}',
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: CustomPaint(
                  key: ValueKey(revelee ? 'saisie_reponse' : 'balance_dessin'),
                  painter: PeintreBalance(
                    gauche: controleur.gauche,
                    droite: controleur.droite,
                    sacAGauche: controleur.sacAGauche,
                    valeurSac: valeur.isEmpty
                        ? '?'
                        : afficherChiffres(
                            valeur,
                            orientaux: controleur.orientaux,
                          ),
                    inclinaison: controleur.inclinaison,
                    couleurs: c,
                    couleurSac: juste
                        ? c.olive
                        : faux
                        ? c.coral
                        : c.blue,
                    orientaux: controleur.orientaux,
                    styleMasse: ThemeYasmina.pourLangue(
                      StylesYasmina.latinLabel,
                      langue,
                    ).copyWith(color: c.ink),
                    styleSac: ThemeYasmina.pourLangue(
                      StylesYasmina.contentOption,
                      langue,
                    ).copyWith(color: c.onAccent),
                  ),
                ),
              ),
            ),
            if (motEtat != null)
              Text(
                motEtat,
                key: const ValueKey('saisie_mot_etat'),
                textAlign: TextAlign.center,
                style: StylesYasmina.latinLabel.copyWith(
                  color: faux ? c.coralText : c.oliveText,
                ),
              ),
            PaveNumerique(
              orientaux: controleur.orientaux,
              libelleEffacer: libelles.effacer,
              onChiffre: modifiable ? controleur.ajouter : null,
              onEffacer: modifiable && controleur.complete
                  ? controleur.effacer
                  : null,
            ),
          ],
        );
      },
    );
  }
}

/// Peint la balance : un pied, un fléau incliné selon [inclinaison] (de −1
/// à 1, un angle maximal d'un huitième de tour), deux plateaux suspendus,
/// les masses connues en carrés numérotés et le sac (rond, `blue`) avec sa
/// valeur écrite ou « ? ».
class PeintreBalance extends CustomPainter {
  const PeintreBalance({
    required this.gauche,
    required this.droite,
    required this.sacAGauche,
    required this.valeurSac,
    required this.inclinaison,
    required this.couleurs,
    required this.couleurSac,
    required this.orientaux,
    required this.styleMasse,
    required this.styleSac,
  });

  final List<int> gauche;
  final List<int> droite;
  final bool sacAGauche;
  final String valeurSac;
  final double inclinaison;
  final CouleursYasmina couleurs;
  final Color couleurSac;
  final bool orientaux;
  final TextStyle styleMasse;
  final TextStyle styleSac;

  /// Angle du fléau pour une inclinaison de 1 (un huitième de tour).
  static const angleMax = math.pi / 8;

  @override
  void paint(Canvas canvas, Size size) {
    final trait = Paint()
      ..color = couleurs.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThick
      ..strokeCap = StrokeCap.round;
    final pivot = Offset(size.width / 2, size.height * 0.3);
    // Pied : un triangle et une colonne.
    canvas.drawLine(pivot, Offset(pivot.dx, size.height * 0.92), trait);
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.92),
      Offset(size.width * 0.65, size.height * 0.92),
      trait,
    );
    // Fléau incliné : la droite descend quand elle est plus lourde.
    final angle = inclinaison * angleMax;
    final demi = size.width * 0.38;
    final boutGauche =
        pivot + Offset(-math.cos(angle) * demi, -math.sin(angle) * demi);
    final boutDroit =
        pivot + Offset(math.cos(angle) * demi, math.sin(angle) * demi);
    canvas.drawLine(boutGauche, boutDroit, trait);
    canvas.drawCircle(
      pivot,
      EspacesYasmina.space2,
      Paint()..color = couleurs.ink,
    );
    _plateau(canvas, size, boutGauche, gauche, sacAGauche);
    _plateau(canvas, size, boutDroit, droite, !sacAGauche);
  }

  void _plateau(
    Canvas canvas,
    Size size,
    Offset accroche,
    List<int> masses,
    bool avecSac,
  ) {
    final trait = Paint()
      ..color = couleurs.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThin;
    final chute = size.height * 0.28;
    final largeur = size.width * 0.3;
    final y = accroche.dy + chute;
    final gaucheP = accroche.dx - largeur / 2;
    // Fils et plateau.
    canvas.drawLine(accroche, Offset(gaucheP, y), trait);
    canvas.drawLine(accroche, Offset(gaucheP + largeur, y), trait);
    canvas.drawLine(
      Offset(gaucheP, y),
      Offset(gaucheP + largeur, y),
      trait..strokeWidth = TraitsYasmina.borderThick,
    );
    // Masses connues : des carrés `amber` numérotés, posés sur le plateau.
    const cote = EspacesYasmina.targetMin * 0.6;
    final elements = masses.length + (avecSac ? 1 : 0);
    final pas = elements == 0
        ? 0
        : math.min(cote + EspacesYasmina.space1, largeur / elements);
    var x = accroche.dx - (pas * (elements - 1)) / 2;
    for (final m in masses) {
      final rect = Rect.fromCenter(
        center: Offset(x, y - cote / 2 - TraitsYasmina.borderThick),
        width: cote,
        height: cote,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(RayonsYasmina.radiusSm),
        ),
        Paint()..color = couleurs.amberSoft,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(RayonsYasmina.radiusSm),
        ),
        Paint()
          ..color = couleurs.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = TraitsYasmina.borderThin,
      );
      _texte(
        canvas,
        afficherChiffres('$m', orientaux: orientaux),
        rect.center,
        styleMasse,
      );
      x += pas;
    }
    if (avecSac) {
      final centre = Offset(x, y - cote * 0.6 - TraitsYasmina.borderThick);
      canvas.drawCircle(centre, cote * 0.6, Paint()..color = couleurSac);
      _texte(canvas, valeurSac, centre, styleSac);
    }
  }

  void _texte(Canvas canvas, String texte, Offset centre, TextStyle style) {
    final peintre = TextPainter(
      text: TextSpan(text: texte, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    peintre.paint(
      canvas,
      centre - Offset(peintre.width / 2, peintre.height / 2),
    );
    peintre.dispose();
  }

  @override
  bool shouldRepaint(PeintreBalance ancien) =>
      ancien.inclinaison != inclinaison ||
      ancien.valeurSac != valeurSac ||
      ancien.couleurSac != couleurSac ||
      ancien.gauche != gauche ||
      ancien.droite != droite;
}
