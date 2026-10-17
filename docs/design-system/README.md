Yasmina apprend l'arabe, le français, l'anglais, les maths et l'éveil scientifique aux enfants du primaire tunisien (1re à 6e année). L'interface est douce, ronde et lisible par un enfant de 6 ans qui ne lit pas encore bien. Ce système reprend le langage visuel de la démo jouable et s'applique à l'app Flutter, à l'aperçu web du moteur et au futur back-office.

## Principes

- **L'exercice d'abord.** Rien ne décore l'écran d'exercice : consigne, zone de jeu, feedback, bouton. Yasmina accompagne, elle ne cache jamais la tâche.
- **Une langue par exercice.** Consigne, choix, boutons du lecteur, feedback et bulle de Yasmina sont dans la langue de la matière, quelle que soit la langue de l'interface (maths et éveil en arabe).
- **Le sens d'écriture suit la langue affichée.** En arabe tout l'écran est en miroir : barres de progression, flèches, chemin de la carte, remplissage des zones.
- **Grand, rond, tactile.** Toute cible fait au moins `target-min` (48 px). Coins arrondis partout, aucun angle vif.
- **Le juste et le faux ne passent jamais par la couleur seule** : Yasmina change d'humeur et le feedback l'écrit.

## Contenu et ton

- On parle à l'enfant directement, au singulier, avec l'accord masculin ou féminin de son profil : « أَحْسَنْتِ » pour Lina, « أَحْسَنْتَ » pour Yassine. Les formulations neutres (« هَيَّا نَتَعَلَّمُ مَعًا. ») évitent l'impératif genré dans l'interface.
- **Feedback en 3 temps** : d'abord ce qui est juste (« «بَابٌ» تَبْدَأُ بِحَرْفِ الْبَاءِ. »), puis un indice, puis l'explication avec la bonne réponse. Jamais de compliment sur la personne (« tu es doué »).
- **Harakat complètes** dans toute l'interface enfant et tout le contenu des exercices. Aucune harakat dans l'espace parent. Toute harakat est relue par un humain avant publication.
- **Conventions d'écriture de l'arabe** (docs/conventions-arabe.md du dépôt) :
  - A. alif de liaison en début de phrase avec kasra : اِسْتَمِعْ
  - B. alif suscrit simplifié : هَذِهِ, jamais هٰذِهِ (aucun caractère U+0670)
  - C. lam de l'article avec soukoun devant une lettre lunaire, hamza comprise (الْإِعْدَادَاتُ, الْكَلِمَةُ), kasra devant un alif de liaison (الِاسْمُ), rien devant une lettre solaire qui porte la shadda (الصَّحِيحَةُ)
- Textes français : phrases courtes, pas de tiret cadratin ni de point-virgule. Les sous-titres français sous un texte arabe sont en `caption` et `muted`.
- Le nom de la mascotte : Yasmina en latin, يَاسْمِينَة en arabe.
- Aucun contenu recopié des manuels scolaires.

## Couleurs

- Écran enfant sur `screen`, barres et cartes sur `surface`, éléments manipulables sur `tile`. `bg` ne sert qu'autour du cadre de téléphone (aperçu, back-office).
- Texte principal `ink`, secondaire `muted`. Jamais de texte `line`.
- **`blue` est la couleur d'action** : bouton principal, sélection, focus, mot mis en évidence. Sélection = fond `blue-soft` et bordure `blue`.
- **Trois couleurs d'état**, chacune avec un fond `-soft` et une variante `-text` pour le petit texte : `olive` réussite, `amber` indice, `coral` explication et erreur.
- Sur un bouton plein `blue` ou `olive`, le texte est `on-accent` (blanc en clair, sombre en sombre).
- Matières : `subject-ar`, `subject-ma`, `subject-ev`. Séquences d'une étape : `seq-1` à `seq-4` et `seq-defi`.
- Carte du trimestre : fond `map`, étape ouverte `sun`, terminée `node-done`, à venir en pointillé `path`.
- Le thème sombre suit le réglage de l'appareil. La mascotte et les pastels des matières ne changent pas.

## Typographie

Trois familles, embarquées dans l'app (licence OFL), servies par Google Fonts dans les pages web :

- **`kid` : Baloo Bhaijaan 2**, ronde et enfantine, pour l'interface arabe : titres, bulle, boutons, consignes (`bubble`, `button-cta`, `prompt`, `title-bar`, `option`, `letter-hero`).
- **`content` : Noto Naskh Arabic**, le naskh enseigné à l'école, pour le texte que l'enfant lit dans l'exercice : mots, phrases, choix (`content-word`, `content-sentence`, `content-option`). Interligne large (1,6 et plus) pour que la shadda et la fatha empilées ne touchent pas la ligne voisine.
- **`latin` : Andika**, conçue pour les lecteurs débutants (a et g d'école, I l 1 distincts), pour le français, l'anglais et l'espace parent (`latin-prompt`, `latin-body`, `latin-label`, `caption`). Remplace Readex Pro de la démo (décision 27).
- Corps minimum : 20 px pour une consigne, 22 px pour un texte arabe à lire, 11 px pour une légende d'adulte seulement.

## Espacements, rayons, ombres

- Marges d'écran `space-5` (exercice) et `space-6` (accueil). Écart entre choix `space-3`, entre tuiles `space-2`.
- Rayons : `radius-md` tuiles et boutons secondaires, `radius-lg` choix, feedback et zones de dépôt, `radius-xl` bouton principal et bulle, `radius-2xl` cartes de profil et de matière, `radius-pill` pastilles et ronds.
- Une seule ombre fonctionnelle, le relief de touche : `shadow-press` sur le bouton principal, `shadow-node` sur les étapes de la carte. Pas d'autre ombre, les cartes sont séparées par une bordure `line`.

## Mouvement

- Yasmina se balance au repos (2,6 s), saute 3 fois sur une réponse juste, se penche sur une erreur. L'étape ouverte pulse doucement sur la carte.
- Tuile hors cible : retour animé à sa place. Dépôt réussi : effet aimant et vibration légère.
- Tout mouvement s'arrête si l'appareil demande moins d'animations.

## Iconographie

- Images d'exercices : emoji dans la démo, à remplacer par les illustrations de l'illustratrice (même style que Yasmina, aplats, contour doux).
- Icônes d'interface : icônes Material arrondies en placeholder, en `ink` ou `blue`. Les flèches suivent le sens d'écriture.
- Avatars des profils : 8 sujets neutres (fleur, soleil, lune, étoile, arbre, bateau, chat, nuage), en placeholder. Aucun personnage de marque.
- Yasmina : le groupe d'assets « Yasmina » (3 humeurs).

## Accessibilité

- Texte : 4,5:1 au minimum dans les deux thèmes. `ink` et `muted` le tiennent sur `screen`, `surface`, `tile` et `bg`. Le petit texte d'état utilise les variantes `-text`.
- `line` (1,35:1) est décoratif : un choix au repos se reconnaît à sa forme, un choix sélectionné à la bordure `blue` (5:1 et plus).
- Anneau de focus : 3 px `blue`, décalé de 2 px.
- Toute consigne est sonorisée, avec un bouton de réécoute.

## Dans le code

- Flutter : un `ThemeYasmina` (couleurs par thème clair et sombre, `TextTheme` par famille, rayons et espacements en constantes) généré à partir de `tokens.json`, dans le package `moteur_exercices` pour que l'app et l'aperçu web aient le même rendu.
- Les noms des tokens sont repris tels quels dans le code (`blue-soft` devient `blueSoft`).
