import 'package:flutter/material.dart';

import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// État visuel d'une carte de révision.
enum EtatCarte { cachee, retournee, trouvee, fausse }

/// Une face de carte : un texte, un emoji, ou les deux.
class FaceCarte {
  const FaceCarte({this.texte, this.emoji});

  factory FaceCarte.depuisJson(Map<String, dynamic> json) => FaceCarte(
    texte: json['texte'] as String?,
    emoji: json['emoji'] as String?,
  );

  final String? texte;
  final String? emoji;

  /// Libellé lu : le texte, sinon un libellé neutre fourni.
  String libelle(String neutre) => texte ?? neutre;
}

/// Carte de révision (docs/moteurs/revision-jeux.md §11) : cachée (`tile`,
/// point d'interrogation discret), retournée (`blue-soft`), trouvée
/// (`olive-soft`), fausse (`coral-soft`).
class CarteRevision extends StatelessWidget {
  const CarteRevision({
    super.key,
    required this.face,
    required this.etat,
    required this.libelle,
    this.onTap,
    this.grande = false,
    this.fixe = false,
    this.motEtat,
  });

  /// Face montrée quand la carte n'est pas cachée.
  final FaceCarte face;
  final EtatCarte etat;
  final String libelle;
  final VoidCallback? onTap;

  /// Carte seule, en grand (flashcard).
  final bool grande;

  /// Carte de taille fixe (memory) : elle remplit la place que lui donne
  /// son parent, même hauteur face cachée et face visible, contenu ajusté.
  final bool fixe;
  final String? motEtat;

  bool get cachee => etat == EtatCarte.cachee;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = ThemeYasmina.langueDe(context);
    final (fond, bord) = switch (etat) {
      EtatCarte.cachee => (c.tile, c.line),
      EtatCarte.retournee => (c.blueSoft, c.blue),
      EtatCarte.trouvee => (c.oliveSoft, c.olive),
      EtatCarte.fausse => (c.coralSoft, c.coral),
    };
    final styleTexte = ThemeYasmina.pourLangue(
      grande
          ? StylesYasmina.contentWord
          : langue == 'ar'
          ? StylesYasmina.contentOption
          : StylesYasmina.latinPrompt,
      langue,
    ).copyWith(color: c.ink);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: cachee ? libelle : face.libelle(libelle),
      excludeSemantics: true,
      child: Material(
        color: fond,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
          side: BorderSide(color: bord, width: TraitsYasmina.borderThick),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: fixe
                ? const BoxConstraints.expand()
                : BoxConstraints(
                    minHeight: grande
                        ? TaillesYasmina.yasminaHome
                        : TaillesYasmina.choiceMinHeight,
                    minWidth: EspacesYasmina.targetMin,
                  ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: EspacesYasmina.space3,
                vertical: EspacesYasmina.space2,
              ),
              child: FittedBox(
                fit: fixe ? BoxFit.scaleDown : BoxFit.none,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (cachee)
                      Text(
                        '?',
                        style: StylesYasmina.contentWord.copyWith(
                          color: c.muted,
                        ),
                      )
                    else ...[
                      if (face.emoji case final emoji?)
                        Text(
                          emoji,
                          style: grande
                              ? StylesYasmina.letterHero
                              : StylesYasmina.contentWord,
                        ),
                      if (face.texte case final texte?)
                        Text(
                          texte,
                          textAlign: TextAlign.center,
                          style: styleTexte,
                        ),
                    ],
                    if (motEtat != null)
                      Text(
                        motEtat!,
                        style: StylesYasmina.latinLabel.copyWith(
                          color: etat == EtatCarte.fausse
                              ? c.coralText
                              : c.oliveText,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Libellés propres au moteur Révision et jeux.
({String jeSavais, String aRevoir, String carte, String Function(int n) carteN})
libellesJeux(String langue, {required bool feminin}) => switch (langue) {
  'ar' => (
    jeSavais: 'عَرَفْتُ',
    aRevoir: 'أُرَاجِعُ',
    carte: 'بِطَاقَةٌ',
    carteN: (n) => 'بِطَاقَةٌ $n',
  ),
  'en' => (
    jeSavais: 'I knew it',
    aRevoir: 'Review again',
    carte: 'card',
    carteN: (n) => 'card $n',
  ),
  _ => (
    jeSavais: 'Je savais',
    aRevoir: 'À revoir',
    carte: 'carte',
    carteN: (n) => 'carte $n',
  ),
};
