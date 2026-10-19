# schema

Schéma JSON `edu-content/1.0` des exercices et son validateur.

- Source de vérité : [`edu-content-1.0.schema.json`](edu-content-1.0.schema.json) (JSON Schema draft 2020-12). Il servira tel quel au back-office (ajv) et au pipeline de génération.
- Un fichier JSON par étape, avec les blocs `generation`, `etape` et `exercices`.
- Le contenu embarqué vit dans `apps/mobile/assets/content/` et doit passer ce schéma.

## Choix du schéma

- Sous-ensemble prudent du draft 2020-12 : `type`, `enum`, `const`, `pattern`, `required`, `additionalProperties: false`, `$defs` et `$ref`, `oneOf`, `anyOf`, `if` et `then`. Pas de `unevaluatedProperties` ni de `$dynamicRef`, pour rester compatible avec le validateur Dart, avec ajv et avec les sorties structurées d'un LLM.
- `donnees` et `reponse` sont détaillées pour les 13 types du moteur Choix (T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61, voir `docs/moteurs/choix.md`). Les autres types ont un `donnees` générique, précisé moteur par moteur pendant A1. Au moins un exemple valide par type (un par gabarit quand il y en a plusieurs) : `schema/exemples/choix/`.
- Une image peut être remplacée par un `emoji` (choix, support, élément de suite, affirmation de T02), jamais les deux ensemble. Dans le prototype, toutes les images sont des emoji.
- T19 a deux formes, choisies par le gabarit : `lettre-vocalisee` (trouver la lettre qui porte la haraka demandée parmi بَ بُ بِ بْ) ou tout autre gabarit (choisir la haraka d'une lettre dans un mot : `avant`, `lettre`, `apres`).
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
| `choix_duplique` | moteur Choix : pas d'id ni de texte en double dans `choix` (et `preuves` pour T46) | erreur |
| `reponse_choix_inconnu` | moteur Choix : la réponse désigne des choix (ou des preuves) existants | erreur |
| `reponse_unique` | T01, T03, T04, T18, T19 (lettre-vocalisee), T24, T55 : exactement une bonne réponse | erreur |
| `reponse_tous_les_choix` | T05, T45, T61 : la réponse ne contient jamais toutes les propositions | erreur |
| `reponse_trop_peu` | T61 : au moins 2 phrases dans le résumé | erreur |
| `choix_trop_peu` | T04 : au moins 3 propositions | erreur |
| `type_langue` | T18 et T19 : exercice en arabe | erreur |
| `forme_sans_lettre` | T18 : chaque forme et le mot contiennent la lettre | erreur |
| `haraka_deja_presente` | T19 (forme mot) : `apres` ne commence pas par une haraka | erreur |
| `reponse_haraka_inconnue` | T19 (forme mot) : la réponse fait partie des harakat proposées | erreur |
| `lettre_vocalisee_invalide` | T19 (lettre-vocalisee) : chaque choix est une lettre arabe suivie d'une seule haraka | erreur |
| `reponse_haraka_incoherente` | T19 (lettre-vocalisee) : seul le bon choix porte la haraka demandée | erreur |
| `ecoute_differente_reponse` | T55 : le mot entendu est le texte du bon choix. T19 (forme mot) : le mot entendu est le mot complet avec la bonne haraka | erreur |
| `reponse_comparaison_fausse` | T23 : le signe correspond aux deux nombres | erreur |
| `suite_reponse_incoherente` | T24 : la réponse suit le motif répété ou la suite arithmétique d'entiers (non contrôlée si aucun des deux n'est reconnu) | erreur |
| `preuve_absente_du_texte` | T46 : chaque preuve est recopiée telle quelle du texte | erreur |
| `exercice_orphelin` | exercice cité dans aucune séquence | avertissement |
| `sequences_nombre` | l'étape n'a pas 4 séquences | avertissement |
| `harakat_manquantes` | texte arabe sans harakat en 1re ou 2e année (sauf une lettre seule, avec ou sans tatweel : formes de T18, lettre de T19) | avertissement |
| `lam_sans_soukoun` | texte vocalisé avec un lam d'article sans soukoun devant une lettre lunaire (convention C) | avertissement |
| `alif_suscrit` | texte avec un alif suscrit U+0670 (convention B de `docs/conventions-arabe.md`) | avertissement |

Les textes ne sont jamais normalisés (pas de NFC ni de NFD, qui réordonneraient shadda et fatha).

## Modifier le schéma

1. Modifier `edu-content-1.0.schema.json`.
2. Lancer `dart run tool/generer_schema.dart` dans `schema/` (sinon `schema_synchro_test` échoue).
3. Lancer `./tool/verifier.sh` à la racine.

## Exemples

Les exemples de `exemples/` (un dossier par moteur) sont copiés dans `lib/src/exemples_generes.dart` (`exemplesEduContent`, chemin relatif vers texte exact). L'app, l'aperçu web et les tests les lisent ainsi sans asset ni `dart:io`, depuis une seule source. Après tout ajout, modification ou suppression d'exemple :

1. Lancer `dart run tool/generer_exemples.dart` dans `schema/` (sinon `exemples_synchro_test` échoue).
2. Lancer `./tool/verifier.sh` à la racine.
