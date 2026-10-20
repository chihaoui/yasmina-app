# Moteur Révision et jeux

Fiche de conception du moteur Révision et jeux, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, soir, décision 39)**, à valider par Lamjed. Base de la tâche A1-08 (2,5 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [revision-jeux-questions.md](revision-jeux-questions.md).

Sources : CLAUDE.md §5 (une langue par exercice, harakat jamais supprimées, 4 à 6 éléments en 1re et 2e), le lecteur (`ModeValidation.automatique`, prévu pour T37 et T38 depuis A0-13, `ModeValidation.sansNote`), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : flashcards hors score, memory en révision, mots mêlés), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour trois activités de **révision** : les flashcards (revoir sans note), le memory (retrouver des paires, noté) et les mots mêlés (retrouver des mots dans une grille, noté). Les trois types se jouent sans Vérifier : les flashcards en mode sans note (Continuer dès que toutes les cartes sont vues), le memory et les mots mêlés en mode automatique (la zone signale la fin, le lecteur affiche le feedback puis Continuer). Il vit dans `packages/moteur_exercices`, compatible web.

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Validation | Réponse | Exemple |
|---|---|---|---|---|---|
| T36 | Flashcards | Retourne chaque carte (recto : mot ou emoji, verso : sa réponse), passe à la suivante, dit s'il savait ou non | sans note | `{ "cartes": [id...] }` (cartes à voir) | `T36-flashcards.json` (arabe) |
| T37 | Memory | Retourne deux cartes à la fois, garde les paires identiques ou associées (mot et image), jusqu'à tout trouver | automatique, noté | `{ "paires": [id...] }` (toutes les paires) | `T37-memory.json` (français) |
| T38 | Mots mêlés | Trouve les mots cachés dans une grille de lettres en touchant leurs lettres une à une, ou en glissant le doigt le long du mot | automatique, noté | `{ "mots": [id...] }` | `T38-mots-meles.json` (arabe), `T38-mots-meles-fr.json` |

## 3. Interaction

### T36 Flashcards (sans note)

1. Une carte à la fois, grande (`content-word`), recto : `recto` (texte ou emoji), bouton Écouter si `ecoute`. Toucher la carte la retourne (verso : `verso`). Sous la carte, deux boutons : « Je savais » (`olive`, alt) et « À revoir » (`amber`, alt), actifs une fois la carte retournée. L'un ou l'autre passe à la carte suivante (la carte « à revoir » revient en fin de paquet, une seule fois).
2. Un compteur « 2 / 5 » (chiffres de gauche à droite). Continuer devient actif quand chaque carte de `reponse.cartes` a été vue au moins une fois. Résultat `termine`, sans note. L'auto-évaluation (`su`, `aRevoir`) est émise dans `reponseDonnee` pour la révision espacée à venir (hors MVP).

### T37 Memory (automatique, noté)

1. Une grille de cartes face cachée (`tile`, bordure `line`, un point d'interrogation discret), mélangées avec la graine, **toujours pleine sur 3 colonnes** selon le niveau (corrections du test du 20 oct.) : 3 × 2 en 1re, 3 × 4 en 2e et 3e, 3 × 6 en 4e et 5e, 3 × 8 en 6e (le validateur exige le nombre de paires du niveau, `memory_cartes_niveau`). Les cartes ont une **taille fixe** (hauteur d'une tuile de choix, même hauteur face cachée et face visible, contenu ajusté) : 24 cartes tiennent sur un écran de 390 × 844 dp sans défilement. Chaque paire est deux cartes : `a` et `b` (le même mot deux fois, ou un mot et son emoji).
2. Toucher une carte la retourne (`blue-soft`). Toucher une deuxième : si les deux forment une paire, elles restent retournées en « juste » (`olive-soft`, son `depot`). Sinon, elles se referment après un court instant (`dureeFaux`). Les essais (deux cartes retournées) sont comptés.
3. Quand toutes les paires sont trouvées, la zone appelle `terminer(juste: ...)`: **juste** si le nombre d'essais est au plus `essais_max` (par défaut deux fois le nombre de paires), sinon **faux** (explication sans jugement : « كُلُّ الْأَزْوَاجِ وُجِدَتْ، بِمُحَاوَلَاتٍ كَثِيرَةٍ »). Résultat `reussi` ou `explique` avec 1 essai (le mode automatique n'a pas de second essai).

### T38 Mots mêlés (automatique, noté)

1. Une grille carrée de lettres (`grille`, lignes de même longueur, 4 à 8 colonnes), en `content-option`. **En arabe, chaque case porte une lettre isolée** (une grille ne lie pas les lettres), et les mots se lisent **de droite à gauche** sur une ligne, de haut en bas sur une colonne. En français et en anglais, de gauche à droite et de haut en bas. Les diagonales ne sont pas utilisées dans le MVP.
2. L'enfant touche les lettres **une à une** (cases `blue-soft`), ou **glisse le doigt** le long du mot (chaque case survolée compte comme un toucher). Une lettre est acceptée si la sélection reste le début d'un mot restant, lu à sa vraie place dans la grille, dans un sens ou dans l'autre (un mot peut se prendre par sa dernière lettre). Dès qu'une lettre ne prolonge plus aucun mot restant, elle passe en rouge (`coral-soft`), puis toute la sélection se vide avec l'**effet d'erreur** : secousse douce de la grille, son `essaiFaux`, vibration légère (jamais la couleur seule). Les erreurs ne font pas perdre. Le mot complet est trouvé (cases `olive-soft`, son `depot`) et barré dans la liste sous la grille (corrections du test du 20 oct., sens de droite à gauche en arabe validé par Lamjed).
3. Quand tous les mots sont trouvés, la zone appelle `terminer(juste: true)` : résultat `reussi`. Un bouton « J'abandonne » n'existe pas dans le MVP (question 3).

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `donneesFlashcards`, `reponseCartes`, `donneesMemory`, `reponsePaires`, `donneesMotsMeles`, `reponseMotsMeles`).

| Type | `donnees` | `reponse` |
|---|---|---|
| T36 | `cartes` (2 à 8, id `c1`..., `recto` et `verso` : texte ou emoji chacun, `ecoute` facultative), `melanger` | `{ "cartes": [id...] }`, les cartes à voir (toutes en général) |
| T37 | `paires` (3 à 12 selon le niveau, id `p1`..., `a` et `b` : texte ou emoji chacun), `essais_max` facultatif, `melanger` | `{ "paires": [id...] }`, toutes les paires à trouver |
| T38 | `grille` (4 à 8 lignes de même longueur, lettres), `mots` (2 à 6, id `m1`..., `texte` sans harakat, `ligne`, `colonne` de la première lettre, `direction` : `ligne` ou `colonne`), `sens` (`droite-gauche` par défaut en arabe, `gauche-droite` sinon) | `{ "mots": [id...] }` tous les mots |

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- T36 : id uniques, `reponse.cartes` existantes (`reponse_element_inconnu`)
- T37 : id uniques, `reponse.paires` cite toutes les paires (`paires_incompletes`), nombre de paires du niveau (`memory_cartes_niveau` : 3, 6, 9 ou 12)
- T38 : lignes de même longueur (`grille_irreguliere`), chaque mot se lit bien dans la grille à sa position et dans le sens déclaré (`mot_hors_grille`), lettres isolées sans harakat en arabe (`lettre_invalide`), `reponse.mots` cite tous les mots (`ordre_incomplet`)

## 5. Correction

- T36 : aucune (sans note). Complète quand toutes les cartes demandées sont vues.
- T37 : fin automatique quand toutes les paires sont trouvées, juste si les essais ne dépassent pas `essais_max`.
- T38 : fin automatique quand tous les mots sont trouvés, toujours juste.

## 6. Feedback

| Type | Pendant | Fin |
|---|---|---|
| T36 | aucun bandeau, Yasmina neutre | Continuer (vert), résultat `termine` |
| T37 | paire trouvée : son `depot`, cartes en `olive-soft`, paire fausse : `coral-soft` un instant puis cachées | validation (olive, bravo) ou explication (coral, encourage), Continuer |
| T38 | mot trouvé : son `depot`, cases `olive-soft`, mot barré dans la liste. Lettre fausse : `coral-soft`, secousse douce, son `essaiFaux`, puis la sélection se vide | validation, Continuer |

## 7. Événements et modes

- `reponseDonnee` : T36 à chaque carte vue (avec l'auto-évaluation), T37 à chaque paire trouvée, T38 à chaque mot trouvé
- `resultat` : `termine` (T36), `reussi` ou `explique` (T37), `reussi` (T38), par le lecteur
- `demandeAudio` : consigne, recto d'une carte (T36)
- Modes `enfant`, `apercu` (afficher la réponse : toutes les cartes retournées, toutes les paires trouvées, tous les mots surlignés), `edition`

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `flashcards-mots` | T36 | Recto mot, verso image ou traduction |
| `memory-mot-image` | T37 | Paires mot et emoji |
| `mots-meles-carre` | T38 | Grille carrée, mots en ligne et en colonne |

## 9. Cas arabe et cas français

- T36 et T37 : textes en `content-word`, de droite à gauche en arabe (grille du memory remplie de droite à gauche).
- T38 en arabe : lettres isolées dans les cases (sans harakat), lecture de droite à gauche sur les lignes (`sens` configurable), de haut en bas sur les colonnes. La liste des mots sous la grille affiche les mots liés (texte normal), avec leurs harakat si `affichage` les porte (question 2).
- Exemples : T36 arabe, T37 français, T38 arabe et français.

## 10. Règles UX

- Cartes et cases d'au moins `target-min`. Memory : 3 colonnes, nombre de paires imposé par le niveau. Mots mêlés : grille de 8 au plus.
- Memory et flashcards : le toucher. Mots mêlés : le toucher lettre à lettre, ou le doigt glissé le long du mot.
- Juste et faux ne passent jamais par la couleur seule : son, mot barré, bandeau.
- Accessibilité : chaque carte et chaque case est un bouton (« carte 3, cachée », « ب, ligne 2, colonne 4 »).

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| Carte | `CarteRevision` | à créer | `tile`, bordure `line`, `radius-lg`, retournée `blue-soft`, trouvée `olive-soft` |
| Case de grille | `CaseGrille` | à créer | `tile`, bordure `line`, `radius-sm`, sélectionnée `blue-soft`, trouvée `olive-soft`, fausse `coral-soft` |
| ChoiceTile, Button, IconButton | existants | | Boutons d'auto-évaluation, Écouter |

## 12. Tests prévus

- T36 : retourner, « je savais », « à revoir » (la carte revient), compteur, Continuer dès que tout est vu, résultat `termine`.
- T37 : paire juste, paire fausse qui se referme, fin automatique juste et fausse (`essais_max`), mélange reproductible, grilles 3 × 2, 3 × 6 et 3 × 8 sur 390 × 844 dp sans défilement avec des cartes d'au moins 48 dp de taille fixe.
- T38 : mot en ligne de droite à gauche en arabe, en colonne, sélection fausse, fin automatique, liste barrée, un cas français de gauche à droite.
- Parité : chaque exemple dans le lecteur et dans l'aperçu web.

## 13. Découpage (A1-08, 2,5 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests | 0,5 |
| c | `CarteRevision`, T36, T37 (mode automatique), `CaseGrille`, T38, tests, parité | 1,75 |
