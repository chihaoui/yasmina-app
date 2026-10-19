# PROGRESS.md : suivi du développement

<!-- avancement:debut -->
## Avancement
Au 19 oct. 2026. Bloc calculé par `dart run tool/avancement.dart`, ne pas modifier à la main.

| Phase | j-h faits | j-h total | % |
|---|---|---|---|
| A0 | 18 | 24,5 | 73 % |
| A1 | 1 | 86,5 | 1 % |
| A2 | 0 | 61 | 0 % |
| B | 0 | 78,5 | 0 % |
| C | 0 | 59,5 | 0 % |
| D | 0 | 33 | 0 % |
| **Total** | **19** | **343** | **5,5 %** |

- **Avancement global : 5,5 %** (19 j-h faits sur 343)
- **Types jouables : 1 sur 53**
- Méthode : une tâche compte seulement quand sa case de premier niveau est cochée (une tâche en cours compte 0). % d'une phase = j-h des cases cochées ÷ j-h de la phase. % global = j-h cochés ÷ total, contrôlé par rapport à `docs/estimations-taches.md`. Types jouables = codes Txx des cases cochées des phases A1 et A2. Les sous-cases détaillent une tâche et ne portent pas d'estimation.
<!-- avancement:fin -->

Mis à jour par Claude Code à la fin de chaque session, relu par Lamjed et par le mentor. Les dates suivent le plan de développement du 17 octobre 2026.

## État global
- Phase en cours : **A0, mise en place du prototype mobile** (19 octobre au 1er novembre 2026)
- Prochain point de décision : **R1, 15 novembre 2026** (vitesse réelle avec Claude Code, décision sur le renfort freelance)
- Framework : **Flutter 3.47.7** (décidé le 17 octobre 2026), poste vérifié par `flutter doctor` sans erreur
- Dépôt : https://github.com/chihaoui/yasmina-app (privé), dossier local `/Users/chihaoui/Documents/Forgia/Yasmina`

## Ordre de développement (décision 34, 19 oct. 2026)
**Atelier d'abord.** Les 12 moteurs et les 53 types du MVP sont développés et validés dans l'atelier du menu développeur (chaque type jouable seul, contenu statique) avant le parcours. Ordre des moteurs :
1. Choix (A1-01b)
2. Glisser-déposer (A1-02)
3. Tracé (A1-04)
4. Manipulables (A1-06)
5. Autres moteurs du lot 1 (Texte, Saisie numérique, Scène image, Révision et jeux)
6. Lot 2 (phase A2)

Le parcours (choix de la matière, carte du trimestre, intro d'étape, résultat) et l'espace parent viennent après le 53e type validé.

## Jalons
| Jalon | Date | Critère | État |
|---|---|---|---|
| R1 | 15 nov. 2026 | Vitesse mesurée sur 2 semaines, décision freelance | À venir |
| G1 | 31 déc. 2026 | Lot 1 (36 types) testé par 5 à 10 familles | À venir |
| G2 | 28 févr. 2027 | Rendu et UX des 53 types validés après 2 tours de retours | À venir |
| G3 | 30 avr. 2027 | Back-end, back-office et pilote de contenu arabe 1re : chaîne complète | À venir |
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
- [ ] A0-08 JSON embarqués (53 types et parcours arabe 1re) (3 j-h)
  - [x] Première étape `ar-1-t1-u1-e01` (T01 et T02), validée par `flutter test`
  - [x] Relecture des harakat de `ar-1-t1-u1-e01` par Lamjed, étape passée en statut valide le 17 oct. 2026
- [x] A0-09 Conventions d'écriture de l'arabe (0,5 j-h)
- [x] A0-10 Langue de l'interface et Directionality (1,5 j-h)
- [x] A0-11 Profils enfants (5 max) et base drift (2 j-h)
- [x] A0-12 Menu développeur (1,5 j-h)
- [x] A0-13 Lecteur d'exercice générique (4 j-h)
- [x] A0-14 Interfaces de plateforme injectées (1,5 j-h)
- [ ] A0-15 Aperçu web (apps/apercu_web) (1,5 j-h)
- [x] A0-16 Yasmina en placeholder (0,5 j-h)
- [ ] A0-17 Build de test sur téléphone (iPhone fait, Android à installer) (1 j-h)
  - [x] iPhone : build iOS réussi, app installée le 17 oct. 2026
  - [ ] Android : APK debug construit (`flutter build apk --debug`), pas encore installé sur un téléphone
- [ ] A0-18 Pilotage A0 (1 j-h)
- [x] A0-19 Design system Yasmina (artefact, depuis la démo) (1 j-h)
- [x] A0-20 ThemeYasmina appliqué à l'app et à l'aperçu web (1 j-h)

## A1 : lot 1 des moteurs et retours familles, tour 1 (2 nov. au 31 déc. 2026)
- [x] A1-01a Moteur Choix : schéma, exemples et fiche (1 j-h)
- [ ] A1-01b Moteur Choix (13 types), moteur : T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61 (7 j-h)
  - [x] T02 Vrai ou faux jouable dans l'atelier (preuve du lecteur, 19 oct. 2026)
- [ ] A1-02 Moteur Glisser-déposer (10 types) : T06, T09, T11, T12, T13, T14, T15, T16, T56, T62 (12 j-h)
- [ ] A1-03 Moteur Texte (T07, T17) (4 j-h)
- [ ] A1-04 Moteur Tracé (T20) (3 j-h)
- [ ] A1-05 Moteur Saisie numérique, base (T22, T48) (4 j-h)
- [ ] A1-06 Moteur Manipulables, base (T25, T27, T51) (6 j-h)
- [ ] A1-07 Moteur Scène image, base (T08, T47) (3 j-h)
- [ ] A1-08 Moteur Révision et jeux (T36 à T38) (5 j-h)
- [ ] A1-09 Vérification du framework sur le prototype (glisser-déposer arabe, harakat, Rive, Android 2 Go) (4 j-h)
- [ ] A1-10 Choix de l'enfant et de la matière, carte du trimestre (4 j-h)
- [ ] A1-11 Intro d'étape, séquences, écran de résultat (4 j-h)
- [ ] A1-12 Progression locale (2,5 j-h)
- [ ] A1-13 Espace parent local (5 j-h)
- [ ] A1-14 Simulation essai et abonnement (1 j-h)
- [ ] A1-15 Tests de parité et golden (2 j-h)
- [ ] A1-16 Build distribué aux familles (TestFlight, Play) (1 j-h)
- [ ] A1-17 Grille d'observation et questionnaire parent (1 j-h)
- [ ] A1-18 Synthèse des retours, tour 1 (1 j-h)
- [ ] A1-19 Design system et maquettes, partie 1 (designer, part du système Yasmina) (8 j-h)
- [ ] A1-20 Yasmina : brief et 6 états (illustrateur) (5 j-h)
- [ ] A1-21 Pilotage A1 (3 j-h)

## A2 : lot 2 des moteurs et retours familles, tour 2 (4 janv. au 28 févr. 2027)
- [ ] A2-01 Moteur Saisie numérique, avancée (T49, T50, T63) (4 j-h)
- [ ] A2-02 Moteur Manipulables, avancés (T26, T29, T52) (6 j-h)
- [ ] A2-03 Moteur Mesure et temps (T28, T30) (5 j-h)
- [ ] A2-04 Moteur Grille et graphiques (T31 à T33, T60) (7 j-h)
- [ ] A2-05 Moteur Scène image avec audio (T53, T54) (3 j-h)
- [ ] A2-06 Moteur Simulateur (T34, T57) (6 j-h)
- [ ] A2-07 Moteur Récit (T35) (3 j-h)
- [ ] A2-08 Corrections issues du tour 1 (2 j-h)
- [ ] A2-09 Retours familles, tour 2 (2 j-h)
- [ ] A2-10 Design system et maquettes, partie 2 (designer) (10 j-h)
- [ ] A2-11 Yasmina : animations Rive (illustrateur) (10 j-h)
- [ ] A2-12 Pilotage A2 (3 j-h)

## B : back-end, back-office et pilote de contenu (mars et avril 2027)
- [ ] B-01 Back-end : schéma Supabase et RLS (6 j-h)
- [ ] B-02 Back-end : Edge Functions (OTP, droits, clés) (7 j-h)
- [ ] B-03 Connexion par code simulée en développement (3 j-h)
- [ ] B-04 Téléchargement à priorités et journal persistant (8 j-h)
- [ ] B-05 Packs chiffrés et synchronisation (6 j-h)
- [ ] B-06 Back-office : base, comptes, droits (8 j-h)
- [ ] B-07 Back-office : écran de relecture et formulaire par gabarit (10 j-h)
- [ ] B-08 Back-office : publication et construction des packs (5 j-h)
- [ ] B-09 Pipeline dans le Projet Claude (registre anti-doublon, HTML de validation, GitHub) (8 j-h)
- [ ] B-10 Outil de validation pour le LLM (edu_content:valider) (1 j-h)
- [ ] B-11 Médias et packs du pipeline (6,5 j-h)
- [ ] B-12 Pilote de contenu arabe 1re T1 (go ou no-go) (4 j-h)
- [ ] B-13 Relecture du pilote (3 j-h)
- [ ] B-14 Pilotage B (3 j-h)

## C : bêta et paiements (mai et juin 2027)
- [ ] C-01 Couche jeu complète (pièces, avatar, compagnon, album) (6 j-h)
- [ ] C-02 Temps d'écran et paramètres parent (4 j-h)
- [ ] C-03 Paiements (Konnect, Flouci, D17, RevenueCat, codes prépayés, parrainage) (12 j-h)
- [ ] C-04 Site web (landing, paiement, activation) (6 j-h)
- [ ] C-05 n8n et WhatsApp (OTP, workflow d'essai, rapports) (8 j-h)
- [ ] C-06 Analytics internes, Sentry, tableaux de bord (3 j-h)
- [ ] C-07 Bêta auprès de 150 familles (6 j-h)
- [ ] C-08 Relecture du contenu de la bêta (7 j-h)
- [ ] C-09 Ajustements UX après la bêta (designer) (5 j-h)
- [ ] C-10 Pilotage C (2,5 j-h)

## D : contenu T1 et lancement (juillet et août 2027)
- [ ] D-01 Contenu T1 des 26 combinaisons (8 j-h)
- [ ] D-02 Relecture du contenu T1 (15 j-h)
- [ ] D-03 Publication stores, conformité, déclaration INPDP (4 j-h)
- [ ] D-04 Recette finale avant lancement (3,5 j-h)
- [ ] D-05 Pilotage D (2,5 j-h)

## Blocages
- À suivre (menu développeur, CLAUDE.md §7) : la « progression d'exemple » du profil de test Lina viendra avec la progression locale (A1-12). Le JSON de l'exercice en cours est affiché dans l'atelier, sous le lecteur et son journal.
- Résolu le 20 oct. 2026 (moteur Choix) : tout texte court lu par l'enfant en français ou en anglais (affirmation, texte des propositions) passe en `latin-prompt` (20 px). `latin-body` reste pour les textes longs à lire (T45, T46, T61), choix.md §9 mis à jour.
- À savoir : dans les tests et les goldens, les emoji s'affichent en carré (le moteur de test n'a pas de police emoji). Sur l'appareil et dans le navigateur, ils s'affichent normalement.
- Aperçu web : services factices (aucune voix) jusqu'à l'implémentation web des services (A0-15).
- Résolu le 17 oct. 2026 : build Android bloqué par le disque plein. Espace libéré, `flutter build apk --debug` réussi.
- Risques à suivre sur `flutter_tts` (warnings au build, pas bloquants aujourd'hui) :
  - iOS : pas encore de support Swift Package Manager (CocoaPods utilisé). Flutter annonce que cela deviendra une erreur dans une version future.
  - Android : warning sur le Kotlin Gradle Plugin (KGP) appliqué par le plugin. Même risque : à surveiller à chaque montée de version de Flutter ou d'AGP, mettre à jour `flutter_tts` ou chercher une alternative si le warning devient une erreur.
- Contrainte : `package:test` ne peut pas entrer dans le workspace (le `test_api` épinglé par Flutter et l'`analyzer` exigé par `build_runner` 2.16.2 sont incompatibles). Les tests du package `schema` utilisent donc `flutter_test`. À revoir quand `build_runner` sera relâché.

- Risque à suivre (aperçu web) : nos polices sont embarquées, mais le moteur web de Flutter charge encore par défaut CanvasKit et ses polices de secours depuis les CDN de Google (`gstatic.com`). À traiter avec la tâche A0-15 (`--no-web-resources-cdn` et thème de l'aperçu) si l'aperçu doit marcher hors ligne.
- Taille : les polices ajoutent environ 2,1 Mo à l'app (Andika fait 1,3 Mo à elle seule, car elle couvre beaucoup d'écritures). Un sous-ensemble pourra être produit avant la publication.
- Résolu le 17 oct. 2026 : double bonjour de l'accueil. La bulle de Yasmina porte le bonjour, la ligne du dessous devient « هَيَّا نَتَعَلَّمُ مَعًا. » ou « On apprend ensemble. » (textes validés par Lamjed).
- Point de design à trancher (tokens.json) : en thème sombre, `ink` devient clair et ne fait que 1,4:1 sur `sun` (étape ouverte de la carte). La démo écrit les étapes et les cartes de matière en #16243A fixe, absent des jetons. Proposition : un jeton `ink-fixed` (ou `on-pastel`) identique dans les deux thèmes, à ajouter à l'artefact avant la carte du trimestre (A1-10).
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
