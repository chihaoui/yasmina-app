#!/usr/bin/env bash
# Vérification complète avant chaque commit.
# Usage : ./tool/verifier.sh depuis n'importe quel dossier du dépôt.
# Prérequis : Chrome installé (tests web du package schema).
set -euo pipefail

racine="$(cd "$(dirname "$0")/.." && pwd)"
cd "$racine"

etape() { printf '\n== %s ==\n' "$1"; }

etape "Dépendances (workspace)"
flutter pub get

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

etape "Design : aucune valeur en dur"
dart run tool/garde_design.dart

etape "Avancement de PROGRESS.md à jour"
dart run tool/avancement.dart --verifier

etape "Formatage"
dart format --output=none --set-exit-if-changed .

etape "Analyse"
flutter analyze

for paquet in schema packages/moteur_exercices apps/mobile apps/apercu_web; do
  etape "Tests : $paquet"
  (cd "$paquet" && flutter test)
done

etape "Tests dans Chrome : schema (validateur compatible web)"
(cd schema && flutter test --platform chrome)

etape "Build web : apps/apercu_web"
(cd apps/apercu_web && flutter build web --release)

printf '\nTout est vert.\n'
