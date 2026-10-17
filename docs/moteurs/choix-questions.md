# Moteur Choix : points tranchés et questions ouvertes

Préparation du moteur Choix (branche `proposition/moteur-choix`, 17 oct. 2026). Consigne reçue : en cas de doute, choisir l'option la plus simple, la noter ici et continuer. Chaque point dit ce qui a été choisi, pourquoi, et ce qu'il faudrait changer si Lamjed tranche autrement.

## Points tranchés (à confirmer)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Format des exemples | Un **exercice seul** par fichier (`schema/exemples/choix/`), validé par `validerExercice` | C'est l'unité de l'aperçu du back-office et du pipeline. Une étape complète par exemple aurait mélangé 5 matières | Une étape par matière, plus lourde, validable par `validerEtape` |
| 2 | T05 et T01 | T05 reste un **type distinct** (plusieurs bonnes réponses) | Compatibilité avec le schéma et les tests existants. Le catalogue v3 propose de fusionner T05 dans T01 (option de QCM) | T01 avec un champ `plusieurs: true`, et T05 réservé comme alias |
| 3 | Code d'erreur | `reponse_t01_unique` devient `reponse_unique`, commun à T01, T03, T04, T18, T24 et T55 | Une même règle, un même code. Aucun outil ne lisait encore l'ancien code | Garder `reponse_t01_unique` pour T01 seulement |
| 4 | Nombre de bonnes réponses | Contrôlé par le validateur Dart, pas par le schéma | `reponseChoix` reste une seule définition partagée par 9 types | Une définition de réponse par type dans le schéma (plus de duplication) |
| 5 | T19 : forme des données | `avant` + `lettre` + `apres`, la haraka vient de la réponse. 4 harakat possibles : fatha, damma, kasra, soukoun | Pas d'index de position fragile dans une chaîne avec signes combinants. Le mot complet se reconstruit sans ambiguïté | Ajouter shadda et tanwin (plus tard, surtout 2e et 3e année) |
| 6 | T19 : écoute | `ecoute` facultative, et si elle existe, son texte doit être le mot complet avec la bonne haraka | Évite un audio qui contredit la réponse | Rendre l'écoute obligatoire (la démo lit toujours le mot) |
| 7 | T23 : sens des signes | La réponse se lit « a signe b » en notation mathématique de gauche à droite, affichée isolée du sens de la phrase | Le catalogue demande de valider le sens d'écriture des symboles dans les manuels tunisiens. En attendant, une seule convention, stable | Afficher la comparaison de droite à gauche si les manuels l'écrivent ainsi (seul l'affichage change, pas les données) |
| 8 | T24 : place de l'inconnue | L'élément à trouver vient **toujours après** le dernier élément | Cas du catalogue (« ce qui vient après »), le plus simple à afficher | Un champ `trou` (index) pour une case au milieu de la suite |
| 9 | T24 : contrôle de la réponse | Le validateur vérifie la réponse quand il reconnaît un motif répété au moins deux fois ou une suite arithmétique d'entiers. Sinon, pas de contrôle | Attrape les erreurs fréquentes sans bloquer les suites plus riches | Contrôle plus large (suites géométriques, motifs croissants) |
| 10 | T46 : réponse | Exactement **une** réponse et **une** preuve. Chaque preuve est une phrase recopiée telle quelle du texte (contrôlé) | Comme la démo. Le contrôle évite une preuve reformulée qui ne figure pas dans le texte | Plusieurs preuves acceptées |
| 11 | T55 : mot entendu | Le texte entendu doit être le texte du bon choix (contrôlé). T03 n'a pas cette contrainte | En T55 l'enfant lit les mots, en T03 il voit des images | Aucune |
| 12 | T61 : nombre de phrases | Au moins 2 phrases justes, jamais toutes. Le moteur n'affiche pas de compteur, la consigne donne le nombre (« les trois phrases ») | Simple. Le compteur peut s'ajouter sans changer les données | Afficher « 1 sur 3 » pendant la sélection |
| 13 | T45 : réponse | `reponse.choix` contient les éléments **à barrer** (les faux) | Colle à la consigne « barre les phrases fausses » | Stocker les phrases vraies et laisser le moteur inverser |
| 14 | Harakat d'une lettre seule | L'avertissement `harakat_manquantes` ne vise plus un texte réduit à une lettre, avec ou sans tatweel (formes de T18, lettre de T19) | Une forme de lettre ne porte pas de haraka. Sans cette exception, chaque T18 de 1re année donnait des avertissements | Exception limitée aux champs de T18 et T19 |
| 15 | Mélange des propositions | Tirage une fois à l'ouverture, avec une graine injectée, ordre gardé entre les essais. T02 et T23 en ordre fixe. T18 de l'exemple avec `melanger: false` (ordre isolée, début, milieu, fin) | Reproductible en test et en aperçu, et l'enfant ne perd pas ses repères au 2e essai | Nouveau tirage à chaque essai |
| 16 | 1er essai faux | Les tuiles fausses passent en « faux » un instant, puis la sélection est vidée | L'enfant repart d'une page propre avec l'indice | Garder la sélection et laisser l'enfant la corriger |
| 17 | Score | Réussite au premier essai, comme la démo | Même règle que la démo et l'espace parent | Compter aussi la réussite au 2e essai |

## Questions ouvertes

1. **Médias** : les images et audios des exemples (`images/...`) sont des chemins de placeholder. Où vivront les fichiers du prototype (`apps/mobile/assets/` ou un pack par étape) et quel format d'image (PNG, SVG, WebP) ?
2. **Accessibilité des tuiles en image seule** (T03, T24) : un libellé pour le lecteur d'écran donnerait la réponse (« chat »). Proposition : libellé neutre (« image 1, image 2 ») et le mot entendu reste seulement audio. À valider.
3. **Libellés arabes du moteur** : تَحَقَّقْ, وَاصِلْ, تَلْمِيحٌ, لِنَتَعَلَّمْ, أَحْسَنْتَ et أَحْسَنْتِ (repris de la démo), صَحِيحٌ et خَطَأٌ pour T02. À relire.
4. **Harakat des exemples arabes** (T01, T05, T18, T19, T23, T24) : statut `brouillon`, relecture humaine nécessaire avant `valide`.
5. **Codes de compétence** des exemples (`ev-milieux-de-vie`, `ma-nombres-pairs`...) : inventés en attendant le référentiel. À remplacer.
6. **Taille du texte du Feedback** : le design system indique la police kid en 19 px gras pour le texte du bandeau, sans jeton. Ajouter un style `feedback` à `tokens.json` ?
7. **Variante `listen` du IconButton** (grand bouton « اِسْمَعْ ») : ses dimensions (marges 10 × 22, icône 26) ne sont pas dans `tokens.json`. Même question.
8. **Niveau des exemples** : T02 et T03 en anglais 4e année, T04 et T55 en français 3e année. Les années de début de l'anglais et du français dans le programme tunisien sont à confirmer pour le parcours réel.
9. **T23 avec des expressions** (« 3 + 4 ? 8 ») : hors du schéma actuel (nombres seulement). À prévoir pour la 2e année ?
10. **Tanwin et shadda en T19** : utiles dès la 2e année ? Ils demandent d'élargir l'énumération `haraka`.
