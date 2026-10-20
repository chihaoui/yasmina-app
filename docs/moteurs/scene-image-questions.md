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

## Questions ouvertes

1. **Images réelles** : quand arrivent-elles (phase B, packs) ? Le schéma garde `scene` sans champ `image` pour l'instant, en ajouter un plus tard n'invalide rien.
2. **Formes** : six couleurs de jetons suffisent-elles pour un schéma (plante, corps, maison) ? Un vrai schéma demandera des images.
3. **T08 avec consigne audio seule** (T53 Écoute et place) : A2-05.
4. **Harakat des exemples arabes** : brouillon, relecture humaine.
