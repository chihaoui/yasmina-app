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
| 9 | Libellés de T27 et T51 | Propres au gabarit (الْعَشَرَاتُ, الْوَحَدَاتُ, اللَّوْحَةُ, قِطْعَةٌ, خَانَةٌ), pas dans `LibellesLecteur`, compte affiché en chiffres « الْعَشَرَاتُ: 3 وَالْوَحَدَاتُ: 4 » | Évite l'accord du pluriel arabe selon le nombre (عَشَرَةٌ, عَشَرَتَانِ, عَشَرَاتٍ) | Compte en toutes lettres accordé |
| 10 | T51 : réserve au-dessus du cadre | Le jeton de réserve est au-dessus des cases, au début de ligne, et les cases ont une marge réduite : cinq cases ne tiennent pas à côté de la réserve dans la largeur d'un téléphone | Contrainte de largeur (360 px du cadre de l'aperçu) | Cases plus petites que `target-min` |

### Nuit du 20 au 21 oct. (corrections du test de Lamjed du 20 oct. au soir)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 11 | Retrait par glisser (T27, T51) | Un bloc ou un jeton posé se glisse : lâché hors du plateau ou du cadre, il est retiré. Un bloc lâché sur le plateau y reste, un jeton lâché sur sa case y reste, sur une autre case vide il s'y déplace | Demandé par Lamjed pour tous les types à glisser | Toucher seulement |

### Nuit du 20 au 21 oct., types avancés (A2-02)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 12 | T26 : montant | En millimes dans le JSON (`cible`, `montant`), affiché en clair « 2 د وَ700 م » (dinars puis millimes, chiffres de gauche à droite), 0 affiché « 0 م ». Juste si la somme vaut la cible, quelles que soient les pièces | Un entier sans décimale, l'affichage reste lisible pour un enfant | Décimal « 2,700 د », ou pièces imposées |
| 13 | T26 : pièces | Dessinées par le code (rondes, valeur dessus), millimes en `amber`, dinars en `blue` et plus grands, réserve inépuisable de la plus grande à la plus petite, 20 pièces au plus | Aucune image sous droits, même matériel que les blocs | Billets de 5 et 10 dinars, images réelles plus tard |
| 14 | T29 : geste | Toucher pour colorier, re-toucher pour décolorier, cibles de `target-min` au centre de chaque part, forme dans le sens des aiguilles d'une montre (disque) ou de gauche à droite (rectangle), jamais retournée | Le catalogue colorie au toucher, un glisser n'apporterait rien | Glisser une couleur sur la part |
| 15 | T29 : correction | Le nombre de parts coloriées, quelles que soient les parts | 3/4 est 3/4 quelles que soient les parts choisies | Parts contiguës exigées |
| 16 | T52 : deux étapes dans une zone | Les nombres glissés dans les segments connus (une étiquette par segment, comparée par son texte), puis l'inconnue écrite au pavé, un seul Vérifier. Le catalogue prévoyait « choisir le schéma puis calculer » : le schéma est donné, l'enfant le remplit | Réutilise tuile, zone, retrait et pavé, un seul déroulé pour le lecteur | Choix du schéma parmi plusieurs (type à étapes, comme T35) |
| 17 | T52 : inconnue | `inconnue` = `{ "barre": "b2" }` (accolade sous la barre, total) ou `{ "segment": "s3" }` (case « ? » dans la barre). La réponse reste explicite (`valeur`) et contrôlée | Couvre partie-tout et comparaison avec un seul schéma | Plusieurs inconnues |
| 18 | T52 : largeur des segments | Proportionnelle à la valeur sur la plus longue barre, au moins une cible, la barre se réduit (`FittedBox`) si elle déborde | Lisible sur un téléphone | Largeur fixe |

## Questions ouvertes

1. **Sens de la droite numérique en arabe** : question en attente sur les manuels tunisiens. Le JSON porte `sens`, défaut `gauche-droite`. Quel défaut retenir, et faut-il un défaut différent par niveau ?
2. **Couleurs du matériel** : barres `blue-soft`, cubes `amber-soft`, jetons `olive` pris dans les jetons existants. À confirmer avec le designer (A1-19) : les manuels ont peut-être des couleurs de base 10 à reprendre.
3. **T27 avec des centaines** (3e année) : hors schéma de base (cible 10 à 99). Non traité par A2-02 : à prévoir ?
7. **T26** : billets (5, 10, 20 dinars) et pièces de 2 et 5 dinars dans la réserve, écriture du montant (« 2 د وَ700 م » ou « 2,700 د »), convention des manuels à confirmer.
8. **T29** : parts contiguës ou non, fractions supérieures à 1 (plusieurs formes), forme du catalogue (disque) suffisante ?
9. **T52** : le choix du schéma parmi plusieurs (catalogue, étape 1) est-il attendu dans le MVP ? Les harakat de سَامِي et رِيمَ et des libellés الْمَجْهُولُ, شَرِيطُ sont à relire.
4. **T51 « combien manque-t-il pour faire 10 »** : variante à prévoir avec un cadre pré-rempli.
5. **Réponse 0** : T51 n'accepte pas 0 jeton, T27 exige au moins un bloc. Un exercice « représente 0 » a-t-il un sens en 1re ?
6. **Harakat des exemples arabes** : brouillon, relecture humaine avant `valide`. Les mots عَشَرَاتٌ, وَحَدَاتٌ, خَانَةٌ, مُسْتَقِيمُ الْأَعْدَادِ sont à relire.
