# Moteur Révision et jeux : points tranchés et questions ouvertes

Préparation du moteur Révision et jeux (branche `moteur/revision-jeux`, soir du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | T36 sans note | Mode sans note du lecteur, Continuer dès que toutes les cartes demandées sont vues, auto-évaluation (« je savais », « à revoir ») émise dans `reponseDonnee` sans effet sur le résultat | Catalogue : « révision espacée, hors score », la révision espacée viendra plus tard avec la progression | Compter les « je savais » |
| 2 | T37 noté par les essais | Mode automatique, juste si les essais ne dépassent pas `essais_max` (deux fois le nombre de paires par défaut), sinon explication sans jugement | Le catalogue dit « révision optionnelle, hors score », la consigne du jour dit « noté » : un seuil large garde le jeu bienveillant | Toujours juste, ou seuil strict |
| 3 | T38 : sélection par les deux bouts | Toucher la première lettre puis la dernière : plus simple au doigt qu'un glisser sur une grille, et sans ambiguïté | Un glisser sur une grille de 48 dp est imprécis pour un enfant | Glisser le long du mot |
| 4 | T38 en arabe : lettres isolées, sens configurable | Chaque case porte une lettre isolée nue, les mots se lisent de droite à gauche sur une ligne (`sens`, défaut `droite-gauche` en arabe) et de haut en bas en colonne, jamais en diagonale | Une grille ne lie pas les lettres (même règle que T15 et T56 pour les tuiles), le sens de lecture suit l'écriture | Lettres liées par tatweel, diagonales |
| 5 | T38 : position des mots dans le JSON | `ligne`, `colonne` de la première lettre et `direction`, contrôlées par le validateur contre la grille | Le contenu reste lisible et vérifiable, le moteur ne cherche pas les mots lui-même | Le moteur cherche les mots dans la grille |
| 6 | Mélange | Graine de la configuration pour le memory et les flashcards (`melanger`), ordre fixe des cases de la grille | Reproductible en test et en aperçu | Mélange à chaque partie |

## Questions ouvertes

1. **Sens de lecture des mots mêlés en arabe** : de droite à gauche sur les lignes (défaut), de haut en bas sur les colonnes. À confirmer avec les cahiers de jeux tunisiens (`sens` dans le JSON).
2. **Harakat dans la liste des mots** (T38) : les cases sont nues, la liste sous la grille pourrait afficher le mot vocalisé (`affichage` par mot, non prévu dans le MVP).
3. **Abandon** : faut-il un bouton pour finir un memory ou des mots mêlés sans tout trouver ? Rien dans le MVP, Continuer n'arrive qu'à la fin.
4. **T37 : révision espacée** et score des flashcards : avec la progression locale (A3-03).
5. **Harakat des exemples arabes** : brouillon, relecture humaine.
