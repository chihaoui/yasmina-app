# Moteur Texte

Fiche de conception du moteur Texte, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, soir, décision 39)**, à valider par Lamjed. Base de la tâche A1-03 (2 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [texte-questions.md](texte-questions.md).

Sources : CLAUDE.md §5 (harakat jamais supprimées ni réordonnées, comparaisons avec normalisation explicite et testée, une langue par exercice), `docs/conventions-arabe.md` (jamais de NFC ni de NFD sur les textes stockés), le schéma (`normalisation` et `tolerance` de l'exercice), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : mots touchables d'une phrase, dictée à étiquettes), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour les exercices où l'enfant **agit sur du texte** : il touche des mots dans une phrase (T07), ou il écrit un mot entendu (T17). Il vit dans `packages/moteur_exercices` et tourne à l'identique dans l'app et dans l'aperçu web :

- il reçoit un exercice edu-content/1.0 et une configuration (langue, forme d'adresse, mode)
- il émet des événements (réponse donnée, essai, résultat, demande d'audio)
- il ne connaît ni la base locale, ni la navigation, ni les profils
- il est compatible web : le clavier arabe est dessiné par le moteur, le clavier système n'est demandé que par un `TextField` ordinaire

Les deux types se branchent sur le lecteur en `ModeValidation.verifier` : Vérifier, feedback en 3 temps, 2 essais.

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Réponse | Exemples |
|---|---|---|---|---|
| T07 | Toucher les mots | Touche dans une phrase le ou les mots demandés (le verbe, les noms, le mot qui rime) | `{ "mots": [index...] }` | `T07-toucher-mots.json` (arabe), `T07-toucher-mots-fr.json` |
| T17 | Dictée au clavier | Écoute un mot (bouton Écouter) et l'écrit : clavier arabe du moteur en arabe, clavier système en français et en anglais | `{ "texte": "..." }` | `T17-dictee.json` (arabe), `T17-dictee-fr.json` |

## 3. Interaction

### T07 Toucher les mots

1. La phrase (`donnees.texte`) est affichée mot par mot, chaque mot est une tuile légère (`word-tok` de la démo : sans bordure au repos, `blue-soft` et bordure `blue` sélectionné), dans le sens d'écriture, les mots se suivent en ligne et passent à la ligne naturellement (`Wrap`). La ponctuation reste collée au mot.
2. Toucher un mot le sélectionne, toucher à nouveau le désélectionne. `plusieurs: false` (par défaut) : un seul mot à la fois, toucher un autre mot déplace la sélection. `plusieurs: true` : chaque toucher ajoute ou retire.
3. Vérifier devient actif dès qu'un mot est sélectionné. Juste si l'ensemble des index sélectionnés est exactement `reponse.mots`.

### T17 Dictée au clavier

1. Bouton Écouter (grand, `listen`) : le mot (`ecoute.texte`) est dit après la consigne, puis à chaque toucher. Le mot n'est jamais affiché avant la correction. Un emoji facultatif (`emoji`) donne un indice visuel.
2. Le champ de saisie (grand, `content-word`, centré, dans le sens de la langue) montre ce que l'enfant écrit.
3. **Arabe : clavier du moteur.** Trois rangées de lettres arabes (28 lettres, hamza et ta marbouta comprises, plus alif maqsura), une rangée de harakat facultative (fatha, damma, kasra, soukoun, shadda, les trois tanwin) si `harakat: true`, une touche Effacer (dernier caractère) et une touche Espace si le mot en a. Jamais le clavier système en arabe : il varie trop d'un appareil à l'autre et mélange des claviers dialectaux. Les touches font au moins `target-min`, en `content-option`.
4. **Français et anglais : clavier système** (`TextField` sans correction automatique ni suggestions, majuscules selon `casse`), parce que les enfants le retrouvent sur tous les appareils et que le moteur n'a pas à dessiner un AZERTY.
5. Vérifier devient actif dès qu'un caractère est saisi. Après Vérifier, le champ est verrouillé. Explication : le mot attendu s'affiche en `olive` au-dessus du champ.

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `donneesToucherMots`, `reponseMots`, `donneesDictee`, `reponseTexte`).

| Type | `donnees` | `reponse` |
|---|---|---|
| T07 | `texte` (la phrase, 2 à 20 mots séparés par des espaces), `plusieurs` (faux par défaut) | `{ "mots": [index à partir de 0] }`, 1 à 6 index, sans doublon, tous dans la phrase |
| T17 | `ecoute` (le mot dit, obligatoire), `emoji` facultatif, `harakat` (arabe : rangée de harakat proposée, faux par défaut), `casse` (latin : `libre` par défaut, `minuscules`) | `{ "texte": "le mot attendu" }` |

`normalisation` (champ commun de l'exercice) dit comment comparer la saisie à la réponse de T17, sur une copie, jamais sur le texte stocké : `harakat_ignorees` (les harakat de la saisie et de la réponse sont retirées avant de comparer, défaut recommandé en 1re et 2e quand `harakat` est faux), `casse`, `espaces`, `ponctuation`, `tatweel`, `chiffres`. Sans normalisation, la comparaison est exacte, caractère par caractère, harakat comprises et dans l'ordre d'écriture.

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- T07 : chaque index de `reponse.mots` désigne un mot de la phrase (`mot_inconnu`), au plus un mot si `plusieurs` est faux (`reponse_unique`)
- T17 : `reponse.texte` est le mot entendu (`ecoute_differente_reponse`), `harakat` seulement en arabe (`harakat_hors_arabe`), un mot sans harakat avec `harakat: true` est signalé (`harakat_manquantes_reponse`, avertissement), et si la réponse porte des harakat sans `harakat` ni `harakat_ignorees`, l'enfant ne pourrait pas l'écrire (`harakat_impossibles`)

## 5. Correction

- T07 : égalité d'ensembles entre les index sélectionnés et `reponse.mots`.
- T17 : la saisie et `reponse.texte` sont normalisées de la même façon (copie), puis comparées caractère par caractère. `comparerTextes(saisie, attendu, normalisation)` vit dans le moteur, en Dart pur, et chaque normalisation est testée séparément (CLAUDE.md §5). Aucune normalisation Unicode (ni NFC ni NFD) : les harakat gardent leur ordre d'écriture.
- Résultat : `reussi` ou `explique`, avec le nombre d'essais, comme le moteur Choix.

## 6. Feedback en 3 temps

| Moment | Bandeau | Yasmina | Zone | Bouton |
|---|---|---|---|---|
| Réponse juste | validation, olive | bravo | T07 : les mots choisis en « juste ». T17 : le champ en bordure `olive` | Continuer |
| 1er essai faux | indice, amber | encourage | T07 : les mots choisis en « faux » un instant, puis la sélection est vidée. T17 : le champ en bordure `coral` un instant, puis vidé | Vérifier |
| 2e essai faux | explication, coral | encourage | T07 : les bons mots en « juste », verrouillés. T17 : le mot attendu affiché en `olive` au-dessus du champ, champ verrouillé | Continuer |

Sons et libellés : ceux du lecteur (décision 35, choix.md §6).

## 7. Événements et modes

- `reponseDonnee` : à chaque sélection (T07) ou à chaque caractère saisi (T17)
- `essai`, `resultat`, `demandeAudio` (consigne, mot de T17) : comme le moteur Choix
- Modes `enfant`, `apercu` (afficher la réponse : bons mots en « juste », mot attendu dans le champ) et `edition`

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `toucher-mots` | T07 | Phrase en mots touchables |
| `dictee-mot` | T17 | Écouter, clavier, un mot |

## 9. Cas arabe et cas français

- T07 : phrase en `content-sentence` (arabe) ou `latin-prompt` (français, anglais), de droite à gauche en arabe. Les mots sont découpés sur les espaces, sans toucher aux harakat ni à la ponctuation collée.
- T17 en arabe : clavier du moteur en naskh (`content-option`), lettres dans l'ordre alphabétique sur trois rangées de droite à gauche, harakat sur une rangée à part si `harakat`. Le champ affiche le mot lié, harakat comprises.
- T17 en français et en anglais : clavier système, `autocorrect` et suggestions coupés, pas de majuscule automatique.
- Exemples : arabe (T07 trouver le verbe, T17 écrire قَلَمٌ sans harakat avec `harakat_ignorees`), français (T07 trouver les noms, T17 écrire « lapin »).

## 10. Règles UX

- Mot touchable d'au moins `target-min` de haut, touche de clavier d'au moins `target-min`, écart `space-1` entre les touches, `space-2` entre les mots.
- Clavier arabe : 3 rangées de 9 à 10 touches, qui tiennent dans 360 px (touches de `target-min` de large au minimum, défilement en largeur si l'écran est plus étroit).
- Un seul bouton principal par écran : Vérifier, sous le clavier.
- Juste et faux ne passent jamais par la couleur seule.
- Accessibilité : chaque mot et chaque touche est un bouton nommé, le champ de T17 annonce ce qui est écrit.

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| Mot touchable | `MotTouchable` | à créer | Sans bordure au repos, `blue-soft` et bordure `blue` sélectionné, `olive-soft` juste, `coral-soft` faux, `radius-sm` |
| Touche | `ToucheClavier` | à créer | `tile`, bordure `line`, `radius-md`, `target-min`, lettre en `content-option` |
| Champ de saisie | `ChampDictee` | à créer | `tile`, bordure `line` (`blue` au focus, `olive` juste, `coral` faux), `radius-lg`, texte en `content-word` |
| IconButton (listen), Button, Feedback | existants | | Écouter, Vérifier, bandeau |

## 12. Tests prévus

- T07 : un cas arabe et un cas français, sélection unique et multiple, faux puis juste, révélation.
- T17 : clavier arabe (toucher les lettres, Effacer, harakat), comparaison avec `harakat_ignorees` et exacte, clavier système en français (saisie par `enterText`), faux deux fois avec le mot attendu affiché.
- `comparerTextes` : un test par normalisation, et le cas sans normalisation (harakat dans l'ordre d'écriture, jamais réordonnées).
- Parité : chaque exemple dans le lecteur et dans l'aperçu web.

## 13. Découpage (A1-03, 2 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests, `comparerTextes` et ses normalisations | 0,5 |
| c | T07 (mots touchables), T17 (champ, clavier arabe, clavier système), tests, parité | 1,25 |
