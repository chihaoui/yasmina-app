# Moteur Mesure et temps : points tranchés et questions ouvertes

Préparation du moteur Mesure et temps (branche `moteur/mesure-temps`, nuit du 20 au 21 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | T28 : prise de l'aiguille | Le doigt prend l'aiguille la plus proche de l'angle touché, n'importe où sur le cadran | Demande de Lamjed (aiguilles déplacées au doigt), une cible au bout d'une aiguille serait trop petite | Toucher le bout de l'aiguille seulement |
| 2 | T28 : aimant et couplage | Minutes aimantées au `pas` (5 par défaut), l'aiguille des heures suit les minutes (passer 12 change d'heure), l'aiguille des heures aimantée à l'heure en gardant les minutes | Comme une vraie horloge, et une réponse toujours lisible | Aiguilles indépendantes |
| 3 | T28 : réponse | `reponse` porte l'heure cible (`heure` 1 à 12, `minutes`), `depart` dans `donnees` (12 h 00 par défaut), cadran de 12 heures seulement | 2e année, pas d'heure de l'après-midi en 24 h | Cadran 24 h, cible dans `donnees` |
| 4 | T28 : retour au départ | Après le 1er essai faux, les aiguilles reviennent au départ | Une heure n'a pas de partie juste à garder | Garder l'aiguille juste |
| 5 | T30 : lecture et pavé | L'enfant lit et écrit la longueur (pas de curseur à glisser), `depart` permet l'objet qui ne part pas de zéro | Catalogue : « mesurer un crayon », saisie au pavé déjà prête | Glisser l'objet contre le zéro |
| 6 | T30 : unité | `unite` libre dans le JSON (« صم », « cm »), affichée après le nombre | Convention d'écriture de l'unité en arabe non tranchée (voir T22) | Unité fixe |
| 7 | Clés de parité | Les deux types partagent la clé `saisie_reponse` quand la réponse est révélée (comme la saisie numérique) | Un seul test de parité web pour tous les types à valeur | Clé par moteur |

## Questions ouvertes

1. **T28** : faut-il aussi l'heure numérique affichée (« 6:30 ») pendant le réglage, ou seulement en explication ? Les minutes pas à pas (`pas: 1`) pour les grands ?
2. **T28 sur l'iPhone** : la rotation au doigt dans la page du lecteur qui défile (le `GestureDetector` pan doit garder le doigt, comme la grille des mots mêlés).
3. **T30** : règle qui dépasse 10 cm sur un téléphone (graduations serrées), demi-centimètres à lire (valeur décimale, hors pavé entier) ?
4. **Harakat** des exemples (السَّادِسَةِ وَالنِّصْفِ, الْعَقْرَبُ, الصِّفْرِ, بِالسَّنْتِيمِتْرِ) et de l'abréviation « صم » : brouillon, relecture humaine.
