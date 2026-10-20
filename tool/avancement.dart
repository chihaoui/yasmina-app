// Recalcule le bloc Avancement de PROGRESS.md à partir des cases de premier
// niveau et de leur estimation en jours-homme « (X j-h) ».
//
// Usage, depuis la racine du dépôt :
//   dart run tool/avancement.dart              réécrit le bloc
//   dart run tool/avancement.dart --verifier   échoue si le bloc n'est pas à jour
//
// Échoue aussi si une tâche de PROGRESS.md (id et j-h) diffère de
// docs/estimations-taches.md, si l'une des deux listes en a une de plus, ou
// si un total déclaré dans docs/estimations-taches.md (« Total en vigueur »,
// « Total au plan ») ne correspond pas à la somme de sa colonne.
//
// Les tableaux de docs/estimations-taches.md sont lus par leur en-tête : la
// colonne « j-h » est l'estimation en vigueur, la colonne facultative
// « Plan » (estimation initiale, décision 37) est ignorée par le calcul et
// seulement sommée pour le contrôle du total au plan.
//
// Testé par test/avancement_test.dart (flutter test à la racine).
import 'dart:io';

/// Phases connues, dans l'ordre d'affichage. Seules celles qui ont au moins
/// une tâche dans PROGRESS.md apparaissent dans le bloc.
const phases = ['A0', 'A1', 'A2', 'A3', 'B', 'C', 'D'];

/// Phases dont les cases portent les types d'exercices (moteurs).
const _phasesTypes = {'A1', 'A2'};
// 53 au catalogue v3.1, T20 Tracé de lettre retiré du MVP le 20 oct. 2026.
const _typesAttendus = 52;

const _debut = '<!-- avancement:debut -->';
const _fin = '<!-- avancement:fin -->';

final _titrePhase = RegExp('^## (${phases.join('|')}) :');
final _casePremierNiveau = RegExp(r'^- \[([ x])\] (.*)$');
final _sousCase = RegExp(r'^\s+- \[([ x])\] (.*)$');
final _estimation = RegExp(r'\((\d+(?:,\d+)?) j-h\)$');
final _idTache = RegExp('^((?:${phases.join('|')})-\\d\\d[a-z]?) ');
final _idSeul = RegExp('^(?:${phases.join('|')})-\\d\\d[a-z]?\$');
final _nombreSeul = RegExp(r'^\d+(?:,\d+)?$');
final _totalDeclare = RegExp(
  r'Total (en vigueur|au plan) : (\d+(?:,\d+)?) j-h',
);
final _dateJournal = RegExp(r'^\| (\d{1,2} [^|]+ \d{4}) \|');
final _plageTypes = RegExp(r'T(\d\d) à T(\d\d)');
final _type = RegExp(r'T(\d\d)');

void main(List<String> arguments) {
  final racine = File.fromUri(Platform.script).parent.parent.path;
  final fichierProgres = File('$racine/PROGRESS.md');
  final fichierEstimations = File('$racine/docs/estimations-taches.md');

  try {
    final progres = fichierProgres.readAsStringSync();
    final bloc = calculerBloc(progres, fichierEstimations.readAsStringSync());
    final i = progres.indexOf(_debut);
    final j = progres.indexOf(_fin);
    if (i < 0 || j < i) {
      throw FormatException('marqueurs $_debut et $_fin absents.');
    }
    final actuel = progres.substring(i, j + _fin.length);

    if (arguments.contains('--verifier')) {
      if (actuel != bloc) {
        stderr
          ..writeln('Le bloc Avancement de PROGRESS.md n\'est pas à jour.')
          ..writeln('Lancer : dart run tool/avancement.dart')
          ..writeln('\nBloc attendu :\n$bloc');
        exit(1);
      }
      stdout.writeln('Bloc Avancement à jour.');
    } else {
      fichierProgres.writeAsStringSync(
        progres.replaceRange(i, j + _fin.length, bloc),
      );
      stdout.writeln('Bloc Avancement réécrit.');
    }
  } on FormatException catch (e) {
    stderr.writeln('Erreur : ${e.message}');
    exit(1);
  }
}

/// Une ligne de tableau de docs/estimations-taches.md : estimation en
/// vigueur et, si la colonne existe, estimation initiale du plan.
typedef EstimationTache = ({double jh, double? plan});

/// Lit les tableaux de [estimations] par leur en-tête (« Id », « j-h »,
/// « Plan » facultative). Un tableau sans colonne « j-h » est ignoré.
Map<String, EstimationTache> lireEstimations(String estimations) {
  final taches = <String, EstimationTache>{};
  int? colonneId;
  int? colonneJh;
  int? colonnePlan;
  for (final ligne in estimations.split('\n')) {
    if (!ligne.startsWith('|')) {
      colonneId = colonneJh = colonnePlan = null;
      continue;
    }
    final cellules = ligne
        .split('|')
        .map((c) => c.trim())
        .toList()
        .sublist(1); // avant le premier « | », rien
    if (cellules.isNotEmpty && cellules.last.isEmpty) cellules.removeLast();
    if (colonneJh == null) {
      final id = cellules.indexOf('Id');
      final jh = cellules.indexOf('j-h');
      if (id >= 0 && jh >= 0) {
        colonneId = id;
        colonneJh = jh;
        final plan = cellules.indexOf('Plan');
        colonnePlan = plan >= 0 ? plan : null;
      }
      continue;
    }
    if (cellules.length <= colonneJh || colonneId == null) continue;
    final id = cellules[colonneId];
    if (!_idSeul.hasMatch(id)) continue;
    final jh = cellules[colonneJh];
    if (!_nombreSeul.hasMatch(jh)) {
      throw FormatException('$id : estimation « $jh » illisible.');
    }
    final plan = colonnePlan != null && colonnePlan < cellules.length
        ? cellules[colonnePlan]
        : null;
    if (plan != null && !_nombreSeul.hasMatch(plan)) {
      throw FormatException('$id : estimation du plan « $plan » illisible.');
    }
    if (taches.containsKey(id)) {
      throw FormatException('$id en double dans docs/estimations-taches.md.');
    }
    taches[id] = (jh: _nombre(jh), plan: plan == null ? null : _nombre(plan));
  }
  return taches;
}

String calculerBloc(String progres, String estimations) {
  final faits = {for (final p in phases) p: 0.0};
  final totaux = {for (final p in phases) p: 0.0};
  final presentes = <String>{};
  final typesFaits = <String>{};
  final typesTotal = <String>{};
  final taches = <String, double>{};
  String? phase;
  String? date;

  for (final ligne in progres.split('\n')) {
    final titre = _titrePhase.firstMatch(ligne);
    if (titre != null) {
      phase = titre.group(1);
      continue;
    }
    if (ligne.startsWith('## ')) phase = null;
    final dateLigne = _dateJournal.firstMatch(ligne);
    if (dateLigne != null) date = dateLigne.group(1);
    if (phase == null) continue;

    final principale = _casePremierNiveau.firstMatch(ligne);
    final sous = _sousCase.firstMatch(ligne);
    final caseTrouvee = principale ?? sous;
    if (caseTrouvee == null) continue;
    final cochee = caseTrouvee.group(1) == 'x';

    if (principale != null) {
      final jh = _estimation.firstMatch(principale.group(2)!);
      if (jh == null) {
        throw FormatException('case de $phase sans « (X j-h) » : $ligne');
      }
      final valeur = _nombre(jh.group(1)!);
      final id = _idTache.firstMatch(principale.group(2)!)?.group(1);
      if (id == null || !id.startsWith('$phase-')) {
        throw FormatException('case de $phase sans id « $phase-NN » : $ligne');
      }
      if (taches.containsKey(id)) throw FormatException('$id en double.');
      taches[id] = valeur;
      presentes.add(phase);
      totaux[phase] = totaux[phase]! + valeur;
      if (cochee) faits[phase] = faits[phase]! + valeur;
    }
    if (_phasesTypes.contains(phase)) {
      final types = _types(caseTrouvee.group(2)!);
      typesTotal.addAll(types);
      if (cochee) typesFaits.addAll(types);
    }
  }

  // Contrôle tâche par tâche par rapport à docs/estimations-taches.md.
  final attendues = lireEstimations(estimations);
  final ecarts = [
    for (final MapEntry(key: id, value: jh) in taches.entries)
      if (!attendues.containsKey(id))
        '$id absente de docs/estimations-taches.md'
      else if (attendues[id]!.jh != jh)
        '$id : ${_jh(jh)} j-h au lieu de ${_jh(attendues[id]!.jh)}',
    for (final id in attendues.keys)
      if (!taches.containsKey(id)) '$id absente de PROGRESS.md',
  ];
  if (ecarts.isNotEmpty) {
    throw FormatException(
      'PROGRESS.md et docs/estimations-taches.md diffèrent : '
      '${ecarts.join(', ')}.',
    );
  }
  _controlerTotauxDeclares(estimations, attendues);

  final total = totaux.values.reduce((a, b) => a + b);
  if (typesTotal.length != _typesAttendus) {
    throw FormatException(
      '${typesTotal.length} types trouvés dans A1 et A2 au lieu de '
      '$_typesAttendus.',
    );
  }
  if (date == null) throw FormatException('aucune date dans le journal.');

  final fait = faits.values.reduce((a, b) => a + b);
  final lignes = [
    for (final p in phases)
      if (presentes.contains(p))
        '| $p | ${_jh(faits[p]!)} | ${_jh(totaux[p]!)} | '
            '${(faits[p]! / totaux[p]! * 100).round()} % |',
  ];
  final global = (fait / total * 100).toStringAsFixed(1).replaceAll('.', ',');

  return '''
$_debut
## Avancement
Au $date. Bloc calculé par `dart run tool/avancement.dart`, ne pas modifier à la main.

| Phase | j-h faits | j-h total | % |
|---|---|---|---|
${lignes.join('\n')}
| **Total** | **${_jh(fait)}** | **${_jh(total)}** | **$global %** |

- **Avancement global : $global %** (${_jh(fait)} j-h faits sur ${_jh(total)})
- **Types jouables : ${typesFaits.length} sur ${typesTotal.length}**
- Méthode : une tâche compte seulement quand sa case de premier niveau est cochée (une tâche en cours compte 0). % d'une phase = j-h des cases cochées ÷ j-h de la phase. % global = j-h cochés ÷ total, contrôlé par rapport à `docs/estimations-taches.md`. Types jouables = codes Txx des cases cochées des phases A1 et A2. Les sous-cases détaillent une tâche et ne portent pas d'estimation.
$_fin''';
}

/// « Total en vigueur : X j-h » doit être la somme de la colonne j-h,
/// « Total au plan : X j-h » celle de la colonne Plan. Chaque total est
/// contrôlé seulement s'il est déclaré.
void _controlerTotauxDeclares(
  String estimations,
  Map<String, EstimationTache> taches,
) {
  for (final m in _totalDeclare.allMatches(estimations)) {
    final declare = _nombre(m.group(2)!);
    final auPlan = m.group(1) == 'au plan';
    final valeurs = [
      for (final t in taches.values)
        if (auPlan) t.plan ?? t.jh else t.jh,
    ];
    final somme = valeurs.fold(0.0, (a, b) => a + b);
    if ((somme - declare).abs() > 0.001) {
      throw FormatException(
        'docs/estimations-taches.md déclare un total ${m.group(1)} de '
        '${_jh(declare)} j-h, mais les tâches font ${_jh(somme)} j-h '
        '(écart ${_jh(somme - declare)}).',
      );
    }
  }
}

double _nombre(String texte) => double.parse(texte.replaceAll(',', '.'));

String _jh(double valeur) => valeur == valeur.roundToDouble()
    ? valeur.toInt().toString()
    : valeur.toString().replaceAll('.', ',');

Set<String> _types(String texte) {
  final types = <String>{};
  for (final plage in _plageTypes.allMatches(texte)) {
    final de = int.parse(plage.group(1)!);
    final a = int.parse(plage.group(2)!);
    for (var n = de; n <= a; n++) {
      types.add('T${n.toString().padLeft(2, '0')}');
    }
  }
  types.addAll(_type.allMatches(texte).map((m) => m.group(0)!));
  return types;
}
