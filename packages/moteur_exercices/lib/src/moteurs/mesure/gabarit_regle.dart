import 'package:flutter/material.dart';

import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../registre/registre_types.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';
import '../saisie/pave_numerique.dart';

/// T30 Règle (docs/moteurs/mesure-temps.md) : un objet posé le long d'une
/// règle graduée en centimètres, l'enfant lit sa longueur et l'écrit sur le
/// pavé. L'objet peut ne pas partir de zéro (`depart`).
class GabaritRegle implements GabaritReponse {
  const GabaritRegle();

  @override
  ModeValidation get validation => ModeValidation.verifier;

  @override
  ControleurRegle creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    final objet = donnees['objet'] as Map<String, dynamic>;
    return ControleurRegle(
      config: config,
      longueurRegle: donnees['longueur_regle'] as int? ?? 10,
      longueur: objet['longueur'] as int,
      depart: objet['depart'] as int? ?? 0,
      emoji: objet['emoji'] as String?,
      unite: donnees['unite'] as String? ?? 'cm',
      orientaux: donnees['chiffres'] == 'orientaux',
      attendu: reponse['valeur'] as int,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneRegle(controleur as ControleurRegle);
}

/// La longueur écrite.
class ControleurRegle extends ControleurReponse {
  ControleurRegle({
    required this.config,
    required this.longueurRegle,
    required this.longueur,
    required this.depart,
    required this.unite,
    required this.orientaux,
    required this.attendu,
    this.emoji,
  });

  final ConfigExercice config;

  /// Longueur de la règle en centimètres.
  final int longueurRegle;

  /// Longueur et position de départ de l'objet, en centimètres.
  final int longueur;
  final int depart;
  final String? emoji;
  final String unite;
  final bool orientaux;
  final int attendu;

  static const chiffresMax = 2;

  String _chiffres = '';

  String get chiffres =>
      affichage == AffichageReponse.revelee ? '$attendu' : _chiffres;

  int? get valeur => _chiffres.isEmpty ? null : int.parse(_chiffres);

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

/// La règle et l'objet, la longueur écrite, le pavé.
class _ZoneRegle extends StatelessWidget {
  const _ZoneRegle(this.controleur);

  final ControleurRegle controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    final styleValeur = ThemeYasmina.pourLangue(
      StylesYasmina.contentWord,
      langue,
    ).copyWith(color: c.ink);
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
        final bord = juste
            ? c.olive
            : faux
            ? c.coral
            : c.line;
        String ch(String t) =>
            afficherChiffres(t, orientaux: controleur.orientaux);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            // La règle se lit de gauche à droite, même en arabe.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Semantics(
                label:
                    '${ch('${controleur.longueurRegle}')} ${controleur.unite}',
                child: AspectRatio(
                  aspectRatio: 3,
                  child: CustomPaint(
                    key: ValueKey(revelee ? 'saisie_reponse' : 'regle'),
                    painter: PeintreRegle(
                      longueurRegle: controleur.longueurRegle,
                      longueur: controleur.longueur,
                      depart: controleur.depart,
                      emoji: controleur.emoji,
                      couleurs: c,
                      orientaux: controleur.orientaux,
                      styleNombre: ThemeYasmina.pourLangue(
                        StylesYasmina.latinLabel,
                        langue,
                      ).copyWith(color: c.ink),
                    ),
                  ),
                ),
              ),
            ),
            // La longueur écrite, suivie de l'unité.
            Center(
              child: Container(
                key: const ValueKey('regle_valeur'),
                constraints: const BoxConstraints(
                  minWidth: EspacesYasmina.targetMin * 2,
                  minHeight: TaillesYasmina.choiceMinHeight,
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: EspacesYasmina.space4,
                ),
                decoration: BoxDecoration(
                  color: c.tile,
                  borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
                  border: Border.all(
                    color: bord,
                    width: TraitsYasmina.borderThick,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${ch(controleur.chiffres)} ${controleur.unite}'.trim(),
                    style: styleValeur,
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

/// Peint la règle (bande `sun` graduée au centimètre et au demi-centimètre,
/// nombres de 0 à la longueur) et, au-dessus, l'objet (barre `amber` de sa
/// longueur, à partir de `depart`, avec son emoji).
class PeintreRegle extends CustomPainter {
  const PeintreRegle({
    required this.longueurRegle,
    required this.longueur,
    required this.depart,
    required this.emoji,
    required this.couleurs,
    required this.orientaux,
    required this.styleNombre,
  });

  final int longueurRegle;
  final int longueur;
  final int depart;
  final String? emoji;
  final CouleursYasmina couleurs;
  final bool orientaux;
  final TextStyle styleNombre;

  @override
  void paint(Canvas canvas, Size size) {
    final marge = EspacesYasmina.space4;
    final largeur = size.width - 2 * marge;
    final cm = largeur / longueurRegle;
    final hautRegle = size.height * 0.5;
    final regle = Rect.fromLTWH(
      marge,
      hautRegle,
      largeur,
      size.height - hautRegle,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        regle,
        const Radius.circular(RayonsYasmina.radiusSm),
      ),
      Paint()..color = couleurs.sun,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        regle,
        const Radius.circular(RayonsYasmina.radiusSm),
      ),
      Paint()
        ..color = couleurs.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = TraitsYasmina.borderThin,
    );
    final trait = Paint()
      ..color = couleurs.ink
      ..strokeWidth = TraitsYasmina.borderThin;
    for (var i = 0; i <= longueurRegle * 2; i++) {
      final x = marge + i * cm / 2;
      final entier = i.isEven;
      canvas.drawLine(
        Offset(x, hautRegle),
        Offset(
          x,
          hautRegle + (entier ? EspacesYasmina.space6 : EspacesYasmina.space2),
        ),
        trait,
      );
      if (entier) {
        final peintre = TextPainter(
          text: TextSpan(
            text: afficherChiffres('${i ~/ 2}', orientaux: orientaux),
            style: styleNombre,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        peintre.paint(
          canvas,
          Offset(
            x - peintre.width / 2,
            size.height - peintre.height - EspacesYasmina.space1,
          ),
        );
        peintre.dispose();
      }
    }
    // L'objet, juste au-dessus de la règle.
    final objet = Rect.fromLTWH(
      marge + depart * cm,
      hautRegle - EspacesYasmina.space8 - EspacesYasmina.space2,
      longueur * cm,
      EspacesYasmina.space8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        objet,
        const Radius.circular(RayonsYasmina.radiusMd),
      ),
      Paint()..color = couleurs.amberSoft,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        objet,
        const Radius.circular(RayonsYasmina.radiusMd),
      ),
      Paint()
        ..color = couleurs.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = TraitsYasmina.borderThick,
    );
    if (emoji case final e?) {
      final peintre = TextPainter(
        text: TextSpan(text: e, style: StylesYasmina.contentOption),
        textDirection: TextDirection.ltr,
      )..layout();
      peintre.paint(
        canvas,
        objet.center - Offset(peintre.width / 2, peintre.height / 2),
      );
      peintre.dispose();
    }
  }

  @override
  bool shouldRepaint(PeintreRegle ancien) =>
      ancien.longueurRegle != longueurRegle ||
      ancien.longueur != longueur ||
      ancien.depart != depart ||
      ancien.emoji != emoji;
}
