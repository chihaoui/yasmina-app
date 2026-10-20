# schema

Schéma JSON `edu-content/1.0` des exercices et son validateur.

- Source de vérité : [`edu-content-1.0.schema.json`](edu-content-1.0.schema.json) (JSON Schema draft 2020-12). Il servira tel quel au back-office (ajv) et au pipeline de génération.
- Un fichier JSON par étape, avec les blocs `generation`, `etape` et `exercices`.
- Le contenu embarqué vit dans `apps/mobile/assets/content/` et doit passer ce schéma.

## Choix du schéma

- Sous-ensemble prudent du draft 2020-12 : `type`, `enum`, `const`, `pattern`, `required`, `additionalProperties: false`, `$defs` et `$ref`, `oneOf`, `anyOf`, `if` et `then`. Pas de `unevaluatedProperties` ni de `$dynamicRef`, pour rester compatible avec le validateur Dart, avec ajv et avec les sorties structurées d'un LLM.
- `donnees` et `reponse` sont détaillées pour les 13 types du moteur Choix (T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61, voir `docs/moteurs/choix.md`) et les 10 types du moteur Glisser-déposer (T06, T09, T11, T12, T13, T14, T15, T16, T56, T62, voir `docs/moteurs/glisser-deposer.md`, brouillon) les 6 types du moteur Manipulables (T25, T27, T51, et T26, T29, T52 avancés, voir `docs/moteurs/manipulables.md`, brouillon) les 2 types du moteur Texte (T07, T17, voir `docs/moteurs/texte.md`, brouillon) les 5 types du moteur Saisie numérique (T22, T48, et T49, T50, T63 avancés, voir `docs/moteurs/saisie-numerique.md`, brouillon) les 4 types du moteur Scène image (T08, T47, et T53, T54 avec audio, voir `docs/moteurs/scene-image.md`, brouillon) les 3 types du moteur Révision et jeux (T36, T37, T38, voir `docs/moteurs/revision-jeux.md`, brouillon) les 2 types du moteur Mesure et temps (T28, T30, voir `docs/moteurs/mesure-temps.md`, brouillon) et les 4 types du moteur Grille et graphiques (T31, T32, T33, T60, voir `docs/moteurs/grille-graphiques.md`, brouillon). Les autres types ont un `donnees` générique, précisé moteur par moteur pendant A1. Au moins un exemple valide par type (un par gabarit quand il y en a plusieurs) : `schema/exemples/choix/`, `schema/exemples/glisser-deposer/`, `schema/exemples/manipulables/`, `schema/exemples/texte/`, `schema/exemples/saisie-numerique/`, `schema/exemples/scene-image/`, `schema/exemples/revision-jeux/`, `schema/exemples/mesure-temps/`, `schema/exemples/grille-graphiques/`.
- Révision et jeux : T36 (sans note) liste les cartes à voir, T37 les paires à trouver, T38 une grille de lettres (lignes de même longueur) et les mots avec leur position, lus de droite à gauche en arabe (`sens`).
- Scène image : la scène est dessinée par le moteur (`scene.elements` : emoji ou formes en coordonnées normalisées, aucune image), les zones sont des rectangles normalisés `z1` à `z9`. T08 répond par des zones, T47 par des placements zone → étiquette.
- Saisie numérique : pavé numérique du moteur, `chiffres` (occidentaux ou orientaux) sur le pavé et la saisie, valeur stockée en entier. T48 porte `sens` (colonne des unités à droite par défaut) et `retenues`, en attendant les manuels.
- Texte : T07 répond par les index des mots de la phrase (découpée sur les espaces), T17 par le texte attendu, comparé à la saisie après les normalisations du champ `normalisation` (sur une copie, jamais sur le texte stocké).
- Manipulables : le matériel est dessiné à partir de nombres (`min`, `max`, `pas`, `cible`, `sens` de la droite numérique, `cible` et `canonique` des blocs base 10, `cible` du cadre de 10), la `reponse` reste explicite et le validateur contrôle qu'elle correspond à la cible.
- Glisser-déposer : les réponses sont des tableaux d'objets (`trous`, `paires`, `classement`, `ordre`), jamais des objets à clés variables. Les trous de T06 sont des marqueurs `{t1}` à `{t9}` dans le texte. T62 (frise) reprend la réponse `ordre` de T13 avec une `date` facultative par élément. T56 (racine et schème, arabe) donne le `mot`, la `forme` (`racine` ou `scheme`), un emplacement par lettre attendue (avec sa `haraka` pour le schème) et des tuiles de `lettres` nues, la réponse est l'`ordre` des lettres.
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
| `element_duplique` | moteur Glisser-déposer : pas d'id ni de texte en double dans une liste (les lettres de T15, T16 et T56 peuvent se répéter) | erreur |
| `reponse_element_inconnu` | moteur Glisser-déposer : la réponse désigne des éléments, cibles et catégories existants | erreur |
| `trou_duplique`, `trou_sans_reponse`, `reponse_trou_inconnu`, `etiquette_reutilisee` | T06 : chaque trou du texte une fois, une réponse par trou, une étiquette pour un seul trou | erreur |
| `association_incomplete` | T09 : gauche et droite de même taille, la réponse est une bijection | erreur |
| `classement_incomplet`, `categorie_vide` | T11, T12 : chaque élément classé une fois, chaque catégorie utilisée | erreur |
| `element_sans_texte` | T12 : des mots seulement | erreur |
| `ordre_incomplet` | T13, T14, T62 : l'ordre cite chaque élément une fois. T56 : une lettre par emplacement | erreur |
| `mot_different_ecoute` | T15, T16 : le mot construit par l'ordre est le mot entendu sans ses harakat | erreur |
| `type_langue` (suite) | T12, T15 et T56 en arabe, T16 jamais en arabe | erreur |
| `lettre_invalide` | T56 : chaque tuile porte une seule lettre arabe nue | erreur |
| `haraka_hors_scheme` | T56 forme racine : aucun emplacement ne porte de haraka | erreur |
| `scheme_longueur`, `scheme_harakat_differentes` | T56 forme scheme : un emplacement par lettre du mot, avec la haraka que porte cette lettre dans le mot (shadda et voyelle comparées sans tenir compte de leur ordre) | erreur |
| `ecoute_differente_reponse` (suite) | T56 : le mot entendu est le mot | erreur |
| `racine_hors_mot` | T56 forme racine : les lettres de la racine ne se lisent pas dans l'ordre dans le mot (racine creuse ou défectueuse, à relire) | avertissement |
| `droite_invalide`, `droite_trop_longue`, `cible_hors_droite` | T25 : max au-dessus de min, étendue multiple du pas, 20 intervalles au plus, cible sur une graduation | erreur |
| `reponse_valeur_incoherente` | T25, T51 : la réponse est la cible. T27 : dizaines × 10 + unités vaut la cible, 9 unités au plus en mode canonique | erreur |
| `graduations_trop_nombreuses` | T25 : plus de 10 intervalles en 1re ou 2e année | avertissement |
| `montant_inatteignable`, `reponse_valeur_incoherente` (T26) | T26 : la cible se forme avec les pièces de la réserve, la réponse est la cible | erreur |
| `fraction_invalide`, `reponse_valeur_incoherente` (T29) | T29 : numérateur au plus égal aux parts, la réponse est le numérateur | erreur |
| `element_duplique`, `inconnue_invalide`, `etiquette_non_numerique`, `segment_sans_etiquette`, `reponse_valeur_incoherente` (T52) | T52 : id uniques, une seule inconnue (barre ou segment existant), étiquettes entières, une étiquette libre de la bonne valeur par segment connu, la réponse est l'inconnue | erreur |
| `elements_trop_nombreux` (T26), `etiquettes_sans_intrus` (T52) | T26 : plus de 6 sortes de pièces en 1re ou 2e. T52 : aucune étiquette en trop | avertissement |
| `phrase_invalide`, `mot_inconnu`, `reponse_unique` (T07) | T07 : 2 à 20 mots, index existants, un seul mot sans `plusieurs` | erreur |
| `ecoute_differente_reponse` (T17), `harakat_hors_arabe`, `harakat_impossibles` | T17 : le texte attendu est le mot entendu, la rangée de harakat seulement en arabe, un mot attendu vocalisé exige la rangée de harakat ou `harakat_ignorees` | erreur |
| `harakat_manquantes_reponse` | T17 : rangée de harakat proposée mais mot attendu sans harakat | avertissement |
| `clavier_hors_arabe`, `clavier_sans_lettres`, `clavier_lettre_manquante`, `clavier_lettres_inutiles`, `element_duplique` (lettres) | T17 : `clavier` et `lettres` en arabe seulement, un clavier `reduit` exige `lettres`, qui porte toutes les lettres du mot attendu (sans doublon), `lettres` inutile sans `reduit` | erreur |
| `clavier_lettres_en_trop`, `clavier_complet_petits` | T17 : 4 à 6 lettres en trop sur le clavier réduit, clavier réduit recommandé en 1re et 2e | avertissement |
| `clavier_hors_arabe`, `clavier_sans_lettres`, `clavier_lettre_manquante`, `clavier_lettres_inutiles`, `element_duplique` (lettres) | T17 : `clavier` et `lettres` en arabe seulement, un clavier `reduit` exige `lettres`, qui porte toutes les lettres du mot attendu (sans doublon), `lettres` inutile sans `reduit` | erreur |
| `clavier_lettres_en_trop`, `clavier_complet_petits` | T17 : 4 à 6 lettres en trop sur le clavier réduit, clavier réduit recommandé en 1re et 2e | avertissement |
| `valeur_trop_longue` | T22 : la réponse tient dans `chiffres_max` chiffres | erreur |
| `soustraction_negative`, `reponse_valeur_incoherente` (T48) | T48 : résultat jamais négatif, la réponse est le résultat du calcul | erreur |
| `soustraction_negative` (T49), `fraction_resultat_incoherente` | T49 : différence jamais négative, la réponse vaut la somme ou la différence des termes (fraction équivalente admise) | erreur |
| `questions_min_trop_grand` (T50) | T50 : sans chronomètre, `questions_min` au plus égal au nombre de questions | erreur |
| `balance_invalide`, `reponse_valeur_incoherente` (T63) | T63 : le plateau du sac pèse strictement moins que l'autre, la réponse est la différence | erreur |
| `champ_inutile` (T50) | T50 : `max` ne sert pas aux compléments | avertissement |
| `heure_hors_pas`, `depart_egal_cible` (T28) | T28 : minutes de la cible multiples du pas, départ différent de la cible | erreur |
| `objet_hors_regle`, `reponse_valeur_incoherente` (T30) | T30 : l'objet tient dans la règle, la réponse est sa longueur | erreur |
| `element_duplique`, `serie_sans_etiquette`, `valeur_hors_axe`, `serie_inconnue` (T31, T32) | Graphiques : id uniques, chaque série a un emoji ou un texte, valeurs sous le haut de l'axe, réponses existantes | erreur |
| `question_ambigue`, `reponse_valeur_incoherente` (T31) | T31 : une seule série extrême, la réponse est cette série | erreur |
| `valeurs_incompletes`, `reponse_valeur_incoherente` (T32) | T32 : une entrée par série, égale à sa valeur | erreur |
| `case_hors_grille`, `case_hors_moitie`, `symetrie_incoherente` (T33) | T33 : cases données dans le quadrillage et à gauche de l'axe, réponse égale au symétrique | erreur |
| `case_hors_grille`, `depart_egal_but`, `obstacle_sur_chemin`, `chemin_invalide` (T60) | T60 : départ et but dans la grille et distincts, pas d'obstacle dessus, le chemin de la réponse arrive au but | erreur |
| `zone_hors_scene`, `element_duplique` (zones), `reponse_element_inconnu` (T08, T47) | Scène image : zones dans la scène, id uniques, réponses existantes | erreur |
| `reponse_unique` (T08) | T08 : une seule zone sans `plusieurs` | erreur |
| `reponse_element_inconnu` (T53, T54), `element_duplique` (T54) | T53 : l'emplacement attendu existe. T54 : id et noms d'objets uniques, objets et couleurs de la réponse existants, un coloriage par objet | erreur |
| `zone_sans_reponse`, `etiquette_reutilisee` (T47) | T47 : une étiquette attendue par zone, une étiquette sur une seule zone | erreur |
| `etiquettes_superposees` (T47) | T47 : deux zones du même côté de la scène (centre à gauche ou à droite de 0,5) à moins de 0,1 de hauteur l'une de l'autre : leurs cases d'étiquettes, placées par le moteur à côté de la scène, se chevaucheraient | erreur |
| `etiquettes_sans_intrus` (T47), `elements_trop_nombreux` (T08, T47) | T47 : aucune étiquette en trop. Scène image : plus de 6 zones en 1re ou 2e | avertissement |
| `element_duplique`, `reponse_element_inconnu` (T36, T37, T38) | Révision et jeux : id uniques, réponses existantes | erreur |
| `paires_incompletes` (T37), `ordre_incomplet` (T38) | T37 : toutes les paires. T38 : tous les mots | erreur |
| `memory_cartes_niveau` (T37) | T37 : nombre de paires du niveau (lu dans l'id) pour une grille de 3 colonnes pleine : 3 en 1re, 6 en 2e et 3e, 9 en 4e et 5e, 12 en 6e | erreur |
| `memory_cartes_niveau` (T37) | T37 : nombre de paires du niveau (lu dans l'id) pour une grille de 3 colonnes pleine : 3 en 1re, 6 en 2e et 3e, 9 en 4e et 5e, 12 en 6e | erreur |
| `grille_irreguliere`, `lettre_invalide` (T38), `mot_hors_grille` | T38 : lignes de même longueur, lettres arabes nues, chaque mot lisible à sa position dans le sens déclaré | erreur |
| `etiquettes_sans_intrus` | T06 à plusieurs trous : toutes les étiquettes servent | avertissement |
| `elements_trop_nombreux` | moteur Glisser-déposer : plus de 6 éléments en 1re ou 2e année (niveau lu dans l'id) | avertissement |
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
