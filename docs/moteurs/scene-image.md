# Moteur Scène image

Fiche de conception du moteur Scène image, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, soir, décision 39)**, à valider par Lamjed. Base de la tâche A1-07 (1,5 j-h en vigueur, les deux types de base). Les types avec audio (T53 Écoute et place, T54 Écoute et colorie, A2-05) viendront compléter cette fiche. Les points tranchés seul et les questions ouvertes sont dans [scene-image-questions.md](scene-image-questions.md).

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

1. Sous la scène, la réserve d'étiquettes (`TuileGlissable`, mélangées). Chaque zone est une `ZoneDepot` posée sur la scène : glisser une étiquette dessus l'y pose (son `depot`, vibration), une autre étiquette la remplace. Toucher-toucher en secours. Toucher une étiquette posée la renvoie dans la réserve.
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
- T47 : chaque zone a une étiquette et une seule (`zone_sans_reponse`, `etiquette_reutilisee`), réponses existantes, avertissement `etiquettes_sans_intrus` s'il n'y a aucune étiquette en trop
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
