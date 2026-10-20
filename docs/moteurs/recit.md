# Moteur Récit

Fiche de conception du moteur Récit, écrite avant le code. Statut : **brouillon de la nuit du 20 au 21 oct. 2026 (Claude Code, session sans surveillance, décision 39)**, à valider par Lamjed. Base de la tâche A2-07 (1,5 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [recit-questions.md](recit-questions.md).

Sources : CLAUDE.md §5 (une langue par exercice, consigne sonorisée), le lecteur (`ModeValidation.sansNote`, types à plusieurs étapes prévus par le contrat du moteur : « les étapes s'enchaînent dans la zone »), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : « Aide Nour à aller à l'école en sécurité », « LLM + validation », « free »), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour l'**histoire à choix** (T35) : une histoire en étapes, une question à chaque étape, deux ou trois choix. Le bon choix fait avancer l'histoire, un mauvais choix dit pourquoi et laisse choisir à nouveau. Sans note : l'enfant va toujours au bout. Il vit dans `packages/moteur_exercices`, compatible web.

## 2. Type couvert

| Type | Nom | Ce que fait l'enfant | Validation | Réponse | Exemple |
|---|---|---|---|---|---|
| T35 | Histoire à choix | Lit (et écoute) l'étape, touche un choix. Bon : étape suivante. Mauvais : explication, « Compris », nouveau choix. À la fin : Continuer | sans note | `{ "etapes": ["e1", ...] }` (les étapes à parcourir) | `T35-histoire-choix.json` (français, 2e, Nour va à l'école) |

## 3. Interaction

1. En haut, le compteur « Étape 1 / 3 ». La scène de l'étape en emoji (`letter-hero`), le texte de l'étape (`content-sentence` ou `latin-prompt`) avec un bouton de réécoute (le texte est dit par la synthèse vocale), puis les choix en tuiles pleine largeur.
2. **Bon choix** (`juste: true`) : son `depot`, l'étape suivante s'affiche. **Mauvais choix** : son `essaiFaux`, le choix reste affiché barré en `coral`, son `pourquoi` s'affiche en dessous, et une tuile « Compris » (« فَهِمْتُ ») ramène aux choix de la même étape.
3. Après la dernière étape : le texte de fin (`fin`, facultatif) remplace le texte de l'étape, « Fin » s'affiche, Continuer devient actif. Résultat `termine`, sans bandeau ni son juste ou faux.
4. La réponse émise (`reponseDonnee`) garde le **premier** choix de chaque étape et le nombre de mauvais choix, pour les retours aux familles et, plus tard, la progression.

## 4. Données JSON

| Champ | Contenu |
|---|---|
| `donnees.etapes` | 2 à 6 étapes : `id` `e1`..., `scene` (emoji, facultatif), `texte`, `choix` (2 à 3 : `id` `c1`..., `texte`, `juste`, `pourquoi` facultatif) |
| `donnees.fin` | Texte de fin facultatif |
| `reponse.etapes` | Les étapes à parcourir, dans l'ordre : toutes (`etapes_incompletes`) |

Règles du validateur : id d'étapes et de choix uniques (`element_duplique`), **exactement un choix juste par étape** (`choix_juste_unique`), un mauvais choix porte un `pourquoi` (`pourquoi_manquant`), `reponse.etapes` cite toutes les étapes dans l'ordre.

## 5. Correction et feedback

Aucune note : le lecteur active Continuer quand l'histoire est finie, résultat `termine`. L'explication est dans l'histoire (`pourquoi`), pas dans le bandeau. Aperçu : « afficher la réponse » montre la dernière étape et le texte de fin.

## 6. Événements et modes

`reponseDonnee` à chaque choix (premiers choix et erreurs), `resultat` (`termine`), `demandeAudio` (consigne, texte de l'étape à la réécoute). Modes `enfant`, `apercu`, `edition`.

## 7. Cas arabe et cas français

L'exemple est en français (programme de 2e, sécurité). Un cas arabe est testé (de droite à gauche, trois choix, consigne et libellés genrés). Le texte de l'étape n'est pas lu automatiquement à l'ouverture (seule la consigne l'est, le bouton de réécoute dit l'étape) : question 1.

## 8. Règles UX

- Tuiles de choix pleine largeur, d'au moins `choice-min-height`.
- Un mauvais choix n'est jamais puni : explication, puis on continue. Juste et faux ne passent jamais par la couleur seule (barré, son, texte).
- Accessibilité : chaque choix est un bouton, le texte de l'étape est lu au bouton.

## 9. Composants

| Composant | Dans le moteur | Statut |
|---|---|---|
| ChoiceTile, IconButton | `TuileChoix`, `BoutonIcone` | existent |
| Zone du récit | `gabarit_recit.dart` | à créer |

## 10. Tests prévus

`recit_test.dart` : étapes enchaînées, mauvais choix expliqué puis repris, premier choix gardé dans la réponse, réécoute, fin et Continuer sans note, cas arabe à trois choix, aperçu. Parité dans `parite_recit_test.dart` et l'aperçu web.

## 11. Découpage (A2-07, 1,5 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemple, tests | 0,25 |
| c | Gabarit, tests, parité | 1 |
