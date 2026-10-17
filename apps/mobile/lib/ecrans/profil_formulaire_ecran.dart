import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../l10n/app_localizations.dart';
import '../profils/avatar.dart';
import '../profils/depot_profils.dart';
import '../profils/libelles.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Création (sans [profilId]) ou modification d'un profil : prénom, niveau,
/// avatar et forme d'adresse. Suppression avec confirmation en modification.
class ProfilFormulaireEcran extends ConsumerStatefulWidget {
  const ProfilFormulaireEcran({super.key, this.profilId});

  final int? profilId;

  @override
  ConsumerState<ProfilFormulaireEcran> createState() =>
      _ProfilFormulaireEcranState();
}

class _ProfilFormulaireEcranState extends ConsumerState<ProfilFormulaireEcran> {
  final _prenom = TextEditingController();
  int _niveau = 1;
  Avatar _avatar = Avatar.fleur;
  FormeAdresse? _forme;
  String? _erreurPrenom;
  String _prenomInitial = '';
  bool _charge = false;

  bool get _creation => widget.profilId == null;

  @override
  void initState() {
    super.initState();
    if (_creation) {
      _charge = true;
    } else {
      _charger(widget.profilId!);
    }
  }

  Future<void> _charger(int id) async {
    final profil = await ref.read(depotProfilsProvider).lire(id);
    if (!mounted) return;
    if (profil == null) {
      context.go('/');
      return;
    }
    setState(() {
      _prenom.text = profil.prenom;
      _prenomInitial = profil.prenom;
      _niveau = profil.niveau;
      _avatar = profil.avatar;
      _forme = profil.formeAdresse;
      _charge = true;
    });
  }

  @override
  void dispose() {
    _prenom.dispose();
    super.dispose();
  }

  bool get _peutEnregistrer => _prenom.text.trim().isNotEmpty && _forme != null;

  Future<void> _enregistrer() async {
    final textes = AppLocalizations.of(context);
    final depot = ref.read(depotProfilsProvider);
    try {
      if (_creation) {
        final profil = await depot.creer(
          prenom: _prenom.text,
          niveau: _niveau,
          avatar: _avatar,
          formeAdresse: _forme!,
        );
        if (!mounted) return;
        ref.read(profilActifProvider.notifier).choisir(profil.id);
        context.go('/accueil');
      } else {
        final id = widget.profilId!;
        await depot.modifier(
          id,
          prenom: _prenom.text,
          avatar: _avatar,
          formeAdresse: _forme,
        );
        await depot.changerNiveau(id, _niveau);
        if (!mounted) return;
        context.canPop() ? context.pop() : context.go('/');
      }
    } on PrenomInvalide {
      setState(() => _erreurPrenom = textes.profilPrenomVide);
    } on PrenomDejaUtilise {
      setState(() => _erreurPrenom = textes.profilPrenomExiste);
    } on LimiteProfilsAtteinte {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textes.profilsLimite)));
    }
  }

  Future<void> _supprimer() async {
    final textes = AppLocalizations.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogue) => AlertDialog(
        content: Text(textes.profilSupprimerQuestion(_prenomInitial)),
        actions: [
          TextButton(
            key: const ValueKey('dialogue_annuler'),
            onPressed: () => Navigator.pop(dialogue, false),
            child: Text(textes.annuler),
          ),
          FilledButton(
            key: const ValueKey('dialogue_supprimer'),
            onPressed: () => Navigator.pop(dialogue, true),
            child: Text(textes.supprimer),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    final id = widget.profilId!;
    await ref.read(depotProfilsProvider).supprimer(id);
    if (!mounted) return;
    if (ref.read(profilActifProvider) == id) {
      ref.read(profilActifProvider.notifier).oublier();
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    if (!_charge) return const EcranChargement();
    final nombre = ref.watch(profilsProvider).value?.length ?? 0;
    final theme = Theme.of(context);

    Widget titreSection(String texte) => Padding(
      padding: const EdgeInsetsDirectional.only(top: 24, bottom: 8),
      child: Text(texte, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _creation ? textes.profilNouveauTitre : textes.profilModifierTitre,
          key: const ValueKey('formulaire_titre'),
        ),
        actions: [if (_creation) const BoutonReglages()],
      ),
      body: _creation && nombre >= DepotProfils.maxProfils
          ? Center(
              child: Text(
                textes.profilsLimite,
                key: const ValueKey('profils_limite'),
              ),
            )
          // Formulaire court : tous les champs sont construits (tests et
          // lecteurs d'écran), contrairement à un ListView.
          : SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('champ_prenom'),
                    controller: _prenom,
                    maxLength: DepotProfils.longueurMaxPrenom,
                    decoration: InputDecoration(
                      labelText: textes.profilPrenom,
                      errorText: _erreurPrenom,
                    ),
                    onChanged: (_) => setState(() => _erreurPrenom = null),
                  ),
                  titreSection(textes.profilNiveau),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var n = 1; n <= 6; n++)
                        ChoiceChip(
                          key: ValueKey('niveau_$n'),
                          label: Text(libelleNiveau(textes, n)),
                          selected: _niveau == n,
                          onSelected: (_) => setState(() => _niveau = n),
                        ),
                    ],
                  ),
                  if (!_creation)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 8),
                      child: Text(
                        textes.profilNiveauAide,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  titreSection(textes.profilAvatar),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final avatar in Avatar.values)
                        Semantics(
                          selected: avatar == _avatar,
                          button: true,
                          child: InkWell(
                            key: ValueKey('avatar_${avatar.name}'),
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _avatar = avatar),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 3,
                                  color: avatar == _avatar
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: AvatarVisuel(avatar, taille: 56),
                            ),
                          ),
                        ),
                    ],
                  ),
                  titreSection(textes.profilFormeAdresse),
                  RadioGroup<FormeAdresse>(
                    groupValue: _forme,
                    onChanged: (forme) => setState(() => _forme = forme),
                    child: Column(
                      children: [
                        RadioListTile<FormeAdresse>(
                          key: const ValueKey('forme_masculin'),
                          value: FormeAdresse.masculin,
                          title: Text(textes.formeMasculin),
                        ),
                        RadioListTile<FormeAdresse>(
                          key: const ValueKey('forme_feminin'),
                          value: FormeAdresse.feminin,
                          title: Text(textes.formeFeminin),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const ValueKey('profil_enregistrer'),
                    onPressed: _peutEnregistrer ? _enregistrer : null,
                    child: Text(textes.profilEnregistrer),
                  ),
                  if (!_creation) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const ValueKey('profil_supprimer'),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(textes.profilSupprimer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: _supprimer,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
