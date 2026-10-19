# Moteur Choix

Fiche de conception du moteur Choix, écrite avant le code. Statut : **validée par Lamjed le 19 oct. 2026**, base de la tâche A1-01b (7 j-h). Les points tranchés et les réponses de Lamjed sont dans [choix-questions.md](choix-questions.md).

Sources : catalogue v3 (`docs/reference/catalogue-v3-poc.html`) et démo (`docs/reference/yasmina-demo.html`), qui servent de référence visuelle et de comportement, jamais de code à reprendre. Règles : CLAUDE.md, `docs/conventions-arabe.md`, `docs/design-system/`.

## 1. Objectif

Un seul moteur pour tous les exercices où l'enfant **touche une ou plusieurs propositions**, puis appuie sur Vérifier. Il couvre 13 types du lot 1. Il vit dans `packages/moteur_exercices` et tourne à l'identique dans l'app et dans l'aperçu web (règle d'architecture n°1) :

- il reçoit un exercice edu-content/1.0 et une configuration (langue, forme d'adresse du profil, mode)
- il émet des événements (réponse donnée, essai, résultat, demande d'audio)
- il ne connaît ni la base locale, ni la navigation, ni les profils, ni l'abonnement

Pas de glisser-déposer dans ce moteur : tout se fait au toucher.

Chaque type se branche sur le lecteur générique (A0-13) par le contrat de `packages/moteur_exercices/lib/src/lecteur/contrat_moteur.dart` : un `GabaritReponse` (mode de validation, contrôleur, zone de réponse) inscrit dans `gabaritsJouables`, puis le type passe à « jouable » dans le registre. Le lecteur porte la consigne, Yasmina, Vérifier et Continuer, le feedback en 3 temps, les libellés, les modes et les événements. T02 est branché depuis le 19 oct. 2026.

Ordre « atelier d'abord » (décision 34) : c'est le premier des 12 moteurs. Ses 13 types sont développés et validés dans l'atelier du menu développeur (chaque type jouable seul, à partir des exemples statiques de `schema/exemples/choix/`), avant tout travail sur le parcours.

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Sélection | Exemples |
|---|---|---|---|---|
| T01 | QCM | Touche la bonne réponse (texte, emoji ou les deux), avec un support facultatif | une | [texte et image](../../schema/exemples/choix/T01-qcm-texte-image.json), [scène](../../schema/exemples/choix/T01-qcm-scene.json), [orthographe](../../schema/exemples/choix/T01-qcm-orthographe.json), [contraire](../../schema/exemples/choix/T01-qcm-contraire.json) |
| T02 | Vrai ou faux | Lit une affirmation, touche Vrai ou Faux | une | [T02-vrai-faux.json](../../schema/exemples/choix/T02-vrai-faux.json) |
| T03 | Écoute et choisis | Écoute un mot, touche la bonne image | une | [T03-ecoute-et-choisis.json](../../schema/exemples/choix/T03-ecoute-et-choisis.json) |
| T04 | Trouve l'intrus | Touche l'élément qui n'appartient pas au groupe | une | [T04-intrus.json](../../schema/exemples/choix/T04-intrus.json) |
| T05 | Choix multiple | Touche toutes les bonnes réponses | plusieurs | [T05-choix-multiple.json](../../schema/exemples/choix/T05-choix-multiple.json) |
| T18 | Forme de la lettre | Choisit la forme d'une lettre arabe selon sa position (2 formes suffisent pour ر ou د) | une | [T18-forme-lettre.json](../../schema/exemples/choix/T18-forme-lettre.json) |
| T19 | Choisir la haraka | Forme mot : choisit la haraka d'une lettre dans un mot. Forme lettre vocalisée : trouve la lettre qui porte la haraka demandée | une | [mot](../../schema/exemples/choix/T19-haraka.json), [lettre vocalisée](../../schema/exemples/choix/T19-lettre-vocalisee.json) |
| T23 | Comparer | Choisit <, = ou > entre deux nombres | une | [T23-comparer.json](../../schema/exemples/choix/T23-comparer.json) |
| T24 | Suites et motifs | Choisit l'élément qui vient après la suite | une | [T24-suite.json](../../schema/exemples/choix/T24-suite.json) |
| T45 | Barrer l'élément faux | Barre les phrases fausses (souvent après un texte) | plusieurs | [T45-barrer.json](../../schema/exemples/choix/T45-barrer.json) |
| T46 | Réponse puis justification | Répond (A), puis touche la phrase du texte qui le prouve (B) | une + une | [T46-justification.json](../../schema/exemples/choix/T46-justification.json) |
| T55 | Paires minimales sonores | Écoute un mot, choisit entre deux mots proches (pain, bain) | une | [T55-paire-minimale.json](../../schema/exemples/choix/T55-paire-minimale.json) |
| T61 | Résumé par sélection | Choisit les phrases qui résument un texte | plusieurs | [T61-resume.json](../../schema/exemples/choix/T61-resume.json) |

## 3. Interaction

Déroulé commun, repris de la démo :

1. L'écran affiche Yasmina (58 px, neutre) à côté de la consigne, et le bouton de réécoute de la consigne. La consigne est lue une fois à l'ouverture.
2. Sous la consigne : le support éventuel (texte, emoji, mot à écouter, suite, mot à vocaliser), puis la grille de propositions.
3. L'enfant touche une proposition :
   - **sélection unique** : la tuile passe en « sélectionné », toucher une autre tuile déplace la sélection
   - **sélection multiple** (T05, T45, T61) : chaque toucher ajoute ou retire la tuile
   - tant que Vérifier n'est pas appuyé, tout reste modifiable
4. **Vérifier** (bouton principal bleu) devient actif dès que la réponse est complète (au moins une tuile, et les deux parties pour T46).
5. Le moteur corrige et affiche le feedback (section 6). Après une réussite ou l'explication, le bouton devient **Continuer** (vert).

Particularités par type :

| Type | Affichage propre |
|---|---|
| T01 | Support au-dessus de la grille, chaque partie facultative et combinable : texte (une ou plusieurs lignes), emoji en grand, bouton Écouter si `support.ecoute` existe |
| T02 | Deux tuiles Vrai et Faux, libellés fournis par le moteur dans la langue de l'exercice, ordre fixe |
| T03, T55 | Grand bouton Écouter (variante `listen` du IconButton, « اِسْمَعْ » ou « اِسْمَعِي » en arabe). Le mot est lu une fois à l'ouverture, puis à chaque toucher. Le texte entendu n'est jamais affiché |
| T18 | Le mot (`mot`) au-dessus, en content-word. Les formes en content-word, dans l'ordre isolée, début, milieu, fin (`melanger: false` dans l'exemple). 2 formes pour les lettres qui ne s'attachent pas à gauche |
| T19, forme mot | Le mot en grand, la lettre cible en blue avec un cercle pointillé à la place de la haraka. Chaque tuile montre la haraka sur ◌ et son nom (فَتْحَةٌ, ضَمَّةٌ, كَسْرَةٌ, سُكُونٌ). La haraka choisie s'affiche aussitôt sur la lettre |
| T19, lettre vocalisée | 2 à 4 tuiles de lettres vocalisées (بَ بُ بِ بْ) en content-word. La consigne nomme la haraka demandée |
| T23 | « a ? b » en grand, isolé du sens de la phrase (toujours de gauche à droite). 3 tuiles <, =, > en ordre fixe. Le signe choisi remplace le « ? » |
| T24 | La suite sur une ligne, suivie d'une case « ? ». L'élément choisi s'affiche dans la case |
| T45 | Tuiles de phrase pleine largeur. Une tuile touchée est barrée (trait sur le texte), en plus de l'état sélectionné |
| T46 | Le texte en content-sentence ou latin-body, puis la partie A (question en latin-prompt et réponses), puis la partie B (les phrases du texte, une par tuile) |
| T61 | Le texte, puis les phrases en tuiles pleine largeur |

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence. Dans le prototype, **toutes les images sont des emoji** (champ `emoji`, jamais avec `image` sur le même objet). Résumé :

| Type | `donnees` | `reponse` |
|---|---|---|
| T01, T04, T05, T45 | `choix` (2 à 6, texte, image ou emoji, audio facultatif), `support` facultatif (texte sur une ou plusieurs lignes, image ou emoji, `ecoute`, tous combinables), `melanger` | `{ "choix": [id...] }` |
| T02 | `affirmation`, `image` ou `emoji`, `audio` facultatif | `{ "valeur": true }` |
| T03, T55 | `ecoute` (`texte` dit par la synthèse vocale, `audio` plus tard), `choix`, `melanger` | `{ "choix": [id] }` |
| T18 | `lettre` (une lettre sans haraka), `position` (isolee, debut, milieu, fin), `mot` facultatif, `choix` (2 à 4, texte obligatoire) | `{ "choix": [id] }` |
| T19, gabarit `lettre-vocalisee` | `haraka` demandée (fatha, damma, kasra ou soukoun), `choix` (2 à 4 lettres vocalisées), `melanger` | `{ "choix": [id] }` |
| T19, autres gabarits | `avant`, `lettre`, `apres` (le mot vaut avant + lettre + haraka + apres), `harakat` proposées (2 à 4 parmi fatha, damma, kasra, soukoun), `ecoute` facultative | `{ "haraka": "damma" }` |
| T23 | `a`, `b` (nombres) | `{ "signe": ">" }`, lu « a > b » |
| T24 | `suite` (3 à 12 éléments, texte, image ou emoji), `choix` | `{ "choix": [id] }` |
| T46 | `texte`, `question`, `choix` (2 à 4), `preuves` (2 à 6 phrases du texte, id `p1`...) | `{ "choix": [id], "preuves": [id] }` |
| T61 | `texte`, `choix` (3 à 6 phrases) | `{ "choix": [id, id...] }` |

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- une seule bonne réponse pour T01, T03, T04, T18, T19 (lettre vocalisée), T24 et T55
- jamais toutes les propositions pour T05, T45 et T61, et au moins 2 phrases pour T61
- au moins 3 propositions pour T04 seulement (T18 accepte 2 formes)
- T18 et T19 en arabe seulement
- cohérence de la réponse :
  - T19 forme mot : mot entendu
  - T19 lettre vocalisée : lettres vocalisées valides, seul le bon choix porte la haraka demandée
  - T23 : signe
  - T24 : motif ou suite arithmétique
  - T46 : preuves recopiées du texte
  - T55 : mot entendu
- jamais une image et un emoji sur le même objet

## 5. Correction

- La réponse de l'enfant est un **ensemble d'id** (ou une haraka, un signe). Elle est juste si elle est égale à `reponse`, ni plus ni moins. T46 est juste si les deux parties le sont.
- Aucune comparaison de texte : `normalisation` et `tolerance` ne servent pas dans ce moteur.
- Réponse incomplète (rien de touché) : Vérifier reste inactif. Aucun essai n'est compté.
- `melanger` : l'ordre des tuiles est tiré une fois à l'ouverture de l'exercice et ne change plus entre les essais. Le tirage utilise une graine injectée (tests et aperçu reproductibles). T02 et T23 gardent toujours leur ordre.
- Résultat : `reussi` (au 1er ou au 2e essai) ou `explique` (après 2 essais faux), avec le nombre d'essais. La progression locale compte la réussite au premier essai, comme la démo.

## 6. Feedback en 3 temps

| Moment | Bandeau Feedback | Yasmina | Tuiles | Bouton |
|---|---|---|---|---|
| Réponse juste (1er ou 2e essai) | validation : `feedbacks.reussite`, olive | bravo | les tuiles choisies passent en « juste » | Continuer (vert) |
| 1er essai faux | indice : `feedbacks.indice`, amber | encourage | les tuiles choisies passent en « faux » un court instant, puis la sélection est vidée pour le nouvel essai | Vérifier |
| 2e essai faux | explication : `feedbacks.explication`, coral | encourage | les bonnes tuiles passent en « juste », les autres sont verrouillées | Continuer (vert) |

- Les textes sont pris au masculin ou au féminin selon la forme d'adresse reçue dans la configuration.
- **Sons d'interface** (décision 35) : le lecteur joue `juste` à la validation, `essaiFaux` à l'indice (doux, jamais un buzzer) et `revelee` à l'explication, par `ServiceAudio.jouerSon`. Volume bas, rien en mode silencieux ni quand « Sons des effets » est coupé dans le menu développeur.
- La validation dit ce qui est juste, jamais « tu es doué ». Les exemples suivent ce modèle (« إِجَابَتُكَ صَحِيحَةٌ: ... », « Oui : ... »).
- Le libellé du bandeau et les boutons sont dans la langue de l'exercice, fournis par le moteur. **En arabe, ils sont genrés comme les consignes** (masculin ou féminin selon le profil) :

| Langue | Vérifier | Continuer | Écouter | Validation | Indice | Explication | Vrai | Faux |
|---|---|---|---|---|---|---|---|---|
| ar, masculin | تَحَقَّقْ | وَاصِلْ | اِسْمَعْ | أَحْسَنْتَ | تَلْمِيحٌ | لِنَتَعَلَّمْ | صَحِيحٌ | خَطَأٌ |
| ar, féminin | تَحَقَّقِي | وَاصِلِي | اِسْمَعِي | أَحْسَنْتِ | تَلْمِيحٌ | لِنَتَعَلَّمْ | صَحِيحٌ | خَطَأٌ |
| fr | Vérifier | Continuer | Écouter | Bravo | Indice | Explication | Vrai | Faux |
| en | Check | Continue | Listen | Well done | Hint | Let's learn | True | False |

## 7. Événements et modes

Événements émis vers l'hôte (l'app ou l'aperçu web) :

- `reponseDonnee` : à chaque changement de sélection (id sélectionnés)
- `essai` : à chaque Vérifier (numéro, juste ou faux)
- `resultat` : fin de l'exercice (`reussi` ou `explique`, nombre d'essais)
- `demandeAudio` : consigne, mot à écouter (`ecoute.texte`, aussi dans `support`), choix avec `audio`. L'hôte joue l'audio par l'interface injectée (flutter_tts sur mobile, synthèse du navigateur sur le web)

Modes :

- `enfant` : comportement ci-dessus
- `apercu` : bascule « afficher la réponse » (bonnes tuiles en « juste », avec un mot d'état sous la tuile), bouton Rejouer, aucun événement de progression
- `edition` : comme l'aperçu, et l'exercice se recharge dès que le JSON change

## 8. Variantes (gabarits)

`gabarit` choisit la présentation sans changer la correction, sauf pour T19 où `lettre-vocalisee` choisit aussi la forme des données. Valeurs utilisées par les exemples, à figer dans le référentiel des gabarits :

| Gabarit | Types | Présentation |
|---|---|---|
| `qcm-texte`, `qcm-texte-image` | T01 | Grille de tuiles, texte seul ou emoji et texte |
| `qcm-scene` | T01 | Support texte (une ou plusieurs lignes) et emoji, puis grille |
| `qcm-orthographe` | T01 | Support emoji et bouton Écouter, puis les écritures possibles du mot |
| `qcm-contraire` | T01 | Support : le mot en grand, puis grille de mots |
| `vrai-faux-texte` | T02 | Affirmation, emoji facultatif, deux tuiles |
| `ecoute-image` | T03 | Bouton Écouter, grille d'emoji |
| `intrus-texte` | T04 | Grille de tuiles |
| `choix-multiple-texte` | T05 | Grille de tuiles, sélection multiple |
| `forme-lettre` | T18 | Mot, puis 2 à 4 formes |
| `haraka` | T19 | Mot avec lettre cible, puis harakat |
| `lettre-vocalisee` | T19 | 2 à 4 lettres vocalisées |
| `comparer-nombres` | T23 | a ? b, puis <, =, > |
| `suite-images` | T24 | Suite, case « ? », grille |
| `barrer-phrases` | T45 | Support, phrases pleine largeur barrées au toucher |
| `reponse-justification` | T46 | Texte, partie A, partie B |
| `paire-minimale` | T55 | Bouton Écouter, 2 tuiles texte et emoji |
| `resume-selection` | T61 | Texte, phrases pleine largeur |

## 9. Cas arabe et cas français

- **Sens** : tout l'exercice suit `langue` par `LangueExercice`. En arabe, la grille se remplit de droite à gauche, Yasmina et la consigne sont en miroir, la flèche de réécoute suit le sens.
- **Polices** : en arabe, propositions en `content-option` (Noto Naskh, interligne 1,6), mots isolés en `content-word`, textes en `content-sentence`. En français et en anglais, **tout texte court lu par l'enfant est en `latin-prompt` (20 px)** : consigne, affirmation de T02, texte des propositions (tuiles), question de T46. `latin-body` ne sert qu'aux textes longs à lire (support de T45, texte de T46 et de T61). Décision de Lamjed du 20 oct. 2026.
- **Nombres** : chiffres occidentaux (4, 10) dans les textes arabes, comme les exemples. T23 affiche « a ? b » isolé (`Directionality` de gauche à droite) pour que < et > ne soient jamais retournés par l'algorithme bidirectionnel. Les feedbacks arabes évitent les signes et écrivent « 14 أَكْبَرُ مِنْ 9 ».
- **Arabe seulement** : T18 et T19. Les harakat des propositions ne sont jamais supprimées ni réordonnées (pas de NFC ni de NFD).
- **Exemples** :
  - arabe : T01 (éveil, scène, contraire), T05, T23, T24 (maths), T18, T19 forme mot et lettre vocalisée
  - français : T01 (orthographe), T04, T45, T46, T55, T61
  - anglais : T02, T03

## 10. Règles UX

- Toute tuile fait au moins 48 dp de côté et `choice-min-height` (60) de haut. Écart `space-3` entre tuiles, marge d'écran `space-5`.
- Grille : 2 propositions sur 2 colonnes, 3 sur 3 colonnes, 4 en 2 × 2, 5 ou 6 sur 3 colonnes. Les phrases (T45, T46 partie B, T61) en pleine largeur.
- **4 à 6 propositions au maximum en 1re et 2e année.** Le schéma plafonne déjà à 6 (4 pour T18, T19 et T46 partie A).
- Consigne toujours sonorisée, avec le bouton de réécoute.
- Un seul bouton principal par écran.
- Juste et faux ne passent jamais par la couleur seule : humeur de Yasmina, texte du bandeau, et en aperçu un mot d'état sur la tuile.
- Tout mouvement (secousse de la tuile fausse, saut de Yasmina) s'arrête si l'appareil demande moins d'animations.
- Accessibilité : chaque tuile est un bouton avec son état (sélectionné ou non) et un libellé. **Une tuile en image ou en emoji seul a un libellé neutre** (« صُورَةٌ 1 », « image 1 », « picture 1 », selon la langue de l'exercice) : le mot à trouver reste seulement audio, sinon le lecteur d'écran donnerait la réponse.

## 11. Composants du design system

Toutes les valeurs viennent de `tokens.json` (version 7), il n'en reste aucune hors jetons.

| Composant (design system) | Dans le moteur | Statut | Usage ici |
|---|---|---|---|
| ChoiceTile | `TuileChoix` | existe (variante barrée de T45 à ajouter) | Toutes les propositions. États repos (`tile`, bordure `line`), sélectionné (`blue-soft`, `blue`), juste (`olive-soft`, `olive`), faux (`coral-soft`, `coral`). Bordure `border-thick`, rayon `radius-lg`, hauteur `choice-min-height`. Emoji en grand au-dessus du texte. Texte en `content-option` en arabe, `latin-prompt` en français et en anglais. Variante barrée pour T45 |
| Feedback | `BandeauFeedback` | existe | Validation, indice, explication. Bord de début de ligne `border-feedback`, rayon `radius-lg`, marges `pad-feedback-x` et `pad-bubble-y`, libellé en `latin-label` ou kid, texte en style `feedback` (kid, 19 px, gras) |
| Button | `BoutonYasmina` | existe | Vérifier (bleu), Continuer (vert), Rejouer en aperçu (alt) |
| YasminaBubble | `Yasmina` et `YasminaBulle` | existent | Yasmina 58 px (`yasmina-reader`) à côté de la consigne, humeur neutre, bravo ou encourage |
| IconButton | `BoutonIcone` | existe, à compléter | Réécoute de la consigne (rond, icône `icon-md`). Nouvelle variante `listen` pour T03, T55 et le support écouté de T01 : fond `blue`, texte `on-accent` en style `listen`, marges `pad-listen-x` et `pad-listen-y`, icône `icon-listen`, rayon `radius-pill` |

Tout texte posé sur un pastel fixe (matières, séquences, carte) utilise `ink-fixed`, jamais `ink`.

## 12. Tests prévus

- Un test de widget par type, un cas en arabe et un cas en français (ou anglais) quand le type le permet, à partir des exemples de `schema/exemples/choix/`.
- Le déroulé complet : juste au 1er essai, juste au 2e essai, faux deux fois (indice, puis explication et réponse révélée), événements émis.
- Libellés arabes au masculin et au féminin.
- Test de parité : le même JSON dans un test de widget mobile et dans le build web de l'aperçu.
- Goldens : T01 en arabe et T45 en français, à l'état sélectionné et après l'explication, en clair et en sombre.
- Validation dans l'atelier : les 13 types jouables seuls, avec chaque exemple.

## 13. Découpage (A1-01b, 7 j-h)

| Étape | j-h |
|---|---|
| Modèles Dart des 13 types (freezed, lecture des exemples) et correction pure, testée sans widget | 1,5 |
| `TuileChoix`, `BandeauFeedback` et variante `listen` de `BoutonIcone` (composants, tests, goldens) | 1,5 |
| Lecteur commun : consigne, réécoute, Yasmina, Vérifier, 3 temps, libellés genrés, événements | 1,5 |
| Affichages propres : T01 (support), T19 (deux formes), T23, T24, T45, T46, T03 et T55 | 1,5 |
| Modes aperçu et édition, parité web, goldens, atelier | 1 |
