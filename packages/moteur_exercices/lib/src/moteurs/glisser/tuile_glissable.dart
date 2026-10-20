import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';

import '../../theme/jetons_yasmina.g.dart';
import '../../theme/mouvements_yasmina.dart';
import '../../theme/theme_yasmina.dart';
import 'controleur_glisser.dart';

/// Tuile déplaçable du moteur Glisser-déposer (LetterTile du design
/// system) : lettre, syllabe, mot, étiquette ou image légendée.
///
/// Glisser-déposer réel ([Draggable], la place reste vide pendant le
/// déplacement) et toucher-toucher en secours : un toucher sans
/// déplacement appelle [onToucher] (mise en attente). Un dépôt hors cible
/// ramène la tuile à sa place en un retour animé.
class TuileGlissable extends StatefulWidget {
  const TuileGlissable({
    super.key,
    required this.id,
    required this.etat,
    this.texte,
    this.emoji,
    this.grand = false,
    this.libelleAccessibilite,
    this.motEtat,
    this.onToucher,
    this.onPris,
    this.onLache,
  });

  /// Id de l'élément, donnée du glisser.
  final String id;

  final EtatGlissable etat;
  final String? texte;
  final String? emoji;

  /// Texte en content-word (lettres, syllabes).
  final bool grand;

  /// Libellé lu par le lecteur d'écran (une tuile en emoji seul garde un
  /// libellé neutre). Par défaut, le texte.
  final String? libelleAccessibilite;

  /// Mot d'état sous la tuile, en aperçu.
  final String? motEtat;

  /// Toucher sans déplacement. `null` : tuile verrouillée (ni glisser, ni
  /// toucher).
  final VoidCallback? onToucher;

  /// Début et fin d'un glisser (la zone peut marquer l'élément tenu).
  final VoidCallback? onPris;
  final VoidCallback? onLache;

  @override
  State<TuileGlissable> createState() => _TuileGlissableState();
}

class _TuileGlissableState extends State<TuileGlissable> {
  bool _tenue = false;

  Offset _origine() {
    final boite = context.findRenderObject() as RenderBox?;
    return boite?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  void _finDeGlisser(DraggableDetails details) {
    if (!mounted) return;
    setState(() => _tenue = false);
    widget.onLache?.call();
    if (details.wasAccepted) return;
    final origine = _origine();
    // Sans déplacement : un toucher (toucher-toucher), sinon un dépôt hors
    // cible : la tuile revient à sa place.
    if ((details.offset - origine).distance <= kTouchSlop) {
      widget.onToucher?.call();
      return;
    }
    RetourAnime.jouer(
      context,
      depuis: details.offset,
      vers: origine,
      enfant: _Corps(
        widget: widget,
        tenue: true,
        flottante: true,
        langue: ThemeYasmina.langueDe(context),
      ),
      largeur: (context.findRenderObject() as RenderBox?)?.size.width,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onToucher == null) {
      return _Corps(widget: widget, tenue: _tenue);
    }
    // Le toucher est reconnu au plus près de la tuile : il l'emporte sur
    // le toucher d'une zone de dépôt qui la contient (élément posé).
    final corps = GestureDetector(
      onTap: widget.onToucher,
      child: _Corps(widget: widget, tenue: _tenue),
    );
    final boite = context.findRenderObject() as RenderBox?;
    // La copie qui suit le doigt vit dans l'overlay, hors de
    // LangueExercice : elle reçoit la langue d'ici.
    final langue = ThemeYasmina.langueDe(context);
    return Draggable<String>(
      data: widget.id,
      maxSimultaneousDrags: 1,
      onDragStarted: () {
        setState(() => _tenue = true);
        widget.onPris?.call();
      },
      onDragEnd: _finDeGlisser,
      // La tuile tenue suit le doigt, légèrement agrandie.
      feedback: Transform.scale(
        scale: MouvementsYasmina.echelleTenue,
        // Même largeur que la tuile, hauteur naturelle.
        child: SizedBox(
          width: boite?.size.width,
          child: _Corps(
            widget: widget,
            tenue: true,
            flottante: true,
            langue: langue,
          ),
        ),
      ),
      // Sa place reste vide pendant le déplacement.
      childWhenDragging: Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: corps,
      ),
      child: corps,
    );
  }
}

class _Corps extends StatelessWidget {
  const _Corps({
    required this.widget,
    required this.tenue,
    this.flottante = false,
    this.langue,
  });

  final TuileGlissable widget;
  final bool tenue;

  /// Copie qui suit le doigt (dans l'overlay, hors de LangueExercice).
  final bool flottante;

  /// Langue imposée (copie flottante), sinon celle de l'endroit.
  final String? langue;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final langue = this.langue ?? ThemeYasmina.langueDe(context);
    final (fond, bord) = switch (widget.etat) {
      _ when tenue => (c.blueSoft, c.blue),
      EtatGlissable.attente => (c.blueSoft, c.blue),
      EtatGlissable.juste => (c.oliveSoft, c.olive),
      EtatGlissable.faux => (c.coralSoft, c.coral),
      EtatGlissable.repos || EtatGlissable.pose => (c.tile, c.line),
    };
    final styleTexte =
        (widget.grand
                ? ThemeYasmina.pourLangue(StylesYasmina.contentWord, langue)
                : langue == 'ar'
                ? StylesYasmina.contentOption
                : StylesYasmina.latinPrompt)
            .copyWith(color: c.ink);
    return Semantics(
      button: true,
      enabled: widget.onToucher != null,
      selected: widget.etat == EtatGlissable.attente,
      label: widget.libelleAccessibilite ?? widget.texte ?? '',
      excludeSemantics: true,
      child: Material(
        color: fond,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusMd),
          side: BorderSide(color: bord, width: TraitsYasmina.borderThick),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: EspacesYasmina.targetMin,
            minWidth: EspacesYasmina.targetMin,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: EspacesYasmina.space3,
              vertical: EspacesYasmina.space2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.emoji != null)
                  Text(widget.emoji!, style: StylesYasmina.contentWord),
                if (widget.texte != null)
                  Text(
                    widget.texte!,
                    textAlign: TextAlign.center,
                    style: styleTexte,
                  ),
                if (widget.motEtat != null)
                  Text(
                    widget.motEtat!,
                    style: StylesYasmina.latinLabel.copyWith(
                      color: widget.etat == EtatGlissable.faux
                          ? c.coralText
                          : c.oliveText,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Retour animé d'une tuile lâchée hors cible : une copie glisse de
/// [depuis] vers [vers] dans l'overlay, puis disparaît. Aucun mouvement si
/// l'appareil demande moins d'animations.
class RetourAnime extends StatefulWidget {
  const RetourAnime({
    super.key,
    required this.depuis,
    required this.vers,
    required this.enfant,
    required this.largeur,
    required this.onFin,
  });

  final Offset depuis;
  final Offset vers;
  final Widget enfant;

  /// Largeur de la tuile (hauteur naturelle).
  final double largeur;
  final VoidCallback onFin;

  static void jouer(
    BuildContext context, {
    required Offset depuis,
    required Offset vers,
    required Widget enfant,
    double? largeur,
  }) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null || largeur == null) return;
    late final OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => RetourAnime(
        depuis: depuis,
        vers: vers,
        enfant: enfant,
        largeur: largeur,
        onFin: () => entree.remove(),
      ),
    );
    overlay.insert(entree);
  }

  @override
  State<RetourAnime> createState() => _RetourAnimeState();
}

class _RetourAnimeState extends State<RetourAnime>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: MouvementsYasmina.dureeRetour,
  );

  @override
  void initState() {
    super.initState();
    _controleur
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onFin();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controleur,
      builder: (context, _) {
        final position = Offset.lerp(
          widget.depuis,
          widget.vers,
          Curves.easeOut.transform(_controleur.value),
        )!;
        return Positioned(
          left: position.dx,
          top: position.dy,
          width: widget.largeur,
          child: IgnorePointer(child: widget.enfant),
        );
      },
    );
  }
}
