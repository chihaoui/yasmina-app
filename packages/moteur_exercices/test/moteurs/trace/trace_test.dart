import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../choix/outils_choix.dart';
import 'fixtures_trace.dart';

/// T20 Tracé de lettre, non noté (docs/moteurs/trace.md) : vrai geste de
/// tracé au doigt, formes en boutons sans sous-titre, tolérance, Effacer,
/// Continuer sans correction ni feedback, aperçu.
void main() {
  late Partie p;

  PeintreTrace peintre(WidgetTester tester) =>
      tester.widget<CustomPaint>(p.cle('trace_dessin')).painter!
          as PeintreTrace;

  /// Un trait du doigt dans la zone, de droite à gauche, long de [pas] ×
  /// [etapes] pixels.
  Future<void> tracer(
    WidgetTester tester, {
    double pas = 80,
    int etapes = 3,
    Offset depart = Offset.zero,
  }) async {
    final geste = await tester.startGesture(
      tester.getCenter(p.cle('trace_zone')) + depart,
    );
    for (var i = 0; i < etapes; i++) {
      await geste.moveBy(Offset(-pas, 0));
      await tester.pump();
    }
    await geste.up();
    await tester.pump();
  }

  testWidgets('ب : nom de la lettre dit après la consigne, 4 formes sans '
      'sous-titre, la 1re choisie, Continuer inactif', (tester) async {
    p = Partie(tester);
    await p.jouer(exempleTrace('T20-ba.json'));
    expect(p.sens, TextDirection.rtl);
    expect(p.audio.audioFactice.dits.map((d) => d.texte), [
      'اِتْبَعِ النُّقَطَ وَارْسُمْ حَرْفَ الْبَاءِ.',
      'بَاءٌ',
    ]);
    await p.toucher('trace_ecouter');
    expect(p.audio.audioFactice.dits.last.texte, 'بَاءٌ');
    // Les formes : glyphe seul, dans l'ordre du JSON, isolée à droite.
    final formes = tester.widgetList<TuileChoix>(
      find.descendant(
        of: p.cle('trace_formes'),
        matching: find.byType(TuileChoix),
      ),
    );
    expect(formes.map((f) => f.texte), ['ب', 'بـ', 'ـبـ', 'ـب']);
    expect(formes.every((f) => f.emoji == null && f.motEtat == null), isTrue);
    expect(
      tester.getCenter(p.cle('forme_f1')).dx,
      greaterThan(tester.getCenter(p.cle('forme_f2')).dx),
    );
    expect(p.etat('forme_f1'), EtatTuile.selectionne);
    expect(p.etat('forme_f2'), EtatTuile.repos);
    expect(peintre(tester).forme.id, 'f1');
    expect(peintre(tester).forme.traits, hasLength(2));
    expect(peintre(tester).traits, isEmpty);
    // Non noté : Continuer dès l'ouverture, inactif tant que rien n'est
    // tracé. Effacer inactif.
    expect(p.bouton.libelle, 'وَاصِلْ');
    expect(p.bouton.onPressed, isNull);
    expect(
      tester.widget<BoutonYasmina>(p.cle('trace_effacer')).onPressed,
      isNull,
    );
    expect(p.reponsesDonnees, isEmpty);
  });

  testWidgets('vrai geste : l\'encre suit le doigt, un trait trop court ne '
      'compte pas, puis la forme est tracée, Continuer, résultat terminé '
      'sans feedback ni son', (tester) async {
    p = Partie(tester);
    await p.jouer(exempleTrace('T20-ba.json'));
    // Trait court (60 px sur 772 de large) : de l'encre, pas de réponse.
    await tracer(tester, pas: 20);
    expect(peintre(tester).traits, hasLength(1));
    expect(peintre(tester).traits.single, hasLength(4));
    expect(p.reponsesDonnees, isEmpty);
    expect(p.bouton.onPressed, isNull);
    expect(
      tester.widget<BoutonYasmina>(p.cle('trace_effacer')).onPressed,
      isNotNull,
    );
    // Un deuxième trait, assez long : la forme isolée est tracée.
    await tracer(tester, depart: const Offset(0, 30));
    expect(peintre(tester).traits, hasLength(2));
    expect(p.reponsesDonnees, [
      {
        'formes': ['f1'],
      },
    ]);
    expect(p.bouton.onPressed, isNotNull);
    expect(p.humeur, HumeurYasmina.neutre);
    await p.verifier();
    await tester.pumpAndSettle();
    expect(p.resultat, const Resultat(IssueExercice.termine, essais: 0));
    expect(p.essais, isEmpty);
    expect(find.byType(BandeauFeedback), findsNothing);
    expect(p.audio.audioFactice.sons, isEmpty);
    expect(p.humeur, HumeurYasmina.neutre);
    // Après Continuer, la zone est verrouillée.
    await tracer(tester);
    expect(peintre(tester).traits, hasLength(2));
  });

  testWidgets('chaque forme garde son tracé, Effacer vide la forme '
      'affichée seulement, forme féminine des libellés', (tester) async {
    p = Partie(tester);
    await p.jouer(exempleTrace('T20-lam.json'), forme: FormeAdresse.feminin);
    expect(p.bouton.libelle, 'وَاصِلِي');
    expect(
      tester.widget<BoutonYasmina>(p.cle('trace_effacer')).libelle,
      'اِمْسَحِي',
    );
    await tracer(tester);
    expect(p.reponsesDonnees.last, {
      'formes': ['f1'],
    });
    await p.toucher('forme_f2');
    expect(p.etat('forme_f2'), EtatTuile.selectionne);
    expect(peintre(tester).forme.texte, 'لـ');
    expect(peintre(tester).traits, isEmpty);
    await tracer(tester);
    expect(p.reponsesDonnees.last, {
      'formes': ['f1', 'f2'],
    });
    await p.toucher('trace_effacer');
    expect(peintre(tester).traits, isEmpty);
    expect(p.reponsesDonnees.last, {
      'formes': ['f1'],
    });
    // La forme isolée a gardé son encre : Continuer reste actif.
    await p.toucher('forme_f1');
    expect(peintre(tester).traits, hasLength(1));
    expect(p.bouton.onPressed, isNotNull);
  });

  testWidgets('aperçu : afficher la réponse montre la lettre et son guidage '
      'sans encre, Rejouer efface tout', (tester) async {
    p = Partie(tester);
    await p.jouer(exempleTrace('T20-mim.json'), mode: ModeExercice.apercu);
    await tracer(tester);
    expect(peintre(tester).traits, hasLength(1));
    await tester.tap(p.cle('lecteur_afficher_reponse'));
    await tester.pump();
    expect(p.cle('trace_dessin'), findsNothing);
    final revele =
        tester.widget<CustomPaint>(p.cle('trace_reponse')).painter!
            as PeintreTrace;
    expect(revele.traits, isEmpty);
    expect(revele.forme.traits, isNotEmpty);
    expect(revele.couleurLettre, revele.couleurGuide);
    // Verrouillé : les formes ne se changent plus.
    expect(tester.widget<TuileChoix>(p.cle('forme_f2')).onTap, isNull);
    await tester.tap(p.cle('lecteur_rejouer'));
    await tester.pump();
    expect(peintre(tester).traits, isEmpty);
    expect(p.etat('forme_f1'), EtatTuile.selectionne);
    // Aucun événement de progression en aperçu.
    expect(p.evenements!.whereType<Resultat>(), isEmpty);
  });
}
