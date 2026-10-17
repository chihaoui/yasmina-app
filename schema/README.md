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

## Validateur Dart (package `edu_content`)

Dart pur, sans Flutter ni `dart:io` dans `lib/` : il tourne dans l'app mobile, dans l'aperçu web et, plus tard, dans un outil en ligne de commande du pipeline.

```dart
import 'package:edu_content/edu_content.dart';

final r = validerEtape(texteJson); // ou validerEtapeDecodee(map)
if (!r.estValide) print(r);
// Erreur /exercices/1/langue [langue_incoherente] : la langue de l'exercice (fr) doit être celle de l'étape (ar).
```

`validerExercice(map)` valide un exercice seul, pour l'aperçu web.

Trois étapes : lecture du JSON, schéma (messages traduits en français, chemin JSON Pointer), puis règles métier si le schéma passe.

| Code | Règle | Gravité |
|---|---|---|
| `id_duplique` | id uniques sur toute l'étape | erreur |
| `id_inconnu` | chaque id cité dans une séquence existe | erreur |
| `exercice_en_double` | un exercice ne figure que dans une séquence | erreur |
| `id_incoherent` | les id correspondent aux champs de l'étape et à la date de génération | erreur |
| `langue_incoherente` | langue de chaque exercice = langue de l'étape | erreur |
| `langue_matiere` | arabe, maths et éveil en `ar`, français en `fr`, anglais en `en` | erreur |
| `competence_matiere` | la compétence commence par le code matière de l'étape | erreur |
| `langue_competence` | exercice seul : la langue suit le code matière de la compétence | erreur |
| `date_invalide` | la date de génération existe | erreur |
| `choix_duplique` | T01 et T05 : pas d'id ni de texte de choix en double | erreur |
| `reponse_choix_inconnu` | T01 et T05 : la réponse désigne des choix existants | erreur |
| `reponse_t01_unique` | T01 : exactement une bonne réponse | erreur |
| `exercice_orphelin` | exercice cité dans aucune séquence | avertissement |
| `sequences_nombre` | l'étape n'a pas 4 séquences | avertissement |
| `harakat_manquantes` | texte arabe sans harakat en 1re ou 2e année | avertissement |

Les textes ne sont jamais normalisés (pas de NFC ni de NFD, qui réordonneraient shadda et fatha).

## Modifier le schéma

1. Modifier `edu-content-1.0.schema.json`.
2. Lancer `dart run tool/generer_schema.dart` dans `schema/` (sinon `schema_synchro_test` échoue).
3. Lancer `./tool/verifier.sh` à la racine.
