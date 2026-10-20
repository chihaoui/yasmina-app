# Exemples edu-content/1.0

Exercices d'exemple, au moins un fichier par type (un par gabarit quand un type en a plusieurs, par exemple `T01-qcm-scene.json`), rangés par moteur. Ils servent de référence au moteur, au back-office et au pipeline de génération. Ce ne sont pas des étapes de l'app.

- Chaque fichier est un **exercice seul** (définition `exercice` du schéma), validé par `validerExercice` et par `test/exemples_choix_test.dart`, `test/exemples_glisser_test.dart`, `test/exemples_manipulables_test.dart`, `test/exemples_texte_test.dart`, `test/exemples_saisie_test.dart`, `test/exemples_scene_test.dart` ou `test/exemples_jeux_test.dart` : aucune erreur ni aucun avertissement.
- Contenu original, écrit pour l'exemple, jamais recopié des manuels. Statut `brouillon` : les textes arabes attendent la relecture humaine des harakat.
- Toutes les images du prototype sont des **emoji** (champ `emoji`), aucun fichier image. Les audios sont produits par la synthèse vocale à partir de `ecoute.texte`.
- Après tout ajout, modification ou suppression, lancer `dart run tool/generer_exemples.dart` dans `schema/` : les exemples sont copiés dans `lib/src/exemples_generes.dart`, que lisent l'atelier de l'app et l'aperçu web. Le test `exemples_synchro_test` échoue sinon.
- L'empreinte est calculée selon `schema/README.md` (JSON canonique de type, consigne, donnees et reponse). Elle est à recalculer après toute modification de ces champs.

| Dossier | Moteur | Types |
|---|---|---|
| `choix/` | Choix (`docs/moteurs/choix.md`) | T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61 |
| `glisser-deposer/` | Glisser-déposer (`docs/moteurs/glisser-deposer.md`, brouillon) | T06 (deux gabarits), T09, T11, T12, T13, T14, T15, T16, T56 (racine et schème), T62 |
| `manipulables/` | Manipulables (`docs/moteurs/manipulables.md`, brouillon) | T25, T27, T51, T26 (dinars et millimes), T29 (disque en quarts), T52 (comparaison de deux barres) |
| `texte/` | Texte (`docs/moteurs/texte.md`, brouillon) | T07 (arabe et français), T17 (arabe avec clavier réduit, et français) |
| `saisie-numerique/` | Saisie numérique (`docs/moteurs/saisie-numerique.md`, brouillon) | T22, T48 (addition et soustraction, avec retenue et avec emprunt), T49 (1/4 + 2/4), T50 (compléments à 10 en 30 s), T63 (sac de 5) |
| `scene-image/` | Scène image (`docs/moteurs/scene-image.md`, brouillon) | T08 (arabe), T47 (français), T53 et T54 (anglais, avec consigne entendue), scènes en emoji et en formes |
| `revision-jeux/` | Révision et jeux (`docs/moteurs/revision-jeux.md`, brouillon) | T36 (arabe), T37 (français, 6 paires en 2e), T38 (arabe et français) |
