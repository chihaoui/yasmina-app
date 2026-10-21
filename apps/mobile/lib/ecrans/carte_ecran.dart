import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moteur_exercices/moteur_exercices.dart';

import '../composants/noeud_carte.dart';
import '../dev/reglages_dev.dart';
import '../l10n/app_localizations.dart';
import '../parcours/matieres.dart';
import '../parcours/parcours.dart';
import '../parcours/progression.dart';
import '../profils/depot_profils.dart';
import '../profils/profil_actif.dart';
import 'commun.dart';

/// Carte du trimestre d'une matière (A3-01) : les étapes dans l'ordre
/// (unités, lettres, défi), ouverte, faite ou verrouillée, sur un chemin
/// qui serpente dans le sens de l'interface. Une matière sans contenu
/// affiche « bientôt ».
class CarteEcran extends ConsumerWidget {
  const CarteEcran({super.key, required this.code});

  /// Code de la matière (`ar`, `ma`...).
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textes = AppLocalizations.of(context);
    final matiere = Matiere.parCode(code);
    final id = ref.watch(profilActifProvider);
    final profils = ref.watch(profilsProvider).value ?? const [];
    final profil = profils.where((p) => p.id == id).firstOrNull;
    final catalogue = ref.watch(catalogueParcoursProvider);
    if (matiere == null) return _bientot(context, textes, textes.appTitre);
    if (profil == null || catalogue.isLoading) return const EcranChargement();
    final parcours = catalogue.value?.pour(
      matiere: matiere.cle,
      niveau: profil.niveau,
    );
    if (parcours == null || parcours.etapes.isEmpty) {
      return _bientot(context, textes, matiere.nom(textes));
    }
    final faites = ref.watch(etapesFaitesProvider(profil.id)).value ?? {};
    final toutDebloque = ref.watch(toutDebloqueProvider);
    return _Carte(
      code: code,
      titre: matiere.nom(textes),
      parcours: parcours,
      faites: faites,
      toutDebloque: toutDebloque,
    );
  }

  Widget _bientot(
    BuildContext context,
    AppLocalizations textes,
    String titre,
  ) => Scaffold(
    appBar: AppBar(title: Text(titre, key: const ValueKey('carte_titre'))),
    body: Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(EspacesYasmina.space6),
        child: Text(
          textes.carteBientot,
          key: const ValueKey('carte_bientot'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}

/// Décalage de chaque étape sur le chemin (serpentin de la démo), en
/// multiples de space-8, depuis le début de ligne.
const _serpentin = [
  0.0,
  EspacesYasmina.space8 * 3, // design-ok : serpentin, multiples de space-8
  EspacesYasmina.space8 * 5, // design-ok : serpentin, multiples de space-8
  EspacesYasmina.space8 * 3, // design-ok : serpentin, multiples de space-8
  0.0,
];

class _Carte extends StatelessWidget {
  const _Carte({
    required this.code,
    required this.titre,
    required this.parcours,
    required this.faites,
    required this.toutDebloque,
  });

  final String code;
  final String titre;
  final Parcours parcours;
  final Set<String> faites;
  final bool toutDebloque;

  void _ouvrir(BuildContext context, Etape etape, EtatEtape etat) {
    if (etat == EtatEtape.verrouillee) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).etapeVerrouilleeMessage),
          ),
        );
      return;
    }
    context.push('/matiere/$code/etape/${etape.id}');
  }

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final c = context.couleurs;
    final theme = Theme.of(context).textTheme;
    final unites = parcours.parUnite;
    final total = parcours.etapes.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(titre, key: const ValueKey('carte_titre')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: EspacesYasmina.space4,
            ),
            child: Center(
              child: Text(
                textes.carteTrimestre(parcours.trimestre),
                key: const ValueKey('carte_trimestre'),
                style: theme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: ColoredBox(
        color: c.map,
        child: ListView(
          padding: const EdgeInsetsDirectional.all(EspacesYasmina.space4),
          children: [
            Text(
              textes.matiereEtapesFaites(
                faites
                    .intersection(parcours.etapes.map((e) => e.id).toSet())
                    .length,
                total,
              ),
              key: const ValueKey('carte_avancement'),
              textAlign: TextAlign.center,
              style: theme.bodySmall,
            ),
            for (final MapEntry(key: unite, value: etapes)
                in unites.entries) ...[
              const SizedBox(height: EspacesYasmina.space4),
              _BandeauUnite(
                libelle: textes.carteUnite(unite),
                faites: etapes.where((e) => faites.contains(e.id)).length,
                total: etapes.length,
                cle: ValueKey('carte_unite_$unite'),
              ),
              for (var i = 0; i < etapes.length; i++)
                _LigneEtape(
                  etape: etapes[i],
                  etat: etatEtape(
                    parcours,
                    etapes[i].id,
                    faites,
                    toutDebloque: toutDebloque,
                  ),
                  decalage: _serpentin[i % _serpentin.length],
                  onTap: (etat) => _ouvrir(context, etapes[i], etat),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BandeauUnite extends StatelessWidget {
  const _BandeauUnite({
    required this.libelle,
    required this.faites,
    required this.total,
    required this.cle,
  });

  final String libelle;
  final int faites;
  final int total;
  final Key cle;

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EspacesYasmina.space4,
          vertical: EspacesYasmina.space2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(libelle, key: cle, style: theme.titleMedium),
            ),
            Text(
              textes.matiereEtapesFaites(faites, total),
              style: theme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneEtape extends StatelessWidget {
  const _LigneEtape({
    required this.etape,
    required this.etat,
    required this.decalage,
    required this.onTap,
  });

  final Etape etape;
  final EtatEtape etat;
  final double decalage;
  final ValueChanged<EtatEtape> onTap;

  @override
  Widget build(BuildContext context) {
    final textes = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final libelleEtat = switch (etat) {
      EtatEtape.ouverte => textes.etapeOuverte,
      EtatEtape.faite => textes.etapeFaite,
      EtatEtape.verrouillee => textes.etapeVerrouillee,
    };
    final glyphe = etape.estDefi ? '🏆' : etape.lettre;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: decalage,
        top: EspacesYasmina.space3,
        bottom: EspacesYasmina.space3,
      ),
      child: Row(
        children: [
          NoeudCarte(
            key: ValueKey('etape_${etape.id}'),
            glyphe: glyphe,
            etat: etat,
            defi: etape.estDefi,
            libelle: '${etape.titre}, $libelleEtat',
            onTap: () => onTap(etat),
          ),
          const SizedBox(width: EspacesYasmina.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Le titre est dans la langue de la matière.
                Text(
                  etape.titre,
                  key: ValueKey('etape_titre_${etape.id}'),
                  textDirection: LangueExercice.directionDe(etape.langue),
                  style: ThemeYasmina.pourLangue(
                    StylesYasmina.prompt,
                    etape.langue,
                  ).copyWith(color: context.couleurs.ink),
                ),
                Text(
                  libelleEtat,
                  key: ValueKey('etape_etat_${etape.id}'),
                  style: theme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
