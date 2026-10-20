# Moteur Grille et graphiques : points tranchés et questions ouvertes

Préparation du moteur Grille et graphiques (branche `moteur/grille-graphiques`, nuit du 20 au 21 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | T31 : question | `question` vaut `plus` ou `moins`, la réponse est la série touchée (barre entière), unique (le validateur refuse deux barres à égalité pour la question) | Catalogue : « quel fruit est le plus choisi ? », le toucher d'une barre est le geste le plus simple | Question libre avec une valeur à écrire |
| 2 | T32 : cellule touchée | Toucher la cellule de niveau n monte la barre à n, retoucher le sommet baisse d'un cran | Un geste, pas de boutons plus et moins | Glisser le sommet de la barre |
| 3 | T32 : retrait des faux | Seules les barres fausses redescendent après le 1er essai | Comme le glisser-déposer, l'enfant ne refait que ce qui est faux | Tout vider |
| 4 | T33 : axe vertical au milieu | `colonnes` pair, axe entre les deux moitiés, cases données à gauche, l'enfant colorie à droite | Catalogue : « les cases grises sont données, colorie les cases de droite » | Axe horizontal ou oblique, côté configurable |
| 5 | T60 : tout chemin accepté | Juste si la fleur arrive au but, quel que soit le chemin. `reponse.chemin` est un chemin possible, contrôlé par le validateur | Il y a souvent plusieurs chemins justes | Chemin unique imposé |
| 6 | T60 : lecture du programme | Un pas toutes les 0,4 s avec le son `depot`, immédiat si l'appareil demande moins d'animations, Vérifier actif seulement après lecture, Revenir pour corriger | L'enfant voit sa fleur avancer et comprend où elle se trompe | Correction sans lecture |
| 7 | Clé de parité | Les quatre types partagent la clé `grille_reponse` quand la réponse est révélée | Un seul test de parité web | Clé par type |
| 8 | Hauteur des cellules (T32) | 36 dp par cellule (en dessous de `target-min`) pour qu'un graphique de 6 tienne, colonnes larges | 6 × 48 = 288 dp plus le tableau et le pavé déborderaient | 48 dp et défilement |

## Questions ouvertes

1. **T31** : faut-il aussi la lecture d'une valeur (« combien d'élèves ont choisi la banane ? ») avec le pavé ?
2. **T32** : les barres se construisent au toucher, faut-il un glisser du sommet ? Les valeurs du tableau en toutes lettres ?
3. **T33** : axe horizontal, symétrie par rapport à une diagonale (plus tard), figure donnée des deux côtés ?
4. **T60** : le catalogue le marquait « plus tard, présence au programme tunisien à vérifier » : à confirmer. Faut-il des boucles (répéter 3 fois) en 4e ?
5. **Harakat** des exemples (الْأَعْمِدَةَ, الْمِحْوَرِ, الْبِئْرِ, التَّنَاظُرِ) : brouillon, relecture humaine.
