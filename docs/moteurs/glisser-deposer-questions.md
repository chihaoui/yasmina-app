# Moteur Glisser-déposer : points tranchés et questions ouvertes

Préparation du moteur Glisser-déposer (branche `proposition/moteur-glisser-deposer`, 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la noter ici et continuer. Chaque point dit ce qui a été choisi, pourquoi, et ce qu'il faudrait changer si Lamjed tranche autrement.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Périmètre du code | Le moteur code les 8 types rangés sous Glisser-déposer dans le registre et dans la liste de la décision 3 : T06, T09, T11, T12, T13, T14, T15, T16. T26 et T27 restent au moteur Manipulables (registre, A1-06 et A2-02), T39 est le gabarit `texte-trous` de T06 (fusion du catalogue v3), T56 et T62 (registre) ne sont pas traités | La liste de la décision 3 et le registre ne concordent pas, le registre est la source de l'atelier et des tests (53 types) : ne rien y changer seul | Déplacer T26 et T27 dans ce moteur (leurs pièces et blocs se glissent aussi), ou ajouter T56 et T62 à la fiche |
| 2 | Cinq interactions | Trous, paires, bacs, ordre, mot : chaque type est une présentation de l'une d'elles, avec un contrôleur d'affectation (trous, paires, bacs) ou d'ordre (ordre, mot) | Un seul geste, deux formes de réponse, peu de code par type | Un contrôleur par type |
| 3 | Toucher-toucher | Tout toucher sans déplacement met l'élément en attente, qu'il dure 200 ms ou moins : le seuil de 200 ms de CLAUDE.md distingue un glisser commencé par accident, pas le toucher bref | Un enfant qui tape vite doit pouvoir poser au toucher. Le glisser réel reste le geste premier | Exiger 200 ms immobiles, un toucher plus bref ne faisant rien |
| 4 | 1er essai faux | Seuls les éléments mal placés reviennent dans la réserve, les bons restent | CLAUDE.md : « un élément déposé peut être réordonné ou retiré ». Refaire 6 dépôts pour une erreur décourage. Les faux sont marqués un instant avant de revenir | Tout vider comme le moteur Choix (`vider`) |
| 5 | Agrandissement de la tuile tenue et bordure pointillée | Aucun nouveau jeton : échelle légère fixée dans `mouvements_yasmina.dart` (comme les mouvements de Yasmina), pointillé en `border-thick` et `line` | Le design system n'a pas de famille motion ni de jeton « pointillé » | Ajouter des jetons `scale-drag` et `dash` à tokens.json |
| 6 | Format des trous de T06 | Marqueurs `{t1}`, `{t2}` dans `texte`, réponse `trous: [{ trou, etiquette }]` (tableau d'objets : le schéma reste sans `patternProperties`) | Lisible par un humain et par le LLM, un seul champ texte, les trous gardent leur place exacte dans la phrase | Un tableau de segments (texte, trou, texte), ou un objet à clés variables |
| 7 | T09 : réponse explicite | `paires: [{ gauche, droite }]` avec des ids distincts à gauche (`g1`) et à droite (`d1`) | Permet des paires non alignées par l'ordre des listes, et des contrôles simples (bijection) | Paires implicites par position |
| 8 | T11 et T12 : chaque catégorie utilisée | Erreur `categorie_vide` si une catégorie ne reçoit aucun élément | Un bac vide est un piège sans valeur en 1re et 2e | Autoriser un bac vide (règle de langue avec un cas absent) |
| 9 | T15 et T16 : lettres en trop | Les éléments non cités par `ordre` sont des lettres ou syllabes en trop, autorisées (2 au plus conseillées) | Cas du catalogue (ق ل م ب ن pour قلم) | Interdire les éléments en trop |
| 10 | T15 : tuiles sans harakat | Les tuiles portent la lettre nue, le mot entendu (`ecoute.texte`) est vocalisé, le validateur compare sans harakat | Une lettre isolée avec sa haraka serait une 2e forme de T19. Le mot construit s'affiche lié, sans harakat | Tuiles vocalisées (بَ) et mot construit vocalisé |
| 11 | T16 jamais en arabe | `type_langue` refuse l'arabe pour T16 | Des syllabes arabes isolées montrent des formes de lettres fausses là où l'écrit les lie | Autoriser avec des syllabes rendues avec tatweel |
| 12 | T12 en arabe seulement | `type_langue` | Le type vise une règle de la langue arabe (lam solaire ou lunaire, ta marbouta...) | Autoriser le français (masculin ou féminin, singulier ou pluriel) |
| 13 | Remplissage des lignes (T13 à T16) | Un élément déposé entre deux autres s'insère à cet endroit. Le toucher d'un élément posé retire le dernier de la ligne seulement | Insertion simple à coder et à comprendre, retrait sans déplacer les autres par erreur (catalogue : « touche le mot pour retirer la dernière lettre ») | Retirer n'importe quel élément au toucher |
| 14 | Avertissement 4 à 6 éléments | `elements_trop_nombreux` (avertissement) si plus de 6 éléments et niveau 1 ou 2, le niveau étant lu dans l'id de l'exercice | Le schéma ne connaît pas le niveau d'un exercice seul | Rendre l'erreur bloquante |

## Questions ouvertes

1. **T56 et T62** sont rangés sous Glisser-déposer dans le registre mais absents de la liste de la décision 3. Faut-il les décrire dans cette fiche (racine et schème : glisser des lettres dans un schème, frise : ordre avec un rendu en ligne du temps) ou les déplacer vers un autre moteur ?
2. **T26 et T27** : rester au moteur Manipulables (fiche à écrire pour A1-06) ou rejoindre ce moteur avec une 6e interaction « compter » (pièces, blocs, somme attendue) ?
3. **Aimant** : calage au centre de la cible seulement, ou aussi attraction du doigt quand il approche (rayon d'aimantation) ? Le prototype fait le premier.
4. **Retour animé hors cible** : 200 ms en ligne droite. Durée et courbe à valider sur l'iPhone.
5. **Jetons** : agrandissement de la tuile tenue et bordure pointillée sans jeton (point 5). À ajouter à tokens.json ?
6. **T06 texte long (T39)** : en 4e à 6e année, un texte de 3 à 5 trous dépasse l'écran avec la réserve en dessous. Réserve fixée en bas de l'écran (au-dessus de Vérifier) ou texte défilant ?
7. **T09 avec des mots des deux côtés** : les deux colonnes ont le même aspect, faut-il différencier la réserve (gauche) des cibles (droite) par une étiquette (« mots », « contraires ») ?
8. **Lecteur d'écran** : le toucher-toucher est le chemin accessible. Les libellés « tenu », « en attente », « posé dans ... » sont à relire en arabe.
9. **Harakat des exemples arabes** (T11, T12, T14, T15) : brouillon, relecture humaine avant `valide`.
10. **Codes de compétence** des exemples : inventés, à remplacer par le référentiel.
