# Moteur Simulateur : points tranchés et questions ouvertes

Préparation du moteur Simulateur (branche `moteur/simulateur`, nuit du 20 au 21 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Généricité | Deux issues possibles (`a`, `b`) par expérience, des objets qui tombent dans l'une ou l'autre, un décor parmi trois (`eau`, `circuit`, `aucun`) | Couvre flotte ou coule, conducteur ou isolant, aimanté ou non, soluble ou non, avec le même code | Issues multiples, décors à dessiner par expérience |
| 2 | T34 instance de T57 | Même gabarit, même schéma, le validateur impose `decor: eau` à T34 | Demande de Lamjed, aucun code en double | Deux gabarits |
| 3 | Mode automatique | L'observation termine l'exercice : juste si toutes les prédictions sont bonnes, sinon explication, sans second essai | On n'observe une expérience qu'une fois, l'explication vient du feedback | Vérifier après observation (la réponse serait connue) |
| 4 | Décor `eau` | Une cuve dessinée (eau `blue-soft`), les objets `a` à la surface, `b` au fond, sans animation | Simple et lisible, l'animation de chute viendra plus tard | Chute animée |
| 5 | Vérité dans `reponse` | `reponse.resultats` porte les issues réelles, `donnees.objets` ne les répète pas | Une seule source pour la correction et le back-office | Issue dans chaque objet |

## Questions ouvertes

1. **Animation** de l'observation (objets qui tombent ou flottent, lampe qui s'allume) : plus tard, avec Rive ?
2. **T57 sur l'iPhone** : la voix arabe pour « يَطْفُو » et « يُضِيءُ », les emoji des matériaux (🥉 pour le cuivre, 🔩 pour le fer, 🧴 pour le plastique) sont des approximations : à remplacer par des images en phase B.
3. **Noté ou non** : le catalogue classe ces types en éveil avec score. Garder la note sur les prédictions, ou passer en sans note (exploration) ?
4. **Harakat** des exemples (يَطْفُوَانِ, يَغْرَقَانِ, نَاقِلَانِ, عَازِلَانِ, بْلَاسْتِيكٌ) : brouillon, relecture humaine.
