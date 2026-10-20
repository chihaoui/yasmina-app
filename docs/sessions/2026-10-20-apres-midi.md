# Session du 20 oct. 2026, après-midi (sans surveillance, décision 39)

Claude Code, seul, deuxième file de la journée (la première est dans [2026-10-20.md](2026-10-20.md)). Règles du jour : une branche par tâche, empilées depuis `proposition/moteur-glisser-deposer` (`moteur/glisser-deposer-t56-t62`, puis `moteur/trace`, puis `moteur/manipulables-base`), `./tool/verifier.sh` lu par son code de sortie avant chaque commit, rien de poussé, aucun fichier iOS touché (`Info.plist` est modifié dans l'arbre par Xcode depuis ce matin et laissé tel quel, hors de tout commit), navigateur non utilisé, aucune dépendance ajoutée.

Hypothèse de périmètre du mentor appliquée sans la rediscuter : le catalogue v3.1 fait foi, T39 hors MVP, T26 et T27 au moteur Manipulables, T56 et T62 au moteur Glisser-déposer (10 types).

## 1. Résumé par tâche

### Tâche 4, T56 et T62 dans le moteur Glisser-déposer : **faite**

Branche `moteur/glisser-deposer-t56-t62` (2 commits) :

- `2a852bf` Définit T56 Racine et schème et T62 Frise chronologique dans le schéma, le validateur et les exemples
- `04cda7f` Rend T56 et T62 jouables : emplacements de racine ou de schème, frise chronologique

| Étape | État | Contenu |
|---|---|---|
| Schéma et validateur | faite | `donneesFrise` (élément avec `date` facultative), `donneesRacineScheme` (`mot`, `forme` racine ou scheme, `emplacements` avec `haraka` nommée parmi 10 valeurs, `lettres` nues), réponses `ordre`. Règles : `lettre_invalide`, `haraka_hors_scheme`, `scheme_longueur`, `scheme_harakat_differentes` (shadda et voyelle comparées sans ordre, jamais de NFC), `ecoute_differente_reponse`, avertissement `racine_hors_mot`. 3 exemples en brouillon : `T56-racine.json` (مَكْتَبٌ, 4e), `T56-scheme.json` (كَاتِبٌ sur فَاعِلٌ), `T62-frise.json` (journée, français 3e) |
| Moteur | faite | `ControleurOrdre` avec une `capacite` (ligne pleine), `TuileGlissable` avec un `detail` (date), frise à cases fixes dans le sens d'écriture avec ligne du temps peinte (trait, repères, flèche), `GabaritRacineScheme` (racine en lettres isolées séparées par une espace, schème lié lettre à lettre avec la haraka de son emplacement, emplacements vides pointillés, retrait du dernier au toucher) |
| Tests | faite | 5 tests de widget avec un vrai geste (T62 français et arabe, T56 racine, schème faux puis révélé, schème juste et aperçu), parité à 10 types dans le moteur et dans l'aperçu web, 20 tests du schéma. 34 tests du moteur Glisser-déposer verts |
| Fiche | faite | `glisser-deposer.md` (10 types, 6 interactions, T56 et T62 décrits) et `glisser-deposer-questions.md` (points 15 à 21, question 1 mise à jour) |

### Tâche 5, moteur Tracé, A1-04, T20 : **faite** (étapes a, b et c)

Branche `moteur/trace` (3 commits) :

- `be25c46` Ajoute le brouillon de fiche du moteur Tracé (T20, non noté) et ses questions
- `5651a63` Définit T20 Tracé de lettre dans le schéma, le validateur et trois exemples (ب ل م)
- `82b4c18` Code le moteur Tracé : T20 jouable, formes en boutons, zone de tracé au doigt, guidage, Effacer

| Étape | État | Contenu |
|---|---|---|
| a, fiche | faite (brouillon) | `docs/moteurs/trace.md` et `trace-questions.md` (11 points tranchés, 8 questions) |
| b, schéma | faite | `donneesTrace` (lettre nue, 1 à 4 formes avec glyphe, position et `traits` de guidage en points normalisés, nom de la lettre à dire), `reponseTrace` (formes à tracer pour finir). Règles : arabe seulement, `lettre_invalide`, `forme_sans_lettre`, `position_dupliquee`, `reponse_element_inconnu`. Exemples `T20-ba.json`, `T20-lam.json`, `T20-mim.json` (4 formes chacun, traits faits main), 10 tests du schéma |
| c, moteur | faite | `GabaritTrace` en mode sans note : formes en `TuileChoix` (glyphe seul, sans sous-titre), zone 3 : 2 avec la lettre modèle en naskh, points et flèches de guidage dans le sens d'écriture, encre qui suit le doigt (`GestureDetector`), Effacer par forme (libellé genré ajouté à `LibellesLecteur`), Continuer dès que les formes demandées sont tracées (un quart de la largeur d'encre, rien n'est jugé). Le lecteur verrouille la zone après Continuer en mode sans note. 4 tests de widget avec un vrai geste de tracé, 3 de parité, aperçu web adapté (révélation en olive) |

### Tâche 6, moteur Manipulables, base, A1-06 : **partielle** (a, b et c1 faites, c2 non faite)

Branche `moteur/manipulables-base` (part de `moteur/trace`).

Commits :

- `255a860` Ajoute le brouillon de fiche du moteur Manipulables (T25, T27, T51) et ses questions
- `088bc9b` Définit T25, T27 et T51 dans le schéma, le validateur et les exemples du moteur Manipulables
- `c1597fc` Code T25 Droite numérique : repère glissé avec aimant, graduation touchée, sens configurable
- dernier commit de la journée : PROGRESS.md et ce compte rendu

| Étape | État | Contenu |
|---|---|---|
| a, fiche | **faite** (brouillon) | `docs/moteurs/manipulables.md` (3 types de base, geste, données, correction, feedback avec retour à l'état de départ, composants) et `manipulables-questions.md` (8 points tranchés, 6 questions, sens de la droite configurable par `sens`) |
| b, schéma | **faite** | `donneesDroiteNumerique` (`min`, `max`, `pas`, `reperes`, `cible`, `sens`), `donneesBlocs` (`cible`, `canonique`), `donneesCadreDix` (`cible`), réponses `valeur`, `dizaines` et `unites`, `jetons` contrôlées contre la cible (`droite_invalide`, `droite_trop_longue`, `cible_hors_droite`, `reponse_valeur_incoherente`, avertissement `graduations_trop_nombreuses`). 3 exemples en brouillon (maths en arabe), 23 tests du schéma |
| c1, T25 | **faite** | `GabaritDroiteNumerique` : droite peinte toujours de gauche à droite (chiffres non retournés), étiquettes tous les `reperes` et aux bouts, repère glissé qui suit le doigt et s'aimante à la graduation la plus proche au lâcher, graduation touchée en secours, son `depot` et vibration, retour au départ après le 1er essai faux, cible révélée. 3 tests de widget avec un vrai geste (arabe, sens droite-gauche au féminin, français en aperçu), parité moteur et aperçu web |
| c2, T27 et T51 | **non faite** | Blocs base 10 et cadre de 10 restent « à venir » dans l'atelier : le temps a manqué, arrêt propre à la fin de l'étape c1. À reprendre sur la même branche à partir de la fiche §3 (réserve inépuisable, toucher pour ajouter, toucher un élément posé pour le retirer) |


## 2. Points tranchés seul (à valider par Lamjed)

Les points de détail sont dans les fiches de questions de chaque moteur. Résumé :

| N° | Tâche | Point | Choix fait | Alternative |
|---|---|---|---|---|
| 1 | 4 | Périmètre | Hypothèse du mentor appliquée : 10 types au moteur Glisser-déposer, T39 hors MVP, T26 et T27 au moteur Manipulables | Liste de la décision 3 |
| 2 | 4 | T62 | Variante de T13 (même contrôleur d'ordre), `date` facultative par élément, frise à cases fixes en largeur, seule la case suivante reçoit, tuile posée réduite à l'emoji et la date | Frise verticale, toutes les cases ouvertes |
| 3 | 4 | T56 | `forme` dans `donnees` (racine ou scheme), harakat des emplacements nommées (10 valeurs), racine en lettres isolées séparées par une espace, schème lié avec la haraka de son emplacement, ligne à capacité fixe | Un gabarit par forme, signes combinants dans le JSON |
| 4 | 4 | Commits | Un seul passage du vérificateur pour les deux commits de la tâche 4 (le premier, schéma seul, n'a pas été vérifié isolément) | Un passage par commit |
| 5 | 5 | Réponse non notée | `reponse.formes` = formes à tracer pour que Continuer s'active, réponse émise = formes tracées | Continuer toujours actif |
| 6 | 5 | Tolérance | Une forme est tracée dès un quart de largeur d'encre, sans comparaison au modèle | Couverture du modèle |
| 7 | 5 | Guidage | Points normalisés faits main dans le JSON (approximatifs, à relire par un enseignant), lettre modèle en naskh | Traits générés depuis la police |
| 8 | 5 | Consigne | « اِتْبَعِ النُّقَطَ وَارْسُمْ... » pour rester dans la convention A (kasra), plutôt que اُرْسُمْ (damma) | Compléter la convention A |
| 9 | 5 | Après Continuer | Le lecteur verrouille la zone d'un type sans note (changement du lecteur, 2 lignes) | Zone libre après la fin |
| 10 | 5 | Jetons | Épaisseur de l'encre (18 px) et taille de la lettre (70 % de la zone) sans jeton, `design-ok` | Jetons dans tokens.json |
| 11 | 6 | Sens de la droite | `sens` dans le JSON (`gauche-droite` par défaut, `droite-gauche`), chiffres toujours de gauche à droite | Défaut selon la langue |
| 12 | 6 | Réponses | `reponse` explicite (`valeur`, `dizaines` et `unites`, `jetons`), contrôlée contre `cible`. T27 canonique par défaut. Retour à l'état de départ après le 1er essai faux | Réponse déduite de la cible |
| 13 | 6 | Langue | Aucune règle `type_langue` pour les manipulables : la compétence `ma-` impose déjà l'arabe | Arabe seulement |

## 3. Questions ouvertes de l'après-midi

1. **Périmètre** : confirmer l'hypothèse du mentor (10 types au Glisser-déposer). Si T56 ou T62 devaient changer de moteur, le code se déplace sans changer les données.
2. **T56** : écriture de la racine (lettres séparées par une espace, ou « ك، ت، ب »), place du schème dans le programme (4e supposée), et la liste des 10 harakat nommées suffit-elle (pas de hamza, pas de madda) ?
3. **T62** : frise en largeur (défile au-delà de 6 cases) ou verticale sur téléphone ?
4. **T20** : traits de guidage à relire par un enseignant, police du modèle (naskh retenu), nom des lettres avec tanwin (بَاءٌ), combien de formes par exercice en 1re, retour sur le geste plus tard ?
5. **Droite numérique** : sens par défaut en arabe (question en attente sur les manuels), le JSON porte `sens`.
6. **Harakat** des nouveaux textes arabes (exemples T56, T62 fixture, T20, T25, T27, T51 et libellé اِمْسَحْ) : brouillon, relecture humaine.
7. **À vérifier sur l'iPhone** : le geste de tracé dans la page du lecteur qui défile (le `GestureDetector` doit garder le doigt), le glisser du repère sur la droite, la liaison de « فَاعِلٌ » construit lettre à lettre, la frise qui défile en largeur.

## 4. Fiche de test du soir (45 min au maximum)

Ouvrir l'app (build debug) sur l'iPhone, appui long sur le titre de l'accueil, « Atelier ». Chaque type s'ouvre par son id, puis son exemple. Mode « Enfant » sauf mention. Pour chaque type noté : une réponse fausse (indice), puis la bonne (bravo, Continuer), puis rejouer en « Aperçu » et basculer « Afficher la réponse ». Glisser réel d'abord, toucher-toucher en secours (toucher l'élément, puis la cible).

**Les 6 types les plus à risque en tête (environ 20 min).**

| Ordre | Type, exemple | Comment l'ouvrir | Quoi toucher | Résultat attendu |
|---|---|---|---|---|
| 1 | **T19 Choisir la haraka**, `T19-haraka.json` (arabe) | Atelier, T19, 1er exemple | « كُتُبٌ » dit après la consigne. Toucher ◌َ فَتْحَةٌ : le mot devient كُتَبٌ, la ت reste **liée** et bleue. Vérifier (indice), puis ◌ُ ضَمَّةٌ, Vérifier | Bravo. Si la ت se détache de ses voisines, le noter : on colorera le mot entier |
| 2 | **T15 Construire un mot**, `T15-mot-lettres.json` (arabe) | Atelier, T15 | « قَمَرٌ » dit après la consigne. Glisser ق, م, ر dans la zone : le mot s'écrit lié « قمر ». Toucher la zone : la dernière lettre revient. Le glisser vertical d'une tuile ne doit pas faire défiler la page | أَحْسَنْتَ, zone en vert |
| 3 | **T56 Racine et schème**, `T56-scheme.json` puis `T56-racine.json` (arabe) | Atelier, T56, 2e exemple puis 1er | Schème : كَاتِبٌ affiché et dit. Glisser ف, puis ا, puis ع, puis ل : la zone montre فَ, فَا, فَاعِ, **فَاعِلٌ lié** avec ses harakat, 4 cases pointillées qui disparaissent une à une. Une 5e lettre est refusée. Toucher la zone retire la dernière. Racine : مَكْتَبٌ, glisser ك ت ب : « ك ت ب » en lettres séparées, م et ن en trop | أَحْسَنْتَ. Si les lettres du schème ne se lient pas ou si une haraka saute, le noter avec une capture |
| 4 | **T20 Tracé de lettre**, `T20-ba.json` (arabe, non noté) | Atelier, T20, 1er exemple | « بَاءٌ » dit après la consigne. 4 boutons ب بـ ـبـ ـب sans sous-titre, le 1er choisi. Suivre les points gris avec le doigt (le point bleu est le départ, la flèche le sens) : encre bleue. La page ne doit pas défiler pendant le tracé. Effacer vide la forme. Choisir بـ : zone vide, tracer. Revenir à ب : l'encre est toujours là. Continuer dès la forme isolée tracée | Continuer (vert), aucun bandeau, aucun son juste ou faux, Yasmina neutre. En aperçu, « afficher la réponse » montre la lettre et les points en olive |
| 5 | **T62 Frise chronologique**, `T62-frise.json` (français) | Atelier, T62 | 5 tuiles emoji, texte et heure. Glisser ⏰ 7 h sur la 1re case pointillée : sur la frise, seule l'emoji et l'heure restent. Glisser 🍽️ 12 h, puis 🏫 8 h **sur** 🍽️ : il s'insère avant. Toucher la dernière tuile posée la retire. Une seule case reçoit à la fois | Bravo. Ligne du temps avec repères et flèche vers la droite |
| 6 | **T25 Droite numérique**, `T25-droite-numerique.json` (arabe) | Atelier, T25 | Droite de 0 à 10, 0 à gauche, chiffres de gauche à droite malgré l'arabe. Glisser le repère depuis 0 jusqu'entre 3 et 4 : il s'aimante à 3. Vérifier (indice, le repère revient à 0). Toucher la graduation 7, Vérifier | أَحْسَنْتَ. Son `depot` et vibration à chaque pose |

**Puis les autres, par moteur (environ 25 min).** Moteur Choix (ce matin) : T03 `T03-ecoute-et-choisis.json` (le mot « cat » dit après la consigne, jamais affiché), T23 `T23-comparer.json` (« 14 ? 9 » de gauche à droite, tuiles < = >), T46 `T46-justification.json` (Vérifier gris tant qu'il manque une réponse ou une preuve), T01 `T01-qcm-texte-image.json` (grille 2 × 2 de droite à gauche), T05, T18, T24, T45, T55, T61, T02 (régression), T04.

Moteur Glisser-déposer (ce matin) : T13 `T13-remise-en-ordre.json` (insertion avant un mot, retrait du dernier), T09 `T09-association.json` (lâcher hors cible : retour animé), T11 `T11-tri-categories.json` (bacs de droite à gauche), T06 `T06-texte-trous.json` (« dort » reste en trop), T12, T14, T16 (« tomate » collé).

Moteur Tracé : `T20-lam.json` et `T20-mim.json` (points et flèches des 4 formes de ل et م, à juger à l'œil : ordre et sens des traits).

À regarder en passant : le son `depot` à chaque dépôt et chaque pose du repère, les sons juste et essai faux restent doux, la voix de la consigne se fait entendre même en mode silencieux de l'iPhone, et le bouton Écouter redit le mot (T15, T56, T20).
