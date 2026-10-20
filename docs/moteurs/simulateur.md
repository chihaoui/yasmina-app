# Moteur Simulateur

Fiche de conception du moteur Simulateur, écrite avant le code. Statut : **brouillon de la nuit du 20 au 21 oct. 2026 (Claude Code, session sans surveillance, décision 39)**, à valider par Lamjed. Base de la tâche A2-06 (3 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [simulateur-questions.md](simulateur-questions.md).

Sources : CLAUDE.md §5 (éveil en arabe, consigne sonorisée), le lecteur (`ModeValidation.automatique`, types à plusieurs étapes prévus par le contrat du moteur), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : « flotte ou coule », « tester des matériaux dans un circuit électrique », « moteur générique paramétré par JSON »), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur **générique** d'expérience en trois temps, **prédire, observer, expliquer** : T57 est le moteur paramétré par le JSON (objets, deux issues possibles, décor), T34 Flotte ou coule en est une **instance** (décor `eau`). Tout est dessiné par le code (emoji et formes), sans image, dans `packages/moteur_exercices`, compatible web.

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Validation | Réponse | Exemple |
|---|---|---|---|---|---|
| T57 | Simulateur d'expérience | Pour chaque objet, prédit l'une des deux issues, puis touche Observer : le simulateur montre les issues réelles et compare | automatique | `{ "resultats": [ { "objet", "issue" } ] }` (les issues réelles) | `T57-circuit.json` (4e, matériaux conducteurs) |
| T34 | Flotte ou coule | Même déroulé, décor `eau` : les objets flottent ou coulent dans la cuve | automatique | idem | `T34-flotte-coule.json` (3e) |

## 3. Interaction

1. **Prédire.** Une ligne par objet : l'icône et le nom, puis deux boutons, un par issue (`issues.a`, `issues.b` : libellé et emoji facultatif). Toucher un bouton choisit l'issue pour l'objet (`blue-soft`), un autre toucher change d'avis. Le bouton **Observer** s'active quand tout est prédit.
2. **Observer.** Les prédictions se figent. Le décor s'affiche au-dessus : `eau` (cuve dessinée, les objets de l'issue `a` à la surface, ceux de l'issue `b` au fond), `circuit` (chaque objet avec une lampe allumée en `sun` pour `a`, éteinte pour `b`), `aucun` (chaque objet avec son issue écrite). Chaque prédiction passe en `olive-soft` (juste) ou `coral-soft` (fausse) avec une coche ou une croix. La zone appelle `terminer(juste)` : **juste si toutes les prédictions sont bonnes**.
3. **Expliquer.** Le lecteur affiche le feedback (validation ou explication, qui dit pourquoi) et Continuer. Aucun second essai : une expérience s'observe une fois (mode automatique).

## 4. Données JSON

| Champ | Contenu |
|---|---|
| `donnees.decor` | `eau`, `circuit` ou `aucun` (par défaut). T34 : `eau` obligatoire (`decor_attendu`) |
| `donnees.issues` | `a` et `b` : `libelle` (texte court), `emoji` facultatif |
| `donnees.objets` | 2 à 6 objets : `id` `o1`..., `emoji`, `libelle` (noms uniques) |
| `reponse.resultats` | une entrée par objet (`objet`, `issue` `a` ou `b`) : les issues réelles (`resultats_incomplets`, `reponse_element_inconnu`, `element_duplique`) |

## 5. Correction et feedback

Automatique : la fin vient de la zone, pas de Vérifier. Juste si toutes les prédictions sont bonnes, sinon explication (sans jugement : « الْخَشَبُ وَالتُّفَّاحَةُ يَطْفُوَانِ... »). Aperçu : « afficher la réponse » montre les issues réelles en `olive` et le décor.

## 6. Événements et modes

`reponseDonnee` à chaque prédiction, `resultat` (`reussi` ou `explique`, 1 essai) à l'observation, `demandeAudio` (consigne). Modes `enfant`, `apercu`, `edition`.

## 7. Cas arabe

Éveil en arabe : les deux exemples sont en arabe (libellés et consignes genrées). Les lignes d'objets suivent le sens d'écriture. Un cas français est testé.

## 8. Règles UX

- Boutons d'issue d'au moins `target-min` de haut, pleine largeur disponible.
- Juste et faux ne passent jamais par la couleur seule : coche et croix, Yasmina, le bandeau.
- Accessibilité : chaque bouton d'issue est nommé « objet, issue », le décor annonce « observation ».

## 9. Composants

| Composant | Dans le moteur | Statut |
|---|---|---|
| Lignes d'objets et issues | dans `gabarit_simulateur.dart` | à créer |
| Décor (cuve, circuit, écrit) | `_Decor` | à créer |
| Button, Feedback | existants | Observer, Continuer |

## 10. Tests prévus

`simulateur_test.dart` : prédictions et changement d'avis, Observer actif quand tout est prédit, cuve d'eau, tout juste, une prédiction fausse (explication, prédictions figées), cas français sans décor, aperçu. Parité dans `parite_simulateur_test.dart` et l'aperçu web.

## 11. Découpage (A2-06, 3 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles, exemples, tests | 0,5 |
| c | Gabarit générique, décors, T34 en instance, tests, parité | 2,25 |
