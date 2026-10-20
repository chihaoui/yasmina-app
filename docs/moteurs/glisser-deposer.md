# Moteur Glisser-déposer

Fiche de conception du moteur Glisser-déposer, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, décision 39)**, complété l'après-midi par T56 et T62 (hypothèse de périmètre du mentor : le catalogue v3.1 fait foi, le moteur compte 10 types), à valider par Lamjed. Base de la tâche A1-02 (6 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [glisser-deposer-questions.md](glisser-deposer-questions.md).

Sources : CLAUDE.md §5 (glisser-déposer réel, toucher-toucher en secours, cibles, aimant, retour animé, vibration, réordonner ou retirer avant Vérifier, remplissage de droite à gauche, 4 à 6 éléments en 1re et 2e), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement, jamais du code à reprendre), la liste des types de la décision 3, la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un seul moteur pour tous les exercices où l'enfant **prend un élément et le pose quelque part** : dans un trou, sur sa paire, dans un bac, dans un ordre, dans un mot. Il vit dans `packages/moteur_exercices` et tourne à l'identique dans l'app et dans l'aperçu web (règle d'architecture n°1) :

- il reçoit un exercice edu-content/1.0 et une configuration (langue, forme d'adresse, mode, graine)
- il émet des événements (réponse donnée, essai, résultat, demande d'audio)
- il ne connaît ni la base locale, ni la navigation, ni les profils, ni l'abonnement
- il est compatible web : aucun `dart:io`, les services (audio, vibration) passent par les interfaces injectées

Chaque type se branche sur le lecteur générique par le contrat de `contrat_moteur.dart` (`GabaritReponse`, `ControleurReponse`), comme le moteur Choix. Le lecteur porte la consigne, Yasmina, Vérifier et Continuer, le feedback en 3 temps, les libellés genrés, les modes et les événements. Le moteur ne porte que la zone de réponse : la réserve d'éléments, les cibles, la correction.

## 2. Types couverts

Liste de la décision 3, confrontée au registre des 53 types (`registre_types.dart`) :

| Type | Nom | Ce que fait l'enfant | Dans le registre | Exemple |
|---|---|---|---|---|
| T06 | Texte à trous (étiquettes) | Glisse l'étiquette dans le trou de la phrase | Glisser-déposer, lot 1 | `T06-texte-trou.json`, `T06-texte-trous.json` |
| T09 | Association (paires) | Glisse chaque élément de gauche sur sa paire de droite | Glisser-déposer, lot 1 | `T09-association.json` |
| T11 | Tri en catégories | Glisse chaque élément dans le bon bac | Glisser-déposer, lot 1 | `T11-tri-categories.json` |
| T12 | Tableau de tri (règle de langue) | Comme T11, en colonnes de tableau, texte seulement | Glisser-déposer, lot 1 | `T12-tableau-tri.json` |
| T13 | Remise en ordre (phrase) | Glisse les mots dans la ligne de réponse, dans l'ordre | Glisser-déposer, lot 1 | `T13-remise-en-ordre.json` |
| T14 | Séquence d'images | Comme T13, avec de grandes images légendées | Glisser-déposer, lot 1 | `T14-sequence-images.json` |
| T15 | Construire un mot (lettres) | Glisse les lettres dans la zone du mot, elles se lient | Glisser-déposer, lot 1 | `T15-mot-lettres.json` |
| T16 | Construire un mot (syllabes) | Comme T15, avec des syllabes | Glisser-déposer, lot 1 | `T16-mot-syllabes.json` |
| T56 | Racine et schème (arabe) | Glisse les lettres de la racine (ك ت ب) ou du schème (فَاعِلٌ) d'un mot dans des emplacements | Glisser-déposer, lot 1 (catalogue v3.1) | `T56-racine.json`, `T56-scheme.json` |
| T62 | Frise chronologique | Variante de T13 : glisse des éléments datés ou étiquetés dans l'ordre sur une frise | Glisser-déposer, lot 1 (catalogue v3.1) | `T62-frise.json` |
| T26 | Monnaie | Glisse des pièces dans le porte-monnaie pour former un montant | **Manipulables, lot 2 (A2-02)** | aucun ici (voir §13) |
| T27 | Blocs base 10 | Glisse des dizaines et des unités pour représenter un nombre | **Manipulables, lot 1 (A1-06)** | aucun ici (voir §13) |
| T39 | Glisser des mots dans un texte | Plusieurs trous dans un court texte, avec une banque de mots | **Absent des 53 types** (fusionné dans T06 par le catalogue v3, « plus tard » hors MVP) | couvert par le gabarit `texte-trous` de T06 |

Périmètre retenu l'après-midi du 20 oct. (hypothèse du mentor, à valider le soir) : le catalogue v3.1 (décision 15) fait foi sur la liste de la décision 3. T39 est hors MVP, T26 et T27 relèvent du moteur Manipulables, T56 et T62 appartiennent à ce moteur, qui compte donc **10 types**.

Six interactions suffisent pour les 10 types, chaque type étant une présentation de l'une d'elles :

| Interaction | Types | Cibles |
|---|---|---|
| **Trous** | T06 (et T39 par le gabarit `texte-trous`) | les trous d'un texte, un élément par trou |
| **Paires** | T09 | les éléments de droite, un élément de gauche par cible |
| **Bacs** | T11, T12 | les catégories, plusieurs éléments par bac |
| **Ordre** | T13, T14, T62 | une ligne de réponse (une frise pour T62), les éléments s'y rangent dans l'ordre |
| **Mot** | T15, T16 | la zone du mot, les lettres ou syllabes s'y lient dans l'ordre |
| **Emplacements** | T56 | des emplacements en nombre fixe, un par lettre attendue, remplis dans l'ordre |

## 3. Interaction

### Le geste (CLAUDE.md §5)

1. **Glisser-déposer réel.** L'enfant pose le doigt sur un élément de la réserve, le déplace et le lâche sur une cible. Pendant le déplacement, l'élément suit le doigt (état « tenu » : `blue-soft`, bordure `blue`, légèrement agrandi), sa place dans la réserve reste vide.
2. **Toucher-toucher en secours.** Doigt immobile 200 ms sur un élément (ou toucher bref sans déplacement) : l'élément passe en **attente** (même aspect que « tenu », il reste à sa place). Toucher une cible le pose. Toucher un autre élément déplace l'attente. Toucher l'élément en attente l'en sort.
3. **Cibles d'au moins 48 dp** (`target-min`), bordure pointillée `line` au repos, pleine et `blue` quand un élément est tenu au-dessus (**effet aimant** : la cible s'allume dès que le doigt entre dans sa zone, le dépôt se fait n'importe où dans la cible, l'élément se cale au centre de la cible en un court mouvement).
4. **Dépôt hors cible** : l'élément revient à sa place en un **retour animé** (glissé jusqu'à sa position d'origine, 200 ms, aucun mouvement si l'appareil demande moins d'animations).
5. **Dépôt réussi** : **vibration légère** (`ServiceVibration.legere`) et son `depot` (`ServiceAudio.jouerSon`). Aucun jugement à ce moment : un dépôt n'est ni juste ni faux tant que Vérifier n'est pas appuyé.
6. **Réordonner ou retirer avant Vérifier.** Un élément posé reste glissable : vers une autre cible, vers une autre position de la ligne (ordre, mot), ou vers la réserve. Le toucher d'un élément posé le renvoie dans la réserve (T13 à T16 : seulement le dernier de la ligne, pour ne pas déplacer les autres par erreur).
7. **Vérifier** devient actif quand la réponse est complète : tous les trous remplis (T06), toutes les paires faites (T09), tous les éléments classés (T11, T12), tous les éléments rangés (T13, T14, T62), au moins un élément posé (T15, T16, où des lettres de la réserve peuvent être en trop), tous les emplacements remplis (T56, lettres en trop possibles : une ligne pleine ne reçoit plus rien).

### Déroulé commun

Identique au moteur Choix : Yasmina et la consigne (lue à l'ouverture, réécoute), la zone de réponse, Vérifier, le feedback en 3 temps, Continuer. Particularités d'affichage :

| Type | Zone de réponse | Réserve |
|---|---|---|
| T06 | Le texte en `content-sentence` (arabe) ou `latin-prompt` (court) et `latin-body` (long, décision 38), chaque trou est une cible en ligne, de la largeur de la plus longue étiquette, qui affiche l'étiquette posée | Étiquettes en tuiles, mélangées |
| T09 | Deux colonnes : à gauche (début de ligne) les éléments à glisser, à droite les cibles. Un élément posé s'affiche collé à sa cible, avec un numéro de paire | La colonne de gauche est la réserve |
| T11 | 2 à 3 bacs côte à côte (ou en colonne sur un écran étroit) avec un titre et un emoji, les éléments posés s'empilent dans le bac | Tuiles texte et emoji, mélangées, au-dessus des bacs |
| T12 | 2 colonnes de tableau avec un en-tête, texte seul, les mots posés forment les lignes | Tuiles texte, mélangées |
| T13 | Une ligne de réponse (zone pointillée, `radius-lg`) où les mots se rangent dans l'ordre du dépôt, un mot déposé entre deux autres s'insère | Tuiles de mots, mélangées |
| T14 | Comme T13 avec de grandes tuiles (emoji et légende) | Grandes tuiles, mélangées |
| T15 | La zone du mot : les lettres posées s'affichent **liées comme à l'écrit** (`content-word`, police content), pas en tuiles séparées. Bouton Écouter si `ecoute` existe (mot dit après la consigne, puis à chaque toucher) | Tuiles de lettres (`LetterTile`), mélangées, avec des lettres en trop possibles |
| T16 | Comme T15 avec des syllabes | Tuiles de syllabes |
| T56 | Le mot en grand (`content-word`, bouton Écouter si `ecoute`), puis la ligne des emplacements : les lettres posées, puis une case pointillée par emplacement encore vide (la première reçoit le dépôt). **Racine** : les lettres posées s'affichent isolées, séparées par une espace (ك ت ب), comme un jadhr s'écrit. **Schème** : elles s'affichent **liées en une seule chaîne**, chacune avec la haraka de son emplacement (فَ, فَا, فَاعِ, فَاعِلٌ). Le toucher de la ligne retire la dernière lettre | Tuiles de lettres nues (`content-word`), mélangées, avec des lettres en trop |
| T62 | Une frise : une case par élément sur une ligne du temps (trait, repère par case, flèche dans le sens d'écriture), les éléments posés dans l'ordre puis la case suivante (seule à recevoir un dépôt), puis les cases vides. Sur la frise, la tuile posée montre l'emoji (sinon le texte) et sa date, le texte reste le libellé lu. Un dépôt sur un élément posé s'insère avant lui. Plus de cases que l'écran : la frise défile en largeur | Tuiles emoji, texte et date, mélangées |

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `donneesTrous`, `donneesAssociation`, `donneesTri`, `donneesOrdre`, `donneesMot` et leurs réponses). Dans le prototype, toutes les images sont des emoji (jamais `image` et `emoji` sur le même objet). Un élément de réserve est un objet `{ id, texte, emoji }` avec au moins un texte ou un emoji.

| Type | `donnees` | `reponse` |
|---|---|---|
| T06 | `texte` (avec des trous `{t1}`, `{t2}`... placés dans la phrase), `etiquettes` (2 à 8, id `e1`...), `melanger` | `{ "trous": [ { "trou": "t1", "etiquette": "e2" }, ... ] }`, une étiquette par trou |
| T09 | `gauche` (2 à 6, id `g1`...), `droite` (même nombre, id `d1`...), `melanger` | `{ "paires": [ { "gauche": "g1", "droite": "d2" }, ... ] }`, chaque gauche a une droite, chaque droite une gauche |
| T11, T12 | `categories` (2 à 3, id `k1`..., `titre`, `emoji` facultatif), `elements` (2 à 8, id `e1`...), `melanger` | `{ "classement": [ { "element": "e1", "categorie": "k2" }, ... ] }`, chaque élément dans une catégorie, chaque catégorie utilisée |
| T13, T14 | `elements` (2 à 8, id `e1`...), `melanger` | `{ "ordre": ["e3", "e1", ...] }`, tous les éléments, une fois chacun |
| T15, T16 | `elements` (2 à 10, lettres ou syllabes, id `e1`..., texte obligatoire), `ecoute` facultative (le mot dit), `melanger` | `{ "ordre": ["e2", "e1", ...] }`, chaque id une fois au plus, des éléments de la réserve peuvent rester inutilisés (lettres en trop) |
| T62 | `elements` (2 à 8, id `e1`..., texte ou emoji, `date` facultative : texte court « 7 h », « 1956 »), `melanger` | `{ "ordre": [...] }`, tous les éléments, une fois chacun (comme T13) |
| T56 | `mot` (vocalisé), `forme` (`racine` ou `scheme`), `emplacements` (2 à 6, un par lettre attendue, `haraka` facultative parmi fatha, damma, kasra, soukoun, fathatan, dammatan, kasratan, shadda-fatha, shadda-damma, shadda-kasra, pour le schème seulement), `lettres` (2 à 10 tuiles d'une lettre nue, lettres en trop possibles), `ecoute` facultative (le mot), `melanger` | `{ "ordre": ["e1", ...] }`, une lettre par emplacement, dans l'ordre d'écriture |

Les réponses sont des tableaux d'objets, pas des objets à clés variables : le schéma reste dans son sous-ensemble prudent (pas de `patternProperties`).

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- ids et textes uniques dans chaque liste (`element_duplique`), réponses qui désignent des ids existants (`reponse_element_inconnu`)
- T06 : chaque trou du texte a une réponse et chaque réponse un trou (`trou_sans_reponse`, `reponse_trou_inconnu`), une étiquette ne remplit qu'un trou (`etiquette_reutilisee`), au moins une étiquette en trop ou un seul trou (sinon il suffit de tout poser) : avertissement `etiquettes_sans_intrus`
- T09 : `gauche` et `droite` de même taille, la réponse est une bijection (`association_incomplete`)
- T11, T12 : chaque élément est classé, chaque catégorie reçoit au moins un élément (`classement_incomplet`, `categorie_vide`)
- T13, T14 : l'ordre contient tous les éléments une seule fois (`ordre_incomplet`)
- T15, T16 : l'ordre n'a pas de doublon, et si `ecoute` existe, le mot construit (textes dans l'ordre, collés) est le mot entendu une fois les harakat retirées de la comparaison (`mot_different_ecoute`) : les tuiles portent les lettres nues, l'écoute le mot vocalisé
- T62 : mêmes règles que T13 (`ordre_incomplet`, `reponse_element_inconnu`)
- T56 : une lettre arabe nue par tuile (`lettre_invalide`), une lettre par emplacement (`ordre_incomplet`), aucune haraka sur un emplacement de racine (`haraka_hors_scheme`), pour le schème un emplacement par lettre du mot avec la haraka que cette lettre porte dans le mot (`scheme_longueur`, `scheme_harakat_differentes`, shadda et voyelle comparées sans tenir compte de leur ordre, jamais de NFC ni de NFD), le mot entendu est le mot (`ecoute_differente_reponse`), avertissement `racine_hors_mot` si les lettres de la racine ne se lisent pas dans l'ordre dans le mot (racine creuse ou défectueuse, à relire)
- T12, T15 et T56 en arabe seulement (`type_langue`), T16 jamais en arabe (les syllabes découpées cassent la liaison des lettres)
- avertissement `elements_trop_nombreux` : plus de 6 éléments en 1re ou 2e année (niveau lu dans l'id de l'exercice)

## 5. Correction

- La réponse de l'enfant est une **affectation** : trou → étiquette, gauche → droite, élément → catégorie, ou une **liste ordonnée** d'ids. Elle est juste si elle est égale à `reponse`, ni plus ni moins. Aucune comparaison de texte.
- `melanger` : l'ordre de la réserve est tiré une fois à l'ouverture avec la graine de la configuration et ne change plus entre les essais. Les cibles (trous, droite, catégories) gardent toujours leur ordre.
- Réponse incomplète : Vérifier reste inactif, aucun essai compté.
- Résultat : `reussi` (1er ou 2e essai) ou `explique` (après 2 essais faux), avec le nombre d'essais.
- Mode automatique : aucun type de ce moteur. Tout passe par Vérifier.

## 6. Feedback en 3 temps

| Moment | Bandeau | Yasmina | Zone | Bouton |
|---|---|---|---|---|
| Réponse juste | validation, olive | bravo | les éléments posés passent en « juste » (bordure `olive`, la zone du mot en bordure pleine `olive`) | Continuer |
| 1er essai faux | indice, amber | encourage | les éléments mal placés passent en « faux » un court instant, puis **reviennent seuls dans la réserve** : les éléments bien placés restent, l'enfant ne refait que ce qui est faux | Vérifier |
| 2e essai faux | explication, coral | encourage | la bonne réponse est montrée : chaque élément à sa place, en « juste », zone verrouillée | Continuer |

Sons d'interface : `depot` à chaque dépôt réussi, puis `juste`, `essaiFaux` et `revelee` joués par le lecteur aux 3 temps (décision 35). Les textes et libellés sont ceux du lecteur (genrés en arabe, choix.md §6).

## 7. Événements et modes

- `reponseDonnee` : à chaque dépôt, retrait ou réordonnancement (l'affectation ou la liste courante)
- `essai`, `resultat` : comme le moteur Choix
- `demandeAudio` : consigne, mot à écouter de T15 et T16 (`ecoute.texte`)
- Modes `enfant`, `apercu` (afficher la réponse : chaque élément à sa place en « juste », Rejouer) et `edition` (rechargement) : identiques au moteur Choix

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `texte-trou` | T06 | Une phrase, un trou, 3 à 4 étiquettes |
| `texte-trous` | T06 (ex T39) | Un court texte, 2 à 5 trous, une banque de mots |
| `association-mot-image` | T09 | Mots à gauche, emoji à droite |
| `association-mot-mot` | T09 | Mots des deux côtés (mot et contraire, singulier et pluriel) |
| `tri-bacs` | T11 | Bacs avec titre et emoji |
| `tableau-tri` | T12 | Colonnes de tableau, texte seul |
| `ordre-mots` | T13 | Tuiles de mots |
| `sequence-images` | T14 | Grandes tuiles emoji et légende |
| `mot-lettres` | T15 | Lettres liées dans la zone du mot |
| `mot-syllabes` | T16 | Syllabes collées dans la zone du mot |
| `racine-lettres` | T56 | Forme racine : lettres isolées dans les emplacements |
| `scheme-lettres` | T56 | Forme schème : lettres liées avec leurs harakat |
| `frise-journee`, `frise-etapes` | T62 | Frise des moments d'une journée (avec dates) ou des étapes d'un phénomène (étiquettes seules) |

## 9. Cas arabe et cas français

- **Sens** : toute la zone suit `langue` par `LangueExercice`. En arabe, la réserve se remplit de droite à gauche, la ligne de réponse (T13, T14) et la zone du mot (T15, T16) se remplissent **de droite à gauche**, la colonne de gauche de T09 est à droite (début de ligne), les bacs se lisent de droite à gauche.
- **Liaison des lettres (T15)** : la zone du mot affiche une seule chaîne de texte (les lettres posées, collées), jamais des tuiles séparées, pour que ب + ا + ب donne « باب ». Les tuiles de la réserve montrent la lettre isolée. Les harakat ne sont pas sur les tuiles de lettres : le mot entendu les porte.
- **Racine et schème (T56)** : même vigilance que T15 et T19. Les tuiles portent la lettre nue. Le schème construit est une seule chaîne où chaque lettre posée reçoit la haraka de son emplacement (signes combinants ajoutés après la lettre, jamais réordonnés), pour que ف + ا + ع + ل donne « فَاعِلٌ » lié. La racine s'affiche en lettres isolées séparées par une espace (« ك ت ب »), comme on l'écrit. Le mot à analyser est affiché vocalisé tel qu'écrit.
- **Frise (T62)** : la ligne du temps suit le sens d'écriture : en arabe, la première case est à droite et la flèche pointe vers la gauche.
- **T16 en français ou en anglais seulement** : des syllabes arabes découpées afficheraient des lettres isolées là où l'écrit les lie.
- **Polices** : éléments en `content-option` (arabe) ou `latin-prompt` (français, anglais), lettres et mot construit en `content-word`, texte à trous en `content-sentence` ou `latin-prompt` (long : `latin-body`, décision 38), titres des bacs en `option` (arabe) ou `latin-label`.
- **Exemples** : arabe pour T11, T12, T14, T15, T56 (racine et schème, 4e année), français pour T06, T09, T16, T62 (3e année), anglais pour T13.

## 10. Règles UX

- Tuile d'au moins 48 dp (`target-min`), cible d'au moins 48 dp de haut et de large, écart `space-2` entre tuiles, `space-3` entre cibles, marge d'écran `space-5`.
- **4 à 6 éléments à manipuler au maximum en 1re et 2e année.** Le schéma plafonne à 8 (10 lettres pour T15 et T16, lettres en trop comprises), le validateur avertit au-delà de 6 en 1re et 2e.
- Un seul élément tenu ou en attente à la fois.
- Juste et faux ne passent jamais par la couleur seule : Yasmina, le bandeau et, en aperçu, un mot d'état sur l'élément.
- Tout mouvement (retour animé, aimant, saut de Yasmina) s'arrête si l'appareil demande moins d'animations.
- Accessibilité : chaque élément est un bouton (« tenu », « en attente », « posé dans ... »), chaque cible est un bouton nommé par son titre ou son contenu. Le toucher-toucher est le chemin du lecteur d'écran et du contrôle de sélection. Une tuile en emoji seul garde un libellé neutre (« صُورَةٌ 1 », « image 1 »).

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| LetterTile | `TuileGlissable` | à créer | Toute tuile de la réserve et tout élément posé : `tile`, bordure `line`, `radius-md`, au moins `target-min`. Tenue ou en attente : `blue-soft` et bordure `blue`. Juste : `olive-soft` et `olive`. Faux : `coral-soft` et `coral` |
| LetterTile (zone) | `ZoneDepot` | à créer | Cible : bordure pointillée `line`, `radius-lg`, fond `tile`. Allumée (aimant) : bordure pleine `blue`, fond `blue-soft`. Juste : bordure pleine `olive` |
| ChoiceTile | `TuileChoix` | existe | Non utilisée ici |
| Feedback, Button, YasminaBubble, IconButton | existants | | Portés par le lecteur |

Aucune nouvelle valeur hors `tokens.json` : la bordure pointillée reprend `border-thick` et `line`, l'agrandissement de la tuile tenue reprend l'échelle de `shadow-press` (pas de nouveau jeton, un point à confirmer, question 5).

## 12. Tests prévus

- Un test de widget par type, un cas en arabe (de droite à gauche) et un cas en français ou en anglais, à partir des exemples de `schema/exemples/glisser-deposer/` et de fixtures dans l'autre langue.
- Pour chaque interaction : un vrai geste de glisser (`tester.drag` ou `startGesture` puis `moveTo` et `up`) jusqu'à une cible, un glisser hors cible (retour), et le toucher-toucher (toucher l'élément puis la cible).
- Le déroulé complet : juste au 1er essai, faux puis juste (seuls les éléments faux reviennent), faux deux fois (réponse révélée), événements, son `depot` et vibration à chaque dépôt.
- Test de parité : chaque exemple joué dans un test de widget mobile et par l'aperçu web (test de widget et build web).
- Validation dans l'atelier : les 10 types jouables seuls avec chaque exemple.
- T56 : les lettres isolées de la racine (« ك ت ب »), le schème lié lettre à lettre (« فَ », « فَا », « فَاعِ », « فَاعِلٌ »), la ligne pleine qui refuse une lettre de plus, le retrait du dernier. T62 : les cases de la frise dans le sens d'écriture, la date sous l'élément, l'insertion avant un élément posé.

## 13. Découpage (A1-02, 6 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles du validateur, un exemple par type, tests | 0,75 |
| c1 | `TuileGlissable`, `ZoneDepot`, geste (glisser, attente, aimant, retour), son et vibration, contrôleur d'affectation et d'ordre, tests du geste | 1,5 |
| c2 | T09, T11, T13, T15 | 1,5 |
| c3 | T06 (deux gabarits), T12, T14, T16, parité, atelier | 1,5 |
| c4 | T56 (racine et schème) et T62 (frise) : schéma, validateur, exemples, moteur, tests, parité (après-midi du 20 oct.) | 0,5 de réserve |
| hors fiche | T26 et T27 : restent au moteur Manipulables (A1-06, A2-02), T39 hors MVP | 0 |
