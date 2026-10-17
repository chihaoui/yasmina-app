# Exemples edu-content/1.0

Exercices d'exemple, un fichier par type, rangés par moteur. Ils servent de référence au moteur, au back-office et au pipeline de génération. Ce ne sont pas des étapes de l'app.

- Chaque fichier est un **exercice seul** (définition `exercice` du schéma), validé par `validerExercice` et par `test/exemples_choix_test.dart` : aucune erreur ni aucun avertissement.
- Contenu original, écrit pour l'exemple, jamais recopié des manuels. Statut `brouillon` : les textes arabes attendent la relecture humaine des harakat.
- Les images et les audios cités (`images/...`) n'existent pas encore : ce sont des chemins de placeholder.
- L'empreinte est calculée selon `schema/README.md` (JSON canonique de type, consigne, donnees et reponse). Elle est à recalculer après toute modification de ces champs.

| Dossier | Moteur | Types |
|---|---|---|
| `choix/` | Choix (`docs/moteurs/choix.md`) | T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61 |
