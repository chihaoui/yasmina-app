# Moteur Grille et graphiques

Fiche de conception du moteur Grille et graphiques, écrite avant le code. Statut : **brouillon de la nuit du 20 au 21 oct. 2026 (Claude Code, session sans surveillance, décision 39)**, à valider par Lamjed. Base de la tâche A2-04 (3,5 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [grille-graphiques-questions.md](grille-graphiques-questions.md).

Sources : CLAUDE.md §5 (maths en arabe, cibles d'au moins 48 dp), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : graphique des fruits préférés, barres à tracer, symétrie sur quadrillage, chemin de la fleur au puits), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour quatre exercices sur un **quadrillage** : lire un graphique en barres (T31), en construire un (T32), compléter une figure par symétrie (T33), programmer un déplacement par des flèches (T60). Tout est dessiné par le code, sans image, dans `packages/moteur_exercices`, compatible web, en `ModeValidation.verifier`.

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Réponse | Exemple |
|---|---|---|---|---|
| T31 | Lire un graphique | Touche la barre qui répond à la question (la plus grande, la plus petite) | `{ "serie": "s2" }` | `T31-lire-graphique.json` (4e, fruits préférés) |
| T32 | Construire un graphique | Lit un tableau et touche, dans chaque colonne, la cellule de la hauteur voulue : la barre monte jusque là | `{ "valeurs": [ { "serie", "valeur" } ] }` | `T32-construire-graphique.json` (4e, 3 fruits) |
| T33 | Symétrie | Touche les cases à droite de l'axe pour colorier le symétrique des cases données | `{ "cases": [[ligne, colonne]] }` | `T33-symetrie.json` (4e, 6 × 8) |
| T60 | Codage de déplacement | Compose un programme de flèches, le joue : la fleur avance pas à pas jusqu'au puits | `{ "chemin": ["haut", "droite"...] }` | `T60-codage.json` (3e, 5 × 5, un obstacle) |

## 3. Interaction

- **Graphique en barres (`GraphiqueBarres`, T31 et T32).** Un axe gradué de 0 à `maximum` (lignes fines), une colonne par série avec son étiquette (emoji ou texte) sous l'axe, toujours de gauche à droite. T31 : chaque barre est touchable en bloc (sélection unique, bordure `ink`), juste si la série choisie est la réponse. T32 : chaque colonne est une pile de cellules touchables d'au moins 36 dp de haut, toucher la cellule de niveau n monte la barre à n, toucher le sommet la baisse d'un cran. Vérifier devient actif quand toutes les barres ont au moins une cellule. Juste si chaque barre a la valeur du tableau. Après le 1er essai faux, seules les barres fausses redescendent.
- **Symétrie (T33).** Un quadrillage de `lignes` × `colonnes` (nombre pair), un axe vertical `coral` épais au milieu, les cases données (`cases`, à gauche) en `muted`, inertes. Toucher une case à droite la colorie en `blue`, un second toucher la décolorie. Juste si les cases coloriées sont exactement les symétriques des cases données (le validateur contrôle que `reponse.cases` est ce symétrique). Après le 1er essai faux, seules les cases fausses s'effacent.
- **Codage (T60).** Une grille `lignes` × `colonnes`, la fleur (`emoji_depart`) au départ, le puits (`emoji_but`) au but, les obstacles en `muted`. Quatre touches de flèches (haut, bas, gauche, droite) ajoutent un pas au programme (au plus `max_pas`), Effacer retire le dernier. **Jouer** fait avancer la fleur pas à pas (un pas toutes les 0,4 s, son `depot`) : les pas joués passent en `blue`. Sortir de la grille ou heurter un obstacle bloque la fleur. Vérifier devient actif une fois le programme joué. Juste si la fleur est sur le but : **tout chemin qui arrive est accepté**, `reponse.chemin` n'est qu'un chemin possible (le validateur vérifie qu'il arrive). **Revenir** remet la fleur au départ pour corriger le programme. Après le 1er essai faux, tout revient au départ (programme vidé).

## 4. Données JSON

| Type | `donnees` | `reponse` |
|---|---|---|
| T31 | `series` (2 à 6 : `id` `s1`..., `emoji` ou `texte`, `valeur` 0 à 20), `maximum` (haut de l'axe, 10 par défaut), `question` (`plus`, `moins`), `chiffres` | `{ "serie" }` : la série de la plus grande (ou plus petite) valeur, unique (`serie_inconnue`, `question_ambigue`, `reponse_valeur_incoherente`) |
| T32 | `series` (2 à 6, `valeur` = hauteur à construire), `maximum` (6 par défaut), `chiffres` | `{ "valeurs": [ { "serie", "valeur" } ] }` : une entrée par série, égale à sa valeur (`valeurs_incompletes`, `reponse_valeur_incoherente`) |
| T33 | `lignes` (2 à 10), `colonnes` (pair, 4 à 12), `cases` (1 à 20 cases `[ligne, colonne]` à gauche de l'axe) | `{ "cases" }` : le symétrique exact (`case_hors_grille`, `case_hors_moitie`, `symetrie_incoherente`) |
| T60 | `lignes`, `colonnes` (3 à 8), `depart`, `but` (`ligne`, `colonne`), `obstacles` (0 à 10), `emoji_depart` (🌸), `emoji_but` (🪣), `max_pas` (12 par défaut) | `{ "chemin" }` : 1 à `max_pas` pas parmi haut, bas, gauche, droite, qui mène du départ au but sans sortir ni heurter (`chemin_invalide`, `depart_egal_but`, `case_hors_grille`) |

## 5. Correction et feedback

Vérifier, 3 temps, comme le moteur Choix. 1er essai faux : T31 la barre passe en `coral` un instant puis la sélection se vide, T32 et T33 les éléments faux passent en `coral` puis les seuls éléments faux s'effacent, T60 le programme et la fleur reviennent au départ. 2e essai faux : la bonne réponse est montrée (barre, hauteurs, cases en `olive`, un chemin juste et la fleur sur le but).

## 6. Événements et modes

`reponseDonnee` à chaque toucher qui change la réponse (T60 : à chaque flèche ajoutée ou retirée), `essai`, `resultat`, `demandeAudio` (consigne). Modes `enfant`, `apercu` (afficher la réponse), `edition`.

## 7. Cas arabe

Maths en arabe : les quatre exemples sont en arabe. Les quadrillages et graphiques ne se retournent pas (`Directionality` ltr) : les colonnes gardent l'ordre du JSON de gauche à droite, les flèches gardent leur sens. Un cas français est testé pour chaque type.

## 8. Règles UX

- Cases et cellules d'au moins 36 dp (quadrillages de 8 colonnes sur un téléphone), barres et touches de flèches d'au moins `target-min`.
- Juste et faux ne passent jamais par la couleur seule : Yasmina, le bandeau, le mot d'état en aperçu, la fleur qui n'arrive pas.
- Accessibilité : chaque barre, cellule, case et flèche est un bouton nommé.

## 9. Composants

| Composant | Dans le moteur | Statut |
|---|---|---|
| Graphique en barres | `GraphiqueBarres` | à créer (partagé T31, T32) |
| Quadrillage touchable | dans `gabarit_symetrie.dart` et `gabarit_codage.dart` | à créer |
| Button, Feedback | existants | Jouer, Revenir, Effacer |

## 10. Tests prévus

`grille_graphiques_test.dart` : un cas arabe (exemple réel) et un cas français (fixture) par type, barres touchées, cellules montées et baissées, cases coloriées et décoloriées, programme écrit, joué (temps simulé), bloqué par un obstacle, autre chemin accepté, faux puis juste, révélation. Parité dans `parite_grille_test.dart` et l'aperçu web.

## 11. Découpage (A2-04, 3,5 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests | 0,75 |
| c | `GraphiqueBarres`, T31, T32, T33, T60, tests, parité | 2,5 |
