# Moteur Mesure et temps

Fiche de conception du moteur Mesure et temps, écrite avant le code. Statut : **brouillon de la nuit du 20 au 21 oct. 2026 (Claude Code, session sans surveillance, décision 39)**, à valider par Lamjed. Base de la tâche A2-03 (2,5 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [mesure-temps-questions.md](mesure-temps-questions.md).

Sources : CLAUDE.md §5 (maths en arabe, cibles d'au moins 48 dp, consigne sonorisée), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : horloge réglée sur 6 h 30, crayon mesuré sur une règle), les fiches [manipulables.md](manipulables.md) (geste, retour à l'état de départ) et [saisie-numerique.md](saisie-numerique.md) (pavé numérique), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour deux exercices de **mesure** : régler une horloge à aiguilles (T28) et lire une longueur sur une règle graduée (T30). Tout est dessiné par le code (`CustomPaint`), sans image. Il vit dans `packages/moteur_exercices`, compatible web, et se branche sur le lecteur en `ModeValidation.verifier` (Vérifier, 3 temps, 2 essais).

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Réponse | Exemple |
|---|---|---|---|---|
| T28 | Horloge | Déplace les aiguilles **au doigt** pour régler l'horloge sur l'heure demandée | `{ "heure": 6, "minutes": 30 }` | `T28-horloge.json` (2e, 6 h 30) |
| T30 | Règle | Lit la longueur d'un objet posé le long d'une règle en centimètres et l'écrit sur le pavé | `{ "valeur": 7 }` | `T30-regle.json` (3e, crayon de 7 cm) |

## 3. Interaction

### T28 Horloge

1. Un cadran rond (`tile`, bordure `ink`), les nombres de 1 à 12 (chiffres selon `chiffres`), une graduation par minute (plus longue toutes les 5), une aiguille des heures (courte, épaisse) et une aiguille des minutes (longue, fine). À l'ouverture, les aiguilles sont sur `depart` (12 h 00 par défaut).
2. **Le doigt prend l'aiguille la plus proche** de l'endroit touché (angle), et la fait tourner tant qu'il bouge. L'aiguille tenue passe en `blue`.
3. **L'aiguille des minutes s'aimante au pas** (`pas` : 5 minutes par défaut, 15 ou 30) et **entraîne celle des heures** comme sur une vraie horloge : passer 12 fait changer d'heure. **L'aiguille des heures s'aimante à l'heure** et garde les minutes (6 h 30 : l'aiguille des heures est entre 6 et 7).
4. Doigt levé : son `depot` et vibration. Vérifier devient actif dès qu'une aiguille a bougé. Juste si l'heure réglée est la cible (heures sur 12 et minutes).

### T30 Règle

1. Une règle (bande `sun`, graduations au centimètre et au demi-centimètre, nombres de 0 à `longueur_regle`), lue de gauche à droite même en arabe (`Directionality` ltr). Au-dessus, l'objet : une barre `amber` de `longueur` centimètres qui part de `depart` (0 par défaut, ailleurs pour le piège de la lecture du bout seul), avec son emoji au milieu.
2. L'enfant écrit la longueur sur le pavé numérique du moteur (2 chiffres au plus) : elle s'affiche avec l'unité (`unite`, « صم » ou « cm »). Vérifier devient actif dès qu'un chiffre est tapé. Juste si la valeur est `reponse.valeur`.

## 4. Données JSON

| Type | `donnees` | `reponse` |
|---|---|---|
| T28 | `pas` (5 par défaut, 15, 30), `depart` (`heure` 1 à 12, `minutes` 0 à 59, 12 h 00 par défaut), `chiffres` | `{ "heure", "minutes" }` : la cible (minutes multiple du pas, `heure_hors_pas`, départ différent de la cible, `depart_egal_cible`) |
| T30 | `longueur_regle` (5 à 30, 10 par défaut), `objet` (`emoji` facultatif, `longueur` 1 à 30, `depart` 0 à 29), `unite` (texte court, « cm » par défaut), `chiffres` | `{ "valeur" }` : la longueur de l'objet (`reponse_valeur_incoherente`), objet dans la règle (`objet_hors_regle`) |

## 5. Correction et feedback

Comme le moteur Manipulables : Vérifier, 3 temps. 1er essai faux : les aiguilles passent en `coral` un instant puis **reviennent au départ** (T28), la longueur écrite s'efface (T30). 2e essai faux : la bonne réponse est montrée (aiguilles sur la cible en `olive`, longueur attendue), zone verrouillée. Aperçu : « afficher la réponse » montre la cible, mot d'état « juste ».

## 6. Événements et modes

`reponseDonnee` à chaque aiguille lâchée sur une nouvelle heure (T28) et à chaque chiffre (T30), `essai`, `resultat`, `demandeAudio` (consigne). Modes `enfant`, `apercu`, `edition`.

## 7. Cas arabe

Maths en arabe : les exemples sont en arabe (consigne et feedbacks genrés), les nombres du cadran et de la règle se lisent de gauche à droite (`chiffres` occidentaux par défaut, orientaux possibles). Un cas français est testé pour chaque type.

## 8. Règles UX

- Le cadran prend la largeur de l'écran (carré), les aiguilles se prennent partout sur le cadran : pas de cible minuscule au bout de l'aiguille.
- Le pas de 5 minutes en 2e, 15 ou 30 en 1re : le contenu choisit.
- Juste et faux ne passent jamais par la couleur seule : Yasmina, le bandeau, le mot d'état en aperçu.
- Accessibilité : le cadran annonce l'heure réglée, la règle sa longueur, la valeur écrite est lue.

## 9. Composants

| Composant | Dans le moteur | Statut |
|---|---|---|
| Cadran | `PeintreHorloge` | à créer |
| Règle | `PeintreRegle` | à créer |
| Pavé numérique | `PaveNumerique` | existe (moteur Saisie numérique) |

## 10. Tests prévus

`mesure_temps_test.dart` : T28 (vrai geste de glisser d'une aiguille, aimant au pas, l'heure qui suit les minutes, passage de 12, retour au départ, révélation, un cas arabe et un cas français), T30 (longueur écrite au pavé, objet qui ne part pas de zéro, faux puis juste, révélation). Parité dans `parite_mesure_test.dart` et l'aperçu web.

## 11. Découpage (A2-03, 2,5 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests | 0,5 |
| c | `PeintreHorloge` et T28 (geste), `PeintreRegle` et T30, tests, parité | 1,75 |
