# docs/reference

Maquettes HTML des types d'exercices, copiées depuis le Projet Claude « App éducative ».

| Fichier | Contenu |
|---|---|
| `yasmina-demo.html` | Démo jouable : parcours d'arabe 1re année (trimestre 1) et espace parent |
| `catalogue-v3-poc.html` | Catalogue des types d'exercices v3, T01 à T63 (preuve de concept). La référence produit reste le catalogue v3.1 |

## Référence visuelle seulement, jamais du code à reprendre

- Ces fichiers montrent le rendu attendu de chaque type d'exercice : disposition, enchaînement, feedback. On les ouvre dans un navigateur pour comparer avec l'app.
- Leur code JavaScript ne doit pas être porté ni recopié dans le dépôt. Les gabarits Flutter s'écrivent dans `packages/moteur_exercices`, à partir du catalogue v3.1 et des règles de CLAUDE.md.
- Différence importante : ces maquettes utilisent le toucher-toucher (toucher un élément, puis toucher la cible). L'app utilise un vrai glisser-déposer, avec le toucher-toucher seulement en secours (doigt immobile 200 ms, cibles d'au moins 48 dp, effet aimant, retour animé, vibration au dépôt).
- Le contenu de ces maquettes (textes, mots, consignes) n'est pas du contenu validé : le contenu de l'app passe par le schéma edu-content/1.0.

## Exclus de l'analyse et du formatage

- `analysis_options.yaml` exclut `docs/reference/**` de `flutter analyze`.
- `dart format` ne traite que les fichiers `.dart` : ces fichiers ne sont jamais reformatés par `./tool/verifier.sh`.
- `.gitattributes` les marque comme documentation pour que GitHub ne les compte pas dans les langages du dépôt.
- Ne pas les reformater à la main : ils restent identiques aux originaux du Projet Claude.
