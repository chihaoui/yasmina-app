# Polices embarquées

Toutes sous licence SIL Open Font License 1.1 (fichiers `OFL-*.txt`), embarquées dans le moteur : l'app mobile et l'aperçu web les reçoivent sans aucun téléchargement.

| Famille Flutter | Usage | Source |
|---|---|---|
| `NotoNaskhArabic` | Contenu des exercices en arabe (`LangueExercice`) | google/fonts, `ofl/notonaskharabic/NotoNaskhArabic[wght].ttf` |
| `BalooBhaijaan2` | Titres, boutons et textes de l'interface en arabe | google/fonts, `ofl/baloobhaijaan2/BalooBhaijaan2[wght].ttf` |
| `Andika` | Exercices en français et en anglais, interface en français | google/fonts, `ofl/andika/Andika-Regular.ttf` et `Andika-Bold.ttf` |

Téléchargées le 17 octobre 2026 depuis la branche `main` de https://github.com/google/fonts.

Noto Naskh Arabic et Baloo Bhaijaan 2 n'y existent qu'en police variable. Les fichiers Regular (400) et Bold (700) sont des instances statiques produites avec fontTools 4.55.3 (`fontTools.varLib.instancer.instantiateVariableFont`, `updateFontNames=True`), pour que `FontWeight` fonctionne de la même façon sur toutes les plateformes. Andika est utilisée telle quelle (nom réservé « Andika », fichiers non modifiés).

Les licences sont affichées dans l'écran des licences de Flutter via `enregistrerLicencesPolices()`.
