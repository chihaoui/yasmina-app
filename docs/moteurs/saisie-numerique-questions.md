# Moteur Saisie numérique : points tranchés et questions ouvertes

Préparation du moteur Saisie numérique (branche `moteur/saisie-numerique`, soir du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | Pavé numérique | Dessiné par le moteur, 1 2 3 en haut comme un téléphone, 0 en bas, Effacer, jamais le clavier système | Même pavé partout, compatible web, pas de clavier qui cache l'écran | Clavier système numérique |
| 2 | Chiffres | `chiffres` dans le JSON (`occidentaux` par défaut, `orientaux`), pavé et saisie affichés avec les mêmes chiffres, valeur stockée en entier | Convention scolaire non tranchée, réversible par le contenu | Chiffres selon la langue de l'interface |
| 3 | T48 : sens des colonnes | `sens` dans le JSON, `droite-gauche` par défaut (unités à droite) | Question en attente sur les manuels tunisiens (catalogue : « à confirmer ») | Défaut `gauche-droite` |
| 4 | T48 : ordre de saisie | Les chiffres du résultat se tapent des unités vers les dizaines (ordre du calcul), case active marquée, Effacer vide la dernière | C'est l'ordre dans lequel on pose une opération | Toucher une case pour la choisir |
| 5 | T48 : retenues | `retenues` (faux par défaut) affiche des cases de retenue, remplies au toucher puis au pavé, hors correction | Aide sans juger, réversible | Retenues obligatoires et corrigées |
| 6 | T48 : opérations | Addition et soustraction, opérandes de 0 à 999, résultat jamais négatif | Base de 1re à 3e, les autres opérations viendront avec A2-01 | Multiplication posée |
| 7 | T22 : problème dit | Le texte du problème est dit après la consigne (comme un mot à écouter), bouton de réécoute de la consigne seulement | L'enfant de 1re ne lit pas encore un problème seul | Bouton Écouter dédié au problème |
| 8 | Tolérance | `tolerance` du schéma s'applique à T22 seulement (jamais à un calcul posé) | Un calcul posé a une seule réponse | Tolérance partout |

### Nuit du 20 au 21 oct., types avancés (A2-01)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 9 | T49 : deux cases et un pavé | Numérateur puis dénominateur, case active au toucher (bordure `blue`), le même pavé numérique, fraction équivalente acceptée par défaut (`equivalentes`) | Catalogue : « clavier dédié numérateur et dénominateur, 6/8 accepté » | Un champ texte « 3/4 » |
| 10 | T50 : sans note, trois réponses proposées | Mode sans note du lecteur, questions tirées avec la graine, trois tuiles de choix, fausse marquée 0,7 s puis question suivante, Stop possible, `questions_min` pour Continuer. Aucun record gardé (pas de stockage dans le moteur) | Catalogue : « hors score, comparaison à son propre record » : le record viendra avec la progression locale (A3-03) | Saisie au pavé (plus lente), record dans le moteur |
| 11 | T63 : balance dessinée | `CustomPaint` : pied, fléau incliné (un huitième de tour au plus, proportionnel à l'écart ramené à la masse attendue), plateaux suspendus, masses en carrés `amber` numérotés, sac rond `blue` avec « ? » ou la valeur écrite | Aucune image, la balance réagit à la saisie comme dans le catalogue | Masses glissées sur les plateaux (glisser-déposer) |

## Questions ouvertes

1. **Disposition du calcul posé en arabe** : unités à droite ou à gauche dans les manuels tunisiens ? Retenue écrite au-dessus ou en dessous ? Le JSON porte `sens` et `retenues`, le défaut est `droite-gauche` et sans retenue.
2. **Chiffres** : occidentaux (0 à 9) ou orientaux (٠ à ٩) dans les manuels de maths tunisiens ? Le défaut est occidental, comme tous les exemples.
3. **T22 avec un nombre décimal** : hors base. La fraction est couverte par T49 (A2-01).
6. **T50** : où garder le record personnel (progression locale, A3-03) ? Durée et nombre de réponses proposées (3) à valider sur l'iPhone. Chronomètre désactivable par le contenu (`chrono`), faut-il aussi un réglage parent ?
7. **T63** : unité des masses (grammes, kilos) à afficher ? Masses glissées plutôt qu'écrites ?
4. **Unité après le nombre** (« د » pour dinar) : placement avant ou après en arabe ?
5. **Harakat des exemples arabes** : brouillon, relecture humaine.
