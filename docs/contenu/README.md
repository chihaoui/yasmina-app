# docs/contenu : sources du contenu embarqué

Brouillons de contenu écrits à la main dans un format neutre (`brouillon-contenu`), avant conversion en `edu-content/1.0`.

| Fichier | Contenu | Conversion |
|---|---|---|
| `contenu-ar-1-t1.json` | Parcours d'arabe 1re année, trimestre 1 : 7 étapes (ب ل م ر, défi de l'unité 1, د, ف), 100 exercices, 4 séquences par lettre (أَكْتَشِفُ, أُلَاحِظُ, أُرَكِّبُ, أَكْتُبُ) | `dart run tool/convertir_contenu.dart` écrit un fichier par étape dans `apps/mobile/assets/content/ar/1/` |

## Règles

- La source est la référence des textes arabes : la conversion ne change aucune harakat (contrôlé par `test/convertir_contenu_test.dart` à la racine). Toute correction de texte se fait dans la source, puis la conversion est relancée et les fichiers produits sont commités avec elle.
- T20 Tracé de lettre (retiré du MVP, décision 40) est remplacé à la conversion par un T17 Dictée au clavier réduit d'un mot court de l'étape (table `dictees` du convertisseur), avec un id nouveau (un id n'est jamais réutilisé).
- Les exercices gardent le statut de la source (`valide` pour x01 et x02 de `ar-1-t1-u1-e01`, relus le 17 oct. 2026, `brouillon` pour tout le reste) : la relecture humaine des harakat se fait avec `docs/relecture/harakat.html`.
- Les fichiers produits passent le validateur dans `apps/mobile/test/contenu_embarque_test.dart`.
