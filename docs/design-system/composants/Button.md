# Button

Bouton principal pleine largeur, posé en bas de l'écran d'exercice ou d'étape.

- **Variantes** : `blue` (Vérifier, Commencer), `green` (Continuer, après une réponse juste ou l'explication), `alt` (action secondaire, rejouer).
- **Le consommateur fournit** : le libellé, dans la langue de l'exercice (pas celle de l'interface) quand le bouton appartient au lecteur.
- Fond `blue` ou `olive`, texte `on-accent`, style `button-cta`, coins `radius-xl`, relief `shadow-press` qui disparaît au toucher.
- Hauteur au moins `target-min`. Un seul bouton principal par écran.
- À ne pas faire : un bouton rouge pour « faux », le feedback porte l'erreur, pas le bouton.
