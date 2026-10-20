# Moteur Scène image : points tranchés et questions ouvertes

Préparation du moteur Scène image (branche `moteur/scene-image`, soir du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Scène sans image | `scene.elements` : emoji et formes simples (cercle, carré, rectangle, triangle) en coordonnées normalisées, couleurs parmi six jetons | Aucune image sous droits dans le prototype, scène identique sur mobile et web, dessinée par le code | Fichiers image dès le prototype |
| 2 | Zones visibles | Contour fin `line` au repos, pour que l'enfant sache où toucher, fond translucide quand sélectionnée | Hot spot invisible = devinette pour un enfant de 1re | Zones invisibles |
| 3 | T08 : libellé des zones | Neutre pour le lecteur d'écran (« مِنْطَقَةٌ 1 »), le `libelle` du JSON ne sert qu'à T47 | Le libellé donnerait la réponse | Libellé réel |
| 4 | T47 : affectation « zones » | Réutilise `ControleurAffectation` du moteur Glisser-déposer avec une forme `zones` (`placements`, `zone`, `etiquette`), une étiquette par zone, étiquettes en trop possibles | Même geste, même correction, même retour des seules étiquettes fausses | Contrôleur à part |
| 5 | Zones trop petites | Une zone plus petite que `target-min` est élargie autour de son centre par le moteur | CLAUDE.md : cibles d'au moins 48 dp | Refuser au validateur |
| 6 | Rapport de la scène | 4 : 3 fixe, largeur de l'écran | Simple, tient dans le cadre de téléphone avec la réserve en dessous | Rapport dans le JSON |

### Nuit du 20 au 21 oct. (corrections du test de Lamjed du 20 oct. au soir)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 7 | T47 : cases à côté de la scène | Colonnes d'un quart de la largeur à gauche et à droite, scène 4 : 3 au milieu, cases de la hauteur d'une tuile de choix placées à la hauteur du centre de leur zone puis écartées d'au moins `space-2` si elles se touchent (la figure grandit si une colonne déborde), trait fin `ink` et point sur la zone. Le schéma ne change pas : le point est le centre du rectangle de la zone, le côté suit la moitié où est ce centre | Demandé par Lamjed (schéma de manuel), aucun changement de contenu | Côté choisi dans le JSON, scène plus large avec cases superposées aux bords |
| 8 | T47 : validateur | `etiquettes_superposees` refuse deux zones du même côté à moins de 0,1 de hauteur l'une de l'autre. Les autres cas proches sont écartés par le moteur | Sur un téléphone une case fait près de la moitié de la hauteur de la scène : refuser tout chevauchement avant écartement interdirait tout contenu réel | Seuil plus large, ou avertissement seulement |

## Questions ouvertes

1. **Images réelles** : quand arrivent-elles (phase B, packs) ? Le schéma garde `scene` sans champ `image` pour l'instant, en ajouter un plus tard n'invalide rien.
2. **Formes** : six couleurs de jetons suffisent-elles pour un schéma (plante, corps, maison) ? Un vrai schéma demandera des images.
3. **T08 avec consigne audio seule** (T53 Écoute et place) : A2-05.
4. **Harakat des exemples arabes** : brouillon, relecture humaine.
