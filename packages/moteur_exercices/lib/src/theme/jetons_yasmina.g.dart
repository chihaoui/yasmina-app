// Fichier généré par tool/generer_theme.dart. Ne pas modifier à la main.
// Source de vérité : docs/design-system/tokens.json

import 'package:flutter/material.dart';

import '../polices.dart';

/// Couleurs du design system, une valeur par thème.
class CouleursYasmina extends ThemeExtension<CouleursYasmina> {
  const CouleursYasmina({
    required this.bg,
    required this.screen,
    required this.surface,
    required this.tile,
    required this.ink,
    required this.muted,
    required this.inkFixed,
    required this.line,
    required this.blue,
    required this.blueSoft,
    required this.onAccent,
    required this.olive,
    required this.oliveSoft,
    required this.oliveText,
    required this.amber,
    required this.amberSoft,
    required this.amberText,
    required this.coral,
    required this.coralSoft,
    required this.coralText,
    required this.sun,
    required this.nodeDone,
    required this.map,
    required this.path,
    required this.water,
    required this.leaf,
    required this.frame,
    required this.subjectAr,
    required this.subjectMa,
    required this.subjectEv,
    required this.seq1,
    required this.seq2,
    required this.seq3,
    required this.seq4,
    required this.seqDefi,
    required this.yasminaPetal,
    required this.yasminaInk,
    required this.yasminaCheek,
  });

  /// Fond derrière le cadre de l'app (aperçu web, back-office). Jamais sous un exercice.
  final Color bg;

  /// Fond des écrans de l'app enfant et de l'espace parent.
  final Color screen;

  /// Barres du haut et du bas, cartes, bulle de Yasmina, cartes de profil.
  final Color surface;

  /// Fond des éléments manipulables : choix, tuiles de lettres, touches du clavier, zones de dépôt.
  final Color tile;

  /// Texte principal et texte des exercices, sur screen, surface, tile, map et tous les fonds -soft (13:1 et plus dans les deux thèmes).
  final Color ink;

  /// Texte secondaire : sous-titres en français, légendes, aides, placeholders. Sur surface, screen et bg (4,7:1 au minimum).
  final Color muted;

  /// Texte posé sur un fond pastel fixe (sun, node-done, subject-ar, subject-ma, subject-ev, seq-*), identique dans les deux thèmes (9:1 et plus). Ne jamais utiliser ink sur ces fonds : en sombre, ink devient clair (1,4:1 sur sun).
  final Color inkFixed;

  /// Bordure des cartes et des choix au repos, séparateurs. Contraste 1,35:1 sur surface : décoratif seulement, l'état sélectionné passe par blue.
  final Color line;

  /// Couleur d'action : bouton principal, sélection, consigne réécoutée, mot mis en évidence, anneau de focus. Texte blue sur surface et blue-soft (5:1 et plus).
  final Color blue;

  /// Fond d'un choix sélectionné, d'un bouton de trimestre actif, d'une case sélectionnée.
  final Color blueSoft;

  /// Texte et icône posés sur blue ou olive pleins (boutons). En sombre, blue et olive s'éclaircissent : le texte devient sombre (blanc ne ferait que 2,5:1). Sur olive en clair : 4,05:1, réservé au grand texte gras (bouton principal en 22 px), jamais au petit texte.
  final Color onAccent;

  /// Réussite : bordure d'un choix juste, bouton Continuer, feedback de validation, maîtrise 80 % et plus. Bouton plein : texte on-accent en corps 22 gras (4:1 en clair).
  final Color olive;

  /// Fond d'une réponse juste et du feedback de validation.
  final Color oliveSoft;

  /// Texte vert de petite taille (pastille Abonné, mot trouvé) sur olive-soft et surface (4,5:1 et plus). Remplace olive pour le texte en clair.
  final Color oliveText;

  /// Indice : bordure du feedback d'indice, étoiles, maîtrise 60 à 79 %, cubes des unités.
  final Color amber;

  /// Fond du feedback d'indice et de la pastille d'essai.
  final Color amberSoft;

  /// Texte ambre de petite taille (pastille Essai) sur amber-soft (5,3:1). Remplace amber pour le texte en clair.
  final Color amberText;

  /// Erreur et explication : bordure d'un choix faux, feedback d'explication, maîtrise sous 60 %. Toujours avec un mot ou une icône, jamais seul.
  final Color coral;

  /// Fond d'une réponse fausse et du feedback d'explication.
  final Color coralSoft;

  /// Texte corail de petite taille (pastille Essai terminé, bouton Réinitialiser) sur coral-soft et surface (5,3:1).
  final Color coralText;

  /// Cœur de Yasmina, étape ouverte sur la carte (texte ink-fixed, 9,5:1 en sombre, 11:1 en clair).
  final Color sun;

  /// Étape terminée sur la carte, texte ink-fixed.
  final Color nodeDone;

  /// Fond de la carte du trimestre.
  final Color map;

  /// Bordure pointillée des étapes hors démo ou à venir sur la carte.
  final Color path;

  /// Eau dans les simulations d'éveil (flotte ou coule).
  final Color water;

  /// Feuilles de Yasmina et végétal des illustrations.
  final Color leaf;

  /// Cadre de téléphone de l'aperçu web et du back-office.
  final Color frame;

  /// Carte de la matière arabe sur l'écran des matières, texte ink-fixed (12:1).
  final Color subjectAr;

  /// Carte de la matière maths, texte ink-fixed.
  final Color subjectMa;

  /// Carte de la matière éveil scientifique, texte ink-fixed.
  final Color subjectEv;

  /// Barre de progression : séquence 1, Découvrir.
  final Color seq1;

  /// Barre de progression : séquence 2, Observer.
  final Color seq2;

  /// Barre de progression : séquence 3, Construire.
  final Color seq3;

  /// Barre de progression : séquence 4, Écrire.
  final Color seq4;

  /// Barre de progression : défi de l'unité.
  final Color seqDefi;

  /// Pétales de Yasmina (même valeur dans les deux thèmes, la mascotte ne change pas).
  final Color yasminaPetal;

  /// Yeux et bouche de Yasmina.
  final Color yasminaInk;

  /// Joues de Yasmina, à 60 % d'opacité.
  final Color yasminaCheek;

  static const clair = CouleursYasmina(
    bg: Color(0xFFE9EFF5),
    screen: Color(0xFFF5F9FD),
    surface: Color(0xFFFFFFFF),
    tile: Color(0xFFFFFFFF),
    ink: Color(0xFF16243A),
    muted: Color(0xFF5A6B82),
    inkFixed: Color(0xFF16243A),
    line: Color(0xFFD5DFEB),
    blue: Color(0xFF1F5FA8),
    blueSoft: Color(0xFFE3EEFB),
    onAccent: Color(0xFFFFFFFF),
    olive: Color(0xFF3E8E4F),
    oliveSoft: Color(0xFFE3F3E3),
    oliveText: Color(0xFF2E7A3F),
    amber: Color(0xFFB7791F),
    amberSoft: Color(0xFFFDF3DF),
    amberText: Color(0xFF8A5A12),
    coral: Color(0xFFC4472F),
    coralSoft: Color(0xFFFBE8E3),
    coralText: Color(0xFFA83A24),
    sun: Color(0xFFFFD978),
    nodeDone: Color(0xFFBFE3C6),
    map: Color(0xFFEAF4EC),
    path: Color(0xFFCFE3D2),
    water: Color(0xFFCFE6F7),
    leaf: Color(0xFF4F9A5A),
    frame: Color(0xFF18212E),
    subjectAr: Color(0xFFFFE6A8),
    subjectMa: Color(0xFFCFE6F7),
    subjectEv: Color(0xFFD7F0D9),
    seq1: Color(0xFFF2B544),
    seq2: Color(0xFF5BA4E6),
    seq3: Color(0xFF7CC48A),
    seq4: Color(0xFFE58AA0),
    seqDefi: Color(0xFF9B7FD1),
    yasminaPetal: Color(0xFFFFFFFF),
    yasminaInk: Color(0xFF22252B),
    yasminaCheek: Color(0xFFF48FA0),
  );

  static const sombre = CouleursYasmina(
    bg: Color(0xFF0E1520),
    screen: Color(0xFF1A2638),
    surface: Color(0xFF162131),
    tile: Color(0xFF223047),
    ink: Color(0xFFE8EEF7),
    muted: Color(0xFF9AABC2),
    inkFixed: Color(0xFF16243A),
    line: Color(0xFF2C3A50),
    blue: Color(0xFF6EA6EC),
    blueSoft: Color(0xFF1F3150),
    onAccent: Color(0xFF0E1520),
    olive: Color(0xFF7CC48A),
    oliveSoft: Color(0xFF1E3324),
    oliveText: Color(0xFF7CC48A),
    amber: Color(0xFFE3AD5A),
    amberSoft: Color(0xFF3A2D17),
    amberText: Color(0xFFE3AD5A),
    coral: Color(0xFFF08A74),
    coralSoft: Color(0xFF3D221D),
    coralText: Color(0xFFF08A74),
    sun: Color(0xFFF5C35A),
    nodeDone: Color(0xFFBFE3C6),
    map: Color(0xFF16271C),
    path: Color(0xFF2A4632),
    water: Color(0xFF1D3A55),
    leaf: Color(0xFF6FB57A),
    frame: Color(0xFF05080D),
    subjectAr: Color(0xFFFFE6A8),
    subjectMa: Color(0xFFCFE6F7),
    subjectEv: Color(0xFFD7F0D9),
    seq1: Color(0xFFF2B544),
    seq2: Color(0xFF5BA4E6),
    seq3: Color(0xFF7CC48A),
    seq4: Color(0xFFE58AA0),
    seqDefi: Color(0xFF9B7FD1),
    yasminaPetal: Color(0xFFFFFFFF),
    yasminaInk: Color(0xFF22252B),
    yasminaCheek: Color(0xFFF48FA0),
  );

  @override
  CouleursYasmina copyWith({
    Color? bg,
    Color? screen,
    Color? surface,
    Color? tile,
    Color? ink,
    Color? muted,
    Color? inkFixed,
    Color? line,
    Color? blue,
    Color? blueSoft,
    Color? onAccent,
    Color? olive,
    Color? oliveSoft,
    Color? oliveText,
    Color? amber,
    Color? amberSoft,
    Color? amberText,
    Color? coral,
    Color? coralSoft,
    Color? coralText,
    Color? sun,
    Color? nodeDone,
    Color? map,
    Color? path,
    Color? water,
    Color? leaf,
    Color? frame,
    Color? subjectAr,
    Color? subjectMa,
    Color? subjectEv,
    Color? seq1,
    Color? seq2,
    Color? seq3,
    Color? seq4,
    Color? seqDefi,
    Color? yasminaPetal,
    Color? yasminaInk,
    Color? yasminaCheek,
  }) => CouleursYasmina(
    bg: bg ?? this.bg,
    screen: screen ?? this.screen,
    surface: surface ?? this.surface,
    tile: tile ?? this.tile,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    inkFixed: inkFixed ?? this.inkFixed,
    line: line ?? this.line,
    blue: blue ?? this.blue,
    blueSoft: blueSoft ?? this.blueSoft,
    onAccent: onAccent ?? this.onAccent,
    olive: olive ?? this.olive,
    oliveSoft: oliveSoft ?? this.oliveSoft,
    oliveText: oliveText ?? this.oliveText,
    amber: amber ?? this.amber,
    amberSoft: amberSoft ?? this.amberSoft,
    amberText: amberText ?? this.amberText,
    coral: coral ?? this.coral,
    coralSoft: coralSoft ?? this.coralSoft,
    coralText: coralText ?? this.coralText,
    sun: sun ?? this.sun,
    nodeDone: nodeDone ?? this.nodeDone,
    map: map ?? this.map,
    path: path ?? this.path,
    water: water ?? this.water,
    leaf: leaf ?? this.leaf,
    frame: frame ?? this.frame,
    subjectAr: subjectAr ?? this.subjectAr,
    subjectMa: subjectMa ?? this.subjectMa,
    subjectEv: subjectEv ?? this.subjectEv,
    seq1: seq1 ?? this.seq1,
    seq2: seq2 ?? this.seq2,
    seq3: seq3 ?? this.seq3,
    seq4: seq4 ?? this.seq4,
    seqDefi: seqDefi ?? this.seqDefi,
    yasminaPetal: yasminaPetal ?? this.yasminaPetal,
    yasminaInk: yasminaInk ?? this.yasminaInk,
    yasminaCheek: yasminaCheek ?? this.yasminaCheek,
  );

  @override
  CouleursYasmina lerp(covariant CouleursYasmina? other, double t) {
    if (other == null) return this;
    return CouleursYasmina(
      bg: Color.lerp(bg, other.bg, t)!,
      screen: Color.lerp(screen, other.screen, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      inkFixed: Color.lerp(inkFixed, other.inkFixed, t)!,
      line: Color.lerp(line, other.line, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      olive: Color.lerp(olive, other.olive, t)!,
      oliveSoft: Color.lerp(oliveSoft, other.oliveSoft, t)!,
      oliveText: Color.lerp(oliveText, other.oliveText, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      amberText: Color.lerp(amberText, other.amberText, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralSoft: Color.lerp(coralSoft, other.coralSoft, t)!,
      coralText: Color.lerp(coralText, other.coralText, t)!,
      sun: Color.lerp(sun, other.sun, t)!,
      nodeDone: Color.lerp(nodeDone, other.nodeDone, t)!,
      map: Color.lerp(map, other.map, t)!,
      path: Color.lerp(path, other.path, t)!,
      water: Color.lerp(water, other.water, t)!,
      leaf: Color.lerp(leaf, other.leaf, t)!,
      frame: Color.lerp(frame, other.frame, t)!,
      subjectAr: Color.lerp(subjectAr, other.subjectAr, t)!,
      subjectMa: Color.lerp(subjectMa, other.subjectMa, t)!,
      subjectEv: Color.lerp(subjectEv, other.subjectEv, t)!,
      seq1: Color.lerp(seq1, other.seq1, t)!,
      seq2: Color.lerp(seq2, other.seq2, t)!,
      seq3: Color.lerp(seq3, other.seq3, t)!,
      seq4: Color.lerp(seq4, other.seq4, t)!,
      seqDefi: Color.lerp(seqDefi, other.seqDefi, t)!,
      yasminaPetal: Color.lerp(yasminaPetal, other.yasminaPetal, t)!,
      yasminaInk: Color.lerp(yasminaInk, other.yasminaInk, t)!,
      yasminaCheek: Color.lerp(yasminaCheek, other.yasminaCheek, t)!,
    );
  }
}

/// Styles de texte. La couleur vient du thème (ink ou muted).
abstract final class StylesYasmina {
  /// Lettre de l'étape sur l'écran d'intro. Famille kid.
  static const letterHero = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 84,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  /// Bulle de Yasmina. Famille kid.
  static const bubble = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 22,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// Bouton principal (Vérifier, Continuer, Commencer). Famille kid.
  static const buttonCta = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );

  /// Consigne de l'exercice dans l'interface. Famille kid.
  static const prompt = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// Titre de la barre du haut. Famille kid.
  static const titleBar = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 18,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  /// Texte d'un choix ou d'une tuile. Famille kid.
  static const option = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  /// Texte du bandeau Feedback (validation, indice, explication). Le libellé au-dessus reste en latin-label ou kid selon la langue. Famille kid.
  static const feedback = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 19,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// Libellé du grand bouton Écouter (IconButton variante listen, T03 et T55). Famille kid.
  static const listen = TextStyle(
    fontFamily: PolicesYasmina.interfaceArabe,
    fontFamilyFallback: [PolicesYasmina.contenuArabe],
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  /// Mot isolé à lire, construire ou repérer. Famille content.
  static const contentWord = TextStyle(
    fontFamily: PolicesYasmina.contenuArabe,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 40,
    height: 1.4,
    fontWeight: FontWeight.w700,
  );

  /// Phrase ou court texte. Interligne large pour les harakat empilées. Famille content.
  static const contentSentence = TextStyle(
    fontFamily: PolicesYasmina.contenuArabe,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 24,
    height: 1.7,
    fontWeight: FontWeight.w600,
  );

  /// Choix de réponse en arabe vocalisé. Famille content.
  static const contentOption = TextStyle(
    fontFamily: PolicesYasmina.contenuArabe,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 22,
    height: 1.6,
    fontWeight: FontWeight.w600,
  );

  /// Consigne en français ou en anglais. Famille latin.
  static const latinPrompt = TextStyle(
    fontFamily: PolicesYasmina.latin,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// Texte courant de l'espace parent. Famille latin.
  static const latinBody = TextStyle(
    fontFamily: PolicesYasmina.latin,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// Libellé du feedback, titre de carte parent. Famille latin.
  static const latinLabel = TextStyle(
    fontFamily: PolicesYasmina.latin,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w700,
  );

  /// Sous-titres, légendes, pastilles. Couleur muted ou -text. Famille latin.
  static const caption = TextStyle(
    fontFamily: PolicesYasmina.latin,
    fontFamilyFallback: [PolicesYasmina.interfaceArabe],
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
}

/// Espacements et marges internes (px).
abstract final class EspacesYasmina {
  /// Écart entre une icône et son libellé.
  static const double space1 = 4;

  /// Écart entre tuiles et entre éléments d'une liste.
  static const double space2 = 8;

  /// Écart entre choix d'une grille.
  static const double space3 = 10;

  /// Écart entre blocs d'un écran, padding des cartes parent.
  static const double space4 = 12;

  /// Marge latérale des écrans d'exercice.
  static const double space5 = 14;

  /// Marge latérale des écrans d'accueil, padding de la carte.
  static const double space6 = 16;

  /// Respiration autour de l'écran de résultat.
  static const double space8 = 24;

  /// Taille minimale de toute cible tactile (décision 3, CLAUDE.md §5).
  static const double targetMin = 48;

  /// Marge interne verticale du bouton principal.
  static const double padButtonY = 12;

  /// Marge interne horizontale du bouton principal.
  static const double padButtonX = 18;

  /// Marge interne verticale de la bulle de Yasmina et du feedback.
  static const double padBubbleY = 8;

  /// Marge interne horizontale de la bulle de Yasmina.
  static const double padBubbleX = 16;

  /// Marge interne verticale du bouton Écouter (variante listen).
  static const double padListenY = 10;

  /// Marge interne horizontale du bouton Écouter (variante listen).
  static const double padListenX = 22;

  /// Marge interne horizontale du bandeau Feedback (verticale : pad-bubble-y).
  static const double padFeedbackX = 12;
}

/// Rayons des coins (px).
abstract final class RayonsYasmina {
  /// Cases de grille, mots touchables dans un texte.
  static const double radiusSm = 8;

  /// Tuiles, boutons secondaires, touches du clavier, boutons de barre.
  static const double radiusMd = 12;

  /// Choix de réponse, zones de dépôt, feedback, toast.
  static const double radiusLg = 14;

  /// Bouton principal, bulle de Yasmina, carte de scène.
  static const double radiusXl = 18;

  /// Cartes de profil et de matière.
  static const double radius2xl = 20;

  /// Pastilles, bouton Écouter, nœuds ronds de la carte (cercle).
  static const double radiusPill = 999;

  /// Coins extérieurs du cadre de téléphone de l'aperçu web.
  static const double radiusFrameOuter = 40;

  /// Coins de l'écran dans le cadre de téléphone de l'aperçu web.
  static const double radiusFrameInner = 28;
}

/// Épaisseurs de trait (px).
abstract final class TraitsYasmina {
  /// Bordure des barres, des cartes parent et des boutons de barre.
  static const double borderThin = 1;

  /// Bordure des choix, tuiles, cartes de profil, bulle et zones de dépôt.
  static const double borderThick = 2;

  /// Bord de début de ligne du feedback (validation, indice, explication).
  static const double borderFeedback = 5;

  /// Épaisseur de l'anneau de focus, en blue.
  static const double focusRing = 3;

  /// Décalage de l'anneau de focus.
  static const double focusOffset = 2;
}

/// Tailles fixes de composants (px).
abstract final class TaillesYasmina {
  /// Hauteur minimale d'un choix de réponse.
  static const double choiceMinHeight = 60;

  /// Avatar rond sur la carte de profil.
  static const double avatarCard = 52;

  /// Diamètre d'une étape sur la carte du trimestre.
  static const double mapNode = 74;

  /// Yasmina à côté de la consigne dans le lecteur.
  static const double yasminaReader = 58;

  /// Yasmina sur l'accueil, l'intro d'étape et le résultat.
  static const double yasminaHome = 110;

  /// Largeur de l'écran dans le cadre de téléphone de l'aperçu web.
  static const double frameWidth = 360;

  /// Hauteur de l'écran dans le cadre de téléphone de l'aperçu web.
  static const double frameHeight = 740;

  /// Icône d'un IconButton (retour, réécoute de la consigne).
  static const double iconMd = 22;

  /// Icône du bouton Écouter (variante listen).
  static const double iconListen = 26;
}

/// Ombres fonctionnelles (relief de touche).
abstract final class OmbresYasmina {
  /// Bouton principal : relief de touche qui s'enfonce au toucher.
  static const shadowPress = BoxShadow(
    color: Color(0x2E000000),
    offset: Offset(0, 5),
    blurRadius: 0,
  );

  /// Étapes de la carte du trimestre.
  static const shadowNode = BoxShadow(
    color: Color(0x26000000),
    offset: Offset(0, 5),
    blurRadius: 0,
  );
}
