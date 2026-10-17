# ChoiceTile

Une réponse possible dans un QCM, un vrai ou faux, un choix d'image ou de forme (moteur Choix, T01 à T05, T18, T19, T23, T24…).

- **États** : repos (`tile`, bordure `line`), sélectionné (`blue-soft`, bordure `blue`), juste (`olive-soft`, bordure `olive`), faux (`coral-soft`, bordure `coral`).
- L'état juste ou faux ne repose jamais sur la couleur seule : Yasmina change d'humeur et le feedback l'écrit. En aperçu (back-office), un mot d'état est ajouté.
- **Le consommateur fournit** : le texte (style `content-option`, police `content`) et une image facultative.
- Hauteur au moins 60 px, grille de 2 ou 3 colonnes, 4 à 6 choix maximum en 1re et 2e année.
