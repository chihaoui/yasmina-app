# Moteur Révision et jeux : points tranchés et questions ouvertes

Préparation du moteur Révision et jeux (branche `moteur/revision-jeux`, soir du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | T36 sans note | Mode sans note du lecteur, Continuer dès que toutes les cartes demandées sont vues, auto-évaluation (« je savais », « à revoir ») émise dans `reponseDonnee` sans effet sur le résultat | Catalogue : « révision espacée, hors score », la révision espacée viendra plus tard avec la progression | Compter les « je savais » |
| 2 | T37 noté par les essais | Mode automatique, juste si les essais ne dépassent pas `essais_max` (deux fois le nombre de paires par défaut), sinon explication sans jugement | Le catalogue dit « révision optionnelle, hors score », la consigne du jour dit « noté » : un seuil large garde le jeu bienveillant | Toujours juste, ou seuil strict |
| 3 | T38 : sélection par les deux bouts | ~~Toucher la première lettre puis la dernière~~ Remplacé le 20 oct. au soir par la demande de Lamjed : lettres touchées une à une ou doigt glissé le long du mot, erreur signalée à la première lettre qui ne prolonge plus un mot restant (point 7) | | |
| 4 | T38 en arabe : lettres isolées, sens configurable | Chaque case porte une lettre isolée nue, les mots se lisent de droite à gauche sur une ligne (`sens`, défaut `droite-gauche` en arabe) et de haut en bas en colonne, jamais en diagonale | Une grille ne lie pas les lettres (même règle que T15 et T56 pour les tuiles), le sens de lecture suit l'écriture | Lettres liées par tatweel, diagonales |
| 5 | T38 : position des mots dans le JSON | `ligne`, `colonne` de la première lettre et `direction`, contrôlées par le validateur contre la grille | Le contenu reste lisible et vérifiable, le moteur ne cherche pas les mots lui-même | Le moteur cherche les mots dans la grille |
| 6 | Mélange | Graine de la configuration pour le memory et les flashcards (`melanger`), ordre fixe des cases de la grille | Reproductible en test et en aperçu | Mélange à chaque partie |

### Nuit du 20 au 21 oct. (corrections du test de Lamjed du 20 oct. au soir)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 7 | T38 : règle d'acceptation | Une lettre est acceptée si la sélection reste un préfixe des cases d'un mot restant, dans l'ordre ou à l'envers. Une lettre déjà sélectionnée est ignorée, une lettre d'un mot déjà trouvé peut servir à un autre mot (croisements). Pendant l'effet d'erreur (0,7 s, `dureeFaux`), les touchers sont ignorés. Après l'erreur, tout est vidé, rien n'est compté | Demande de Lamjed, le plus simple à expliquer à un enfant : « tu t'es trompé de lettre, recommence le mot » | Garder le début juste de la sélection |
| 8 | T38 : secousse | `Secousse` (composant du moteur) : 3 allers-retours de 6 px en 400 ms, constantes dans `mouvements_yasmina.dart`, aucun mouvement si l'appareil demande moins d'animations | Pas de famille motion dans tokens.json (même choix que les mouvements de Yasmina) | Jetons dans tokens.json |
| 9 | T38 : glisser dans la page qui défile | `GestureDetector` (pan) sur la grille : il l'emporte sur le défilement vertical du lecteur dès que le doigt bouge, comme la zone de tracé de T20 l'avait fait. Le doigt levé, la sélection reste et la prochaine glissade repart | Même approche que celle déjà prévue pour T20 | `Listener` brut |
| 10 | T37 : grille par niveau | Nombre de paires imposé par le validateur (`memory_cartes_niveau`), lu dans le niveau de l'id, grille de 3 colonnes toujours pleine, cartes de hauteur fixe `choice-min-height` (60 dp) et contenu ajusté par `FittedBox`. Le schéma passe `paires` de 2 à 6 à 3 à 12. L'exemple de 2e passe à 6 paires | Demande de Lamjed. 3 × 8 tient sur 390 × 844 (8 × 60 + 7 × 8 = 536 dp) | Hauteur selon la place restante |

## Questions ouvertes

1. **Sens de lecture des mots mêlés en arabe** : de droite à gauche sur les lignes (défaut), de haut en bas sur les colonnes. À confirmer avec les cahiers de jeux tunisiens (`sens` dans le JSON).
2. **Harakat dans la liste des mots** (T38) : les cases sont nues, la liste sous la grille pourrait afficher le mot vocalisé (`affichage` par mot, non prévu dans le MVP).
3. **Abandon** : faut-il un bouton pour finir un memory ou des mots mêlés sans tout trouver ? Rien dans le MVP, Continuer n'arrive qu'à la fin.
4. **T37 : révision espacée** et score des flashcards : avec la progression locale (A3-03).
5. **Harakat des exemples arabes** : brouillon, relecture humaine.
