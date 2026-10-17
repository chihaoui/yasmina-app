# schema

Schéma JSON `edu-content/1.0` des exercices et son validateur.

- Un fichier JSON par étape, avec les blocs `generation`, `etape` et `exercices`.
- Le validateur tourne dans `flutter test` : un JSON invalide fait échouer les tests.
- Le contenu embarqué vit dans `apps/mobile/assets/content/` et doit passer ce schéma.

À venir en phase A0 : schéma, validateur et test qui échoue sur un JSON invalide.
