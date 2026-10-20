# Estimations des tâches (mis à jour le 20 octobre 2026)

Découpage du plan de développement (lots L00 à L18) en tâches par phase. Préparé par le mentor, à valider par Lamjed, recalé au point R1 (15 nov. 2026). Source du tableau de bord « Avancement Yasmina » et des estimations reportées dans PROGRESS.md (décision 26).

Deux estimations par tâche depuis la replanification du 19 oct. (décision 37) :

- **j-h** : l'estimation **en vigueur**, celle qui compte pour l'avancement. Pour toute tâche non faite au 19 oct. (statut « à faire » ou « en cours »), elle vaut la moitié de l'estimation du plan. Les tâches faites gardent leur valeur.
- **Plan** : l'estimation initiale du plan de développement du 17 oct., gardée pour mémoire et pour le recalage de R1. `tool/avancement.dart` lit les colonnes par leur en-tête et ignore cette colonne dans le calcul.

Méthode : une tâche compte seulement quand elle est faite. Avancement d'une phase = j-h faits ÷ j-h en vigueur de la phase. Global = j-h faits ÷ 182,25 (total en vigueur).

Changement du 17 oct. 19 h (décision 29) : 2 j-h de la tâche A1-19 (design, partie 1) passent en A0 (A0-19 design system Yasmina, A0-20 ThemeYasmina). Total inchangé.

Changements du 19 oct. (décisions 34, 35, 37) :

- décision 34, ordre « atelier d'abord » : A1-01 Moteur Choix (8 j-h) est découpée en A1-01a schéma, exemples et fiche (1 j-h, fait) et A1-01b moteur (7 j-h au plan). Total inchangé.
- décision 35, sons d'interface : nouvelle tâche A0-21 « Sons d'interface (5 sons, réglage, décision 35) », lot L04, 0,5 j-h en vigueur (0,75 au plan), faite le 20 oct.
- décision 37, replanification : toutes les tâches non faites passent à la moitié de leur estimation du plan, quel que soit leur lot. Nouvelle tâche A1-22 « Séquence de test pour le tour 1 des familles (exercices enchaînés, sans carte) », lot L05, 0,75 j-h (1,5 au plan). Les tâches A1-10 à A1-14 (parcours, progression, espace parent, simulation d'abonnement) deviennent A3-01 à A3-05 dans une nouvelle phase A3 « Parcours et espace parent » (1er au 14 mars 2027), après la validation des 53 types dans l'atelier. La phase B passe au 15 mars au 30 avril 2027. Total en vigueur : 182,25 j-h (345,25 au plan), calcul vérifié tâche par tâche (aucun écart).

## Phase A0, 19 oct. au 1er nov. 2026 (21,75 j-h en vigueur, 18,5 faits, 25,25 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A0-01 | L03 | Dépôt GitHub privé | 0,25 | 0,25 | fait |
| A0-02 | L03 | Structure pub workspace | 0,5 | 0,5 | fait |
| A0-03 | L14 | Script tool/verifier.sh | 0,5 | 0,5 | fait |
| A0-04 | L03 | CLAUDE.md et PROGRESS.md | 0,25 | 0,25 | fait |
| A0-05 | L04 | Maquettes HTML de référence | 0,5 | 0,5 | fait |
| A0-06 | L03 | Projet Flutter et dépendances | 0,5 | 0,5 | fait |
| A0-07 | L11 | Schéma edu-content/1.0 et validateur | 2 | 2 | fait |
| A0-08 | L18 | JSON embarqués (53 types et parcours arabe 1re) | 1,5 | 3 | en cours |
| A0-09 | L11 | Conventions d'écriture de l'arabe | 0,5 | 0,5 | fait |
| A0-10 | L03 | Langue de l'interface et Directionality | 1,5 | 1,5 | fait |
| A0-11 | L03 | Profils enfants (5 max) et base drift | 2 | 2 | fait |
| A0-12 | L03 | Menu développeur | 1,5 | 1,5 | fait |
| A0-13 | L04 | Lecteur d'exercice générique | 4 | 4 | fait |
| A0-14 | L04 | Interfaces de plateforme injectées | 1,5 | 1,5 | fait |
| A0-15 | L04 | Aperçu web (apps/apercu_web) | 0,75 | 1,5 | à faire |
| A0-16 | L04 | Yasmina en placeholder | 0,5 | 0,5 | fait |
| A0-17 | L00 | Build de test sur téléphone (iPhone fait, Android à installer) | 0,5 | 1 | en cours |
| A0-18 | L17 | Pilotage A0 | 0,5 | 1 | en cours |
| A0-19 | L01 | Design system Yasmina (artefact, depuis la démo) | 1 | 1 | fait |
| A0-20 | L01 | ThemeYasmina appliqué à l'app et à l'aperçu web | 1 | 1 | fait |
| A0-21 | L04 | Sons d'interface (5 sons, réglage, décision 35) | 0,5 | 0,75 | fait |

## Phase A1, 2 nov. au 31 déc. 2026 (36,25 j-h en vigueur, 1 fait, 71,5 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A1-01a | L04 | Moteur Choix : schéma, exemples et fiche | 1 | 1 | fait |
| A1-01b | L04 | Moteur Choix (13 types) : moteur | 3,5 | 7 | à faire |
| A1-02 | L04 | Moteur Glisser-déposer (10 types) | 6 | 12 | à faire |
| A1-03 | L04 | Moteur Texte (T07, T17) | 2 | 4 | à faire |
| A1-04 | L04 | Moteur Tracé (T20) : fait le 20 oct. 2026, puis T20 retiré du MVP le soir même (décision de Lamjed, l'écriture sur écran n'est pas fiable), code dans l'historique Git, estimation et totaux inchangés | 1,5 | 3 | fait |
| A1-05 | L04 | Moteur Saisie numérique, base (T22, T48) | 2 | 4 | à faire |
| A1-06 | L04 | Moteur Manipulables, base (T25, T27, T51) | 3 | 6 | à faire |
| A1-07 | L04 | Moteur Scène image, base (T08, T47) | 1,5 | 3 | à faire |
| A1-08 | L04 | Moteur Révision et jeux (T36 à T38) | 2,5 | 5 | à faire |
| A1-09 | L00 | Vérification du framework sur le prototype (glisser-déposer arabe, harakat, Rive, Android 2 Go) | 2 | 4 | à faire |
| A1-15 | L14 | Tests de parité et golden | 1 | 2 | à faire |
| A1-16 | L14 | Build distribué aux familles (TestFlight, Play) | 0,5 | 1 | à faire |
| A1-17 | L14 | Grille d'observation et questionnaire parent | 0,5 | 1 | à faire |
| A1-18 | L14 | Synthèse des retours, tour 1 | 0,5 | 1 | à faire |
| A1-19 | L01 | Design system et maquettes, partie 1 (designer, part du système Yasmina) | 4 | 8 | à faire |
| A1-20 | L02 | Yasmina : brief et 6 états (illustrateur) | 2,5 | 5 | à faire |
| A1-21 | L17 | Pilotage A1 | 1,5 | 3 | à faire |
| A1-22 | L05 | Séquence de test pour le tour 1 des familles (exercices enchaînés, sans carte) | 0,75 | 1,5 | à faire |

## Phase A2, 4 janv. au 28 févr. 2027 (30,5 j-h en vigueur, 0 faits, 61 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A2-01 | L04 | Moteur Saisie numérique, avancée (T49, T50, T63) | 2 | 4 | à faire |
| A2-02 | L04 | Moteur Manipulables, avancés (T26, T29, T52) | 3 | 6 | à faire |
| A2-03 | L04 | Moteur Mesure et temps (T28, T30) | 2,5 | 5 | à faire |
| A2-04 | L04 | Moteur Grille et graphiques (T31 à T33, T60) | 3,5 | 7 | à faire |
| A2-05 | L04 | Moteur Scène image avec audio (T53, T54) | 1,5 | 3 | à faire |
| A2-06 | L04 | Moteur Simulateur (T34, T57) | 3 | 6 | à faire |
| A2-07 | L04 | Moteur Récit (T35) | 1,5 | 3 | à faire |
| A2-08 | L03 | Corrections issues du tour 1 | 1 | 2 | à faire |
| A2-09 | L14 | Retours familles, tour 2 | 1 | 2 | à faire |
| A2-10 | L01 | Design system et maquettes, partie 2 (designer) | 5 | 10 | à faire |
| A2-11 | L02 | Yasmina : animations Rive (illustrateur) | 5 | 10 | à faire |
| A2-12 | L17 | Pilotage A2 | 1,5 | 3 | à faire |

## Phase A3, parcours et espace parent, 1er au 14 mars 2027 (8,25 j-h en vigueur, 0 faits, 16,5 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| A3-01 | L05 | Choix de l'enfant et de la matière, carte du trimestre | 2 | 4 | à faire |
| A3-02 | L05 | Intro d'étape, séquences, écran de résultat | 2 | 4 | à faire |
| A3-03 | L03 | Progression locale | 1,25 | 2,5 | à faire |
| A3-04 | L06 | Espace parent local | 2,5 | 5 | à faire |
| A3-05 | L05 | Simulation essai et abonnement | 0,5 | 1 | à faire |

## Phase B, 15 mars au 30 avril 2027 (39,25 j-h en vigueur, 0 faits, 78,5 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| B-01 | L07 | Back-end : schéma Supabase et RLS | 3 | 6 | à faire |
| B-02 | L07 | Back-end : Edge Functions (OTP, droits, clés) | 3,5 | 7 | à faire |
| B-03 | L07 | Connexion par code simulée en développement | 1,5 | 3 | à faire |
| B-04 | L03 | Téléchargement à priorités et journal persistant | 4 | 8 | à faire |
| B-05 | L03 | Packs chiffrés et synchronisation | 3 | 6 | à faire |
| B-06 | L10 | Back-office : base, comptes, droits | 4 | 8 | à faire |
| B-07 | L10 | Back-office : écran de relecture et formulaire par gabarit | 5 | 10 | à faire |
| B-08 | L10 | Back-office : publication et construction des packs | 2,5 | 5 | à faire |
| B-09 | L11 | Pipeline dans le Projet Claude (registre anti-doublon, HTML de validation, GitHub) | 4 | 8 | à faire |
| B-10 | L11 | Outil de validation pour le LLM (edu_content:valider) | 0,5 | 1 | à faire |
| B-11 | L11 | Médias et packs du pipeline | 3,25 | 6,5 | à faire |
| B-12 | L18 | Pilote de contenu arabe 1re T1 (go ou no-go) | 2 | 4 | à faire |
| B-13 | L16 | Relecture du pilote | 1,5 | 3 | à faire |
| B-14 | L17 | Pilotage B | 1,5 | 3 | à faire |

## Phase C, mai et juin 2027 (29,75 j-h en vigueur, 0 faits, 59,5 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| C-01 | L05 | Couche jeu complète (pièces, avatar, compagnon, album) | 3 | 6 | à faire |
| C-02 | L06 | Temps d'écran et paramètres parent | 2 | 4 | à faire |
| C-03 | L08 | Paiements (Konnect, Flouci, D17, RevenueCat, codes prépayés, parrainage) | 6 | 12 | à faire |
| C-04 | L09 | Site web (landing, paiement, activation) | 3 | 6 | à faire |
| C-05 | L12 | n8n et WhatsApp (OTP, workflow d'essai, rapports) | 4 | 8 | à faire |
| C-06 | L13 | Analytics internes, Sentry, tableaux de bord | 1,5 | 3 | à faire |
| C-07 | L14 | Bêta auprès de 150 familles | 3 | 6 | à faire |
| C-08 | L16 | Relecture du contenu de la bêta | 3,5 | 7 | à faire |
| C-09 | L01 | Ajustements UX après la bêta (designer) | 2,5 | 5 | à faire |
| C-10 | L17 | Pilotage C | 1,25 | 2,5 | à faire |

## Phase D, juillet et août 2027 (16,5 j-h en vigueur, 0 faits, 33 au plan)

| Id | Lot | Tâche | j-h | Plan | Statut |
|---|---|---|---|---|---|
| D-01 | L18 | Contenu T1 des 26 combinaisons | 4 | 8 | à faire |
| D-02 | L16 | Relecture du contenu T1 | 7,5 | 15 | à faire |
| D-03 | L15 | Publication stores, conformité, déclaration INPDP | 2 | 4 | à faire |
| D-04 | L14 | Recette finale avant lancement | 1,75 | 3,5 | à faire |
| D-05 | L17 | Pilotage D | 1,25 | 2,5 | à faire |

## Contrôle par lot

En vigueur : L00 2,5, L01 13,5, L02 7,5, L03 15,75, L04 47,75, L05 8,25, L06 4,5, L07 8, L08 6, L09 3, L10 11,5, L11 10,25, L12 4, L13 1,5, L14 8,75, L15 2, L16 12,5, L17 7,5, L18 7,5.

Au plan : L00 5, L01 25, L02 15, L03 25, L04 87,75, L05 16,5, L06 9, L07 16, L08 12, L09 6, L10 23, L11 18, L12 8, L13 3, L14 17, L15 4, L16 25, L17 15, L18 15 (343 du plan du 17 oct., plus 0,75 pour A0-21 et 1,5 pour A1-22).

Total en vigueur : 182,25 j-h. Total au plan : 345,25 j-h. Les deux totaux sont contrôlés par `tool/avancement.dart` (somme des colonnes j-h et Plan).
