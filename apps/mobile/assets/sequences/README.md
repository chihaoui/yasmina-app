# Séquences de test (A1-22)

`tour-1.json` décrit la séquence de test du tour 1 des familles : des **séries** d'exercices enchaînés, sans carte du trimestre (le parcours vient en phase A3). L'enfant l'ouvre par le bouton « Jouer » de l'accueil, choisit une série, et les exercices se jouent à la suite dans le lecteur (mode enfant, forme d'adresse du profil, voix et sons réels). À la fin, Yasmina fait le bilan. Rien n'est enregistré.

## Format

```json
{
  "id": "tour-1",
  "series": [
    {
      "id": "choix",
      "titre": { "ar": "أَخْتَارُ الْجَوَابَ الصَّحِيحَ", "fr": "Choisir la bonne réponse" },
      "exemples": ["choix/T01-qcm-scene.json", "choix/T02-vrai-faux.json"]
    }
  ]
}
```

- `id` d'une série : kebab-case, unique, dans l'adresse `/sequence/<id>`.
- `titre` : en arabe (harakat complètes, conventions de `docs/conventions-arabe.md`) et en français (ni tiret cadratin ni point-virgule). La langue de l'interface choisit.
- `exemples` : chemins dans le catalogue `schema/exemples/` (dossier et fichier), dans l'ordre de passage. Un chemin absent du catalogue, invalide ou d'un type à venir est **sauté** sans erreur. Une série sans exercice jouable ne s'ouvre pas.

Le fichier est contrôlé par `test/sequences/sequence_asset_test.dart` : id uniques, titres conformes, chaque exemple présent et jouable, cité une seule fois, chaque type jouable joué au moins une fois.

## Modifier la séquence

Changer l'ordre des séries ou des exemples, en retirer, en ajouter (un exemple du catalogue) ou renommer une série : éditer le JSON, puis `flutter test test/sequences` dans `apps/mobile`. Le fichier par défaut a été généré le 21 oct. 2026 (une série par moteur, tous les exemples du catalogue, dans l'ordre du registre) : à trier par Lamjed avant le tour 1 (séries plus courtes, 1re année d'abord).
