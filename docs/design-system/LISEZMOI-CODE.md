# Design system Yasmina : mode d'emploi pour le code

Source de vérité : l'artefact « Design system Yasmina » (claude.ai), copié ici le 17 oct. 2026.

- `README.md` : règles d'usage (couleurs, typographie, ton, harakat, accessibilité).
- `tokens.json` : toutes les valeurs. Couleurs avec une valeur par thème (`light`, `dark`). Familles de polices `kid`, `content`, `latin`. Styles de texte, espacements, rayons, ombres.
- `composants/*.md` : règles de chaque composant (Button, ChoiceTile, Feedback...).
- `bundle.css` : le rendu HTML de référence des composants (aperçu web, pas à copier en Dart, mais les valeurs y sont toutes en tokens).
- `yasmina/` : la mascotte en 3 humeurs (SVG placeholders).

Ne jamais écrire une couleur, une taille ou un rayon en dur dans un widget : passer par ThemeYasmina, généré depuis tokens.json.
