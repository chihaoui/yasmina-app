# Moteur Tracé

Fiche de conception du moteur Tracé, écrite avant le code. Statut : **brouillon du 20 oct. 2026 (Claude Code, session sans surveillance, après-midi, décision 39)**, à valider par Lamjed. Base de la tâche A1-04 (1,5 j-h en vigueur). Les points tranchés seul et les questions ouvertes sont dans [trace-questions.md](trace-questions.md).

Sources : CLAUDE.md §5 (« Tracé (T20) non noté, sans sous-titres sous les boutons », consigne toujours sonorisée, 1re année), la page catalogue v3 (`docs/reference/catalogue-v3-poc.html`, référence visuelle seulement : lettre grise, encre bleue, formes de la lettre en boutons), le lecteur générique (`ModeValidation.sansNote`, prévu pour T20 depuis A0-13), la fiche [choix.md](choix.md) pour tout ce qui est commun au lecteur.

## 1. Objectif

Un moteur pour l'exercice où l'enfant **trace une lettre arabe avec le doigt**, dans une ou plusieurs de ses formes, guidé par des points et des flèches dans le sens d'écriture. Il vit dans `packages/moteur_exercices` et tourne à l'identique dans l'app et dans l'aperçu web (règle d'architecture n°1) :

- il reçoit un exercice edu-content/1.0 et une configuration (langue, forme d'adresse, mode)
- il émet des événements (réponse donnée, résultat, demande d'audio)
- il ne connaît ni la base locale, ni la navigation, ni les profils
- il est compatible web : aucun `dart:io`, le tracé est un `CustomPaint` et un détecteur de geste, les services passent par les interfaces injectées

**Non noté.** Le tracé n'est jamais jugé juste ou faux : pas de Vérifier, pas de feedback en 3 temps, pas d'essai. Le lecteur joue le type en `ModeValidation.sansNote` : Continuer devient actif dès que la réponse est complète, et le résultat émis est `termine` (0 essai). C'est un entraînement (catalogue v3 : « MVP en entraînement non noté »).

Le type se branche sur le lecteur par le contrat de `contrat_moteur.dart` (`GabaritReponse`, `ControleurReponse`), comme les moteurs Choix et Glisser-déposer. Le lecteur porte la consigne et sa lecture, Yasmina, Continuer, les libellés et les modes. Le moteur ne porte que la zone de tracé.

## 2. Types couverts

| Type | Nom | Ce que fait l'enfant | Dans le registre | Exemples |
|---|---|---|---|---|
| T20 | Tracé de lettre (non noté) | Choisit une forme de la lettre (isolée, début, milieu, fin), suit les points avec le doigt pour la tracer, peut effacer et recommencer, passe à la forme suivante, puis Continuer | Tracé, lot 1 | `T20-ba.json`, `T20-lam.json`, `T20-mim.json` (les 3 premières lettres de la démo, 1re année) |

Un seul type pour ce moteur dans le MVP. Les lettres de la démo (ب ل م ر, puis د et ف) auront chacune leur exercice T20 dans le parcours d'arabe 1re année.

## 3. Interaction

1. L'écran affiche Yasmina et la consigne (lue à l'ouverture, bouton de réécoute), comme pour tout exercice. Le nom de la lettre (`ecoute.texte`, « بَاءٌ ») est dit après la consigne, et redit par le bouton Écouter.
2. **Les formes de la lettre** sont des boutons en ligne, dans l'ordre du JSON (isolée, début, milieu, fin), de droite à gauche. Chaque bouton montre seulement le glyphe de la forme (ب, بـ, ـبـ, ـب), **sans sous-titre** (CLAUDE.md §5). La première forme est choisie à l'ouverture. Toucher un bouton change la forme affichée dans la zone de tracé, chaque forme garde son propre tracé.
3. **La zone de tracé** (3 : 2, fond `tile`, bordure `line`, coins `radius-lg`) montre la forme en grand, en gris (`line`), police naskh du contenu (celle qu'on apprend à l'école). Par-dessus, le **guidage** : pour chaque trait de la forme, une suite de points (`muted`) dans le sens d'écriture, un point de départ plus gros (`blue`) et une flèche (`blue`) au bout du trait. Les traits se tracent dans l'ordre des points, de droite à gauche comme on écrit l'arabe, le point en dernier.
4. **Le tracé.** L'enfant pose le doigt et le déplace : l'encre (`blue`, trait épais, bouts ronds) suit le doigt. Un doigt levé puis reposé fait un nouveau trait. Rien n'est jugé : l'encre reste telle qu'elle est tracée, sur ou à côté du modèle.
5. **Effacer** (bouton secondaire sous la zone, icône et libellé) vide le tracé de la forme affichée, pour recommencer.
6. **Tolérance large.** Une forme compte comme tracée dès que l'encre a une longueur suffisante (un quart de la largeur de la zone, cumulé sur tous les traits), sans comparaison avec le modèle. Un enfant de 1re qui a fait l'effort de tracer passe toujours.
7. **Continuer** (vert) devient actif quand toutes les formes demandées par `reponse.formes` sont tracées (par défaut la forme isolée seule, l'exemple de la démo demande la forme isolée, les autres formes restent libres). Le résultat `termine` est émis, sans son juste ni faux. Aucun bandeau de feedback.

Particularité d'affichage : la zone de tracé a la largeur de l'écran, moins les marges du lecteur. Sur une tablette, elle garde son rapport 3 : 2 et se centre.

## 4. Données JSON

Le schéma `schema/edu-content-1.0.schema.json` est la référence (définitions `donneesTrace`, `formeTrace`, `pointTrace`, `reponseTrace`).

| Champ | Contenu |
|---|---|
| `donnees.lettre` | Une lettre arabe nue (ب) |
| `donnees.formes` | 1 à 4 formes, id `f1` à `f4`, chacune avec `texte` (le glyphe, avec tatweel : بـ, ـبـ, ـب), `position` (isolee, debut, milieu, fin, une seule fois chacune) et `traits` facultatifs : 1 à 4 traits, chacun une suite de 2 à 20 points `{ x, y }` entre 0 et 1, dans le repère de la zone de tracé (x de gauche à droite, y de haut en bas), dans le sens d'écriture |
| `donnees.ecoute` | Facultatif : le nom de la lettre dit après la consigne (« بَاءٌ ») |
| `reponse.formes` | Les formes à tracer pour que Continuer s'active (1 à 4 id, sans doublon). Les autres formes restent proposées, sans obligation |

Les `feedbacks` restent obligatoires par le schéma (commun à tous les types) mais ne sont jamais affichés par le lecteur en mode sans note.

Règles du validateur propres au moteur (détail dans `schema/README.md`) :

- T20 en arabe seulement (`type_langue`)
- `lettre` est une seule lettre arabe nue (`lettre_invalide`)
- chaque forme contient la lettre une fois le tatweel retiré (`forme_sans_lettre`, comme T18), id uniques (`element_duplique`), positions uniques (`position_dupliquee`)
- `reponse.formes` désigne des formes existantes (`reponse_element_inconnu`)

## 5. Correction

Aucune. La « réponse » est l'ensemble des formes tracées (`{ "formes": ["f1", "f2"] }`), complète quand elle contient toutes celles de `reponse.formes`. Le moteur ne compare jamais l'encre au modèle : ni couverture, ni ordre des traits, ni sens. Ce sont des pistes pour plus tard (question 3 de la fiche des questions), si les familles demandent un retour sur le geste.

## 6. Feedback

| Moment | Bandeau | Yasmina | Zone | Bouton |
|---|---|---|---|---|
| Pendant le tracé | aucun | neutre | encre bleue sur la lettre grise | Continuer inactif tant qu'une forme demandée manque |
| Formes demandées tracées | aucun | neutre | inchangée | Continuer (vert) |
| Après Continuer | aucun | neutre | inchangée et verrouillée (plus de tracé, plus de changement de forme) | l'hôte enchaîne (résultat `termine`) |

Aucun son `juste`, `essaiFaux` ni `revelee` (décision 35 : le lecteur n'en joue aucun en mode sans note). Pas de vibration au tracé.

## 7. Événements et modes

- `reponseDonnee` : à chaque changement de l'ensemble des formes tracées (après un trait qui rend une forme tracée, après Effacer)
- `resultat` : `termine`, 0 essai, à Continuer (mode enfant seulement)
- `demandeAudio` : consigne, nom de la lettre (`ecoute.texte`)
- Modes : `enfant` (ci-dessus), `apercu` (« afficher la réponse » montre la lettre et ses traits de guidage en `olive`, sans encre, Rejouer efface tout), `edition` (rechargement)

## 8. Variantes (gabarits)

| Gabarit | Types | Présentation |
|---|---|---|
| `trace-lettre` | T20 | Formes en boutons, zone de tracé, Effacer |

Une variante « mot entier » (tracer بَابٌ) n'est pas prévue dans le MVP.

## 9. Cas arabe

- T20 n'existe qu'en arabe (`type_langue`). Pas de cas français ni anglais : les tests portent un cas au masculin et un cas au féminin (libellés genrés : اِمْسَحْ, اِمْسَحِي).
- Sens : les boutons des formes se lisent de droite à gauche (isolée d'abord, à droite), les points de guidage vont de droite à gauche, la zone de tracé n'est pas retournée (les coordonnées des traits sont absolues).
- Police : la lettre modèle en naskh (`content`, police de l'école), à la taille de la zone. Les boutons des formes en `content-word`.
- Le nom de la lettre est vocalisé (بَاءٌ, لَامٌ, مِيمٌ) et relu comme tout texte arabe (`docs/conventions-arabe.md`). Les glyphes des formes portent un tatweel, jamais de haraka.

## 10. Règles UX

- Zone de tracé d'au moins la largeur de l'écran moins les marges, 3 : 2, bouton de forme d'au moins 48 dp (`target-min`), écart `space-2`.
- Un seul tracé en cours à la fois (un doigt). Un deuxième doigt est ignoré.
- La zone de tracé capte le geste : le défilement de la page ne se déclenche pas quand le doigt trace (à vérifier sur l'iPhone, voir les blocages de PROGRESS.md).
- Rien n'est jugé : pas de rouge, pas de secousse, Yasmina reste neutre.
- Tout mouvement s'arrête si l'appareil demande moins d'animations (il n'y en a pas dans ce moteur, hors Yasmina).
- Accessibilité : chaque bouton de forme est un bouton avec le glyphe pour libellé et son état sélectionné, la zone de tracé est une image nommée par la lettre, Effacer est un bouton nommé. Le tracé au doigt n'a pas d'équivalent clavier : l'exercice reste passable avec Continuer après un tracé minimal (question 5).

## 11. Composants du design system

| Composant | Dans le moteur | Statut | Usage |
|---|---|---|---|
| ChoiceTile | `TuileChoix` | existe | Les boutons des formes (repos, sélectionné), glyphe seul en `content-word` |
| Button | `BoutonYasmina` | existe | Continuer (vert, par le lecteur), Effacer (variante `alt`, avec icône) |
| IconButton (listen) | `BoutonEcouter` | existe | Nom de la lettre |
| Zone de tracé | `ZoneTrace` | à créer | Fond `tile`, bordure `line` (`border-thick`), coins `radius-lg`, lettre en `line`, guidage en `muted` et `blue`, encre en `blue` |

Aucune nouvelle valeur hors `tokens.json`, sauf l'épaisseur de l'encre et la taille de la lettre dans la zone, sans jeton (exception `design-ok`, question 4).

## 12. Tests prévus

- Un test de widget par exemple (ب, ل, م), au masculin et au féminin, avec un **vrai geste de tracé** (`startGesture`, plusieurs `moveBy`, `up`) sur la zone : l'encre apparaît, la forme devient tracée, Continuer s'active, `reponseDonnee` puis `resultat termine` (0 essai), aucun son juste ni faux, aucun bandeau.
- Un geste trop court ne compte pas (tolérance), Effacer vide la forme affichée seulement, le changement de forme garde les tracés.
- Boutons des formes : glyphe seul, sans sous-titre, première forme choisie à l'ouverture.
- Aperçu : afficher la réponse (lettre et guidage en olive, sans encre), Rejouer.
- Test de parité : chaque exemple joué dans un test de widget mobile et par l'aperçu web (test de widget et build web).
- Validation dans l'atelier : T20 jouable seul avec chaque exemple.

## 13. Découpage (A1-04, 1,5 j-h en vigueur)

| Étape | Contenu | j-h |
|---|---|---|
| a | Cette fiche, les questions | 0,25 |
| b | Schéma, règles du validateur, trois exemples (ب ل م) avec leurs traits de guidage, tests | 0,5 |
| c | `ZoneTrace` (modèle, guidage, encre, geste), contrôleur, boutons des formes, Effacer, mode sans note dans le lecteur, tests de widget, parité, atelier | 0,75 |
