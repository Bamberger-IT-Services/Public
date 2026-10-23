#!/usr/bin/env bash
# Vorlage: deploy/abnahme.sh – automatische Abnahme eines Release (Anweisung 01 › Abnahme).
# Aufruf aus release.yml:  bash deploy/abnahme.sh <vorige-version|leer> <neue-version>
#
# 1. Startet die VORIGE Version als komplette Anlage (Compose-Datei aus deren Tag) und
#    spielt Testdaten ein – so wird der Update-Weg geprüft, nicht nur eine Neuinstallation.
# 2. Stellt auf die NEUE Version um (pull + up -d): Migrationen laufen wie auf der VM.
# 3. Prüft Healthcheck und die Kernabläufe per Playwright (Projekt „abnahme“).
# 4. Räumt immer ab (Container, Volumes, Arbeitsordner).
#
# Läuft unter eigenem Compose-Projektnamen und mit Ports Dev + 20000 (Anweisung 05),
# stört also weder Dev noch Staging. Geheimnisse werden je Lauf neu erzeugt.
# ANPASSEN: Variablennamen (PROJEKT_…), Testdaten-Befehl, Pfad zur Compose-Datei.
set -euo pipefail

VORHER="${1:-}"
NEU="${2:?neue Version fehlt}"
WURZEL="$(git rev-parse --show-toplevel)"
ARBEIT="$(mktemp -d)"
export COMPOSE_PROJECT_NAME="abnahme"
ENVDATEI="$ARBEIT/abnahme.env"

aufraeumen() {
  for ordner in "$ARBEIT/vorher/deploy" "$WURZEL/deploy"; do
    [ -f "$ordner/docker-compose.yaml" ] && \
      docker compose -f "$ordner/docker-compose.yaml" --env-file "$ENVDATEI" down -v --remove-orphans >/dev/null 2>&1 || true
  done
  git -C "$WURZEL" worktree remove --force "$ARBEIT/vorher" >/dev/null 2>&1 || true
  rm -rf "$ARBEIT"
}
trap aufraeumen EXIT

# Konfiguration nur mit Testwerten: Beispiel-Datei + frisch erzeugte Geheimnisse.
cp "$WURZEL/deploy/.env.example" "$ENVDATEI"
# ANPASSEN: Geheimnisse erzeugen, z. B. bash "$WURZEL/deploy/geheimnisse-erzeugen.sh" "$ENVDATEI"
{
  echo "PROJEKT_PORT_WEB=23000"          # Dev 3000 + 20000
  echo "PROJEKT_BIND=127.0.0.1"
  echo "PROJEKT_SITE_URL=http://127.0.0.1:23000"
} >> "$ENVDATEI"

starten() {  # $1 = Ordner mit docker-compose.yaml, $2 = Version
  PROJEKT_VERSION="$2" docker compose -f "$1/docker-compose.yaml" --env-file "$ENVDATEI" pull --quiet
  PROJEKT_VERSION="$2" docker compose -f "$1/docker-compose.yaml" --env-file "$ENVDATEI" up -d --wait --wait-timeout 300
}

if [ -n "$VORHER" ]; then
  echo "== 1/3 Vorige Version $VORHER mit Testdaten"
  git -C "$WURZEL" worktree add --detach "$ARBEIT/vorher" "v$VORHER" >/dev/null
  starten "$ARBEIT/vorher/deploy" "$VORHER"
  # ANPASSEN: Testdaten einspielen (nur erfundene Daten), z. B.
  # docker compose -f "$ARBEIT/vorher/deploy/docker-compose.yaml" --env-file "$ENVDATEI" exec -T web node scripts/testdaten.mjs
else
  echo "== 1/3 Erstes Release – keine vorige Version, Neuinstallation wird geprüft"
fi

echo "== 2/3 Update auf $NEU"
starten "$WURZEL/deploy" "$NEU"
docker compose -f "$WURZEL/deploy/docker-compose.yaml" --env-file "$ENVDATEI" logs migrate | tail -n 20 || true
curl -fsS "http://127.0.0.1:23000/api/health"; echo

echo "== 3/3 Kernabläufe"
cd "$WURZEL"
BASE_URL="http://127.0.0.1:23000" pnpm exec playwright test --project=abnahme   # ANPASSEN: npx
echo "Abnahme bestanden: $VORHER → $NEU"
