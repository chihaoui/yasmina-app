# Moteur Récit : points tranchés et questions ouvertes

Préparation du moteur Récit (branche `moteur/recit`, nuit du 20 au 21 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Sans note | Mode sans note du lecteur : Continuer dès la fin de l'histoire, résultat `termine`, les premiers choix et le nombre d'erreurs dans `reponseDonnee` | Catalogue : « free », l'histoire enseigne, elle ne juge pas | Mode automatique noté sur les premiers choix |
| 2 | Mauvais choix | Le choix reste affiché barré en `coral`, son `pourquoi` dessous, une tuile « Compris » ramène aux choix de la même étape | L'enfant lit pourquoi avant de choisir à nouveau | Nouveau choix direct, sans « Compris » |
| 3 | Un seul bon choix par étape | Le validateur l'impose (`choix_juste_unique`) et exige un `pourquoi` pour chaque mauvais choix | Une histoire linéaire, chaque erreur expliquée | Plusieurs bons choix, embranchements |
| 4 | Lecture du texte | La consigne est lue à l'ouverture, le texte de l'étape au bouton de réécoute (et à chaque étape si l'enfant appuie) | Ne pas enchaîner deux lectures à l'ouverture | Lire chaque étape automatiquement |
| 5 | Scène | Un emoji (ou une suite d'emoji) en `letter-hero` | Aucune image dans le prototype | Scène dessinée du moteur Scène image |

## Questions ouvertes

1. **Lecture automatique** du texte de chaque étape (enfants de 2e qui lisent peu) : l'activer par défaut ?
2. **Embranchements** (une histoire qui change selon le choix) : hors MVP, à prévoir dans le schéma plus tard (`suivante` par choix) ?
3. **Génération par LLM** (catalogue : « LLM + validation ») : le validateur impose déjà la structure, le `pourquoi` et l'unicité du bon choix.
4. **Harakat** de la fixture arabe et des libellés الْمَرْحَلَةُ, فَهِمْتُ, النِّهَايَةُ : brouillon, relecture humaine.
