# Moteur Saisie numérique

Fiche de conception du moteur Saisie numérique, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, soir, décision 39)**, à valider par Lamjed. Base de la tâche A1-05 (2 j-h en vigueur, les deux types de base). Les types avancés (T49 Saisie de fraction, T50 Fluidité chronométrée, T63 Balance d'équivalence, A2-01) sont décrits au §14 (nuit du 20 au 21 oct. 2026, brouillon). Les points tranchés seul et les questions ouvertes sont dans [saisie-numerique-questions.md](saisie-numerique-questions.md).

Sources : CLAUDE.md §5 (maths en arabe, consigne sonorisée), le schéma (`tolerance` de l'exercice), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : problème en dinars et pavé numérique, T48 « à confirmer sur les manuels »), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour les exercices où l'enfant **écrit un nombre** avec un pavé numérique dessiné par le moteur : la réponse d'un problème (T22) ou le résultat d'un calcul posé (T48). Il vit dans `packages/moteur_exercices` et tourne à l'identique dans l'app et dans l'aperçu web : aucun clavier système, le pavé est un widget.

Les deux types se branchent sur le lecteur en `ModeValidation.verifier` : Vérifier, feedback en 3 temps, 2 essais.

## 2. Types couverts (base, A1-05)

| Type | Nom | Ce que fait l'enfant | Réponse | Exemple |
|---|---|---|---|---|
| T22 | Saisie numérique | Lit (et entend) un court problème, tape la réponse sur le pavé | `{ "valeur": 27 }` | `T22-probleme.json` |
| T48 | Calcul posé | Lit une addition ou une soustraction posée en colonnes, écrit le résultat chiffre par chiffre, des unités vers les dizaines | `{ "valeur": 59 }` | `T48-addition-posee.json`, `T48-soustraction-posee.json`, `T48-addition-retenue.json` (47 + 36, cases de retenue), `T48-soustraction-emprunt.json` (62 − 28, cases de retenue) |

## 3. Interaction

### Commun : le pavé numérique

- 10 touches de 0 à 9 sur trois rangées (1 2 3, 4 5 6, 7 8 9, puis 0 au centre de la dernière rangée), une touche Effacer. Touches d'au moins `target-min`, en `content-option`, fond `tile`, bordure `line`, `radius-md`.
- **Chiffres** : `chiffres` dans le JSON, `occidentaux` (0 à 9, par défaut, comme tous les textes arabes des exemples) ou `orientaux` (٠ à ٩). Le pavé et la saisie affichent les mêmes chiffres. La réponse stockée est toujours un entier.
- L'ordre des touches ne dépend pas de la langue : 1 2 3 de gauche à droite (`Directionality` ltr sur le pavé), comme un téléphone.

### T22 Saisie numérique

1. Le problème (`donnees.texte`, facultatif : sinon la consigne suffit) en `content-sentence`, avec un emoji facultatif. Il est dit avec la consigne (le lecteur lit la consigne, le texte est dit après, comme un mot à écouter).
2. Le champ de réponse (grand, `content-word`, centré) montre les chiffres tapés, jusqu'à `chiffres_max` (3 par défaut). Une unité facultative (`unite`, « د ») s'affiche après le nombre.
3. Vérifier devient actif dès qu'un chiffre est tapé. Juste si la valeur est `reponse.valeur` à `tolerance` près (0 par défaut).

### T48 Calcul posé

1. Le calcul en colonnes : `a` au-dessus de `b`, le signe (+ ou −) au début de la ligne du bas, un trait, puis les cases du résultat (une par colonne, autant de colonnes que le résultat peut avoir de chiffres). Les chiffres sont alignés par colonne (unités, dizaines, centaines).
2. **Sens** : `sens` dans le JSON. `droite-gauche` (par défaut : la colonne des unités à droite, disposition internationale des manuels) ou `gauche-droite` (unités à gauche). La question est en attente sur les manuels tunisiens : le défaut se change en une ligne.
3. **Retenues** : `retenues` (faux par défaut) affiche une petite case de retenue au-dessus de chaque colonne, que l'enfant peut remplir en la touchant puis en tapant un chiffre. Elles ne comptent pas dans la correction (aide seulement).
4. Les chiffres du résultat s'écrivent **dans l'ordre du calcul** : la colonne des unités d'abord, puis les dizaines, puis les centaines. Chaque chiffre tapé remplit la colonne suivante, Effacer vide la dernière remplie. La case active est marquée (bordure `blue`).
5. Vérifier devient actif dès qu'un chiffre est tapé. Juste si le nombre formé par les cases est `a + b` ou `a − b`.

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `donneesSaisieNumerique`, `donneesCalculPose`, `reponseValeur`).

| Type | `donnees` | `reponse` |
|---|---|---|
| T22 | `texte` facultatif (le problème), `emoji` facultatif, `unite` facultative (texte court après le nombre), `chiffres_max` (1 à 6, 3 par défaut), `chiffres` (`occidentaux` par défaut, `orientaux`) | `{ "valeur": entier de 0 à 999999 }` |
| T48 | `a`, `b` (0 à 999), `operation` (`addition` ou `soustraction`), `sens` (`droite-gauche` par défaut, `gauche-droite`), `chiffres`, `retenues` (faux par défaut) | `{ "valeur": entier }`, égal au résultat |

`tolerance` (champ commun) s'applique à T22 seulement.

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- T22 : `reponse.valeur` tient dans `chiffres_max` chiffres (`valeur_trop_longue`)
- T48 : `a − b` jamais négatif (`soustraction_negative`), `reponse.valeur` égal au résultat (`reponse_valeur_incoherente`)
- aucune règle de langue : la compétence `ma-` impose l'arabe

## 5. Correction

- T22 : `|valeur − reponse.valeur| ≤ tolerance`.
- T48 : le nombre formé par les cases (unités, dizaines, centaines) est égal au résultat. Les cases vides valent 0 à gauche : « 59 » tapé « 9 » puis « 5 » dans deux cases donne 59, une case de centaines laissée vide ne compte pas.
- Réponse incomplète (rien tapé) : Vérifier inactif.

## 6. Feedback en 3 temps

| Moment | Bandeau | Yasmina | Zone | Bouton |
|---|---|---|---|---|
| Réponse juste | validation, olive | bravo | champ ou cases en bordure `olive` | Continuer |
| 1er essai faux | indice, amber | encourage | champ ou cases en `coral` un instant, puis vidés | Vérifier |
| 2e essai faux | explication, coral | encourage | la bonne valeur affichée dans le champ ou les cases, en `olive`, verrouillé | Continuer |

## 7. Événements et modes

- `reponseDonnee` : à chaque chiffre tapé ou effacé
- `essai`, `resultat`, `demandeAudio` (consigne, texte du problème) : comme le moteur Choix
- Modes `enfant`, `apercu` (afficher la réponse : la valeur attendue dans le champ ou les cases), `edition`

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `probleme-court` | T22 | Problème en une ou deux phrases, emoji, pavé |
| `addition-posee`, `soustraction-posee` | T48 | Calcul en colonnes, pavé |

## 9. Cas arabe

- Maths en arabe : les exemples sont en arabe, chiffres occidentaux par défaut. Un cas en français est testé pour T22 (le type reste utilisable hors maths).
- Le pavé et le calcul posé ne se retournent pas avec la langue (`Directionality` ltr) : seuls `sens` et `chiffres` du JSON changent la disposition. Le texte du problème suit la langue.

## 10. Règles UX

- Touches et cases d'au moins `target-min`, écart `space-1` entre les touches, `space-2` entre les colonnes.
- Un seul chiffre par case en T48, au plus `chiffres_max` chiffres en T22 (les touches sont ignorées au-delà).
- Juste et faux ne passent jamais par la couleur seule.
- Accessibilité : chaque touche est un bouton nommé par son chiffre, le champ et les cases annoncent leur contenu, le calcul posé est lu « a plus b ».

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| Pavé numérique | `PaveNumerique` | à créer | Touches `tile`, bordure `line`, `radius-md`, `target-min` |
| Champ de réponse | `ChampNombre` | à créer | `tile`, bordure `line` (`olive` juste, `coral` faux), `radius-lg`, `content-word` |
| Case de chiffre | `CaseChiffre` | à créer | `tile`, bordure `line` (`blue` active, `olive` juste, `coral` faux), `radius-md`, `target-min` |
| Button, Feedback, IconButton | existants | | Vérifier, bandeau, réécoute |

## 12. Tests prévus

- T22 : taper, effacer, limite de chiffres, tolérance, unité, chiffres orientaux, faux puis juste, révélation, un cas français.
- T48 : addition et soustraction, remplissage des cases des unités vers les dizaines, les deux sens, chiffres orientaux, retenues facultatives, faux deux fois avec le résultat révélé.
- Parité : chaque exemple dans le lecteur et dans l'aperçu web.

## 13. Découpage (A1-05, 2 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests | 0,5 |
| c | `PaveNumerique`, T22, T48 (colonnes, sens, chiffres, retenues), tests, parité | 1,25 |

## 14. Types avancés (A2-01, 2 j-h en vigueur)

Brouillon de la nuit du 20 au 21 oct. 2026 (session sans surveillance). Trois types de plus sur le pavé numérique du moteur et sur la tuile de choix.

| Type | Nom | Ce que fait l'enfant | Validation | Réponse | Exemple |
|---|---|---|---|---|---|
| T49 | Saisie de fraction | Calcule une addition ou une soustraction de deux fractions, écrit le résultat sur le pavé : le numérateur dans la case du haut, le dénominateur dans celle du bas (toucher une case la rend active, Effacer vide la case active puis revient au numérateur) | Vérifier | `{ "numerateur": 3, "denominateur": 4 }` | `T49-saisie-fraction.json` (5e, 1/4 + 2/4) |
| T50 | Fluidité chronométrée | Lance le chronomètre (bouton), puis répond au plus vite à des questions de calcul mental (compléments à la cible, additions ou soustractions jusqu'à `max`) en touchant l'une des trois réponses proposées. Une fausse est marquée un instant (son `essaiFaux`), une juste joue `depot`, chaque réponse passe à la question suivante. À la fin du temps (ou après `questions` questions sans chronomètre, ou au bouton Stop), le score s'affiche | sans note | `{ "questions_min": 1 }` (questions répondues au moins pour Continuer) | `T50-fluidite.json` (1re, compléments à 10 en 30 s) |
| T63 | Balance d'équivalence | Lit la balance (masses connues en carrés numérotés sur chaque plateau, un sac rond sur l'un d'eux), écrit la masse du sac sur le pavé : **la balance penche selon la valeur écrite** et s'équilibre quand elle est juste | Vérifier | `{ "valeur": 5 }` | `T63-balance.json` (4e, 2 + 2 + sac contre 3 + 3 + 3) |

### Données JSON

| Type | `donnees` | `reponse` |
|---|---|---|
| T49 | `termes` (2 fractions `numerateur` 0 à 99, `denominateur` 1 à 99), `operation` (`addition`, `soustraction`), `equivalentes` (vrai par défaut : 6/8 accepté pour 3/4), `chiffres` | la fraction attendue, égale au résultat à une fraction équivalente près (`fraction_resultat_incoherente`), différence jamais négative (`soustraction_negative`) |
| T50 | `exercice` (`complement` par défaut, `addition`, `soustraction`), `cible` (compléments, 10 par défaut), `max` (additions et soustractions, 10 par défaut), `duree` (10 à 120 s, 30 par défaut), `chrono` (vrai par défaut), `questions` (sans chronomètre, 10 par défaut), `chiffres` | `questions_min` (1 par défaut, au plus le nombre de questions sans chronomètre : `questions_min_trop_grand`) |
| T63 | `gauche` et `droite` (0 à 6 masses de 1 à 50), `sac` (`gauche` par défaut, `droite`), `chiffres` | `valeur`, la différence des plateaux, strictement positive (`balance_invalide`, `reponse_valeur_incoherente`) |

Les questions de T50 sont tirées avec la graine de la configuration (reproductibles en test et en aperçu), trois réponses proposées dont la bonne, dans les bornes de l'exercice. L'énoncé se lit de gauche à droite (« 7 + ? = 10 »), les chiffres suivent `chiffres`.

### Correction et feedback

T49 et T63 : Vérifier, 3 temps, cases ou sac en `coral` un instant puis vidés après le 1er essai faux, bonne réponse révélée après le 2e (balance à l'équilibre). T50 : sans note, aucun bandeau, Continuer dès que le temps est écoulé et `questions_min` questions répondues, résultat `termine` avec le score dans `reponseDonnee` (justes, total). Le record personnel (catalogue : « bats ton record ») attend la progression locale (A3-03) : le moteur ne garde rien.

### Tests

`saisie_avancee_test.dart` : un cas arabe (exemple réel) et un cas français (fixture) par type. T49 : cases activées au toucher, Effacer, fraction équivalente acceptée ou refusée. T50 : chronomètre qui descend (temps simulé), réponses justes et fausses, fin du temps, score, Stop, sans chronomètre. T63 : inclinaison selon la valeur écrite (vers la droite sans sac, vers la gauche quand le sac pèse trop, équilibre), faux puis juste, révélation. Parité dans `parite_saisie_test.dart` et l'aperçu web.
