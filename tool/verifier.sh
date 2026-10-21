#!/usr/bin/env bash
# Vérification complète avant chaque commit.
# Usage : ./tool/verifier.sh depuis n'importe quel dossier du dépôt.
# Prérequis : Chrome installé (tests web du package schema).
set -euo pipefail

racine="$(cd "$(dirname "$0")/.." && pwd)"
cd "$racine"

# Marqueur lu par le hook pre-commit (tool/hooks/pre-commit, CLAUDE.md §8) :
# l'empreinte de l'index (git write-tree) au moment d'un passage vert, hors
# suivi Git. Retiré au départ : un passage rouge ne laisse aucun marqueur.
marqueur="$(git rev-parse --git-dir)/verifier-vert"
rm -f "$marqueur"

etape() { printf '\n== %s ==\n' "$1"; }

etape "Dépendances (workspace)"
# Une seule résolution, ici, d'abord hors ligne (cache du poste, sans
# réseau), en ligne seulement si le cache ne suffit pas (nouvelle
# dépendance). Les étapes suivantes passent --no-pub : sans cela, chaque
# commande Flutter relance une résolution qui interroge pub.dev (avis de
# sécurité) et un réseau capricieux fait tomber ou bloque un passage sans
# rapport avec le code (nuit du 20 au 21 oct. 2026).
flutter pub get --offline || flutter pub get

etape "Moteur et schéma compatibles web (pas de dart:io)"
for dossier in packages/moteur_exercices/lib schema/lib; do
  if grep -rn "dart:io" "$dossier"; then
    echo "Erreur : dart:io est interdit dans $dossier." >&2
    exit 1
  fi
done
if grep -rn "package:flutter/" schema/lib; then
  echo "Erreur : schema/lib doit rester en Dart pur (pas de Flutter)." >&2
  exit 1
fi
echo "OK"

etape "Exemples de l'atelier hors des builds release (apps/mobile)"
# exemplesEduContent n'est lu que par sourcesAtelier (lib/dev/menu_dev.dart),
# derrière kReleaseMode : ailleurs, les textes des exemples entreraient dans
# l'app publiée.
if grep -rn "exemplesEduContent" apps/mobile/lib | grep -v "lib/dev/menu_dev.dart"; then
  echo "Erreur : exemplesEduContent ne se lit que dans apps/mobile/lib/dev/menu_dev.dart (sourcesAtelier)." >&2
  exit 1
fi
if ! grep -q "release ? const {} : exemplesEduContent" apps/mobile/lib/dev/menu_dev.dart; then
  echo "Erreur : sourcesAtelier doit rendre une carte vide en release." >&2
  exit 1
fi
echo "OK"

etape "Design : aucune valeur en dur"
dart run tool/garde_design.dart

etape "Avancement de PROGRESS.md à jour"
dart run tool/avancement.dart --verifier

etape "Tests : outils de la racine (tool/)"
flutter test --no-pub

etape "Formatage"
dart format --output=none --set-exit-if-changed .

etape "Analyse"
flutter analyze --no-pub

for paquet in schema packages/moteur_exercices apps/mobile apps/apercu_web; do
  etape "Tests : $paquet"
  (cd "$paquet" && flutter test --no-pub)
done

etape "Tests dans Chrome : schema (validateur compatible web)"
(cd schema && flutter test --no-pub --platform chrome)

etape "Build web : apps/apercu_web"
(cd apps/apercu_web && flutter build web --release --no-pub)

etape "Marqueur du hook pre-commit"
git write-tree > "$marqueur"
printf 'Index vérifié vert : %s\n' "$(cat "$marqueur")"
if [ -n "$(git status --short)" ]; then
  printf "État de l'arbre (seul l'index est couvert par le marqueur) :\n"
  git status --short
fi

printf '\nTout est vert.\n'
