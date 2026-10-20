# Exemples edu-content/1.0

Exercices d'exemple, au moins un fichier par type (un par gabarit quand un type en a plusieurs, par exemple `T01-qcm-scene.json`), rangés par moteur. Ils servent de référence au moteur, au back-office et au pipeline de génération. Ce ne sont pas des étapes de l'app.

- Chaque fichier est un **exercice seul** (définition `exercice` du schéma), validé par `validerExercice` et par `test/exemples_choix_test.dart`, `test/exemples_glisser_test.dart` ou `test/exemples_trace_test.dart` : aucune erreur ni aucun avertissement.
- Contenu original, écrit pour l'exemple, jamais recopié des manuels. Statut `brouillon` : les textes arabes attendent la relecture humaine des harakat.
- Toutes les images du prototype sont des **emoji** (champ `emoji`), aucun fichier image. Les audios sont produits par la synthèse vocale à partir de `ecoute.texte`.
- Après tout ajout, modification ou suppression, lancer `dart run tool/generer_exemples.dart` dans `schema/` : les exemples sont copiés dans `lib/src/exemples_generes.dart`, que lisent l'atelier de l'app et l'aperçu web. Le test `exemples_synchro_test` échoue sinon.
- L'empreinte est calculée selon `schema/README.md` (JSON canonique de type, consigne, donnees et reponse). Elle est à recalculer après toute modification de ces champs.

| Dossier | Moteur | Types |
|---|---|---|
| `choix/` | Choix (`docs/moteurs/choix.md`) | T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61 |
| `glisser-deposer/` | Glisser-déposer (`docs/moteurs/glisser-deposer.md`, brouillon) | T06 (deux gabarits), T09, T11, T12, T13, T14, T15, T16, T56 (racine et schème), T62 |
| `trace/` | Tracé (`docs/moteurs/trace.md`, brouillon) | T20 (ب, ل, م : les trois premières lettres de la démo, traits de guidage faits main) |
