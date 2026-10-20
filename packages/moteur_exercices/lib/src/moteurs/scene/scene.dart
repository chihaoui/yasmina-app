import 'package:flutter/material.dart';

import '../../theme/jetons_yasmina.g.dart';
import '../../theme/theme_yasmina.dart';

/// Un élément dessiné de la scène (docs/moteurs/scene-image.md §3) : un
/// emoji centré sur (x, y) de hauteur h, ou une forme dans le rectangle
/// (x, y, l, h), en coordonnées normalisées de 0 à 1.
class ElementScene {
  const ElementScene({
    required this.x,
    required this.y,
    this.emoji,
    this.forme,
    this.couleur = 'line',
    this.l = 0.2,
    this.h = 0.2,
  });

  factory ElementScene.depuisJson(Map<String, dynamic> json) => ElementScene(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    emoji: json['emoji'] as String?,
    forme: json['forme'] as String?,
    couleur: json['couleur'] as String? ?? 'line',
    l: (json['l'] as num?)?.toDouble() ?? 0.2,
    h: (json['h'] as num?)?.toDouble() ?? 0.2,
  );

  final double x;
  final double y;
  final String? emoji;
  final String? forme;
  final String couleur;
  final double l;
  final double h;
}

/// Une zone touchable de la scène, rectangle normalisé.
class ZoneScene {
  const ZoneScene({
    required this.id,
    required this.x,
    required this.y,
    required this.l,
    required this.h,
    this.libelle,
  });

  factory ZoneScene.depuisJson(Map<String, dynamic> json) => ZoneScene(
    id: json['id'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    l: (json['l'] as num).toDouble(),
    h: (json['h'] as num).toDouble(),
    libelle: json['libelle'] as String?,
  );

  final String id;
  final double x;
  final double y;
  final double l;
  final double h;
  final String? libelle;

  /// Rectangle en pixels dans une scène de [taille], élargi autour de son
  /// centre à `target-min` au moins (CLAUDE.md §5).
  Rect rect(Size taille) {
    var r = Rect.fromLTWH(
      x * taille.width,
      y * taille.height,
      l * taille.width,
      h * taille.height,
    );
    if (r.width < EspacesYasmina.targetMin) {
      r = Rect.fromCenter(
        center: r.center,
        width: EspacesYasmina.targetMin,
        height: r.height,
      );
    }
    if (r.height < EspacesYasmina.targetMin) {
      r = Rect.fromCenter(
        center: r.center,
        width: r.width,
        height: EspacesYasmina.targetMin,
      );
    }
    return r;
  }
}

/// Couleur d'un élément de scène, parmi les jetons.
Color couleurScene(CouleursYasmina c, String nom) => switch (nom) {
  'blue' => c.blue,
  'olive' => c.olive,
  'amber' => c.amber,
  'coral' => c.coral,
  'sun' => c.sun,
  _ => c.line,
};

/// La scène dessinée (cadre 4 : 3, fond `tile`) : formes et emoji, puis
/// une zone par élément de [zones], construite par [zone] avec son
/// rectangle en pixels.
class SceneDessinee extends StatelessWidget {
  const SceneDessinee({
    super.key,
    required this.elements,
    required this.zones,
    required this.zone,
  });

  final List<ElementScene> elements;
  final List<ZoneScene> zones;
  final Widget Function(ZoneScene zone, Rect rect) zone;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.tile,
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
          border: Border.all(color: c.line, width: TraitsYasmina.borderThin),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
          child: LayoutBuilder(
            builder: (context, contraintes) {
              final taille = Size(contraintes.maxWidth, contraintes.maxHeight);
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        key: const ValueKey('scene_formes'),
                        painter: PeintreScene(elements: elements, couleurs: c),
                      ),
                    ),
                    for (final (i, e) in elements.indexed)
                      if (e.emoji case final emoji?)
                        Positioned(
                          left: e.x * taille.width - e.h * taille.height / 2,
                          top: e.y * taille.height - e.h * taille.height / 2,
                          width: e.h * taille.height,
                          height: e.h * taille.height,
                          child: ExcludeSemantics(
                            child: FittedBox(
                              key: ValueKey('scene_emoji_$i'),
                              child: Text(
                                emoji,
                                style: StylesYasmina.contentWord,
                              ),
                            ),
                          ),
                        ),
                    for (final z in zones)
                      Positioned.fromRect(
                        rect: z.rect(taille),
                        child: zone(z, z.rect(taille)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Peint les formes de la scène (les emoji sont des widgets).
class PeintreScene extends CustomPainter {
  const PeintreScene({required this.elements, required this.couleurs});

  final List<ElementScene> elements;
  final CouleursYasmina couleurs;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in elements) {
      final forme = e.forme;
      if (forme == null) continue;
      final r = Rect.fromLTWH(
        e.x * size.width,
        e.y * size.height,
        e.l * size.width,
        e.h * size.height,
      );
      final peinture = Paint()..color = couleurScene(couleurs, e.couleur);
      switch (forme) {
        case 'cercle':
          canvas.drawOval(r, peinture);
        case 'carre':
          final cote = r.shortestSide;
          canvas.drawRect(
            Rect.fromCenter(center: r.center, width: cote, height: cote),
            peinture,
          );
        case 'triangle':
          canvas.drawPath(
            Path()
              ..moveTo(r.center.dx, r.top)
              ..lineTo(r.right, r.bottom)
              ..lineTo(r.left, r.bottom)
              ..close(),
            peinture,
          );
        default:
          canvas.drawRect(r, peinture);
      }
    }
  }

  @override
  bool shouldRepaint(PeintreScene ancien) =>
      ancien.elements != elements || ancien.couleurs != couleurs;
}
