# Moteur Manipulables : points tranchés et questions ouvertes

Préparation du moteur Manipulables, base (branche `moteur/manipulables-base`, après-midi du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la noter ici et continuer. Chaque point dit ce qui a été choisi, pourquoi, et ce qu'il faudrait changer si Lamjed tranche autrement.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Sens de la droite numérique | Champ `sens` dans `donnees` (`gauche-droite` ou `droite-gauche`), par défaut `gauche-droite` quelle que soit la langue, chiffres toujours de gauche à droite | La question est en attente sur les manuels : le contenu choisit, le défaut se change en une ligne du schéma et du moteur | Défaut selon la langue (droite-gauche en arabe), ou aucun champ |
| 2 | Geste de T25 | Le repère se glisse le long de la droite et s'aimante à la graduation la plus proche au lâcher, toucher une graduation l'y pose aussi | Vrai glisser d'abord (CLAUDE.md §5), le toucher comme secours | Toucher seulement, ou flèches gauche et droite |
| 3 | T27 : canonique par défaut | `canonique: true` par défaut : exactement les dizaines et unités du nombre (34 = 3 barres et 4 cubes), le plateau refuse une 10e unité. `canonique: false` accepte toute somme (2 barres et 14 cubes) | En 1re et 2e, le but est de lire les dizaines et les unités | Toujours libre |
| 4 | T27 et T51 : réserve inépuisable | Un bloc ou un jeton de réserve se glisse autant de fois que nécessaire (il reste à sa place), toucher un bloc de la réserve l'ajoute aussi, toucher un élément posé le retire | Un seul élément par sorte dans la réserve, pas de tuiles à compter dans la réserve | Une réserve de 9 cubes et 9 barres comptés |
| 5 | T51 : cases libres | Les jetons se posent dans n'importe quelle case vide, la réponse est leur nombre | Le cadre de 10 sert à voir le nombre, pas une position | Remplissage imposé de gauche à droite |
| 6 | 1er essai faux | Tout revient à l'état de départ (repère au début, plateau et cadre vides), contrairement au moteur Glisser-déposer qui ne retire que les éléments faux | Une valeur unique ou un compte n'a pas de « partie juste » à garder | Garder les blocs et laisser corriger |
| 7 | Réponse dans le JSON | `reponse` reste explicite (`valeur`, `dizaines` et `unites`, `jetons`) et le validateur contrôle qu'elle correspond à `cible` | Même forme que les autres types pour le back-office et le pipeline | Déduire la réponse de `cible` sans champ |
| 8 | Langue | Aucune règle `type_langue` : la compétence `ma-` impose l'arabe, et T25 reste jouable en français pour un futur usage | Réversible, et les tests gardent un cas latin pour le sens | Arabe seulement |

## Questions ouvertes

1. **Sens de la droite numérique en arabe** : question en attente sur les manuels tunisiens. Le JSON porte `sens`, défaut `gauche-droite`. Quel défaut retenir, et faut-il un défaut différent par niveau ?
2. **Couleurs du matériel** : barres `blue-soft`, cubes `amber-soft`, jetons `olive` pris dans les jetons existants. À confirmer avec le designer (A1-19) : les manuels ont peut-être des couleurs de base 10 à reprendre.
3. **T27 avec des centaines** (3e année) : hors schéma de base (cible 10 à 99). À prévoir pour A2-02 ?
4. **T51 « combien manque-t-il pour faire 10 »** : variante à prévoir avec un cadre pré-rempli.
5. **Réponse 0** : T51 n'accepte pas 0 jeton, T27 exige au moins un bloc. Un exercice « représente 0 » a-t-il un sens en 1re ?
6. **Harakat des exemples arabes** : brouillon, relecture humaine avant `valide`. Les mots عَشَرَاتٌ, وَحَدَاتٌ, خَانَةٌ, مُسْتَقِيمُ الْأَعْدَادِ sont à relire.
