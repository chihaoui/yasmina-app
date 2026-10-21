import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../../dev/reglages_dev.dart';
import '../../donnees/base_yasmina.dart' show EtatEtapeProfil, ProfilEnfant;
import '../../l10n/app_localizations.dart';
import '../../parcours/matieres.dart';
import '../../parcours/parcours.dart';
import '../../parcours/progression.dart';
import '../../parent/porte_parentale.dart';
import '../../parent/sans_harakat.dart';
import '../../profils/avatar.dart';
import '../../profils/depot_profils.dart';
import '../../profils/libelles.dart';
import '../../reglages/langue_interface.dart';

/// Noms des langues, chacun écrit dans sa propre langue quelle que soit la
/// langue affichée.
const _nomsLangues = {
  LangueInterface.ar: ('العربية', TextDirection.rtl),
  LangueInterface.fr: ('Français', TextDirection.ltr),
};

/// Espace parent local (A3-04), dans la langue de l'interface et sans
/// harakat (décision 27) : les enfants (création, modification, suppression,
/// décision 28), la progression de chacun par matière et par étape, la
/// langue de l'application, les sons des effets (décision 35) et
/// l'abonnement simulé (A3-05).
class EspaceParentEcran extends ConsumerWidget {
  const EspaceParentEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final catalogue = ref.watch(catalogueParcoursProvider).value;
    final theme = Theme.of(context).textTheme;
    Widget titre(String texte, Key cle) => Padding(
      padding: const EdgeInsetsDirectional.only(
        top: EspacesYasmina.space8,
        bottom: EspacesYasmina.space2,
      ),
      child: Text(sansHarakat(texte), key: cle, style: theme.titleMedium),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          sansHarakat(textes.parentTitre),
          key: const ValueKey('parent_titre'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: EspacesYasmina.space2,
            ),
            child: BoutonIcone(
              key: const ValueKey('parent_quitter'),
              icone: Icons.lock_rounded,
              libelle: textes.parentQuitter,
              onPressed: () {
                ref.read(porteOuverteProvider.notifier).fermer();
                context.go('/');
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EspacesYasmina.space6,
          vertical: EspacesYasmina.space2,
        ),
        children: [
          titre(textes.parentEnfants, const ValueKey('parent_enfants')),
          _Enfants(profils: profils, textes: textes),
          titre(textes.parentProgression, const ValueKey('parent_progression')),
          if (profils.isEmpty)
            Text(textes.parentAucuneProgression, style: theme.bodyMedium),
          for (final p in profils)
            _ProgressionEnfant(profil: p, catalogue: catalogue, textes: textes),
          titre(textes.parentLangue, const ValueKey('parent_langue')),
          const _Langue(),
          titre(textes.parentSons, const ValueKey('parent_sons')),
          const _Sons(),
          titre(textes.parentAbonnement, const ValueKey('parent_abonnement')),
          const EmplacementAbonnement(),
          const SizedBox(height: EspacesYasmina.space8),
        ],
      ),
    );
  }
}

class _Enfants extends ConsumerWidget {
  const _Enfants({required this.profils, required this.textes});

  final List<ProfilEnfant> profils;
  final AppLocalizations textes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final limite = profils.length >= DepotProfils.maxProfils;
    return Card(
      child: Column(
        children: [
          for (final p in profils)
            ListTile(
              key: ValueKey('parent_profil_${p.id}'),
              leading: AvatarVisuel(p.avatar),
              title: Text(p.prenom),
              subtitle: Text(sansHarakat(libelleNiveau(textes, p.niveau))),
              trailing: const Icon(Icons.edit_rounded),
              onTap: () => context.push('/parent/profils/${p.id}'),
            ),
          if (limite)
            Padding(
              padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
              child: Text(
                textes.parentLimite,
                key: const ValueKey('parent_limite'),
                style: theme.bodySmall,
              ),
            )
          else
            ListTile(
              key: const ValueKey('parent_ajouter'),
              leading: const Icon(Icons.person_add_alt_1_rounded),
              title: Text(textes.parentAjouterEnfant),
              onTap: () => context.push('/parent/profils/nouveau'),
            ),
        ],
      ),
    );
  }
}

/// Progression d'un enfant : par matière de son niveau, le nombre d'étapes
/// faites, puis chaque étape commencée (faite ou en cours).
class _ProgressionEnfant extends ConsumerWidget {
  const _ProgressionEnfant({
    required this.profil,
    required this.catalogue,
    required this.textes,
  });

  final ProfilEnfant profil;
  final CatalogueParcours? catalogue;
  final AppLocalizations textes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final c = context.couleurs;
    final etats = ref.watch(etatsEtapesProvider(profil.id)).value ?? const [];
    final parId = {for (final e in etats) e.etapeId: e};
    return Card(
      key: ValueKey('parent_progression_${profil.id}'),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarVisuel(profil.avatar),
                const SizedBox(width: EspacesYasmina.space3),
                Text(profil.prenom, style: theme.titleMedium),
              ],
            ),
            for (final matiere in Matiere.pourNiveau(profil.niveau))
              ..._matiere(
                context,
                theme,
                c,
                matiere,
                catalogue?.pour(matiere: matiere.cle, niveau: profil.niveau),
                parId,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _matiere(
    BuildContext context,
    TextTheme theme,
    CouleursYasmina c,
    Matiere matiere,
    Parcours? parcours,
    Map<String, EtatEtapeProfil> parId,
  ) {
    final nom = sansHarakat(matiere.nom(textes));
    if (parcours == null || parcours.etapes.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: EspacesYasmina.space3),
          child: Text('$nom : ${textes.parentBientot}', style: theme.bodySmall),
        ),
      ];
    }
    final faites = parcours.etapes.where((e) => parId[e.id]?.faite ?? false);
    return [
      Padding(
        padding: const EdgeInsetsDirectional.only(top: EspacesYasmina.space3),
        child: Text(
          '$nom : ${textes.parentEtapesFaites(faites.length, parcours.etapes.length)}',
          key: ValueKey('parent_${profil.id}_${matiere.code}'),
          style: theme.bodyLarge,
        ),
      ),
      for (final etape in parcours.etapes)
        if (parId[etape.id] case final etat?)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: EspacesYasmina.space1,
            ),
            child: Row(
              children: [
                Icon(
                  etat.faite
                      ? Icons.check_circle_rounded
                      : Icons.timelapse_rounded,
                  size: TaillesYasmina.iconMd,
                  color: etat.faite ? c.olive : c.amber,
                ),
                const SizedBox(width: EspacesYasmina.space2),
                // Le titre de l'étape est du contenu : il garde ses harakat.
                Expanded(
                  child: Text(
                    etape.titre,
                    textDirection: LangueExercice.directionDe(etape.langue),
                    style: ThemeYasmina.pourLangue(
                      StylesYasmina.option,
                      etape.langue,
                    ).copyWith(color: c.ink),
                  ),
                ),
                Text(
                  etat.faite
                      ? textes.parentEtapeFaite(
                          etat.meilleursReussis,
                          etat.total,
                        )
                      : textes.parentEtapeEnCours(
                          etat.indexReprise,
                          etat.total,
                        ),
                  key: ValueKey('parent_etat_${profil.id}_${etape.id}'),
                  style: theme.bodySmall,
                ),
              ],
            ),
          ),
    ];
  }
}

class _Langue extends ConsumerWidget {
  const _Langue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final langue = ref.watch(langueInterfaceProvider);
    return Card(
      child: Column(
        children: [
          ListTile(subtitle: Text(textes.parentLangueAide)),
          RadioGroup<LangueInterface>(
            groupValue: langue,
            onChanged: (choix) {
              if (choix != null) {
                ref.read(langueInterfaceProvider.notifier).choisir(choix);
              }
            },
            child: Column(
              children: [
                for (final MapEntry(key: valeur, value: (nom, sens))
                    in _nomsLangues.entries)
                  RadioListTile<LangueInterface>(
                    key: ValueKey('langue_${valeur.name}'),
                    value: valeur,
                    title: Text(nom, textDirection: sens),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sons extends ConsumerWidget {
  const _Sons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    return Card(
      child: SwitchListTile(
        key: const ValueKey('parent_sons_effets'),
        title: Text(textes.parentSons),
        subtitle: Text(textes.parentSonsAide),
        value: ref.watch(sonsEffetsProvider),
        onChanged: (valeur) =>
            ref.read(sonsEffetsProvider.notifier).choisir(valeur),
      ),
    );
  }
}

/// Abonnement simulé (A3-05, décision 13) : le statut, puis les trois
/// offres par compte (jusqu'à 5 enfants), sans paiement ni réseau.
/// « S'abonner » bascule le statut simulé sur abonné ; un bouton de
/// simulation le remet sur essai.
class EmplacementAbonnement extends ConsumerWidget {
  const EmplacementAbonnement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final statut = ref.watch(abonnementSimuleProvider);
    final theme = Theme.of(context).textTheme;
    final c = context.couleurs;
    final libelle = switch (statut) {
      AbonnementSimule.essai => textes.parentAbonnementEssai,
      AbonnementSimule.essaiTermine => textes.parentAbonnementEssaiTermine,
      AbonnementSimule.abonne => textes.parentAbonnementAbonne,
    };
    final abonne = statut == AbonnementSimule.abonne;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            key: const ValueKey('parent_abonnement_statut'),
            leading: Icon(
              abonne ? Icons.verified_rounded : Icons.card_membership_rounded,
              color: abonne ? c.olive : c.amber,
            ),
            title: Text(libelle),
            subtitle: Text(textes.parentAbonnementAide),
          ),
          if (abonne)
            Padding(
              padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
              child: TextButton.icon(
                key: const ValueKey('parent_abonnement_retour'),
                icon: const Icon(Icons.replay_rounded),
                label: Text(textes.parentAbonnementRetourEssai),
                onPressed: () => ref
                    .read(abonnementSimuleProvider.notifier)
                    .choisir(AbonnementSimule.essai),
              ),
            )
          else
            for (final (cle, titre, aide, meilleure) in [
              (
                'mois',
                textes.parentOffreMois,
                textes.parentOffreMoisAide,
                false,
              ),
              (
                'trimestre',
                textes.parentOffreTrimestre,
                textes.parentOffreTrimestreAide,
                false,
              ),
              (
                'annee',
                textes.parentOffreAnnee,
                textes.parentOffreAnneeAide,
                true,
              ),
            ])
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  EspacesYasmina.space4,
                  0,
                  EspacesYasmina.space4,
                  EspacesYasmina.space4,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.tile,
                    borderRadius: BorderRadius.circular(RayonsYasmina.radiusLg),
                    border: Border.all(
                      color: meilleure ? c.blue : c.line,
                      width: TraitsYasmina.borderThick,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(
                      EspacesYasmina.space4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(titre, style: theme.bodyLarge),
                              Text(aide, style: theme.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: EspacesYasmina.space3),
                        FilledButton(
                          key: ValueKey('parent_sabonner_$cle'),
                          onPressed: () => ref
                              .read(abonnementSimuleProvider.notifier)
                              .choisir(AbonnementSimule.abonne),
                          child: Text(textes.parentSabonner),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
