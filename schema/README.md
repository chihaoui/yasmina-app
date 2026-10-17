# schema

Schéma JSON `edu-content/1.0` des exercices et son validateur.

- Source de vérité : [`edu-content-1.0.schema.json`](edu-content-1.0.schema.json) (JSON Schema draft 2020-12). Il servira tel quel au back-office (ajv) et au pipeline de génération.
- Un fichier JSON par étape, avec les blocs `generation`, `etape` et `exercices`.
- Le contenu embarqué vit dans `apps/mobile/assets/content/` et doit passer ce schéma.

## Choix du schéma

- Sous-ensemble prudent du draft 2020-12 : `type`, `enum`, `const`, `pattern`, `required`, `additionalProperties: false`, `$defs` et `$ref`, `oneOf`, `anyOf`, `if` et `then`. Pas de `unevaluatedProperties` ni de `$dynamicRef`, pour rester compatible avec le validateur Dart, avec ajv et avec les sorties structurées d'un LLM.
- `donnees` et `reponse` sont détaillées pour T01 (QCM, une seule bonne réponse), T05 (choix multiple) et T02 (vrai ou faux). Les autres types ont un `donnees` générique, précisé moteur par moteur pendant A1.
- Les textes destinés à l'enfant (consigne, feedbacks) sont un texte simple ou `{ "masculin", "feminin" }`.
- `normalisation` s'applique uniquement au moment de comparer une réponse, jamais au texte stocké. Les harakat ne sont jamais supprimées ni réordonnées.

## Identifiants

| Objet | Format | Exemple |
|---|---|---|
| Étape | `<mat>-<niveau>-t<trim>-u<unite>-e<ordre sur 2 chiffres>` | `ar-1-t1-u1-e01` |
| Séquence | `<etape>-s<n>` | `ar-1-t1-u1-e01-s1` |
| Exercice | `<etape>-x<nn>` | `ar-1-t1-u1-e01-x03` |
| Génération | `gen-<etape>-<aaaammjj>-<nn>` | `gen-ar-1-t1-u1-e01-20261017-01` |

Codes matière : `ar` arabe, `fr` français, `en` anglais, `ma` maths, `ev` éveil. Le numéro d'un exercice est un numéro de création, pas une position : l'ordre de passage vient uniquement des séquences. Un id n'est jamais réutilisé, même après un rejet.

## Empreinte

`empreinte` vaut `sha256:` suivi du hash hexadécimal du JSON canonique de `{type, consigne, donnees, reponse}` : clés triées, aucun espace, UTF-8 sans échappement des caractères non ASCII. En A0, seul le format est vérifié. Le recalcul arrive en phase B.
