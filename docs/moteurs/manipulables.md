# Moteur Manipulables

Fiche de conception du moteur Manipulables, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, après-midi, décision 39)**, à valider par Lamjed. Base de la tâche A1-06 (3 j-h en vigueur, les trois types de base). Les types avancés (T26 Monnaie, T29 Fractions, T52 Modèle en barres, A2-02) viendront compléter cette fiche. Les points tranchés seul et les questions ouvertes sont dans [manipulables-questions.md](manipulables-questions.md).

Sources : CLAUDE.md §5 (maths en arabe, glisser-déposer réel avec toucher en secours, cibles d'au moins 48 dp, 4 à 6 éléments manipulables en 1re et 2e), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : droite de 0 à 10 avec repères, blocs base 10 par boutons, cadre de 10 à cases touchées), la fiche [glisser-deposer.md](glisser-deposer.md) pour le geste, la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour les exercices de maths où l'enfant **manipule du matériel** : il place un repère sur une droite numérique, il assemble des dizaines et des unités, il pose des jetons dans un cadre de 10. Le matériel est dessiné par le moteur à partir de nombres (aucune image), il vit dans `packages/moteur_exercices` et tourne à l'identique dans l'app et dans l'aperçu web (règle d'architecture n°1) :

- il reçoit un exercice edu-content/1.0 et une configuration (langue, forme d'adresse, mode)
- il émet des événements (réponse donnée, essai, résultat, demande d'audio)
- il ne connaît ni la base locale, ni la navigation, ni les profils
- il est compatible web : du `CustomPaint`, des `Draggable` et des détecteurs de geste, aucun `dart:io`

Chaque type se branche sur le lecteur par le contrat de `contrat_moteur.dart`, en `ModeValidation.verifier` : Vérifier, feedback en 3 temps, 2 essais, comme le moteur Choix.

## 2. Types couverts (base, A1-06)

| Type | Nom | Ce que fait l'enfant | Réponse | Exemple |
|---|---|---|---|---|
| T25 | Droite numérique | Place le repère sur le nombre demandé, en le glissant le long de la droite ou en touchant la graduation | `{ "valeur": 7 }` | `T25-droite-numerique.json` |
| T27 | Blocs base 10 | Représente un nombre avec des barres de dix et des cubes d'unités, glissés (ou touchés) depuis la réserve vers le plateau | `{ "dizaines": 3, "unites": 4 }` | `T27-blocs-base-10.json` |
| T51 | Cadre de 10 | Pose le nombre demandé de jetons dans un cadre de 2 lignes de 5 cases, en les glissant (ou en touchant une case) | `{ "jetons": 7 }` | `T51-cadre-de-10.json` |

Trois manipulations, trois contrôleurs simples (une valeur, deux compteurs, un ensemble de cases), un seul geste partagé avec le moteur Glisser-déposer.

## 3. Interaction

Déroulé commun : Yasmina et la consigne (lue à l'ouverture, réécoute), le matériel, Vérifier, feedback en 3 temps, Continuer. Le nombre demandé est dans la consigne, en chiffres occidentaux comme dans tout texte arabe des exemples (choix.md §9).

### T25 Droite numérique

1. Une droite horizontale de `min` à `max` par pas de `pas`, avec une graduation par valeur et une étiquette tous les `reperes` (par défaut 0, 5, 10). **Sens** : `sens` dans le JSON, `gauche-droite` (0 à gauche, convention des manuels de maths à confirmer) ou `droite-gauche`. Par défaut `gauche-droite`, quelle que soit la langue. Les chiffres restent de gauche à droite.
2. Le **repère** (un jeton rond `blue` avec une pointe) attend sous la droite, au début (`min`). L'enfant le glisse le long de la droite : il suit le doigt et **s'aimante** à la graduation la plus proche quand il est lâché. Toucher une graduation y pose aussi le repère (secours).
3. Le repère posé reste déplaçable jusqu'à Vérifier. Vérifier devient actif dès qu'il a été posé une fois.

### T27 Blocs base 10

1. À droite (début de ligne en arabe) la **réserve** : une barre de dix (10 cubes collés, `blue-soft`, bordure `blue`) et un cube d'unité (`amber-soft`, bordure `amber`), toujours disponibles. À gauche le **plateau** (zone pointillée, `radius-lg`), avec deux colonnes : les dizaines, puis les unités.
2. Glisser une barre ou un cube de la réserve sur le plateau l'y ajoute (son `depot`, vibration). Toucher un bloc de la réserve l'ajoute aussi (secours). Toucher un bloc posé le retire.
3. Sous le plateau, le compte en clair : « الْعَشَرَاتُ: 3 وَالْوَحَدَاتُ: 4 » (chiffres, sans accord du pluriel à gérer), lu par le lecteur d'écran. Pas le total : c'est à l'enfant de le construire.
4. Vérifier devient actif dès qu'un bloc est posé. Le plateau refuse plus de 9 unités si `canonique` (par défaut) et plus de 9 dizaines.

### T51 Cadre de 10

1. Un cadre de 2 lignes de 5 cases (`target-min` au moins, bordure `line`), qui se lit dans le sens d'écriture. Au-dessus, au début de ligne, la **réserve** : un jeton (`olive`) toujours disponible (à côté du cadre, cinq cases ne tiennent pas dans la largeur d'un téléphone).
2. Glisser le jeton sur une case vide l'y pose (son `depot`, vibration). Toucher une case vide y pose un jeton, toucher la réserve remplit la première case vide (secours), toucher un jeton posé le retire. Les cases se remplissent librement.
3. Vérifier devient actif dès qu'un jeton est posé (la réponse 0 n'existe pas dans le MVP).

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `donneesDroiteNumerique`, `reponseValeur`, `donneesBlocs`, `reponseBlocs`, `donneesCadreDix`, `reponseJetons`).

| Type | `donnees` | `reponse` |
|---|---|---|
| T25 | `min`, `max` (entiers, 0 à 100), `pas` (1 par défaut), `reperes` (étiquette tous les n, 5 par défaut), `cible`, `sens` (`gauche-droite` par défaut, ou `droite-gauche`) | `{ "valeur": entier }`, égal à `cible` |
| T27 | `cible` (10 à 99), `canonique` (vrai par défaut : exactement les dizaines et unités du nombre) | `{ "dizaines", "unites" }`, dont la somme vaut `cible` |
| T51 | `cible` (1 à 10) | `{ "jetons": entier }`, égal à `cible` |

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- T25 : `min` < `max`, étendue multiple de `pas` (`droite_invalide`), au plus 20 intervalles (`droite_trop_longue`), `cible` sur une graduation (`cible_hors_droite`), `reponse.valeur` égale à `cible` (`reponse_valeur_incoherente`)
- T27 : `dizaines × 10 + unites` vaut `cible`, et `unites` au plus 9 si `canonique` (`reponse_valeur_incoherente`)
- T51 : `reponse.jetons` égal à `cible` (`reponse_valeur_incoherente`)
- aucune règle de langue : la compétence `ma-` impose déjà l'arabe (`langue_competence`)

## 5. Correction

- T25 : la valeur du repère est juste si elle est égale à `cible`.
- T27 : juste si `dizaines` et `unites` sont ceux de la réponse (mode canonique), ou si la somme vaut `cible` (mode libre).
- T51 : juste si le nombre de jetons posés est `cible`, quelles que soient les cases.
- Réponse incomplète (rien posé) : Vérifier inactif, aucun essai compté.
- Résultat : `reussi` ou `explique`, avec le nombre d'essais, comme le moteur Choix.

## 6. Feedback en 3 temps

| Moment | Bandeau | Yasmina | Matériel | Bouton |
|---|---|---|---|---|
| Réponse juste | validation, olive | bravo | repère, blocs ou jetons en « juste » (bordure `olive`) | Continuer |
| 1er essai faux | indice, amber | encourage | le matériel passe en « faux » un instant, puis **tout revient à l'état de départ** (repère au début, plateau et cadre vides) | Vérifier |
| 2e essai faux | explication, coral | encourage | la bonne réponse est montrée : repère sur la cible, blocs ou jetons de la bonne réponse, verrouillé | Continuer |

Sons d'interface : `depot` à chaque bloc ou jeton posé et à chaque pose du repère, puis `juste`, `essaiFaux` et `revelee` par le lecteur. Les textes et libellés sont ceux du lecteur, genrés en arabe.

## 7. Événements et modes

- `reponseDonnee` : à chaque pose, retrait ou déplacement (la valeur, les compteurs ou le nombre de jetons)
- `essai`, `resultat`, `demandeAudio` : comme le moteur Choix
- Modes `enfant`, `apercu` (afficher la réponse : matériel de la bonne réponse en « juste », Rejouer) et `edition`

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `droite-0-10` | T25 | Droite de 0 à 10, repère tous les 5 |
| `blocs-dizaines-unites` | T27 | Barres et cubes, deux colonnes |
| `cadre-dix` | T51 | Deux lignes de cinq cases |

Variante à venir pour T51 : « combien manque-t-il pour faire 10 ? » (cadre pré-rempli, l'enfant complète).

## 9. Cas arabe

- Maths en arabe (CLAUDE.md §5) : les trois types se jouent en arabe. Les tests portent un cas au masculin et un cas au féminin, et un cas en français pour la droite numérique (sens et chiffres), au cas où le type servirait en éveil ou en français plus tard.
- **Sens de la droite numérique** : non tranché par les manuels (question 1). Configurable par `sens`, par défaut `gauche-droite`. Les chiffres des étiquettes sont toujours de gauche à droite (`Directionality` ltr sur la droite).
- Réserve et plateau de T27, cadre de T51 : suivent le sens d'écriture (réserve au début de ligne, cases remplies à partir du début de ligne).
- Nombres en chiffres occidentaux dans les consignes et les feedbacks, comme les exemples du moteur Choix.

## 10. Règles UX

- Toute cible (graduation, case, plateau) d'au moins 48 dp (`target-min`). Jeton et cube d'au moins 48 dp, barre de dix plus haute.
- 4 à 6 éléments manipulables en 1re et 2e : T51 a un seul jeton de réserve posé jusqu'à 10 fois, T27 deux blocs de réserve, T25 un repère. Le validateur plafonne la droite à 20 intervalles et avertit au-delà de 10 en 1re et 2e (`graduations_trop_nombreuses`).
- Un seul élément tenu à la fois. Aimant et retour animé comme le moteur Glisser-déposer.
- Juste et faux ne passent jamais par la couleur seule : Yasmina, le bandeau, et en aperçu un mot d'état sous le matériel.
- Accessibilité : la droite est un curseur (valeur courante lue), chaque bloc et chaque case est un bouton nommé (« عَشَرَةٌ », « وَحْدَةٌ », « خَانَةٌ 3 »), le compte en clair est lu.

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| LetterTile (zone) | `ZoneDepot` | existe | Plateau de T27, cases de T51 (pointillé, aimant, juste) |
| Button, Feedback, YasminaBubble, IconButton | existants | | Portés par le lecteur |
| Droite numérique | `DroiteNumerique` | à créer | Trait `ink`, graduations `line`, étiquettes en `option`, repère `blue` |
| Blocs | `Bloc` (barre ou cube) | existe (`materiel.dart`) | Cubes `amber-soft` et `amber`, barre de dix `blue-soft` et `blue`, juste en `olive-soft`, faux en `coral-soft` |
| Jeton | `Jeton` | existe (`materiel.dart`) | Rond `olive`, bordure `olive-text` |
| Réserve et élément posé | `ReserveGlissable`, `Pose` | existent (`materiel.dart`) | Réserve inépuisable (glisser ou toucher), élément posé retiré au toucher, zones de `target-min` |

Aucune nouvelle valeur hors `tokens.json` : les tailles reprennent `target-min`, `space-*` et `border-thick`.

## 12. Tests prévus

- Un test de widget par type (arabe, masculin et féminin, un cas français pour T25), avec un vrai geste : glisser le repère le long de la droite (aimant sur la graduation), glisser une barre et un cube sur le plateau, glisser un jeton sur une case, plus le toucher en secours et le retrait au toucher.
- Le déroulé complet : juste au 1er essai, faux puis juste (retour à l'état de départ), faux deux fois (réponse révélée), événements, son `depot` et vibration.
- T25 : les deux sens de la droite (`gauche-droite`, `droite-gauche`), étiquettes de gauche à droite.
- Test de parité : chaque exemple joué dans un test de widget mobile et par l'aperçu web.
- Validation dans l'atelier : les 3 types jouables seuls avec chaque exemple.

## 13. Découpage (A1-06, 3 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles du validateur, un exemple par type, tests | 0,5 |
| c1 | `DroiteNumerique` et T25 (geste, aimant, sens configurable), tests | 1 |
| c2 | `BlocDix`, `BlocUnite`, `Jeton`, T27 et T51, tests, parité, atelier | 1,25 |
