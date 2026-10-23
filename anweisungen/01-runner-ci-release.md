# 01 · Runner, Prüfungen, Release und Update

Verbindlich für jedes Projekt von Bamberger IT-Services mit eigenem Code-Repository. Weicht
ein Projekt ab, steht die Abweichung mit Begründung in dessen `CLAUDE.md`. Ohne Begründung
gilt diese Anweisung. Alles Nötige steht hier und in [`vorlagen/`](vorlagen/):

| Vorlage | Ziel im Projekt |
|---|---|
| [`vorlagen/ci.yml`](vorlagen/ci.yml) | `.github/workflows/ci.yml` |
| [`vorlagen/release.yml`](vorlagen/release.yml) | `.github/workflows/release.yml` |
| [`vorlagen/dependabot.yml`](vorlagen/dependabot.yml) | `.github/dependabot.yml` |
| [`vorlagen/pull_request_template.md`](vorlagen/pull_request_template.md) | `.github/pull_request_template.md` |
| [`vorlagen/docker-compose-auszug.yaml`](vorlagen/docker-compose-auszug.yaml) | Bausteine für `deploy/docker-compose.yaml` |
| [`vorlagen/runner-einrichten.sh`](vorlagen/runner-einrichten.sh) | wird nur auf der Runner-VM ausgeführt |
| [`vorlagen/UPDATE.md`](vorlagen/UPDATE.md) | `docs/UPDATE.md` |

Stellen mit `ANPASSEN` in den Vorlagen gehören auf das Projekt zugeschnitten (Namen, Pfade,
Images, Versionsdateien). Rohtext zum Herunterladen:
`https://raw.githubusercontent.com/Bamberger-IT-Services/public/main/anweisungen/vorlagen/<datei>`.

## Auf einen Blick

```
Branch ──► Pull Request ──► CI (eigener Runner) ──► grün? Claude merged nach main
                                                      │
Release-PR (Version + CHANGELOG + Release-Notiz) ─────┘
        │
        ▼
GitHub-Release vX.Y.Z veröffentlichen ──► Images bauen (eigener Runner) ──► GHCR
                                            │  X.Y.Z, danach „latest“ + Branch „stabil“
                                            ▼
Produktiv-VM:  git pull  →  docker compose pull  →  docker compose up -d
               (holt sich selbst – GitHub greift nie auf die VM zu)
```

## 1. Der eigene Runner

| Regel | Warum |
|---|---|
| **Eine** eigene Runner-VM (Ubuntu Server LTS) für alle Projekte, nur für Builds und Tests. | Keine GitHub-Minuten, der Docker-Zwischenspeicher bleibt erhalten, nur eine Maschine zu pflegen. |
| **Nie auf einer Produktiv-VM.** | Jobs laufen mit Docker-Rechten (praktisch root). Ein Test oder fremdes Paket könnte sonst echte Daten treffen. |
| Registriert auf **Organisationsebene** (`Bamberger-IT-Services`), Runner-Gruppe „Default“. | Ein Runner bedient alle Repos. Ein neues Projekt braucht keine neue Einrichtung. |
| Labels: `self-hosted, linux, x64, bits`. | `bits` = „eigene Maschine von Bamberger IT-Services“. Die Labels sind in jedem Projekt gleich. |
| Nur für **private** Repos. In der Gruppe „Default“ bleibt „Allow public repositories“ aus. | Bei öffentlichen Repos könnte jeder per Pull Request Code auf der VM ausführen. Ein öffentliches Repo prüft auf GitHubs Rechnern (siehe 2.). |
| Ein Runner-Dienst, Jobs laufen nacheinander. | Tests nutzen feste Ports. Zwei Runner auf derselben VM würden sich stören. |
| Wöchentliches Aufräumen (`docker system prune`, älter als 7 Tage) per Cron. | Die Platte läuft sonst voll. |

### Einrichten (einmalig, Tobias)

1. **VM:** Ubuntu Server 24.04 LTS, eigene VM (kein LXC), 4 vCPU, 12–16 GB RAM, 80 GB Platte.
   Ausgehender Internetzugang reicht, eingehend braucht der Runner nichts.
2. **Token:** GitHub › Organisation › Settings › Actions › Runners › New runner › New
   self-hosted runner › Linux. Nur den Wert hinter `--token` kopieren. Er gilt eine Stunde
   und gehört nicht in Chats oder Notizen.
3. **Auf der VM:**
   ```bash
   curl -fsSLO https://raw.githubusercontent.com/Bamberger-IT-Services/public/main/anweisungen/vorlagen/runner-einrichten.sh
   sudo bash runner-einrichten.sh <TOKEN>
   ```
   Das Skript installiert Docker und die Werkzeuge, legt den Benutzer `github-runner` an,
   meldet den Runner mit Label `bits` bei der Organisation an, startet ihn als Dienst und
   plant das Aufräumen. Prüfen: `sudo systemctl status 'actions.runner.*'` zeigt
   `active (running)`, in GitHub steht der Runner auf „Idle“.
4. **Umschalten:** Organisation › Settings › Secrets and variables › Actions › Variables ›
   New organization variable: `EIGENER_RUNNER` = `["self-hosted","bits"]`, Repository
   access „Private repositories“.

War ein Runner bisher nur bei einem Repo angemeldet, gilt
`sudo bash runner-einrichten.sh --umziehen <TOKEN>` (Organisations-Token). Danach den alten
Eintrag im Repo unter Settings › Actions › Runners entfernen, ebenso eine alte
Repo-Variable für den Runner.

## 2. Wo ein Job läuft: Variable `EIGENER_RUNNER`

Jeder Job wählt seinen Rechner so:

```yaml
runs-on: ${{ fromJSON(vars.EIGENER_RUNNER || '"ubuntu-latest"') }}
```

- Variable leer oder gelöscht → alle Projekte laufen auf GitHubs Rechnern
  (`ubuntu-latest`). Das ist der Rückweg, wenn die Runner-VM ausfällt. Es kostet
  GitHub-Minuten, deshalb laufen dann Datenbanktests und Image-Probe nur von Hand.
- Ein einzelnes Repo kann mit einer **Repository-Variable** gleichen Namens abweichen
  (die geht vor), z. B. ein öffentliches Repo mit leerem Wert.
- Unterschiede regelt der Workflow selbst (`vars.EIGENER_RUNNER != ''`): mehr
  Testprozesse, Docker-Builder `docker` mit bleibendem Cache statt GitHub-Cache.
- Auf dem eigenen Runner ist Node **nicht** vorinstalliert. Jeder Job, der Node braucht,
  ruft `actions/setup-node` mit `node-version-file: .nvmrc` auf.

## 3. Prüfungen bei jedem Pull Request (`ci.yml`)

- **Auslöser:** `pull_request` auf `main` und `workflow_dispatch`. Ein Push auf `main`
  löst nichts aus, denn jeder Stand dort kam über einen geprüften PR.
- **Jobs der Vorlage:**
  - `aenderungen`: Pfadfilter, welche Teile der PR berührt;
  - `pruefen`: Installation aus der Sperrdatei, Lint, Typprüfung, Unit-Tests, Build,
    `audit` (hoch/kritisch bricht ab);
  - `geheimnisse`: gitleaks über alle Commits des PR;
  - `db-test`: Migrationen und Tests gegen eine Wegwerf-Datenbank (Service-Container),
    nie gegen echte Daten;
  - `image-probe`: Images bauen, ohne Push, und ein Rauchtest (`/api/health`).
- **Schnelllauf:** „Run workflow“ mit Eingabe `testdateien` startet nur die angegebenen
  Testdateien, um einen Fehler gezielt nachzustellen.
- `concurrency` mit `cancel-in-progress` für PRs: Ein neuer Push bricht den alten Lauf ab.
- `permissions:` so knapp wie möglich (Vorgabe `contents: read`). Eingaben von außen
  (Feld `testdateien`, PR-Titel) nie direkt in `run:` einsetzen, sondern über `env:`
  übergeben und prüfen.
- **Pflicht vor dem Merge:** alle Jobs grün oder übersprungen. Der kostenlose GitHub-Plan
  kann bei privaten Repos keine Pflicht-Prüfungen erzwingen. Die Regel hält Claude ein:
  kein Merge ohne grüne CI.

## 4. Abhängigkeiten aktuell halten (`dependabot.yml`)

- Ökosysteme: `npm` (gilt auch für pnpm; je Ordner mit eigener Sperrdatei), `docker`,
  `docker-compose`, `github-actions`.
- Versions-Updates **monatlich und gruppiert** (Entwicklung / Laufzeit-Minor+Patch),
  höchstens 5 offene PRs je Eintrag. Major-Versionen kommen einzeln, weil sie Arbeit
  machen. Bei Expo nur Patch-Updates; Expo gibt die Versionen vor (`npx expo install --fix`).
- Sicherheitsupdates sofort (Repo › Settings › Code security › „Dependabot security
  updates“ an).
- Dependabot-PRs laufen durch dieselbe CI. Grün und ohne Breaking Change merged Claude sie
  wie jeden anderen PR.

## 5. Versionen und Änderungsnotizen

- **SemVer** `MAJOR.MINOR.PATCH`. Alle Apps eines Projekts tragen dieselbe Nummer.
- `CHANGELOG.md`: Abschnitt „X.Y.Z (unveröffentlicht)“ wächst mit jedem PR. Beim Release
  bekommt er das Datum. Gegliedert nach App und „Betrieb“.
- `docs/releases/vX.Y.Z.md`: Release-Notiz mit den Abschnitten Update, Einmalig nach dem
  Update, Neue Einstellungen, Was ist neu, Bekannt. Sie nennt **jeden einmaligen Schritt**
  ausdrücklich. Gibt es keinen, steht da „Keine einmaligen Schritte“.
- Migrationen laufen beim Start **ohne Handgriff** und sichern vorher die Datenbank
  ([02](02-architektur.md)).

## 6. Release (`release.yml`)

1. **Release-PR** `release/X.Y.Z`: Versionen, Sperrdateien, CHANGELOG mit Datum,
   Release-Notiz. CI grün → Merge.
2. **GitHub-Release** `vX.Y.Z` auf `main` veröffentlichen. Den Text liefert die
   Release-Notiz. Veröffentlicht wird erst nach Tobias' OK (Auswahlfrage). Danach klickt
   Claude im Browser oder Tobias selbst.
3. **Workflow** startet bei `release: [released, prereleased]`, **nicht** bei Tag- oder
   Branch-Push:
   - prüft, dass alle Versionsnummern zum Tag passen und der Tag auf `main` liegt;
   - baut jedes Image auf dem eigenen Runner mit OCI-Labels und lädt es mit dem Tag `X.Y.Z`
     nach GHCR (`ghcr.io/bamberger-it-services/…`). Die Anmeldung läuft nur mit
     `GITHUB_TOKEN`, ohne persönliche Tokens;
   - scannt jedes Image mit Trivy (Bericht in der Zusammenfassung des Laufs);
   - erst wenn **alle** Images oben sind: `latest` setzen (nur für die höchste Version,
     nie für Vorab-Releases) und Branch **`stabil`** auf den Tag.
4. **Nachbauen:** Actions › Release › „Run workflow“ mit dem Tag. Gebaut wird der Stand
   des Tags.

## 7. Update der Produktiv-VM (Pull-Prinzip)

- Auf der VM liegt ein Klon des Repos auf Branch **`stabil`**. Geheimnisse liegen
  außerhalb von Git (`/etc/<projekt>/deploy.env`, nur root).
- `docker-compose` holt die Images mit `${<PROJEKT>_VERSION:-latest}` aus GHCR. Die VM baut
  nie selbst.
- **Update:** stößt Tobias an, ohne Skript. Die genauen Befehle stehen in
  [`vorlagen/UPDATE.md`](vorlagen/UPDATE.md).
- **Rückweg:** feste alte Version in `deploy.env` und `git checkout v<alt>`.
- GitHub kennt keine Zugangsdaten der VM (kein SSH-Deploy aus der CI). Die VM holt sich
  Updates selbst. Für private Images meldet sich die VM einmalig bei GHCR an, mit einem
  Token, das nur `read:packages` darf.

## 8. Arbeitsweise mit Claude

- Ein Branch je Aufgabe, ein Pull Request mit PR-Vorlage samt Doku-Fragen.
- **Merge nach `main` macht Claude selbst**, sobald die CI grün und der PR konfliktfrei
  ist. Danach bekommt Tobias eine kurze Info. Projekteigene Freigaben (z. B. ein OK vor
  jeder neuen Etappe) bleiben bestehen.
- PRs, die auf einem anderen Branch aufbauen, vorher auf `main` umstellen.
- Doku im selben PR: Handbuch, README, Einrichtung, Update, Sicherheitsbericht.
- Produktive Schritte (Release veröffentlichen, VM umstellen, Daten löschen) nur nach
  ausdrücklichem OK.

## Neues Projekt aufnehmen

1. Repo **privat** in `Bamberger-IT-Services` anlegen. Runner und `EIGENER_RUNNER` gelten
   sofort.
2. Vorlagen aus der Tabelle oben übernehmen und die `ANPASSEN`-Stellen ausfüllen.
3. `deploy/docker-compose.yaml` mit `${<PROJEKT>_VERSION:-latest}`, `docs/UPDATE.md`,
   `CHANGELOG.md`, `docs/releases/` anlegen.
4. Die erste CI auf einem PR prüfen. Den ersten Release mit `v0.1.0` durchspielen.
5. In der `CLAUDE.md` des Projekts auf diese Anweisungen verweisen
   ([README](README.md) › Text für die Projektanweisung).
