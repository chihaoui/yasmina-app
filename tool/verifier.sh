#!/usr/bin/env bash
# Vérification complète avant chaque commit.
# Usage : ./tool/verifier.sh depuis n'importe quel dossier du dépôt.
set -euo pipefail

racine="$(cd "$(dirname "$0")/.." && pwd)"
cd "$racine"

etape() { printf '\n== %s ==\n' "$1"; }

etape "Dépendances (workspace)"
flutter pub get

etape "Moteur compatible web (pas de dart:io)"
if grep -rn "dart:io" packages/moteur_exercices/lib; then
  echo "Erreur : dart:io est interdit dans packages/moteur_exercices." >&2
  exit 1
fi
echo "OK"

etape "Formatage"
dart format --output=none --set-exit-if-changed .

etape "Analyse"
flutter analyze

for paquet in packages/moteur_exercices apps/mobile apps/apercu_web; do
  etape "Tests : $paquet"
  (cd "$paquet" && flutter test)
done

etape "Build web : apps/apercu_web"
(cd apps/apercu_web && flutter build web --release)

printf '\nTout est vert.\n'
