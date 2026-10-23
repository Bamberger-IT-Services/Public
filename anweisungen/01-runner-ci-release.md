# 01 · Runner, Prüfungen, Release und Update

Verbindlich für jedes Projekt von Bamberger IT-Services mit eigenem Code-Repository.
Weicht ein Projekt ab, steht die Abweichung mit Begründung in dessen `CLAUDE.md`.
Ohne Begründung gilt diese Anweisung.

Vorlage zum Abschreiben ist das Projekt **Helios** (privates Repo
`Bamberger-IT-Services/helios`): `.github/workflows/ci.yml`, `.github/workflows/release.yml`,
`.github/dependabot.yml`, `deploy/runner/runner-einrichten.sh`, `docs/RUNNER.md`,
`docs/UPDATE.md`. Interne Angaben (Name und Größe der Runner-VM, Stand je Projekt) stehen im
privaten Repo `Bamberger-IT-Services/DEV` unter `STANDARDS/`.

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
| **Eine** eigene Runner-VM (Ubuntu) für alle Projekte, nur für Builds und Tests. | Keine GitHub-Minuten, der Docker-Zwischenspeicher bleibt erhalten, nur eine Maschine zu pflegen. |
| **Nie auf einer Produktiv-VM.** | Jobs laufen mit Docker-Rechten (praktisch root). Ein Test oder fremdes Paket könnte sonst echte Daten treffen. |
| Registriert auf **Organisationsebene** (`Bamberger-IT-Services`), Runner-Gruppe „Default“. | Ein Runner bedient alle Repos. Ein neues Projekt braucht keine neue Einrichtung. |
| Labels: `self-hosted, linux, x64, bits`. | `bits` = „eigene Maschine von Bamberger IT-Services“. Die Labels sind in jedem Projekt gleich. |
| Nur für **private** Repos. In der Gruppe „Default“ bleibt „Allow public repositories“ aus. | Bei öffentlichen Repos könnte jeder per Pull Request Code auf der VM ausführen. Ein öffentliches Repo prüft auf GitHubs Rechnern (siehe 2.). |
| Ein Runner-Dienst, Jobs laufen nacheinander. Staut es sich dauerhaft, kommt ein zweiter Dienst auf dieselbe VM. | Eine VM mit 4 Kernen schafft einen schweren Job (Image-Bau, DB-Tests) gut, zwei parallel schlecht. |
| Wöchentliches Aufräumen (`docker system prune`, älter als 7 Tage) per Cron. | Die Platte läuft sonst voll. |

Einrichtung: Skript `deploy/runner/runner-einrichten.sh` und `docs/RUNNER.md` im Vorlage-Projekt.

## 2. Wo ein Job läuft: Variable `EIGENER_RUNNER`

Jeder Job wählt seinen Rechner so:

```yaml
runs-on: ${{ fromJSON(vars.EIGENER_RUNNER || '"ubuntu-latest"') }}
```

- **Organisations-Variable** `EIGENER_RUNNER = ["self-hosted","bits"]`, freigegeben für
  die privaten Repos.
- Variable leer oder gelöscht → alle Projekte laufen auf GitHubs Rechnern
  (`ubuntu-latest`). Das ist der Rückweg, wenn die Runner-VM ausfällt (kostet
  GitHub-Minuten).
- Ein einzelnes Repo kann mit einer **Repository-Variable** gleichen Namens abweichen
  (die geht vor), z. B. ein öffentliches Repo mit leerem Wert.
- Unterschiede zwischen beiden Rechnern regelt der Workflow selbst
  (`vars.EIGENER_RUNNER != ''`): mehr Testprozesse, Docker-Builder `docker` mit
  bleibendem Cache statt GitHub-Cache.

## 3. Prüfungen bei jedem Pull Request (`ci.yml`)

- **Auslöser:** `pull_request` auf `main`, `push` auf `main`, `workflow_dispatch`.
- **Inhalt:** Installation aus der Sperrdatei (`npm ci` / `pnpm install --frozen-lockfile`),
  Lint, Typprüfung, Tests, Build. Läuft das Projekt als Image, kommt eine Image-Probe dazu,
  sobald Dockerfile oder Abhängigkeiten sich ändern.
- **Nur Betroffenes:** Ein erster Job `aenderungen` ermittelt per Pfadfilter, welche
  Teile der PR berührt. Teure Jobs (DB-Tests, Image-Probe) laufen nur dann.
- **Schnelllauf:** `workflow_dispatch` mit Eingabe `testdateien` (einzelne Testdateien),
  um einen Fehler gezielt nachzustellen.
- **Datenbanktests** nur gegen eine Wegwerf-Instanz mit Markierung, nie gegen echte
  Daten.
- `concurrency` mit `cancel-in-progress` für PRs: Ein neuer Push bricht den alten Lauf ab.
- Node-Version aus `.nvmrc` (`actions/setup-node`), denn auf dem eigenen Runner ist Node
  nicht vorinstalliert.
- `permissions:` so knapp wie möglich (meist `contents: read`).
- **Pflicht vor dem Merge:** alle Jobs grün oder übersprungen. Die Organisation nutzt den
  kostenlosen GitHub-Plan. Bei privaten Repos kann GitHub deshalb keine Pflicht-Prüfungen
  erzwingen (Branch-Schutz/Rulesets brauchen GitHub Team). Die Regel hält Claude ein:
  kein Merge ohne grüne CI.

## 4. Abhängigkeiten aktuell halten (`dependabot.yml`)

- Ökosysteme: `npm` (je Projektordner mit eigener Sperrdatei), `docker`,
  `docker-compose`, `github-actions`.
- Versions-Updates **monatlich und gruppiert** (Entwicklung / Laufzeit-Minor+Patch), höchstens 5
  offene PRs je Eintrag. Major-Versionen kommen einzeln, weil sie Arbeit machen.
- Sicherheitsupdates sofort (Repo › Settings › Code security › „Dependabot security updates“ an).
- Dependabot-PRs laufen durch dieselbe CI. Grün und ohne Breaking Change merged Claude sie wie
  jeden anderen PR.

## 5. Versionen und Änderungsnotizen

- **SemVer** `MAJOR.MINOR.PATCH`. Alle Apps eines Projekts tragen dieselbe Nummer.
- `CHANGELOG.md`: Abschnitt „X.Y.Z (unveröffentlicht)“ wächst mit jedem PR. Beim Release
  bekommt er das Datum.
- `docs/releases/vX.Y.Z.md`: Release-Notiz. Sie nennt **jeden einmaligen Schritt**
  ausdrücklich (Skript, neue Variable). Fehlt ein Schritt, steht da „Keine einmaligen
  Schritte“.
- Migrationen laufen beim Start **ohne Handgriff** und sichern vorher die Datenbank.

## 6. Release (`release.yml`)

1. **Release-PR** `release/X.Y.Z`: Versionen, Sperrdateien, CHANGELOG mit Datum,
   Release-Notiz. CI grün → Merge.
2. **GitHub-Release** `vX.Y.Z` auf `main` veröffentlichen. Den Text liefert die
   Release-Notiz. Veröffentlicht wird erst nach Tobias' OK (Auswahlfrage). Danach klickt
   Claude im Browser oder Tobias selbst.
3. **Workflow** startet bei `release: [released, prereleased]`, **nicht** bei Tag- oder
   Branch-Push:
   - prüft, dass alle Versionsnummern zum Tag passen;
   - baut jedes Image auf dem eigenen Runner (Docker-Builder `docker`, Cache bleibt auf
     der VM) mit OCI-Labels (`source`, `version`, `revision`) und lädt es mit dem Tag
     `X.Y.Z` nach GHCR (`ghcr.io/bamberger-it-services/…`, Anmeldung nur mit
     `GITHUB_TOKEN`, keine persönlichen Tokens);
   - erst wenn **alle** Images oben sind: `latest` (nur höchste Version, nie bei
     Vorab-Releases) und Branch **`stabil`** auf den Tag setzen.
4. **Nachbauen:** Actions › Release › „Run workflow“ mit dem Tag. Gebaut wird der Stand
   des Tags.

## 7. Update der Produktiv-VM (Pull-Prinzip)

- Auf der VM liegt ein Klon des Repos auf Branch **`stabil`**. Geheimnisse liegen
  außerhalb von Git (`/etc/<projekt>/deploy.env`).
- `docker-compose` holt die Images mit `${<PROJEKT>_VERSION:-latest}` aus GHCR. Die VM baut
  nie selbst.
- **Update** (stößt Tobias an, kein Skript nötig):

  ```bash
  cd ~/<projekt> && git pull && cd deploy && sudo docker compose pull && sudo docker compose up -d --remove-orphans
  ```

- **Rückweg:** `<PROJEKT>_VERSION=<alte Version>` in `deploy.env` und
  `git checkout v<alte Version>`, dann `pull` und `up -d`.
- GitHub kennt keine Zugangsdaten der VM (kein SSH-Deploy aus der CI). Die VM holt sich
  Updates selbst.

## 8. Arbeitsweise mit Claude

- Ein Branch je Aufgabe, ein Pull Request (mit PR-Vorlage samt Doku-Fragen).
- **Merge nach `main` macht Claude selbst**, sobald die CI grün und der PR konfliktfrei
  ist. Danach bekommt Tobias eine kurze Info. Projekteigene Freigaben (z. B. ein OK vor
  jeder neuen Etappe) bleiben bestehen.
- PRs, die auf einem anderen Branch aufbauen, vorher auf `main` umstellen.
- Doku im selben PR: Handbuch, README, Einrichtung, Update, Sicherheitsbericht.
- Geheimnisse nie in Git, Chat, Wiki oder Client-Variablen. `.env*` (außer
  `.env.example`) wird nie committet.
- Produktive Schritte (Release veröffentlichen, VM umstellen, Daten löschen) nur nach
  ausdrücklichem OK.

## Neues Projekt aufnehmen

1. Repo **privat** in `Bamberger-IT-Services` anlegen. Der Runner und die Variable
   `EIGENER_RUNNER` gelten sofort.
2. `ci.yml`, `release.yml`, `dependabot.yml` und `.github/pull_request_template.md` aus Helios
   übernehmen und auf das Projekt zuschneiden.
3. `deploy/docker-compose.yaml` mit `${<PROJEKT>_VERSION:-latest}`, `docs/UPDATE.md`,
   `CHANGELOG.md`, `docs/releases/`.
4. In der `CLAUDE.md` des Projekts auf diesen Standard verweisen.
