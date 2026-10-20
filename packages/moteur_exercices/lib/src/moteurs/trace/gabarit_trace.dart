import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../composants/bouton_icone.dart';
import '../../composants/bouton_yasmina.dart';
import '../../composants/tuile_choix.dart';
import '../../lecteur/config_exercice.dart';
import '../../lecteur/contrat_moteur.dart';
import '../../lecteur/deroule_exercice.dart';
import '../../lecteur/libelles_lecteur.dart';
import '../../polices.dart';
import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Une forme de la lettre à tracer (docs/moteurs/trace.md §4) : son glyphe,
/// sa position et ses traits de guidage, en points normalisés (0 à 1) de
/// la zone de tracé, dans le sens d'écriture.
class FormeTrace {
  const FormeTrace({
    required this.id,
    required this.texte,
    required this.position,
    this.traits = const [],
  });

  factory FormeTrace.depuisJson(Map<String, dynamic> json) => FormeTrace(
    id: json['id'] as String,
    texte: json['texte'] as String,
    position: json['position'] as String,
    traits: [
      for (final trait in (json['traits'] as List? ?? const []).cast<List>())
        [
          for (final p in trait.cast<Map<String, dynamic>>())
            Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()),
        ],
    ],
  );

  final String id;
  final String texte;
  final String position;
  final List<List<Offset>> traits;
}

/// T20 Tracé de lettre, non noté (docs/moteurs/trace.md) : l'enfant choisit
/// une forme de la lettre, suit les points avec le doigt, peut effacer, et
/// Continuer s'active dès que les formes demandées sont tracées.
class GabaritTrace implements GabaritReponse {
  const GabaritTrace();

  @override
  ModeValidation get validation => ModeValidation.sansNote;

  @override
  ControleurTrace creerControleur(
    Map<String, dynamic> exercice,
    ConfigExercice config,
  ) {
    final donnees = exercice['donnees'] as Map<String, dynamic>;
    final reponse = exercice['reponse'] as Map<String, dynamic>;
    return ControleurTrace(
      config: config,
      lettre: donnees['lettre'] as String,
      formes: [
        for (final f
            in (donnees['formes'] as List).cast<Map<String, dynamic>>())
          FormeTrace.depuisJson(f),
      ],
      requises: (reponse['formes'] as List).cast<String>().toSet(),
      ecoute: (donnees['ecoute'] as Map<String, dynamic>?)?['texte'] as String?,
    );
  }

  @override
  Widget construire(BuildContext context, ControleurReponse controleur) =>
      _ZoneTrace(controleur as ControleurTrace);
}

/// Les tracés de l'enfant, par forme, en coordonnées normalisées (0 à 1) de
/// la zone de tracé. Rien n'est jugé : une forme compte comme tracée dès
/// que son encre cumule [longueurMinimale] (tolérance large, trace.md §3).
///
/// Pendant un trait, seule [encre] change (repeint de la zone) : le lecteur
/// n'est prévenu qu'à la fin du trait, quand la réponse peut avoir changé.
class ControleurTrace extends ControleurReponse {
  ControleurTrace({
    required this.config,
    required this.lettre,
    required this.formes,
    required this.requises,
    this.ecoute,
  }) : _formeCourante = formes.first.id;

  final ConfigExercice config;

  /// Longueur d'encre (en largeurs de zone) à partir de laquelle une forme
  /// est tracée.
  static const longueurMinimale = 0.25;

  final String lettre;
  final List<FormeTrace> formes;

  /// Formes à tracer pour que Continuer s'active (`reponse.formes`).
  final Set<String> requises;

  /// Nom de la lettre, dit après la consigne et au toucher du bouton.
  final String? ecoute;

  String _formeCourante;
  bool _enCours = false;
  final _traits = <String, List<List<Offset>>>{};

  /// Change à chaque point d'encre ajouté (repeint de la zone).
  final encre = ValueNotifier<int>(0);

  String get formeCourante => _formeCourante;

  FormeTrace get forme => formes.firstWhere((f) => f.id == _formeCourante);

  /// Traits tracés sur la forme [id].
  List<List<Offset>> traits(String id) => _traits[id] ?? const [];

  void choisirForme(String id) {
    if (!modifiable || id == _formeCourante) return;
    _formeCourante = id;
    _enCours = false;
    notifyListeners();
  }

  void commencerTrait(Offset point) {
    if (!modifiable) return;
    (_traits[_formeCourante] ??= []).add([point]);
    _enCours = true;
    encre.value++;
  }

  void prolongerTrait(Offset point) {
    if (!modifiable || !_enCours) return;
    _traits[_formeCourante]!.last.add(point);
    encre.value++;
  }

  void finirTrait() {
    if (!_enCours) return;
    _enCours = false;
    reponseModifiee();
  }

  /// Vide le tracé de la forme affichée seulement.
  void effacer() {
    if (!modifiable) return;
    _traits.remove(_formeCourante);
    _enCours = false;
    encre.value++;
    reponseModifiee();
  }

  /// Longueur cumulée de l'encre de la forme [id], en largeurs de zone.
  double longueur(String id) {
    var total = 0.0;
    for (final trait in traits(id)) {
      for (var i = 1; i < trait.length; i++) {
        total += (trait[i] - trait[i - 1]).distance;
      }
    }
    return total;
  }

  bool estTracee(String id) => longueur(id) >= longueurMinimale;

  @override
  bool get complete => requises.every(estTracee);

  @override
  Object? get reponse => {
    'formes': [
      for (final f in formes)
        if (estTracee(f.id)) f.id,
    ],
  };

  @override
  bool corriger() => complete;

  @override
  void vider() {
    _traits.clear();
    _enCours = false;
    _formeCourante = formes.first.id;
    encre.value++;
    reponseModifiee();
  }

  @override
  String? get ecouteOuverture => ecoute;

  @override
  void dispose() {
    encre.dispose();
    super.dispose();
  }
}

/// Le nom de la lettre, les formes en boutons (glyphe seul, sans
/// sous-titre), la zone de tracé, puis Effacer.
class _ZoneTrace extends StatelessWidget {
  const _ZoneTrace(this.controleur);

  final ControleurTrace controleur;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final config = controleur.config;
    final langue = config.langue;
    final libelles = LibellesLecteur.pour(langue, config.formeAdresse);
    return ListenableBuilder(
      listenable: controleur,
      builder: (context, _) {
        final modifiable = controleur.modifiable;
        final revelee = controleur.affichage == AffichageReponse.revelee;
        final courante = controleur.formeCourante;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: EspacesYasmina.space4,
          children: [
            if (controleur.ecoute case final ecoute?)
              Center(
                child: BoutonEcouter(
                  key: const ValueKey('trace_ecouter'),
                  libelle: libelles.ecouter,
                  onPressed: () =>
                      controleur.demanderAudio(ecoute, langue: langue),
                ),
              ),
            Wrap(
              key: const ValueKey('trace_formes'),
              alignment: WrapAlignment.center,
              spacing: EspacesYasmina.space2,
              runSpacing: EspacesYasmina.space2,
              children: [
                for (final f in controleur.formes)
                  TuileChoix(
                    key: ValueKey('forme_${f.id}'),
                    etat: f.id == courante
                        ? EtatTuile.selectionne
                        : EtatTuile.repos,
                    texte: f.texte,
                    grand: true,
                    onTap: modifiable
                        ? () => controleur.choisirForme(f.id)
                        : null,
                  ),
              ],
            ),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: LayoutBuilder(
                builder: (context, contraintes) {
                  final taille = Size(
                    contraintes.maxWidth,
                    contraintes.maxHeight,
                  );
                  Offset normaliser(Offset p) => Offset(
                    (p.dx / taille.width).clamp(0, 1),
                    (p.dy / taille.height).clamp(0, 1),
                  );
                  return Semantics(
                    image: true,
                    label: controleur.lettre,
                    child: GestureDetector(
                      key: const ValueKey('trace_zone'),
                      behavior: HitTestBehavior.opaque,
                      onPanStart: modifiable
                          ? (d) => controleur.commencerTrait(
                              normaliser(d.localPosition),
                            )
                          : null,
                      onPanUpdate: modifiable
                          ? (d) => controleur.prolongerTrait(
                              normaliser(d.localPosition),
                            )
                          : null,
                      onPanEnd: modifiable
                          ? (_) => controleur.finirTrait()
                          : null,
                      onPanCancel: modifiable ? controleur.finirTrait : null,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.tile,
                          borderRadius: BorderRadius.circular(
                            RayonsYasmina.radiusLg,
                          ),
                          border: Border.all(
                            color: c.line,
                            width: TraitsYasmina.borderThick,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            RayonsYasmina.radiusLg,
                          ),
                          child: ValueListenableBuilder<int>(
                            valueListenable: controleur.encre,
                            builder: (context, _, _) => CustomPaint(
                              key: ValueKey(
                                revelee ? 'trace_reponse' : 'trace_dessin',
                              ),
                              size: Size.infinite,
                              painter: PeintreTrace(
                                forme: controleur.forme,
                                traits: revelee
                                    ? const []
                                    : controleur.traits(courante),
                                couleurLettre: revelee ? c.olive : c.line,
                                couleurGuide: revelee ? c.olive : c.muted,
                                couleurDepart: revelee ? c.olive : c.blue,
                                couleurEncre: c.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            BoutonYasmina(
              key: const ValueKey('trace_effacer'),
              libelle: libelles.effacer,
              variante: VarianteBouton.alt,
              icone: Icons.cleaning_services_rounded,
              onPressed: modifiable && controleur.traits(courante).isNotEmpty
                  ? controleur.effacer
                  : null,
            ),
          ],
        );
      },
    );
  }
}

/// Peint la lettre modèle (naskh, en gris), le guidage (points dans le sens
/// d'écriture, point de départ et flèche au bout de chaque trait) et
/// l'encre de l'enfant.
class PeintreTrace extends CustomPainter {
  const PeintreTrace({
    required this.forme,
    required this.traits,
    required this.couleurLettre,
    required this.couleurGuide,
    required this.couleurDepart,
    required this.couleurEncre,
  });

  final FormeTrace forme;

  /// Encre de l'enfant, en coordonnées normalisées.
  final List<List<Offset>> traits;

  final Color couleurLettre;
  final Color couleurGuide;
  final Color couleurDepart;
  final Color couleurEncre;

  // design-ok : épaisseur de l'encre et pas des points de guidage, sans
  // jeton (question 4 de docs/moteurs/trace-questions.md).
  static const epaisseurEncre = 18.0;
  static const _pasGuide = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    _peindreLettre(canvas, size);
    for (final trait in forme.traits) {
      _peindreGuide(canvas, size, trait);
    }
    _peindreEncre(canvas, size);
  }

  void _peindreLettre(Canvas canvas, Size size) {
    final peintre = TextPainter(
      text: TextSpan(
        text: forme.texte,
        style: StylesYasmina.letterHero.copyWith(
          fontFamily: PolicesYasmina.contenuArabe,
          fontFamilyFallback: const [PolicesYasmina.interfaceArabe],
          // design-ok : la lettre remplit la zone de tracé (question 4).
          fontSize: size.height * 0.7,
          color: couleurLettre,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    peintre.paint(
      canvas,
      Offset(
        (size.width - peintre.width) / 2,
        (size.height - peintre.height) / 2,
      ),
    );
  }

  Offset _absolu(Offset p, Size size) =>
      Offset(p.dx * size.width, p.dy * size.height);

  void _peindreGuide(Canvas canvas, Size size, List<Offset> trait) {
    if (trait.isEmpty) return;
    final points = [for (final p in trait) _absolu(p, size)];
    final pas = size.width * _pasGuide;
    final guide = Paint()..color = couleurGuide;
    // Points réguliers le long du trait.
    var reste = pas;
    for (var i = 1; i < points.length; i++) {
      final segment = points[i] - points[i - 1];
      final longueur = segment.distance;
      var parcouru = reste;
      while (parcouru < longueur) {
        canvas.drawCircle(
          points[i - 1] + segment * (parcouru / longueur),
          EspacesYasmina.space1,
          guide,
        );
        parcouru += pas;
      }
      reste = parcouru - longueur;
    }
    // Point de départ, plus gros.
    canvas.drawCircle(
      points.first,
      EspacesYasmina.space2,
      Paint()..color = couleurDepart,
    );
    // Flèche au bout du trait, dans son sens (aucune pour un point).
    final dernier = points.last;
    var avant = points.length - 2;
    while (avant >= 0 && (dernier - points[avant]).distance < pas) {
      avant--;
    }
    if (avant < 0) return;
    final direction = (dernier - points[avant]).direction;
    final fleche = Paint()
      ..color = couleurDepart
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraitsYasmina.borderThick
      ..strokeCap = StrokeCap.round;
    for (final angle in [
      direction + math.pi * 5 / 6,
      direction - math.pi * 5 / 6,
    ]) {
      canvas.drawLine(
        dernier,
        dernier + Offset.fromDirection(angle, EspacesYasmina.space3),
        fleche,
      );
    }
  }

  void _peindreEncre(Canvas canvas, Size size) {
    final plein = Paint()..color = couleurEncre;
    final trait = Paint()
      ..color = couleurEncre
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseurEncre
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final t in traits) {
      final points = [for (final p in t) _absolu(p, size)];
      if (points.length == 1) {
        canvas.drawCircle(points.single, epaisseurEncre / 2, plein);
        continue;
      }
      final chemin = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        chemin.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(chemin, trait);
    }
  }

  @override
  bool shouldRepaint(PeintreTrace ancien) =>
      ancien.forme != forme ||
      ancien.traits != traits ||
      ancien.couleurLettre != couleurLettre ||
      ancien.couleurGuide != couleurGuide ||
      ancien.couleurDepart != couleurDepart ||
      ancien.couleurEncre != couleurEncre;
}
