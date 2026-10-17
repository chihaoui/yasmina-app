# LetterTile

Tuile déplaçable (lettre, syllabe, mot) et sa zone de construction, pour les moteurs Glisser-déposer et Construire (T06, T09, T11 à T16).

- Tuile : `tile`, bordure `line`, coins `radius-md`, au moins `target-min`. Tuile tenue ou en attente (toucher-toucher) : `blue-soft` et bordure `blue`.
- Zone : bordure pointillée `line`, coins `radius-lg`. Mot juste : bordure pleine `olive`.
- Les lettres posées se lient comme à l'écrit (police `content`). En arabe, la zone se remplit de droite à gauche.
- Aimant, retour animé hors cible et vibration : voir les règles du glisser-déposer (décision 3).
