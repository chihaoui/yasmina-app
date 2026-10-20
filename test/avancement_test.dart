import 'package:flutter_test/flutter_test.dart';

import '../tool/avancement.dart';

/// PROGRESS.md réduit : A0, A1, A2, [A3], B, un journal daté. Les 53 types
/// sont portés par deux plages (T01 à T36, T37 à T53).
String progres({bool avecA3 = true}) =>
    '''
# Suivi
<!-- avancement:debut -->
ancien bloc
<!-- avancement:fin -->

## A0 : mise en place (19 oct. au 1er nov. 2026)
- [x] A0-01 Dépôt GitHub privé (0,25 j-h)
- [ ] A0-02 Aperçu web (apps/apercu_web) (0,75 j-h)
  - [x] Sous-case sans estimation (ne compte pas)

## A1 : lot 1 (2 nov. au 31 déc. 2026)
- [ ] A1-01 Moteurs du lot 1 (T01 à T36) (10 j-h)

## A2 : lot 2 (4 janv. au 28 févr. 2027)
- [ ] A2-01 Moteurs du lot 2 (T37 à T53) (5 j-h)
${avecA3 ? '''
## A3 : parcours et espace parent (1er au 14 mars 2027)
- [ ] A3-01 Carte du trimestre (2 j-h)
- [x] A3-02 Progression locale (1,25 j-h)
''' : ''}
## B : back-end (15 mars au 30 avril 2027)
- [ ] B-01 Supabase (3 j-h)

## Journal
| Date | Session | Fait | Suite |
|---|---|---|---|
| 20 oct. 2026 | Test | Rien | Rien |
''';

/// docs/estimations-taches.md réduit, avec la colonne Plan (décision 37) et
/// les totaux déclarés.
String estimations({
  bool avecA3 = true,
  String jhA0_02 = '0,75',
  String totalEnVigueur = '22,25',
  String totalAuPlan = '34,75',
}) =>
    '''
# Estimations

## Phase A0

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A0-01 | L03 | Dépôt GitHub privé | 0,25 | 0,25 | fait |
| A0-02 | L04 | Aperçu web (apps/apercu_web) | $jhA0_02 | 1,5 | à faire |

## Phase A1

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A1-01 | L04 | Moteurs du lot 1 | 10 | 15 | à faire |

## Phase A2

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A2-01 | L04 | Moteurs du lot 2 | 5 | 6 | à faire |
${avecA3 ? '''
## Phase A3

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A3-01 | L05 | Carte du trimestre | 2 | 4 | à faire |
| A3-02 | L03 | Progression locale | 1,25 | 2 | fait |
''' : ''}
## Phase B

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| B-01 | L07 | Supabase | 3 | 6 | à faire |

## Contrôle

Total en vigueur : $totalEnVigueur j-h. Total au plan : $totalAuPlan j-h.
''';

/// Ancien format : sans colonne Plan ni total déclaré.
const estimationsSansPlan = '''
| Id | Lot | Tâche | j-h | Statut |
|---|---|---|---|---|
| A0-01 | L03 | Dépôt GitHub privé | 0,25 | fait |
| A0-02 | L04 | Aperçu web (apps/apercu_web) | 0,75 | à faire |
| A1-01 | L04 | Moteurs du lot 1 | 10 | à faire |
| A2-01 | L04 | Moteurs du lot 2 | 5 | à faire |
| B-01 | L07 | Supabase | 3 | à faire |
''';

void main() {
  test('phase A3 entre A2 et B, calcul sur la colonne j-h, total', () {
    final bloc = calculerBloc(progres(), estimations());
    final lignes = bloc.split('\n');
    expect(lignes, contains('| A0 | 0,25 | 1 | 25 % |'));
    expect(lignes, contains('| A1 | 0 | 10 | 0 % |'));
    expect(lignes, contains('| A2 | 0 | 5 | 0 % |'));
    expect(lignes, contains('| A3 | 1,25 | 3,25 | 38 % |'));
    expect(lignes, contains('| B | 0 | 3 | 0 % |'));
    expect(
      lignes.indexWhere((l) => l.startsWith('| A3 |')),
      lignes.indexWhere((l) => l.startsWith('| A2 |')) + 1,
    );
    // 0,25 + 1,25 faits sur 22,25 en vigueur (le plan, 34,75, ne compte pas).
    expect(lignes, contains('| **Total** | **1,5** | **22,25** | **6,7 %** |'));
    expect(bloc, contains('Avancement global : 6,7 %'));
    expect(bloc, contains('Types jouables : 0 sur 53'));
    expect(bloc, contains('Au 20 oct. 2026.'));
  });

  test('sans phase A3 ni colonne Plan : aucune ligne A3, ancien format lu', () {
    final bloc = calculerBloc(progres(avecA3: false), estimationsSansPlan);
    expect(bloc, isNot(contains('| A3 |')));
    expect(bloc, contains('| **Total** | **0,25** | **19** | **1,3 %** |'));
  });

  test('lireEstimations : j-h en vigueur et plan facultatif', () {
    final avec = lireEstimations(estimations());
    expect(avec['A0-02'], (jh: 0.75, plan: 1.5));
    expect(avec['A3-02'], (jh: 1.25, plan: 2.0));
    expect(avec, hasLength(7));
    final sans = lireEstimations(estimationsSansPlan);
    expect(sans['A0-02'], (jh: 0.75, plan: null));
  });

  test(
    'estimation différente entre les deux fichiers : la tâche est nommée',
    () {
      expect(
        () => calculerBloc(
          progres(),
          estimations(jhA0_02: '1,5', totalEnVigueur: '23'),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('A0-02 : 0,75 j-h au lieu de 1,5'),
          ),
        ),
      );
    },
  );

  test('tâche présente dans un seul fichier : erreur', () {
    expect(
      () => calculerBloc(progres(), estimations(avecA3: false)),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('A3-01 absente de docs/estimations-taches.md'),
            contains('A3-02 absente de docs/estimations-taches.md'),
          ),
        ),
      ),
    );
  });

  test('total déclaré différent de la somme : erreur avec l\'écart', () {
    expect(
      () => calculerBloc(progres(), estimations(totalEnVigueur: '22')),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('total en vigueur de 22 j-h'),
            contains('22,25 j-h'),
            contains('écart 0,25'),
          ),
        ),
      ),
    );
    expect(
      () => calculerBloc(progres(), estimations(totalAuPlan: '30')),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('total au plan de 30 j-h'), contains('34,75 j-h')),
        ),
      ),
    );
  });

  test('estimation illisible dans un tableau : erreur', () {
    final casse = estimations().replaceFirst('| 0,25 | 0,25 |', '| 0,25 | x |');
    expect(
      () => lireEstimations(casse),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('A0-01 : estimation du plan « x » illisible'),
        ),
      ),
    );
  });
}
