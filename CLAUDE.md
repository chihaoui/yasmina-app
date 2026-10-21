# CLAUDE.md : app éducative Yasmina (prototype mobile)

Ce fichier est lu par Claude Code au début de chaque session. Il décrit le projet, les règles et la façon de travailler.

## 1. Le projet en bref
- App mobile éducative pour le primaire tunisien (1re à 6e année), 5 matières : arabe, français, anglais, maths, éveil scientifique. Mascotte : Yasmina (fleur de jasmin).
- Phase actuelle : **prototype mobile Flutter**, contenu en **JSON embarqué** dans l'app, sans back-end. But : valider le rendu et l'UX des 52 types d'exercices (53 au catalogue v3.1, T20 Tracé de lettre retiré le 20 oct. 2026 : l'écriture sur écran n'est pas fiable) avec quelques familles avant de construire le reste.
- Références : spécification v0.2, plan de développement, catalogue v3.1 (voir le Projet Claude « App éducative »). En cas de doute sur une règle produit, demander à Lamjed plutôt que deviner.

## 2. Démarrage de chaque session
1. Lire `PROGRESS.md` (état, tâche en cours, prochaines tâches).
2. Annoncer en 2 lignes ce qui va être fait dans la session.
3. En fin de session : mettre à jour `PROGRESS.md` (cases cochées, journal daté, blocages), puis commit.

## 3. Stack
- Flutter stable, Dart, null safety. Android et iOS (tablette comprise).
- État : Riverpod. Navigation : go_router. Modèles JSON : freezed et json_serializable.
- Langues : flutter_localizations, fichiers ARB pour l'arabe et le français.
- Stockage local : drift (SQLite) pour profils, progression et, plus tard, le journal de téléchargement.
- Audio du prototype : flutter_tts (voix de l'appareil). Plus tard : fichiers audio pré-générés.
- Animations : Rive pour Yasmina (placeholder SVG ou PNG en attendant le fichier Rive).
- Pas de Firebase côté enfant. Pas de back-end dans cette phase.

## 4. Organisation du dépôt
```
packages/moteur_exercices/   moteurs et gabarits (T01 à T63), feedback, modèles JSON, Yasmina
apps/mobile/                 l'app (profils, carte, étapes, espace parent local, menu dev)
apps/mobile/assets/content/  JSON embarqués (schéma edu-content/1.0)
schema/                      schéma JSON edu-content/1.0 et son validateur
docs/                        captures, notes de test avec les familles
apps/apercu_web/             mini-app Flutter web : joue un exercice à partir de son JSON (aperçu du back-office)
```

### Règle d'architecture n°1 : le même moteur pour l'app et le back-office (dès le premier jour)
Les exercices joués par l'enfant dans l'app doivent pouvoir être rejoués à l'identique par l'admin dans le back-office, avec le même code. Conséquences, non négociables :
- **Un seul code** : tout ce qui affiche ou corrige un exercice vit dans `packages/moteur_exercices`. Aucun gabarit, aucune règle de correction ni de feedback dans `apps/mobile`.
- **Le moteur est autonome** : il reçoit un exercice JSON (edu-content/1.0) et une configuration (langue, genre du profil, mode), et il émet des événements (réponse donnée, essai, résultat, demande d'audio). Il ne connaît ni la base locale, ni la navigation, ni les profils, ni l'abonnement.
- **Compatible web** : pas de `dart:io`, pas de plugin sans support web dans le moteur. Les services de plateforme (audio, vibration, stockage d'assets) passent par des interfaces injectées, avec une implémentation mobile et une implémentation web.
- **Modes du moteur** : `enfant` (normal), `apercu` (bascule « afficher la réponse », rejouer, sans enregistrement de progression), `edition` (rechargement à chaud quand le JSON change).
- **Aperçu web dès A0** : `apps/apercu_web` charge un JSON (fichier ou message `postMessage` de la page hôte) et le joue dans un cadre de téléphone. `flutter build web` de cette app fait partie des vérifications avant chaque commit.
- **Test de parité** : pour chaque moteur, le même JSON de test passe dans un test de widget mobile et dans le build web.

## 5. Règles produit à respecter
- **Une langue par exercice** : consigne, choix, boutons, feedback, voix et bulle de Yasmina dans la langue de la matière. Maths et éveil en arabe. Aucune exception.
- **Interface** : arabe ou français, langue de l'appareil si arabe ou français, sinon arabe. Modifiable dans les réglages.
- **Sens d'écriture** : tout l'écran suit la langue affichée (`Directionality`), y compris la barre de progression, les flèches et le remplissage des emplacements.
- **Glisser-déposer réel** avec toucher-toucher en secours : doigt immobile 200 ms, l'élément passe en attente, puis se pose au toucher de la cible. Cibles d'au moins 48 dp, effet aimant, retour animé si dépôt hors cible, vibration légère au dépôt. Un élément déposé peut être réordonné ou retiré tant que l'enfant n'a pas appuyé sur Vérifier.
- **Feedback en 3 temps** : validation centrée sur la tâche (dire ce qui est juste, jamais « tu es doué »), puis indice, puis explication avec la bonne réponse. Accord masculin ou féminin selon le profil.
- 4 à 6 éléments manipulables au maximum en 1re et 2e année. Consigne toujours sonorisée avec bouton de réécoute.
- Profils : 5 enfants maximum.
- Harakat : ne jamais les supprimer ni les réordonner dans les textes. Comparaisons de réponses avec normalisation explicite et testée.
- Conventions d'écriture de l'arabe (`docs/conventions-arabe.md`), imposées dès l'écriture de tout texte arabe (contenu, tests, exemples, prompts du pipeline) : A. alif de liaison en début de phrase avec kasra (اِسْتَمِعْ). B. alif suscrit simplifié : هَذِهِ, jamais d'alif suscrit (aucun caractère U+0670). C. lam de l'article avec soukoun devant une lettre lunaire, hamza comprise (الْإِعْدَادَاتُ, الْكَلِمَةُ), avec kasra devant un alif de liaison (الِاسْمُ).
- Textes français de l'interface : pas de tiret cadratin ni de point-virgule.
- Aucun contenu recopié des manuels scolaires.

## 6. Contenu embarqué
- Un fichier JSON par étape au format edu-content/1.0 (blocs `generation`, `etape`, `exercices`). Identifiants stables.
- Le validateur du schéma tourne dans les tests : un JSON invalide fait échouer `flutter test`.
- Le prototype embarque au moins un exemple de chacun des 52 types du MVP (catalogue v3.1 sans T20), plus le parcours d'arabe 1re année de la démo (lettres ب ل م ر, défi, د, ف).

## 7. Configuration de test
- Menu développeur caché (appui long sur le logo, visible seulement en build debug ou profile) :
  - créer les profils de test Lina (fille, avec progression d'exemple) et Yassine (garçon, vierge)
  - réinitialiser toutes les données
  - statut d'abonnement simulé : essai, essai terminé, abonné
  - tout débloquer
  - afficher le JSON de l'exercice en cours
  - ouvrir l'atelier : liste des 52 types, chacun jouable seul
- Le parcours normal permet aussi de créer des profils à la main.

## 8. Qualité
- Avant chaque commit : `flutter analyze` sans erreur, `flutter test` vert et `flutter build web` de `apps/apercu_web` réussi. Tout cela est joué par `./tool/verifier.sh`, lancé sans pipe ni filtre, sortie dans un fichier, lu avant le commit (« Tout est vert » et code de sortie 0).
- **Hook anti-commit rouge** (`tool/hooks/pre-commit`, versionné, activé une fois par clone avec `git config core.hooksPath tool/hooks`) : `verifier.sh` écrit, seulement quand tout est vert, l'empreinte de l'index (`git write-tree`) dans `.git/verifier-vert` (hors suivi Git, retiré au début de chaque passage). Le hook refuse le commit si le marqueur est absent ou si l'index à commiter a une autre empreinte. Ordre à respecter : `git add` des fichiers, puis `./tool/verifier.sh`, puis `git commit`. Indexer après la vérification oblige à relancer le vérificateur. `git commit --no-verify` est interdit. Testé par `test/hook_verifier_test.dart`.
- Un test de widget par moteur, avec un cas en arabe (droite à gauche) et un cas en français.
- Accessibilité : chaque élément touchable a un libellé pour le lecteur d'écran (neutre pour les images, décision 33), une cible d'au moins 48 dp et le contraste du design system. Contrôlé par `packages/moteur_exercices/test/lecteur/accessibilite_test.dart` (tous les exemples du catalogue, mode enfant puis réponse révélée) et `apps/mobile/test/ecrans/accessibilite_ecrans_test.dart` (parcours et espace parent). Un nouvel écran ou un nouveau gabarit s'ajoute à ces tests.
- Les exemples de l'atelier (`exemplesEduContent`) ne sont embarqués qu'en debug et en profile (`sourcesAtelier` dans `apps/mobile/lib/dev/menu_dev.dart`, contrôlé par `verifier.sh`) : l'app publiée n'emporte que le contenu de `apps/mobile/assets/content/`.
- Tests golden sur les écrans clés en arabe et en français.
- Design : aucune couleur, taille de texte, rayon, espacement ni épaisseur en dur hors `packages/moteur_exercices/lib/src/theme/` (jetons générés depuis `docs/design-system/tokens.json` par `tool/generer_theme.dart`). Contrôlé par `tool/garde_design.dart` dans `verifier.sh`. Exception nommée sur la ligne : `// design-ok : raison`.
- Petits commits, message en français, un sujet par commit.
- Ne pas ajouter de dépendance sans le noter dans le journal de `PROGRESS.md`.

## 9. Ce qu'on ne fait pas dans cette phase
Back-end Supabase, authentification, paiements, téléchargement de packs, back-office, n8n. Ils viennent après la validation du rendu et de l'UX (jalon G2).
