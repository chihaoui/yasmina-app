# PROGRESS.md : suivi du développement

<!-- avancement:debut -->
## Avancement
Au 20 oct. 2026. Bloc calculé par `dart run tool/avancement.dart`, ne pas modifier à la main.

| Phase | j-h faits | j-h total | % |
|---|---|---|---|
| A0 | 18,5 | 21,75 | 85 % |
| A1 | 23,75 | 36,25 | 66 % |
| A2 | 17 | 30,5 | 56 % |
| A3 | 0 | 8,25 | 0 % |
| B | 0 | 39,25 | 0 % |
| C | 0 | 29,75 | 0 % |
| D | 0 | 16,5 | 0 % |
| **Total** | **59,25** | **182,25** | **32,5 %** |

- **Avancement global : 32,5 %** (59,25 j-h faits sur 182,25)
- **Types jouables : 52 sur 52**
- Méthode : une tâche compte seulement quand sa case de premier niveau est cochée (une tâche en cours compte 0). % d'une phase = j-h des cases cochées ÷ j-h de la phase. % global = j-h cochés ÷ total, contrôlé par rapport à `docs/estimations-taches.md`. Types jouables = codes Txx des cases cochées des phases A1 et A2. Les sous-cases détaillent une tâche et ne portent pas d'estimation.
<!-- avancement:fin -->

Mis à jour par Claude Code à la fin de chaque session, relu par Lamjed et par le mentor. Les dates suivent le plan de développement du 17 octobre 2026, replanifié le 19 octobre (décision 37 : estimations en vigueur à la moitié du plan pour les tâches non faites, phase A3 parcours et espace parent, voir `docs/estimations-taches.md`).

## État global
- Phase en cours : **A0, mise en place du prototype mobile** (19 octobre au 1er novembre 2026)
- Prochain point de décision : **R1, 15 novembre 2026** (vitesse réelle avec Claude Code, décision sur le renfort freelance)
- Framework : **Flutter 3.47.7** (décidé le 17 octobre 2026), poste vérifié par `flutter doctor` sans erreur
- Dépôt : https://github.com/chihaoui/yasmina-app (privé), dossier local `/Users/chihaoui/Documents/Forgia/Yasmina`

## Ordre de développement (décision 34, 19 oct. 2026)
**Atelier d'abord.** Les 11 moteurs et les 52 types du MVP (53 au catalogue v3.1, T20 Tracé de lettre retiré le 20 oct. 2026) sont développés et validés dans l'atelier du menu développeur (chaque type jouable seul, contenu statique) avant le parcours. Ordre des moteurs :
1. Choix (A1-01b)
2. Glisser-déposer (A1-02)
3. Tracé (A1-04, fait puis type retiré du MVP le 20 oct. 2026)
4. Manipulables (A1-06)
5. Autres moteurs du lot 1 (Texte, Saisie numérique, Scène image, Révision et jeux)
6. Lot 2 (phase A2)

Le parcours (choix de la matière, carte du trimestre, intro d'étape, résultat) et l'espace parent viennent après le 52e type validé : phase A3 (décision 37). Avant cela, une séquence de test sans carte (A1-22) enchaîne des exercices pour le tour 1 des familles.

## Jalons
| Jalon | Date | Critère | État |
|---|---|---|---|
| R1 | 15 nov. 2026 | Vitesse mesurée sur 2 semaines, décision freelance | À venir |
| G1 | 31 déc. 2026 | Lot 1 (35 types) jouable dans l'atelier, séquence de test jouée par 5 à 10 familles | À venir |
| G2 | 28 févr. 2027 | Rendu et UX des 52 types validés dans l'atelier | À venir |
| G3 | 30 avr. 2027 | Parcours, back-end, back-office, pilote arabe 1re | À venir |
| G4 | 30 juin 2027 | Bêta mesurée auprès de 150 familles | À venir |
| G5 | 31 août 2027 | Contenu T1 publié, apps approuvées par les stores | À venir |
| Lancement | 15 sept. 2027 | Rentrée scolaire | À venir |

## A0 : mise en place (19 oct. au 1er nov. 2026)
- [x] A0-01 Dépôt GitHub privé (0,25 j-h)
- [x] A0-02 Structure pub workspace (0,5 j-h)
- [x] A0-03 Script tool/verifier.sh (0,5 j-h)
- [x] A0-04 CLAUDE.md et PROGRESS.md (0,25 j-h)
- [x] A0-05 Maquettes HTML de référence (0,5 j-h)
- [x] A0-06 Projet Flutter et dépendances (0,5 j-h)
- [x] A0-07 Schéma edu-content/1.0 et validateur (2 j-h)
- [ ] A0-08 JSON embarqués (52 types et parcours arabe 1re) (1,5 j-h)
  - [x] Première étape `ar-1-t1-u1-e01` (T01 et T02), validée par `flutter test`
  - [x] Relecture des harakat de `ar-1-t1-u1-e01` par Lamjed, étape passée en statut valide le 17 oct. 2026
- [x] A0-09 Conventions d'écriture de l'arabe (0,5 j-h)
- [x] A0-10 Langue de l'interface et Directionality (1,5 j-h)
- [x] A0-11 Profils enfants (5 max) et base drift (2 j-h)
- [x] A0-12 Menu développeur (1,5 j-h)
- [x] A0-13 Lecteur d'exercice générique (4 j-h)
- [x] A0-14 Interfaces de plateforme injectées (1,5 j-h)
- [ ] A0-15 Aperçu web (apps/apercu_web) (0,75 j-h)
- [x] A0-16 Yasmina en placeholder (0,5 j-h)
- [ ] A0-17 Build de test sur téléphone (iPhone fait, Android à installer) (0,5 j-h)
  - [x] iPhone : build iOS réussi, app installée le 17 oct. 2026
  - [ ] Android : APK debug construit (`flutter build apk --debug`), pas encore installé sur un téléphone
- [ ] A0-18 Pilotage A0 (0,5 j-h)
- [x] A0-19 Design system Yasmina (artefact, depuis la démo) (1 j-h)
- [x] A0-20 ThemeYasmina appliqué à l'app et à l'aperçu web (1 j-h)
- [x] A0-21 Sons d'interface (5 sons, réglage, décision 35) (0,5 j-h)

## A1 : lot 1 des moteurs et retours familles, tour 1 (2 nov. au 31 déc. 2026)
- [x] A1-01a Moteur Choix : schéma, exemples et fiche (1 j-h)
- [x] A1-01b Moteur Choix (13 types), moteur : T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61 (3,5 j-h)
  - [x] T02 Vrai ou faux jouable dans l'atelier (preuve du lecteur, 19 oct. 2026)
  - [x] Les 12 autres types jouables dans l'atelier, un test de widget par type (arabe et latin), parité mobile et web (20 oct. 2026)
  - [ ] Goldens du moteur Choix (T01 en arabe, T45 en français, clair et sombre) : reportés à A1-15
- [x] A1-02 Moteur Glisser-déposer (10 types) : T06, T09, T11, T12, T13, T14, T15, T16, T56, T62 (6 j-h)
  - [x] Fiche en brouillon `docs/moteurs/glisser-deposer.md` et questions (décision 39, 20 oct. 2026)
  - [x] Schéma, validateur et 9 exemples pour T06, T09, T11, T12, T13, T14, T15, T16 (20 oct. 2026)
  - [x] Moteur : geste (glisser réel, toucher-toucher, aimant, retour animé, son et vibration), 8 types (T06, T09, T11, T12, T13, T14, T15, T16) jouables dans l'atelier (20 oct. 2026)
  - [x] T56 Racine et schème et T62 Frise chronologique : schéma, validateur, 3 exemples, moteur, tests, parité (après-midi du 20 oct. 2026, hypothèse de périmètre du mentor à valider : catalogue v3.1, 10 types)
  - [ ] Validation par Lamjed de la fiche, des 21 points tranchés et du test sur l'iPhone
- [x] A1-03 Moteur Texte (T07, T17) (2 j-h)
  - [x] Fiche en brouillon `docs/moteurs/texte.md`, schéma, validateur, 4 exemples, `comparerTextes` (soir du 20 oct. 2026)
  - [x] T07 mots touchables, T17 clavier arabe du moteur et champ système en latin, tests, parité (20 oct. 2026)
  - [ ] Validation par Lamjed de la fiche et test du clavier arabe sur l'iPhone
- [x] A1-04 Moteur Tracé (1,5 j-h)
  - [x] Fiche en brouillon `docs/moteurs/trace.md`, schéma, validateur, exemples ب ل م, moteur (formes en boutons, zone de tracé au doigt, guidage, Effacer, mode sans note), tests et parité (après-midi du 20 oct. 2026)
  - [x] Type Tracé de lettre retiré du MVP le 20 oct. 2026 au soir (décision de Lamjed après le test sur l'iPhone : l'écriture sur écran n'est pas fiable). Retiré du registre, de l'atelier, du schéma et des exemples embarqués dans la nuit du 20 au 21 oct., code gardé dans l'historique Git (commit `82b4c18`). Le MVP compte 52 types, le lot 1 en compte 35
- [x] A1-05 Moteur Saisie numérique, base (T22, T48) (2 j-h)
  - [x] Fiche en brouillon `docs/moteurs/saisie-numerique.md`, schéma, validateur, 3 exemples (soir du 20 oct. 2026)
  - [x] Pavé numérique du moteur, T22, T48 (sens des colonnes et chiffres configurables, retenues), tests, parité (20 oct. 2026)
  - [ ] Validation par Lamjed (disposition du calcul posé en arabe, chiffres) et test sur l'iPhone
- [x] A1-06 Moteur Manipulables, base (T25, T27, T51) (3 j-h)
  - [x] Fiche en brouillon `docs/moteurs/manipulables.md` et questions (après-midi du 20 oct. 2026, sens de la droite numérique configurable par `sens`)
  - [x] Schéma, validateur, un exemple par type (droite numérique, blocs base 10, cadre de 10), tests (20 oct. 2026)
  - [x] T25 Droite numérique jouable dans l'atelier : repère glissé avec aimant, graduation touchée, sens configurable, tests et parité (20 oct. 2026)
  - [x] T27 Blocs base 10 et T51 Cadre de 10 : réserve inépuisable, plateau canonique, cadre de deux lignes, tests, parité (soir du 20 oct. 2026)
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [x] A1-07 Moteur Scène image, base (T08, T47) (1,5 j-h)
  - [x] Fiche en brouillon `docs/moteurs/scene-image.md`, schéma (scène en emoji et formes, zones normalisées), validateur, 2 exemples (soir du 20 oct. 2026)
  - [x] Scène dessinée par le moteur, T08 zones touchables, T47 étiquettes glissées (affectation « zones »), tests, parité (20 oct. 2026)
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [x] A1-08 Moteur Révision et jeux (T36 à T38) (2,5 j-h)
  - [x] Fiche en brouillon `docs/moteurs/revision-jeux.md`, schéma, validateur, 4 exemples (soir du 20 oct. 2026)
  - [x] T36 flashcards sans note, T37 memory automatique noté par les essais, T38 mots mêlés (lettres isolées, lecture de droite à gauche en arabe), tests, parité (20 oct. 2026)
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [ ] A1-09 Vérification du framework sur le prototype (glisser-déposer arabe, harakat, Rive, Android 2 Go) (2 j-h)
- [ ] A1-15 Tests de parité et golden (1 j-h)
- [ ] A1-16 Build distribué aux familles (TestFlight, Play) (0,5 j-h)
- [ ] A1-17 Grille d'observation et questionnaire parent (0,5 j-h)
- [ ] A1-18 Synthèse des retours, tour 1 (0,5 j-h)
- [ ] A1-19 Design system et maquettes, partie 1 (designer, part du système Yasmina) (4 j-h)
- [ ] A1-20 Yasmina : brief et 6 états (illustrateur) (2,5 j-h)
- [ ] A1-21 Pilotage A1 (1,5 j-h)
- [x] A1-22 Séquence de test pour le tour 1 des familles (exercices enchaînés, sans carte) (0,75 j-h)
  - [x] Bouton « Jouer » de l'accueil, écran des séries, série jouée dans le lecteur avec la progression, bilan de Yasmina, retour (nuit du 20 au 21 oct. 2026)
  - [x] `apps/mobile/assets/sequences/tour-1.json` : une série par moteur, tous les exemples du catalogue, modifiable sans code, contrôlé par `test/sequences/`
  - [ ] Lamjed : trier les séries pour le tour 1 (plus courtes, 1re année d'abord), relire les titres arabes, tester sur l'iPhone

## A2 : lot 2 des moteurs et retours familles, tour 2 (4 janv. au 28 févr. 2027)
- [x] A2-01 Moteur Saisie numérique, avancée (T49, T50, T63) (2 j-h)
  - [x] Fiche §14 de `docs/moteurs/saisie-numerique.md` et questions 9 à 11 (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur, 3 exemples en brouillon (1/4 + 2/4, compléments à 10 en 30 s, sac de 5)
  - [x] T49 deux cases et pavé, T50 chronomètre et trois réponses sans note, T63 balance qui penche selon la saisie, tests arabe et français, parité
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [x] A2-02 Moteur Manipulables, avancés (T26, T29, T52) (3 j-h)
  - [x] Fiche §14 de `docs/moteurs/manipulables.md` et questions 12 à 18 (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur, 3 exemples en brouillon (monnaie 2 dinars 700 millimes, trois quarts d'un disque, comparaison de deux barres)
  - [x] T26 pièces glissées dans le porte-monnaie et glissées hors pour retirer, T29 parts touchées, T52 nombres glissés dans les segments puis inconnue au pavé, tests arabe et français avec un vrai geste, parité
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [x] A2-03 Moteur Mesure et temps (T28, T30) (2,5 j-h)
  - [x] Fiche en brouillon `docs/moteurs/mesure-temps.md` et questions (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur, 2 exemples en brouillon (6 h 30, crayon de 7 cm)
  - [x] T28 aiguilles déplacées au doigt (aimant au pas, l'heure suit les minutes), T30 longueur lue et écrite au pavé, tests arabe et français avec un vrai geste, parité
  - [ ] Validation par Lamjed de la fiche et test du geste sur l'iPhone
- [x] A2-04 Moteur Grille et graphiques (T31 à T33, T60) (3,5 j-h)
  - [x] Fiche en brouillon `docs/moteurs/grille-graphiques.md` et questions (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur, 4 exemples en brouillon (fruits préférés, 3 barres, symétrie 6 × 8, chemin 5 × 5)
  - [x] `GraphiqueBarres` partagé, T31 barre touchée, T32 cellules touchées, T33 cases du quadrillage, T60 programme de flèches joué pas à pas, tests arabe et français, parité
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [x] A2-05 Moteur Scène image avec audio (T53, T54) (1,5 j-h)
  - [x] Fiche §14 de `docs/moteurs/scene-image.md` et questions 9 à 12 (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur, 2 exemples en anglais en brouillon (le chat sous la table, le ballon rouge)
  - [x] T53 un seul toucher sur l'emplacement, T54 couleur puis objet en grandes icônes avec le nom, tests anglais, arabe et français, parité
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone (voix anglaise)
- [x] A2-06 Moteur Simulateur (T34, T57) (3 j-h)
  - [x] Fiche en brouillon `docs/moteurs/simulateur.md` et questions (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur, 2 exemples en brouillon (flotte ou coule dans la cuve, matériaux conducteurs)
  - [x] T57 générique (deux issues, objets, décor eau, circuit ou aucun), T34 en instance au décor eau, prédire puis observer en mode automatique, tests arabe et français, parité
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [x] A2-07 Moteur Récit (T35) (1,5 j-h)
  - [x] Fiche en brouillon `docs/moteurs/recit.md` et questions (nuit du 20 au 21 oct. 2026)
  - [x] Schéma, validateur (un seul choix juste par étape, un pourquoi par mauvais choix), 1 exemple en brouillon (Nour va à l'école)
  - [x] Étapes enchaînées dans la zone, mauvais choix expliqué puis repris, sans note, tests français et arabe, parité
  - [ ] Validation par Lamjed de la fiche et test sur l'iPhone
- [ ] A2-08 Corrections issues du tour 1 (1 j-h)
- [ ] A2-09 Retours familles, tour 2 (1 j-h)
- [ ] A2-10 Design system et maquettes, partie 2 (designer) (5 j-h)
- [ ] A2-11 Yasmina : animations Rive (illustrateur) (5 j-h)
- [ ] A2-12 Pilotage A2 (1,5 j-h)

## A3 : parcours et espace parent (1er au 14 mars 2027)
Après la validation des 52 types dans l'atelier (décision 37) : le parcours, la progression et l'espace parent, déplacés de A1 (anciennes A1-10 à A1-14).
- [ ] A3-01 Choix de l'enfant et de la matière, carte du trimestre (2 j-h)
- [ ] A3-02 Intro d'étape, séquences, écran de résultat (2 j-h)
- [ ] A3-03 Progression locale (1,25 j-h)
- [ ] A3-04 Espace parent local (2,5 j-h)
- [ ] A3-05 Simulation essai et abonnement (0,5 j-h)

## B : back-end, back-office et pilote de contenu (15 mars au 30 avril 2027)
- [ ] B-01 Back-end : schéma Supabase et RLS (3 j-h)
- [ ] B-02 Back-end : Edge Functions (OTP, droits, clés) (3,5 j-h)
- [ ] B-03 Connexion par code simulée en développement (1,5 j-h)
- [ ] B-04 Téléchargement à priorités et journal persistant (4 j-h)
- [ ] B-05 Packs chiffrés et synchronisation (3 j-h)
- [ ] B-06 Back-office : base, comptes, droits (4 j-h)
- [ ] B-07 Back-office : écran de relecture et formulaire par gabarit (5 j-h)
- [ ] B-08 Back-office : publication et construction des packs (2,5 j-h)
- [ ] B-09 Pipeline dans le Projet Claude (registre anti-doublon, HTML de validation, GitHub) (4 j-h)
- [ ] B-10 Outil de validation pour le LLM (edu_content:valider) (0,5 j-h)
- [ ] B-11 Médias et packs du pipeline (3,25 j-h)
- [ ] B-12 Pilote de contenu arabe 1re T1 (go ou no-go) (2 j-h)
- [ ] B-13 Relecture du pilote (1,5 j-h)
- [ ] B-14 Pilotage B (1,5 j-h)

## C : bêta et paiements (mai et juin 2027)
- [ ] C-01 Couche jeu complète (pièces, avatar, compagnon, album) (3 j-h)
- [ ] C-02 Temps d'écran et paramètres parent (2 j-h)
- [ ] C-03 Paiements (Konnect, Flouci, D17, RevenueCat, codes prépayés, parrainage) (6 j-h)
- [ ] C-04 Site web (landing, paiement, activation) (3 j-h)
- [ ] C-05 n8n et WhatsApp (OTP, workflow d'essai, rapports) (4 j-h)
- [ ] C-06 Analytics internes, Sentry, tableaux de bord (1,5 j-h)
- [ ] C-07 Bêta auprès de 150 familles (3 j-h)
- [ ] C-08 Relecture du contenu de la bêta (3,5 j-h)
- [ ] C-09 Ajustements UX après la bêta (designer) (2,5 j-h)
- [ ] C-10 Pilotage C (1,25 j-h)

## D : contenu T1 et lancement (juillet et août 2027)
- [ ] D-01 Contenu T1 des 26 combinaisons (4 j-h)
- [ ] D-02 Relecture du contenu T1 (7,5 j-h)
- [ ] D-03 Publication stores, conformité, déclaration INPDP (2 j-h)
- [ ] D-04 Recette finale avant lancement (1,75 j-h)
- [ ] D-05 Pilotage D (1,25 j-h)

## Blocages
- À vérifier sur l'iPhone (soir du 20 oct. 2026) : le clavier arabe du moteur (T17, touches de 48 dp, trois rangées qui tiennent en largeur), le champ système en français (T17, aucune suggestion), le pavé numérique et le calcul posé (T48), la scène dessinée et le glisser d'une étiquette sur une zone (T47), le memory et les mots mêlés (lettres isolées, sens de lecture).
- Questions en attente (manuels) : disposition du calcul posé en arabe et chiffres (T48, `sens` et `chiffres` dans le JSON), sens de lecture des mots mêlés en arabe (T38, `sens`), ordre des touches du clavier arabe (T17, alphabétique).
- À valider (périmètre du moteur Glisser-déposer, après-midi du 20 oct. 2026) : hypothèse du mentor appliquée, le catalogue v3.1 fait foi sur la décision 3 : T39 hors MVP, T26 et T27 au moteur Manipulables, T56 et T62 au moteur Glisser-déposer (10 types, tous jouables). Voir `docs/moteurs/glisser-deposer-questions.md`, point 15.
- À vérifier sur l'iPhone (après-midi du 20 oct. 2026) : le schème de T56 construit lettre à lettre (« فَاعِلٌ » lié, harakat en place), la frise de T62 qui défile en largeur au-delà de 6 cases, le glisser du repère de T25 avec l'aimant.
- Question en attente (manuels) : le sens de la droite numérique en arabe. Le JSON de T25 porte `sens` (`gauche-droite` par défaut, `droite-gauche`), le moteur suit le JSON : le défaut se change en une ligne.
- À vérifier sur l'iPhone (glisser-déposer) : le vrai glisser dans une liste qui défile (la page du lecteur est un `SingleChildScrollView` : le glisser vertical d'une tuile ne doit pas faire défiler la page), le retour animé, l'aimant, et la liaison des lettres dans la zone du mot de T15.
- À vérifier sur l'iPhone (moteur Choix, 20 oct. 2026) : en T19 forme mot, la lettre cible est colorée en bleu par un span séparé du même texte. Contrôler que ت reste liée à ses voisines (كُتُبٌ) dans Noto Naskh. Sinon, colorer le mot entier.
- À vérifier sur l'iPhone : `AudioMobile` attend désormais la fin de la synthèse (`awaitSpeakCompletion`) pour enchaîner la consigne puis le mot à écouter (T03, T55, T01 orthographe, T19). Contrôler que la réécoute de la consigne coupe bien le mot en cours.
- Aperçu web : joue l'exemple choisi dans une liste déroulante (13 types du moteur Choix), en mode aperçu, avec les services factices. Le chargement d'un JSON par fichier ou `postMessage` reste à faire (A0-15).
- À suivre (menu développeur, CLAUDE.md §7) : la « progression d'exemple » du profil de test Lina viendra avec la progression locale (A3-03). Le JSON de l'exercice en cours est affiché dans l'atelier, sous le lecteur et son journal.
- Résolu le 20 oct. 2026 (moteur Choix) : tout texte court lu par l'enfant en français ou en anglais (affirmation, texte des propositions) passe en `latin-prompt` (20 px). `latin-body` reste pour les textes longs à lire (T45, T46, T61), choix.md §9 mis à jour.
- À savoir : dans les tests et les goldens, les emoji s'affichent en carré (le moteur de test n'a pas de police emoji). Sur l'appareil et dans le navigateur, ils s'affichent normalement.
- Aperçu web : services factices (aucune voix, aucun son) jusqu'à l'implémentation web des services (A0-15).
- Sons d'interface (décision 35) : fichiers provisoires générés par `packages/moteur_exercices/tool/generer_sons.dart` (WAV mono 16 bits, courts, volume bas). Les fichiers définitifs se déposent dans `packages/moteur_exercices/assets/sons/` sous le même nom, en WAV PCM 16 bits mono, sans changer le code (le test `sons_test.dart` contrôle format, durée et crête).
- À vérifier sur l'iPhone : les sons utilisent la catégorie audio iOS `ambient` (coupés par le bouton silencieux). La session audio est partagée avec flutter_tts : contrôler que la consigne reste lue après un son, et ce qui se passe en mode silencieux.
- Résolu le 17 oct. 2026 : build Android bloqué par le disque plein. Espace libéré, `flutter build apk --debug` réussi.
- Risques à suivre sur `flutter_tts` (warnings au build, pas bloquants aujourd'hui) :
  - iOS : pas encore de support Swift Package Manager (CocoaPods utilisé). Flutter annonce que cela deviendra une erreur dans une version future.
  - Android : warning sur le Kotlin Gradle Plugin (KGP) appliqué par le plugin. Même risque : à surveiller à chaque montée de version de Flutter ou d'AGP, mettre à jour `flutter_tts` ou chercher une alternative si le warning devient une erreur.
- Contrainte : `package:test` ne peut pas entrer dans le workspace (le `test_api` épinglé par Flutter et l'`analyzer` exigé par `build_runner` 2.16.2 sont incompatibles). Les tests du package `schema` utilisent donc `flutter_test`. À revoir quand `build_runner` sera relâché.

- Risque à suivre (aperçu web) : nos polices sont embarquées, mais le moteur web de Flutter charge encore par défaut CanvasKit et ses polices de secours depuis les CDN de Google (`gstatic.com`). À traiter avec la tâche A0-15 (`--no-web-resources-cdn` et thème de l'aperçu) si l'aperçu doit marcher hors ligne.
- Taille : les polices ajoutent environ 2,1 Mo à l'app (Andika fait 1,3 Mo à elle seule, car elle couvre beaucoup d'écritures). Un sous-ensemble pourra être produit avant la publication.
- Résolu le 17 oct. 2026 : double bonjour de l'accueil. La bulle de Yasmina porte le bonjour, la ligne du dessous devient « هَيَّا نَتَعَلَّمُ مَعًا. » ou « On apprend ensemble. » (textes validés par Lamjed).
- Point de design à trancher (tokens.json) : en thème sombre, `ink` devient clair et ne fait que 1,4:1 sur `sun` (étape ouverte de la carte). La démo écrit les étapes et les cartes de matière en #16243A fixe, absent des jetons. Proposition : un jeton `ink-fixed` (ou `on-pastel`) identique dans les deux thèmes, à ajouter à l'artefact avant la carte du trimestre (A3-01).
- À noter : `on-accent` sur `olive` ne fait que 4,05:1 en clair. Acceptable en grand texte gras (bouton Continuer en 22 gras, testé à 3:1), jamais en petit texte.
- Contrôle visuel de l'aperçu web dans Chrome (clair et sombre) pas fait par Claude Code (Chrome non utilisé à la demande de Lamjed) : à faire par Lamjed.
- Goldens générés sur macOS : ils peuvent différer sur une autre machine ou une CI Linux (polices et rendu). À régénérer sur la machine de référence si besoin.

## Journal
| Date | Session | Fait | Suite |
|---|---|---|---|
| 17 oct. 2026 | Cadrage (mentor) | Plan mis à jour pour prioriser le prototype mobile, CLAUDE.md et PROGRESS.md créés. Règle : même moteur pour l'app et l'aperçu du back-office dès A0 | A0 : vérifier le poste, créer le dépôt et le projet Flutter |
| 17 oct. 2026 | Mise en place (Lamjed) | Flutter 3.47.7 installé, licences Android acceptées, dépôt yasmina-app créé, CLAUDE.md et PROGRESS.md ajoutés | A0 : créer le projet Flutter et la structure avec Claude Code |
| 17 oct. 2026 | A0 structure (Claude Code) | Pub workspace (moteur_exercices, apps/mobile `tn.forgia.yasmina`, apps/apercu_web), widget CarteDemo partagé avec tests arabe et français, dossiers schema et docs, `tool/verifier.sh` vert, build iOS debug OK. Dépendances ajoutées : flutter_riverpod 3.4.3, go_router 18.1.0, freezed 4.0.2, freezed_annotation 3.1.0, json_serializable 6.14.1, json_annotation 4.12.0, drift 2.35.2, drift_flutter 0.3.1, drift_dev 2.35.1, flutter_tts 4.2.5, flutter_localizations et intl 0.20.3, flutter_lints 6.0.0, build_runner épinglé en 2.16.2 (2.17.1 exige build 5, pas encore suivi par freezed, json_serializable, drift_dev). `.gitignore` remplacé (l'ancien ignorait pubspec.lock). Build Android bloqué par le disque plein | Libérer de l'espace et relancer le build Android, puis schéma edu-content/1.0 et validateur |
| 17 oct. 2026 | Builds de test (Lamjed et Claude Code) | Espace disque libéré, build Android debug réussi (APK construit, pas encore installé), build iOS réussi et app installée sur l'iPhone de Lamjed. Warning KGP de `flutter_tts` côté Android ajouté aux risques. Xcode a mis à jour le format de `project.pbxproj` (objectVersion 60) | Installer l'APK sur un téléphone Android, puis schéma edu-content/1.0 et validateur |
| 17 oct. 2026 | A0 schéma et validateur (Claude Code) | Schéma `schema/edu-content-1.0.schema.json` (draft 2020-12, T01, T02 et T05 détaillés, consigne et feedbacks genrés, id stables), compilé sans avertissement par ajv 8. Package Dart pur `edu_content` dans `schema/` : validateur (messages en français, chemin JSON Pointer), règles métier, 27 tests sur la VM et dans Chrome. Première étape embarquée `ar-1-t1-u1-e01` (brouillon), validée par `flutter test` côté mobile. `tool/verifier.sh` étendu au package schema. Maquettes `docs/reference/` ajoutées. Dépendances ajoutées : json_schema 5.2.2 (entraîne http, quiver, uri), en dev dans schema : flutter_test et flutter_lints 6.0.0, en dev dans apps/mobile : edu_content (workspace) | Relire les harakat de `ar-1-t1-u1-e01`, installer l'APK sur Android, puis langue de l'interface et `Directionality` |
| 17 oct. 2026 | Relecture du contenu (Lamjed et Claude Code) | Lamjed a relu les textes arabes de `ar-1-t1-u1-e01` et fixé 2 conventions : alif de liaison avec kasra en début de phrase, alif suscrit simplifié (aucun U+0670). Consigne de x02 corrigée (هٰذِهِ devient هَذِهِ, seul U+0670 remplacé par U+064E), x01 et x02 en statut valide, empreinte de x02 recalculée. Avertissement `alif_suscrit` ajouté au validateur (30 tests). `docs/conventions-arabe.md` créé. Aucune dépendance ajoutée | Installer l'APK sur Android, puis langue de l'interface et `Directionality` |
| 17 oct. 2026 | Suivi (Claude Code) | Bloc « Avancement » ajouté en tête de PROGRESS.md (% par phase, % global pondéré par les semaines, types jouables), la ligne des types jouables quitte « État global » pour éviter un doublon. Conventions arabes imposées dans CLAUDE.md §5. Aucune dépendance ajoutée | Installer l'APK sur Android, puis langue de l'interface et `Directionality` |
| 17 oct. 2026 | A0 langue de l'interface (Claude Code) | Avancement passé en jours-homme (`docs/estimations-taches.md`, listes de PROGRESS.md réécrites, `tool/avancement.dart` vérifié par `verifier.sh`). Langue de l'interface : première langue arabe ou française de l'appareil, sinon arabe, enregistrée au premier lancement, modifiable dans les réglages (Riverpod, shared_preferences). Textes en ARB via gen-l10n (ar, fr), `CFBundleLocalizations` iOS. `LangueExercice` dans le moteur : sens, locale et police de l'exercice indépendants de l'interface. Accueil et réglages (go_router). Polices embarquées : Noto Naskh Arabic (exercices), Baloo Bhaijaan 2 (interface arabe), Andika (français). Goldens de l'accueil en ar et en fr. Dépendance ajoutée : shared_preferences 2.5.6 (fontTools 4.55.3 utilisé hors dépôt pour produire les polices statiques) | Installer l'APK sur Android, puis profils enfants et base drift (A0-11) |
| 17 oct. 2026 | A0 profils enfants (Claude Code) | Harakat de l'interface corrigées (الْإِعْدَادَاتُ, الْعَرَبِيَّةُ), convention C (soukoun sur le lam devant une lettre lunaire, kasra devant un alif de liaison) dans docs et CLAUDE.md, avertissement `lam_sans_soukoun` au validateur et au test des ARB. `FormeAdresse` dans le moteur. Base drift v1 (`base_yasmina.drift` : profils, historique des niveaux, index partiel, déclencheur des 5 profils, clés étrangères, instantané de migration et test). Dépôt des profils (limite, historique daté, persistance testée). 8 avatars placeholder (icônes Material, nuage à la place de l'oiseau). Écrans : création directe sans profil, accueil direct avec un profil, choix à partir de deux, formulaire de création et modification, suppression confirmée. Goldens du choix et de l'accueil. `flutter build apk --debug` et build iOS réussis, SQLite embarqué par les hooks de sqlite3. Aucune dépendance ajoutée | Relire « سَحَابَةٌ » (avatar nuage), installer l'APK sur Android, puis menu développeur (A0-12) |
| 17 oct. 2026 | A0 ThemeYasmina (Claude Code) | `docs/design-system/` commité (sans le zip, supprimé). PROGRESS.md aligné sur les estimations de 19 h (A0-19, A0-20, A1-19 à 8 j-h), `tool/avancement.dart` contrôle chaque tâche (id et j-h). Graisses 600 et 800 des polices arabes. `tool/generer_theme.dart` génère les jetons depuis `tokens.json` (couleurs clair et sombre, styles, espacements, rayons, traits, tailles, ombres) et copie les SVG de Yasmina, test de synchro. `ThemeYasmina` clair et sombre (suit l'appareil), tests de contraste. Composants du moteur : `BoutonYasmina`, `BoutonIcone`, `Yasmina` et `YasminaBulle` (statiques, A0-16 reste ouverte pour les animations avec le lecteur). App : accueil avec Yasmina, grille de `CarteProfil` et carte d'ajout pointillée, avatars au style de la démo, formulaire thémé. Aperçu web thémé (cadre en jetons). Garde-fou `tool/garde_design.dart` dans `verifier.sh` (aucune valeur en dur, exception `// design-ok`). 8 goldens (ar, fr, clair, sombre). `flutter build apk --debug`, build iOS et build web réussis. Dépendances ajoutées : flutter_svg 2.3.0 dans le moteur (entraîne vector_graphics, vector_graphics_codec, vector_graphics_compiler, xml, path_parsing, petitparser), flutter_localizations en dev dans le moteur (tests en arabe) | Contrôle visuel de l'aperçu web par Lamjed, jeton `ink-fixed` à trancher, installer l'APK sur Android, puis menu développeur (A0-12) |
| 19 oct. 2026 | A1-01a moteur Choix, préparation (Claude Code) | Jetons régénérés depuis tokens.json v7 (ink-fixed, styles feedback et listen, marges listen et feedback, icon-md, icon-listen), test de contraste de ink-fixed. Branche `proposition/moteur-choix` : schéma edu-content/1.0 détaillé pour les 13 types du moteur Choix (emoji à côté de image, support complet de T01, T19 en deux formes dont `lettre-vocalisee`), règles du validateur et tests, 17 exemples en emoji dans `schema/exemples/choix/`, fiche `docs/moteurs/choix.md` validée et réponses de Lamjed dans `choix-questions.md`. A1-01 découpée en A1-01a (fait) et A1-01b, ordre « atelier d'abord » inscrit (décision 34), `tool/avancement.dart` accepte les id à lettre (A1-01a). Branche fusionnée dans main. Aucune dépendance ajoutée | Menu développeur et atelier (A0-12), puis moteur Choix (A1-01b) |
| 19 oct. 2026 | A0-12 menu développeur et atelier (Claude Code) | Exemples de `schema/exemples/` générés dans `edu_content` (`tool/generer_exemples.dart`, `exemplesEduContent`, test de synchro) : une seule source pour l'app, l'aperçu web et les tests, sans asset ni `dart:io`. Moteur : registre des 53 types (12 moteurs dans l'ordre de développement, lot, état, tous à venir), `ModeExercice`, `CatalogueExemples` (chaque exemple validé au premier accès, erreurs affichables sans exception). App : menu développeur par appui long sur le titre des écrans racine, en debug et en profile seulement (redirection en release), toujours en français : atelier, profils de test Lina et Yassine sans doublon, réinitialisation confirmée, abonnement simulé et « tout débloquer » enregistrés sans effet. Atelier : types groupés par moteur avec jouables sur total, écran d'un type et de ses exemples (consigne dans la langue de l'exercice), écran d'un exemple (mode, `ZoneLecteur` comme seul point de branchement du lecteur, JSON formaté). `flutter build apk` debug et release réussis. Dépendance ajoutée : edu_content (workspace) dans moteur_exercices | Lecteur d'exercice générique (A0-13), puis moteur Choix (A1-01b) |
| 19 oct. 2026 | A0-13 lecteur, A0-14 plateforme, A0-16 Yasmina (Claude Code) | Services de plateforme injectés dans le moteur (audio, vibration, assets, factices exportés), implémentation mobile (`AudioFlutterTts` sans plantage si aucune voix, `VibrationHaptique`). Yasmina saute (bravo) et se penche (encourage), sans mouvement si l'appareil le demande (`mouvements_yasmina.dart`, seule source). `BandeauFeedback` (goldens clair et sombre) et `TuileChoix`. Lecteur générique : `DerouleExercice` en Dart pur (modes vérifier, automatique et sans note), contrat `GabaritReponse` et `ControleurReponse`, libellés genrés en arabe, consigne lue à l'ouverture, feedback en 3 temps, aperçu (afficher la réponse, Rejouer) et édition (rechargement), événements. T02 Vrai ou faux jouable (premier type), branché dans l'atelier avec mode, forme, journal des événements et avertissement de voix absente. `flutter build apk --debug` et build iOS réussis. Aucune dépendance ajoutée (flutter_tts déjà déclaré) | Essayer T02 sur l'iPhone (voix arabe), aperçu web (A0-15), puis les 12 autres types du moteur Choix (A1-01b) |
| 20 oct. 2026 | Sons d'interface, décision 35 (Claude Code) | `SonInterface` (juste, essaiFaux, revelee, depot, finEtape) et `ServiceAudio.jouerSon` dans le moteur, sons provisoires WAV générés par un script du dépôt (notes douces, courts, volume bas, essai faux jamais un buzzer), test du format. Le lecteur joue juste, essaiFaux et revelee aux 3 temps du feedback (mode vérifier et automatique, rien sans note). Mobile : `SonsAudioplayers` (basse latence, volume 0,4, catégorie iOS ambient, usage Android sonification), `AudioFlutterTts` devient `AudioMobile` (voix et sons). Menu développeur : interrupteur « Sons des effets » (activé par défaut, enregistré). Textes courts du moteur Choix en latin-prompt (commit séparé). `flutter build apk --debug` et build iOS réussis. Dépendance ajoutée : audioplayers 6.8.1 dans apps/mobile (compatible web, entraîne audioplayers_android, audioplayers_darwin, audioplayers_web, audioplayers_linux, audioplayers_windows, audioplayers_platform_interface et synchronized) | Écouter les sons et la consigne sur l'iPhone (mode silencieux compris), aperçu web (A0-15), puis moteur Choix (A1-01b) |
| 20 oct. 2026 | Replanification, décision 37 (Claude Code, session sans surveillance) | Branche `plan/replanification`. `docs/estimations-taches.md` : toutes les tâches non faites à la moitié du plan (colonne j-h en vigueur, colonne Plan gardée), A0-21 sons d'interface (0,5, fait), A1-22 séquence de test du tour 1 (0,75), A1-10 à A1-14 devenues A3-01 à A3-05 dans la phase A3 « Parcours et espace parent » (1er au 14 mars 2027), phase B du 15 mars au 30 avril 2027. Total en vigueur 182,25 j-h (345,25 au plan), calcul tombé juste tâche par tâche. `tool/avancement.dart` lit les tableaux par leur en-tête (colonne Plan ignorée), affiche A3 et contrôle les totaux déclarés, testé par `test/avancement_test.dart` à la racine (nouvelle étape de `verifier.sh`). Jalons G1, G2 et G3 reformulés. Dépendance ajoutée : flutter_test (SDK) en dev à la racine du workspace, pour ce test | Moteur Choix, 12 types restants (A1-01b), puis moteur Glisser-déposer (A1-02) |
| 20 oct. 2026 | A1-01b moteur Choix (Claude Code, session sans surveillance) | Branche `moteur/choix-a1-01b`. Lecteur : graine de mélange dans `ConfigExercice`, demandes d'audio des zones (`ControleurReponse.demanderAudio`, mot d'ouverture dit après la consigne), `AudioMobile` attend la fin de la synthèse. `TuileChoix` barrée ou grande, `BoutonEcouter` (variante listen). Moteur Choix : `SelectionChoix`, `GrilleChoix`, `GabaritChoix` (T01, T03, T04, T05, T18, T19 lettre vocalisée, T24, T45, T55, T61), `GabaritHaraka` (T19 forme mot), `GabaritComparer` (T23), `GabaritJustification` (T46). Les 13 types jouables dans l'atelier. 45 tests de widget (un cas arabe et un cas latin par type, fixtures arabes en brouillon), test de parité dans le moteur et dans l'aperçu web, qui joue les exemples du catalogue. Un commit rouge (2 tests de l'atelier) détecté après coup et amendé. Aucune dépendance ajoutée | Essayer les 13 types sur l'iPhone (fiche de test de `docs/sessions/2026-10-20.md`), puis moteur Glisser-déposer (A1-02) |
| 20 oct. 2026 | Fin du lot 1, tâches 7 à 11 (Claude Code, session sans surveillance, soir) | Branches `moteur/manipulables-t27-t51`, `moteur/texte`, `moteur/saisie-numerique`, `moteur/scene-image`, `moteur/revision-jeux`. T27 et T51 (matériel dessiné, réserve inépuisable). Moteur Texte : fiche, T07 mots touchables, T17 clavier arabe du moteur ou champ système, `comparerTextes` et ses normalisations testées. Moteur Saisie numérique : fiche, pavé numérique, T22, T48 (sens, chiffres, retenues configurables). Moteur Scène image : fiche, scène en emoji et formes, T08 zones touchables, T47 étiquettes (affectation « zones »). Moteur Révision et jeux : fiche, T36 sans note, T37 automatique, T38 mots mêlés. Un vérificateur par commit, un commit amendé (fait d'abord sur un lint rouge). Dépendance ajoutée : flutter_localizations (SDK) dans apps/apercu_web (localisation Material du champ système de T17) | Lamjed : fiche de test du soir, valider les 6 fiches en brouillon, puis A1-09 (vérification du framework), A1-15 (parité et goldens), A1-22 (séquence de test) |
| 20 oct. 2026 | A1-02 moteur Glisser-déposer, T56 et T62 (Claude Code, session sans surveillance, après-midi) | Branche `moteur/glisser-deposer-t56-t62`. Hypothèse de périmètre du mentor (catalogue v3.1, 10 types). Schéma et validateur : `donneesFrise` (date facultative), `donneesRacineScheme` (mot, forme, emplacements avec haraka nommée, lettres nues), règles `lettre_invalide`, `haraka_hors_scheme`, `scheme_longueur`, `scheme_harakat_differentes`, `racine_hors_mot`. 3 exemples en brouillon. Moteur : contrôleur d'ordre à capacité, tuile avec date, frise à cases fixes avec ligne du temps peinte, gabarit Racine et schème (racine en lettres isolées, schème lié avec les harakat des emplacements). 5 tests de widget avec un vrai geste, parité à 10 types, fiche et 7 points tranchés. Aucune dépendance ajoutée | Valider le périmètre et les points tranchés, test du soir sur l'iPhone |
| 20 oct. 2026 | A1-04 moteur Tracé, T20 (Claude Code, session sans surveillance, après-midi) | Branche `moteur/trace`. Fiche `docs/moteurs/trace.md` en brouillon (11 points tranchés, 8 questions). Schéma `donneesTrace` (lettre, formes avec glyphe, position et traits de guidage normalisés, nom de la lettre), `reponseTrace` (formes à tracer), 6 règles, exemples ب ل م avec traits faits main. Moteur en mode sans note : formes en boutons sans sous-titre, zone de tracé 3 : 2 avec la lettre en naskh, points et flèches dans le sens d'écriture, encre au doigt, Effacer par forme (libellé genré), tolérance d'un quart de largeur, le lecteur verrouille la zone après Continuer. 4 tests de widget avec un vrai geste, parité moteur et aperçu web. Aucune dépendance ajoutée | Relire les traits avec un enseignant, tester le geste sur l'iPhone |
| 20 oct. 2026 | A1-06 moteur Manipulables, base, étapes a et b et c1 (Claude Code, session sans surveillance, après-midi) | Branche `moteur/manipulables-base`. Fiche `docs/moteurs/manipulables.md` en brouillon (8 points tranchés, 6 questions, sens de la droite configurable). Schéma et validateur pour T25 (`min`, `max`, `pas`, `reperes`, `cible`, `sens`), T27 (`cible`, `canonique`), T51 (`cible`), réponses explicites contrôlées contre la cible, 3 exemples en brouillon, 23 tests du schéma. T25 jouable : droite peinte de gauche à droite, repère glissé avec aimant ou graduation touchée, retour au départ après le 1er essai faux, 3 tests de widget, parité. Aucune dépendance ajoutée | Moteur des 3 types (A1-06, étape c2 : T27 et T51), puis moteur Texte (A1-03) |
| 20 oct. 2026 | A1-02 moteur Glisser-déposer, étapes a, b et c (Claude Code, session sans surveillance, décision 39) | Branche `proposition/moteur-glisser-deposer`. Fiche en brouillon `docs/moteurs/glisser-deposer.md` (8 types en 5 interactions) et 14 points tranchés seul dans `glisser-deposer-questions.md`. Schéma, 14 règles du validateur, 9 exemples en brouillon (`schema/exemples/glisser-deposer/`), 55 tests. Moteur : `TuileGlissable` (glisser réel, toucher-toucher, retour animé), `ZoneDepot` (pointillé, aimant), contrôleurs d'affectation et d'ordre, son `depot` et vibration, seuls les éléments faux reviennent après le 1er essai (`ControleurReponse.retirerFaux`). T06, T09, T11, T12, T13, T14, T15, T16 jouables dans l'atelier, 20 tests de widget avec un vrai geste, parité mobile et web. T26, T27 (Manipulables dans le registre), T39 (gabarit de T06), T56 et T62 non traités : à trancher. Compte rendu `docs/sessions/2026-10-20.md`. Aucune dépendance ajoutée | Lamjed : fiche de test du soir, valider la fiche du glisser-déposer et les points tranchés, puis moteur Tracé (A1-04) |
