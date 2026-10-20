> **Type retiré du MVP le 20 oct. 2026 au soir (décision de Lamjed) : l'écriture sur écran n'est pas fiable.** Le moteur Tracé a été codé puis retiré du registre, de l'atelier, du schéma et des exemples (branche `corrections/test-20-oct`). Son code reste dans l'historique Git (commit `82b4c18`). Cette fiche est gardée pour mémoire.

# Moteur Tracé : points tranchés et questions ouvertes

Préparation du moteur Tracé (branche `moteur/trace`, après-midi du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la noter ici et continuer. Chaque point dit ce qui a été choisi, pourquoi, et ce qu'il faudrait changer si Lamjed tranche autrement.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Réponse d'un type non noté | `reponse.formes` liste les formes à tracer pour que Continuer s'active (l'exemple demande la forme isolée seule), la réponse émise est l'ensemble des formes tracées | Le schéma exige une `reponse` non nulle, et l'auteur du contenu choisit combien de formes l'enfant doit tracer | Toutes les formes obligatoires, ou `reponse: {}` et Continuer toujours actif |
| 2 | Tolérance | Une forme est tracée dès que l'encre cumule un quart de la largeur de la zone, sans comparaison avec le modèle | Non noté, enfants de 1re : l'effort compte, pas la précision | Couverture du modèle (comme le prototype HTML), ou aucune condition |
| 3 | Guidage | Les traits de guidage sont des suites de points normalisés (0 à 1) écrits à la main dans le JSON, dans le sens d'écriture : points `muted`, point de départ et flèche `blue`. Sans `traits`, la lettre grise seule | Le moteur n'a pas besoin de connaître la géométrie des polices, et les traits se corrigent dans le contenu sans toucher au code | Traits générés depuis les contours de la police, ou fichiers SVG par lettre |
| 4 | Tracés des exemples | Les traits de ب, ل et م (4 formes chacune) sont approximatifs, faits main d'après la forme naskh, le point en dernier trait | Première version jouable, à affiner avec un enseignant | Relever les traits sur les fiches d'écriture de 1re |
| 5 | Police du modèle | La lettre modèle est en naskh (police du contenu, style de l'école), à la taille de la zone, pas en famille kid (`letter-hero`) | L'enfant trace la forme qu'il apprend à écrire | Famille kid comme sur l'écran d'intro |
| 6 | Épaisseur de l'encre et taille de la lettre | Sans jeton : encre de 18 px (`design-ok`), lettre à 70 % de la hauteur de la zone | Pas de famille « tracé » dans tokens.json | Ajouter des jetons `ink-width` et `trace-letter` |
| 7 | Effacer | Un bouton secondaire (`alt`, icône balai et libellé اِمْسَحْ ou اِمْسَحِي) vide la forme affichée seulement | Recommencer une forme sans perdre les autres | Effacer tout, ou annuler le dernier trait |
| 8 | Formes et tracés | Chaque forme garde son tracé quand l'enfant passe à une autre, Rejouer (aperçu) efface tout et revient à la première forme | L'enfant peut revenir sur une forme | Un seul tracé partagé |
| 9 | Geste | `GestureDetector` (pan) sur la zone, un seul doigt : le geste est capté par la zone et ne fait pas défiler la page du lecteur | Le plus simple en Flutter, même choix que les tuiles glissables | `Listener` brut (laisserait défiler la page en même temps) |
| 10 | Consigne | « اِتْبَعِ النُّقَطَ وَارْسُمْ حَرْفَ الْبَاءِ. » (suis les points et trace la lettre) plutôt qu'une consigne qui commence par اُرْسُمْ | La convention A (alif de liaison avec kasra en début de phrase) et son test ne prévoient pas la damma de اُرْسُمْ | Compléter la convention A pour les verbes en « u » (اُرْسُمْ, اُكْتُبْ) |
| 11 | Libellé Effacer | Ajouté à `LibellesLecteur` (ar genré اِمْسَحْ et اِمْسَحِي, fr Effacer, en Erase), contrôlé par le test des conventions | Un seul endroit pour les libellés du lecteur et des moteurs | Libellé propre au moteur |

## Questions ouvertes

1. **Combien de formes par exercice en 1re ?** Les exemples proposent 4 formes et n'en exigent qu'une. Faut-il un exercice par forme, ou 2 formes (isolée et début) pour les premières lettres ?
2. **Traits de guidage** : à relire par un enseignant (ordre, sens, place du point). Les harakat ne sont pas tracées : faut-il un exercice qui ajoute la haraka après la lettre (بَ) ?
3. **Retour sur le geste** : plus tard, une mesure de couverture ou de sens des traits (sans note, juste un encouragement ciblé) ? Le prototype HTML jugeait la couverture.
4. **Jetons** : épaisseur de l'encre et taille de la lettre sans jeton (point 6). À ajouter à tokens.json ?
5. **Accessibilité** : le tracé au doigt n'a pas d'équivalent au clavier ni au lecteur d'écran. Continuer reste accessible une fois un tracé minimal fait : suffisant pour le MVP ?
6. **Son au tracé** : un léger son ou une vibration en fin de trait ? Rien pour l'instant.
7. **Police** : naskh pour le modèle (point 5), à confirmer avec le style d'écriture enseigné en 1re (naskh ou ruq'a simplifié ?).
8. **Nom des lettres** : بَاءٌ, لَامٌ, مِيمٌ avec tanwin : à relire (ou بَاء sans i'rab ?).
