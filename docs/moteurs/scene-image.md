# Moteur Scène image

Fiche de conception du moteur Scène image, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, soir, décision 39)**, à valider par Lamjed. Base de la tâche A1-07 (1,5 j-h en vigueur, les deux types de base). Les types avec audio (T53 Écoute et place, T54 Écoute et colorie, A2-05) sont décrits au §14 (nuit du 20 au 21 oct. 2026, brouillon). Les points tranchés seul et les questions ouvertes sont dans [scene-image-questions.md](scene-image-questions.md).

Sources : CLAUDE.md §5 (glisser-déposer réel, cibles d'au moins 48 dp, une langue par exercice), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : « moteur scène image commun avec T47, T53, T54 »), la fiche [glisser-deposer.md](glisser-deposer.md) (`TuileGlissable`, `ZoneDepot`, contrôleur d'affectation), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour les exercices où l'enfant **agit sur une scène** : il touche la bonne partie d'une image (T08), ou il pose des étiquettes sur les parties d'un schéma (T47). La scène est **dessinée par le moteur** à partir du JSON : des emoji et des formes simples (cercle, carré, rectangle, triangle) placés en coordonnées normalisées (0 à 1), sans aucun fichier image dans le prototype (aucune image sous droits). Les zones touchables sont des rectangles normalisés sur la scène.

Il vit dans `packages/moteur_exercices`, compatible web (`CustomPaint`, `Stack`), et se branche sur le lecteur en `ModeValidation.verifier`.

## 2. Types couverts (base, A1-07)

| Type | Nom | Ce que fait l'enfant | Réponse | Exemple |
|---|---|---|---|---|
| T08 | Hot spot sur image | Touche la zone demandée de la scène (ou plusieurs zones si `plusieurs`) | `{ "zones": ["z2"] }` | `T08-hot-spot.json` (arabe, éveil) |
| T47 | Étiqueter un schéma | Glisse chaque étiquette sur la zone du schéma qu'elle nomme, étiquettes en trop possibles | `{ "placements": [{ "zone": "z1", "etiquette": "e3" }] }` | `T47-etiqueter-schema.json` (français) |

## 3. Interaction

### Commun : la scène

- Un cadre 4 : 3 de la largeur de l'écran (fond `tile`, bordure `line`, coins `radius-lg`). Les éléments de `scene.elements` y sont dessinés dans l'ordre : un emoji (centré sur `x`, `y`, hauteur `h`) ou une forme (`cercle`, `carre`, `rectangle`, `triangle`, rectangle englobant `x`, `y`, `l`, `h`, couleur parmi les jetons `blue`, `olive`, `amber`, `coral`, `sun`, `line`).
- Les zones (`zones`) sont des rectangles normalisés (`x`, `y`, `l`, `h`), d'au moins `target-min` à l'écran (le moteur élargit une zone trop petite autour de son centre). Au repos, une zone se voit par un fin contour `line` arrondi (`radius-md`), pour que l'enfant sache où toucher.
- La scène ne se retourne pas avec la langue : les coordonnées sont absolues (x de gauche à droite).

### T08 Hot spot sur image

1. Toucher une zone la sélectionne (`blue-soft`, bordure `blue`). Sélection unique par défaut (toucher une autre zone déplace la sélection), `plusieurs: true` ajoute ou retire.
2. Vérifier devient actif dès qu'une zone est sélectionnée. Juste si l'ensemble des zones est exactement `reponse.zones`.
3. Accessibilité : chaque zone est un bouton au libellé **neutre** (« مِنْطَقَةٌ 1 », « zone 1 ») : le libellé de la zone (`libelle`) donnerait la réponse.

### T47 Étiqueter un schéma

1. Sous la figure, la réserve d'étiquettes (`TuileGlissable`, mélangées). **Les cases ne sont plus posées sur le dessin** (elles se superposaient et le cachaient, test du 20 oct.) : chaque zone a une case `ZoneDepot` **à gauche ou à droite de la scène** (selon le côté du centre de la zone), reliée par un trait au point de la zone (son centre), comme dans un schéma de manuel. Les cases sont placées automatiquement à la hauteur de leur point, puis écartées si deux se touchent (le contenu ne donne que les zones). La figure ne se retourne pas avec la langue. Glisser une étiquette sur une case l'y pose (son `depot`, vibration), une autre étiquette la remplace. Toucher-toucher en secours. Toucher une étiquette posée la renvoie dans la réserve, la glisser hors de sa case aussi.
2. Vérifier devient actif quand toutes les zones portent une étiquette. Juste si chaque zone porte l'étiquette attendue (contrôleur d'affectation du moteur Glisser-déposer, forme « zones »).
3. Accessibilité : chaque zone est nommée par son `libelle` (c'est l'étiquette attendue qui est cachée, pas la zone).

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `scene`, `elementScene`, `zoneScene`, `donneesHotSpot`, `reponseZones`, `donneesEtiquetage`, `reponsePlacements`).

| Type | `donnees` | `reponse` |
|---|---|---|
| T08 | `scene` (`elements`, 1 à 12 emoji ou formes), `zones` (2 à 9, id `z1`..., `x`, `y`, `l`, `h`, `libelle` facultatif), `plusieurs` (faux par défaut) | `{ "zones": [id...] }`, 1 à 9, sans doublon |
| T47 | `scene`, `zones` (2 à 6, `libelle` obligatoire), `etiquettes` (2 à 8, id `e1`..., texte), `melanger` | `{ "placements": [{ "zone", "etiquette" }] }`, une étiquette par zone |

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- zones : id uniques (`element_duplique`), rectangles dans la scène (`zone_hors_scene` : x + l et y + h au plus 1)
- T08 : réponses existantes (`reponse_element_inconnu`), une seule zone sans `plusieurs` (`reponse_unique`)
- T47 : chaque zone a une étiquette et une seule (`zone_sans_reponse`, `etiquette_reutilisee`), réponses existantes, deux zones du même côté à moins de 0,1 de hauteur l'une de l'autre refusées (`etiquettes_superposees` : leurs cases se chevaucheraient), avertissement `etiquettes_sans_intrus` s'il n'y a aucune étiquette en trop
- avertissement `elements_trop_nombreux` au-delà de 6 zones en 1re et 2e (T08, T47)

## 5. Correction

- T08 : égalité d'ensembles entre les zones sélectionnées et `reponse.zones`.
- T47 : égalité de l'affectation zone → étiquette avec `reponse.placements` (comme T06).
- Réponse incomplète : Vérifier inactif.

## 6. Feedback en 3 temps

| Moment | Bandeau | Yasmina | Zone | Bouton |
|---|---|---|---|---|
| Réponse juste | validation, olive | bravo | zones ou étiquettes en « juste » | Continuer |
| 1er essai faux | indice, amber | encourage | T08 : zones choisies en « faux » un instant, puis la sélection est vidée. T47 : seules les étiquettes mal placées reviennent (comme le moteur Glisser-déposer) | Vérifier |
| 2e essai faux | explication, coral | encourage | la bonne réponse : zones attendues en « juste », chaque étiquette à sa place | Continuer |

## 7. Événements et modes

Comme le moteur Choix (T08) et le moteur Glisser-déposer (T47) : `reponseDonnee`, `essai`, `resultat`, `demandeAudio` (consigne). Modes `enfant`, `apercu` (afficher la réponse), `edition`.

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `hot-spot-emoji` | T08 | Scène d'emoji, une zone par emoji |
| `schema-formes` | T47 | Schéma dessiné en formes, étiquettes à poser |

## 9. Cas arabe et cas français

- La scène est la même dans toutes les langues (coordonnées absolues). La réserve d'étiquettes de T47 se remplit dans le sens d'écriture.
- Exemples : T08 en arabe (éveil, 1re : toucher le soleil dans une scène), T47 en français (3e : les parties d'une plante dessinée en formes). Les tests portent aussi un cas dans l'autre langue pour chaque type.

## 10. Règles UX

- Zones d'au moins `target-min` (élargies par le moteur), étiquettes d'au moins `target-min`, écart `space-2`.
- 4 à 6 zones au maximum en 1re et 2e (le validateur avertit au-delà de 6, `elements_trop_nombreux`).
- Juste et faux ne passent jamais par la couleur seule.
- Une zone posée sur la scène ne cache pas l'élément qu'elle entoure : contour seul au repos, fond translucide (`blue-soft`) quand elle est sélectionnée ou allumée.

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| Scène dessinée | `SceneDessinee` | à créer | Cadre `tile`, formes aux couleurs des jetons, emoji, zones positionnées |
| LetterTile et zone | `TuileGlissable`, `ZoneDepot` | existent | Étiquettes et zones de T47 |
| Zone touchable | `ZoneTouchable` | à créer | Contour `line`, sélectionnée `blue-soft` et `blue`, juste `olive-soft`, faux `coral-soft` |

## 12. Tests prévus

- T08 : toucher une zone, en changer, sélection multiple, faux puis juste, révélation, un cas arabe et un cas français.
- T47 : vrai geste de glisser sur une zone de la scène, remplacement, retrait au toucher, seules les étiquettes fausses reviennent, révélation.
- Scène : une zone plus petite que `target-min` est élargie, les formes et emoji sont dessinés (test du peintre).
- Parité : chaque exemple dans le lecteur et dans l'aperçu web.

## 13. Découpage (A1-07, 1,5 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests | 0,25 |
| c | `SceneDessinee`, T08, T47 (affectation « zones »), tests, parité | 1 |

## 14. Types avec audio (A2-05, 1,5 j-h en vigueur)

Brouillon de la nuit du 20 au 21 oct. 2026 (session sans surveillance). Deux types où la consigne utile est **entendue** (`ecoute`, dite après la consigne affichée et redite par le bouton Écouter, jamais affichée), format des épreuves Cambridge Starters, en anglais dans les exemples (le moteur accepte toute langue).

| Type | Nom | Ce que fait l'enfant | Réponse | Exemple |
|---|---|---|---|---|
| T53 | Écoute et place | Entend « Put the cat under the table », puis touche **une seule fois** l'emplacement de la scène où va l'objet : l'objet (emoji, nom en sous-titre) s'y pose. Un autre emplacement touché le déplace, le même emplacement touché à nouveau le retire | `{ "zone": "z2" }` | `T53-ecoute-place.json` (anglais, 4e) |
| T54 | Écoute et colorie | Entend « Colour the ball red », touche une couleur de la palette (ronds de `target-min` avec le nom en sous-titre), puis l'objet : l'objet prend la couleur. Les objets sont de **grandes icônes** (emoji en `letter-hero`) **avec leur nom en sous-titre**, sans scène dessinée. Sans couleur en main, un objet colorié touché redevient blanc | `{ "coloriages": [ { "objet": "o1", "couleur": "red" } ] }` | `T54-ecoute-colorie.json` (anglais, 4e) |

### Données JSON

| Type | `donnees` | `reponse` |
|---|---|---|
| T53 | `scene` (comme T08), `objet` (`emoji`, `libelle` facultatif), `zones` (2 à 6, `libelle` sert au contenu, le lecteur d'écran garde un libellé neutre), `ecoute` (obligatoire) | `{ "zone" }`, une zone existante (`reponse_element_inconnu`) |
| T54 | `objets` (2 à 6, `id` `o1`..., `emoji`, `libelle`), `couleurs` (2 à 6 parmi red, blue, green, yellow, orange, purple, brown, black, white, pink, uniques), `ecoute` (obligatoire) | `{ "coloriages": [ { "objet", "couleur" } ] }`, 1 à 6, objets et couleurs existants, un objet une seule fois (`element_duplique`), noms d'objets uniques |

Les couleurs de coloriage sont de **vraies couleurs** (rouge doit être rouge), définies dans le thème (`couleurs_coloriage.dart`, seul endroit autorisé pour une couleur en dur) avec leur nom en anglais, français et arabe (harakat en brouillon).

### Correction et feedback

Comme T08 : Vérifier, 3 temps. T53 : juste si l'emplacement est celui attendu, l'emplacement faux passe en `coral` un instant puis la sélection se vide. T54 : juste si l'affectation objet → couleur est exactement celle attendue (ni plus ni moins), seuls les coloriages faux s'effacent après le 1er essai, un objet bien colorié reste. Réponse révélée : l'objet sur l'emplacement attendu, les objets de la réponse colorés.

### Tests

`scene_audio_test.dart` : un cas anglais (exemple réel) et un cas arabe (T53) ou français (T54) par type, consigne entendue après la consigne affichée et jamais écrite, un seul toucher, déplacement et retrait, couleur puis objet, retour des seuls coloriages faux, révélation, parité dans `parite_scene_test.dart` et l'aperçu web.
