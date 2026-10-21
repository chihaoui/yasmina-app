import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../../l10n/app_localizations.dart';
import '../../parent/porte_parentale.dart';

/// Porte parentale (A3-04) : une opération à résoudre avant l'espace
/// parent, dans la langue de l'interface, sans harakat.
class PorteParentEcran extends ConsumerStatefulWidget {
  const PorteParentEcran({super.key});

  @override
  ConsumerState<PorteParentEcran> createState() => _PorteParentEcranState();
}

class _PorteParentEcranState extends ConsumerState<PorteParentEcran> {
  final _reponse = TextEditingController();
  var _faux = false;

  @override
  void dispose() {
    _reponse.dispose();
    super.dispose();
  }

  void _entrer(QuestionPorte question) {
    if (question.verifier(_reponse.text)) {
      ref.read(porteOuverteProvider.notifier).ouvrir();
      context.pushReplacement('/parent/espace');
    } else {
      setState(() => _faux = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final question = ref.watch(questionPorteProvider);
    final theme = Theme.of(context).textTheme;
    final c = context.couleurs;
    return Scaffold(
      appBar: AppBar(
        title: Text(textes.parentTitre, key: const ValueKey('porte_titre')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_rounded,
              color: c.blue,
              size: TaillesYasmina.avatarCard,
            ),
            const SizedBox(height: EspacesYasmina.space4),
            Text(
              textes.parentPorteTitre,
              textAlign: TextAlign.center,
              style: theme.titleMedium,
            ),
            const SizedBox(height: EspacesYasmina.space2),
            Text(
              textes.parentPorteAide,
              textAlign: TextAlign.center,
              style: theme.bodyMedium,
            ),
            const SizedBox(height: EspacesYasmina.space8),
            Text(
              textes.parentPorteQuestion(question.a, question.b),
              key: const ValueKey('porte_question'),
              textAlign: TextAlign.center,
              // Les chiffres se lisent de gauche à droite dans les deux langues.
              textDirection: TextDirection.ltr,
              style: theme.headlineSmall,
            ),
            const SizedBox(height: EspacesYasmina.space4),
            TextField(
              key: const ValueKey('porte_reponse'),
              controller: _reponse,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: textes.parentPorteReponse,
                errorText: _faux ? textes.parentPorteFaux : null,
              ),
              onChanged: (_) => setState(() => _faux = false),
              onSubmitted: (_) => _entrer(question),
            ),
            const SizedBox(height: EspacesYasmina.space6),
            BoutonYasmina(
              key: const ValueKey('porte_entrer'),
              libelle: textes.parentPorteEntrer,
              icone: Icons.login_rounded,
              onPressed: () => _entrer(question),
            ),
          ],
        ),
      ),
    );
  }
}
