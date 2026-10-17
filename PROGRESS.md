# PROGRESS.md : suivi du développement

Mis à jour par Claude Code à la fin de chaque session, relu par Lamjed et par le mentor. Les dates suivent le plan de développement du 17 octobre 2026.

## État global
- Phase en cours : **A0, mise en place du prototype mobile** (19 octobre au 1er novembre 2026)
- Prochain point de décision : **R1, 15 novembre 2026** (vitesse réelle avec Claude Code, décision sur le renfort freelance)
- Framework : **Flutter 3.47.7** (décidé le 17 octobre 2026), poste vérifié par `flutter doctor` sans erreur
- Dépôt : https://github.com/chihaoui/yasmina-app (privé), dossier local `/Users/chihaoui/Documents/Forgia/Yasmina`
- Types d'exercices jouables : **0 sur 53**

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
- [x] Dépôt GitHub privé créé
- [x] Structure `packages/moteur_exercices`, `apps/mobile`, `apps/apercu_web`, `schema`, `docs` (pub workspace, un seul `pubspec.lock`)
- [x] Script de vérification unique `./tool/verifier.sh` (pub get, garde `dart:io` du moteur, formatage, analyze, tests des 3 membres, build web de l'aperçu)
- [x] CLAUDE.md et PROGRESS.md à la racine
- [x] Projet Flutter créé (Android et iOS, `tn.forgia.yasmina`), dépendances de base (Riverpod, go_router, freezed, json_serializable, drift, flutter_tts, flutter_localizations)
- [ ] Schéma edu-content/1.0 et validateur, test qui échoue sur un JSON invalide
- [ ] JSON embarqués : un exemple par type (53) et le parcours d'arabe 1re de la démo
- [ ] Langue de l'interface (appareil, sinon arabe), bascule arabe et français, `Directionality` par écran
- [ ] Profils enfants (5 max), création manuelle
- [ ] Menu développeur : profils de test Lina et Yassine, réinitialisation, statut d'abonnement simulé, tout débloquer, JSON de l'exercice, atelier
- [ ] Lecteur d'exercice générique dans `packages/moteur_exercices` : en-tête avec Yasmina, consigne, réécoute, zone du moteur, bouton Vérifier, feedback en 3 temps, modes enfant, aperçu et édition
- [ ] Interfaces de plateforme injectées (audio, vibration, assets) avec implémentations mobile et web
- [ ] `apps/apercu_web` : joue un exercice à partir d'un JSON (fichier ou postMessage) dans un cadre de téléphone, `flutter build web` vérifié
- [ ] Yasmina en placeholder (3 humeurs : neutre, bravo, encouragement)
- [ ] Build de test installé sur le téléphone de Lamjed (Android et iPhone)

## A1 : lot 1 des moteurs (2 nov. au 13 déc. 2026)
Moteurs et types :
- [ ] Choix : T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61
- [ ] Glisser-déposer (avec toucher-toucher) : T06, T09, T11, T12, T13, T14, T15, T16, T56, T62
- [ ] Texte : T07, T17
- [ ] Tracé (non noté) : T20
- [ ] Saisie numérique (base) : T22, T48
- [ ] Manipulables (base) : T25, T27, T51
- [ ] Scène image (base) : T08, T47
- [ ] Révision et jeux (notés) : T36, T37, T38

Parcours et couche jeu :
- [ ] Choix de l'enfant, choix de la matière, carte du trimestre (unités, étapes, étoiles, verrous)
- [ ] Intro d'étape, 4 séquences, écran de résultat, rejouer avec une nouvelle série
- [ ] Progression locale (avancement et maîtrise par unité, lettre et compétence)
- [ ] Espace parent local derrière le contrôle parental (semaine, année, trimestre, à revoir, badges)
- [ ] Simulation essai, essai terminé, abonné

Retours familles, tour 1 (14 au 31 déc. 2026) :
- [ ] Build distribué (TestFlight et test interne Play) à 5 à 10 familles
- [ ] Grille d'observation et questionnaire parent prêts
- [ ] Synthèse des retours dans `docs/retours-tour-1.md`

## A2 : lot 2 des moteurs (4 janv. au 14 févr. 2027)
- [ ] Saisie numérique avancée : T49, T50, T63
- [ ] Manipulables avancés : T26, T29, T52
- [ ] Mesure et temps : T28, T30
- [ ] Grille et graphiques : T31, T32, T33, T60
- [ ] Scène image avec audio : T53, T54
- [ ] Simulateur : T34, T57
- [ ] Récit : T35
- [ ] Corrections issues du tour 1
- [ ] Retours familles, tour 2 (15 au 28 févr. 2027), synthèse dans `docs/retours-tour-2.md`

## Phases suivantes (après G2)
- [ ] B, mars et avril 2027 : back-end Supabase (connexion simulée en dev, droits, packs chiffrés), téléchargement à priorités et journal, back-office avec écran de relecture, pipeline dans le Projet Claude, pilote de contenu arabe 1re T1 (go ou no-go)
- [ ] C, mai et juin 2027 : contenu de la bêta, bêta auprès de 150 familles, paiements
- [ ] D, juillet et août 2027 : contenu T1 des 26 combinaisons, publication sur les stores, campagne

## Blocages
- **Build Android impossible pour l'instant : disque plein** (569 Mo libres). `flutter build apk --debug` échoue en installant le NDK 28.2 (« No space left on device »). Libérer au moins 5 Go (par exemple `~/Library/Developer/Xcode/DerivedData`, 13 Go, régénéré par Xcode), puis relancer `flutter build apk --debug` dans `apps/mobile`.
- Risque à suivre : `flutter_tts` ne supporte pas encore Swift Package Manager sur iOS (CocoaPods utilisé). Flutter annonce que cela deviendra une erreur dans une version future.

## Journal
| Date | Session | Fait | Suite |
|---|---|---|---|
| 17 oct. 2026 | Cadrage (mentor) | Plan mis à jour pour prioriser le prototype mobile, CLAUDE.md et PROGRESS.md créés. Règle : même moteur pour l'app et l'aperçu du back-office dès A0 | A0 : vérifier le poste, créer le dépôt et le projet Flutter |
| 17 oct. 2026 | Mise en place (Lamjed) | Flutter 3.47.7 installé, licences Android acceptées, dépôt yasmina-app créé, CLAUDE.md et PROGRESS.md ajoutés | A0 : créer le projet Flutter et la structure avec Claude Code |
| 17 oct. 2026 | A0 structure (Claude Code) | Pub workspace (moteur_exercices, apps/mobile `tn.forgia.yasmina`, apps/apercu_web), widget CarteDemo partagé avec tests arabe et français, dossiers schema et docs, `tool/verifier.sh` vert, build iOS debug OK. Dépendances ajoutées : flutter_riverpod 3.4.3, go_router 18.1.0, freezed 4.0.2, freezed_annotation 3.1.0, json_serializable 6.14.1, json_annotation 4.12.0, drift 2.35.2, drift_flutter 0.3.1, drift_dev 2.35.1, flutter_tts 4.2.5, flutter_localizations et intl 0.20.3, flutter_lints 6.0.0, build_runner épinglé en 2.16.2 (2.17.1 exige build 5, pas encore suivi par freezed, json_serializable, drift_dev). `.gitignore` remplacé (l'ancien ignorait pubspec.lock). Build Android bloqué par le disque plein | Libérer de l'espace et relancer le build Android, puis schéma edu-content/1.0 et validateur |
