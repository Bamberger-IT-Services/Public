# 05 · Betrieb

Wie ein Projekt auf seiner Produktiv-VM läuft. Update und Release stehen in
[01](01-runner-ci-release.md).

## VM und Netz

- Eine eigene Ubuntu-Server-LTS-VM je Produkt (Proxmox), mit automatischen
  Sicherheitsupdates (`unattended-upgrades`). Die Runner-VM ist eine andere Maschine.
- Von außen erreichbar ist nur der **Reverse Proxy** (HTTPS, Zertifikate automatisch). Die
  Dienste lauschen nur auf der Adresse, die der Proxy erreicht, nie ohne Grund auf
  `0.0.0.0`.
- Zusatzdienste (Automatisierung, Statusseite, Admin-Oberflächen) laufen nur intern oder
  hinter dem Proxy mit Anmeldung.
- SSH nur mit Schlüssel, kein Passwort, kein root-Login.

## Container

- Bausteine aus [`vorlagen/docker-compose-auszug.yaml`](vorlagen/docker-compose-auszug.yaml)
  für **jeden** eigenen Dienst:
  - `read_only` + `tmpfs`, Nicht-root-Benutzer;
  - `cap_drop: [ALL]`, `no-new-privileges`, `pids_limit`, `mem_limit`;
  - Log-Rotation (`json-file`, 10 MB × 3);
  - Healthcheck.
- Netz **`intern`** (`internal: true`) für Datenbank und interne Dienste. Ins Internet nur,
  wer muss (Mail, KI, Bankabruf).
- Fremde Images mit **fester Version**, Updates per Dependabot. Eigene Images aus GHCR,
  gebaut nur beim Release.

## Umgebungen und Ports

| Umgebung | Wo | Ports | Daten |
|---|---|---|---|
| **Dev** | Mac, `next dev` + lokale Dienste | Standard (z. B. Web 3000, Datenbank-API 54321) | eigene Testdaten |
| **Staging** | Mac, Release-Images aus GHCR, `docker compose -p <projekt>-staging` | **Dev + 10000** (z. B. 13000) | eigene Volumes, erfundene oder anonymisierte Daten |
| **Abnahme** | Runner-VM, nur während eines Release ([01](01-runner-ci-release.md)) | **Dev + 20000** | Testdaten, wird danach gelöscht |
| **Produktion** | eigene VM | hinter dem Reverse Proxy | echte Daten |

- Alle Host-Ports stehen in der Compose-Datei als Variable (`${PROJEKT_PORT_WEB:-3000}`),
  damit dieselbe Datei für jede Umgebung taugt. Jedes Projekt hat eigene Standard-Ports.
  Die Liste der Ports steht in der Projektdoku, damit sich zwei Projekte nicht in die
  Quere kommen.
- **Staging lokal** (Tobias, 23.10.2026: sobald der Mac genug Speicher hat, z. B. 64 GB):
  Es läuft auf `latest` oder einem Vorab-Release und wird vor dem Update der Produktion
  einmal durchgeklickt. Die Images sind für x64 gebaut und laufen auf Apple-Chips über
  Rosetta. Gebraucht werden grob 4–6 GB je Anlage mit vollem Supabase.
- Produktivdaten kommen nie ungeschützt nach Dev oder Staging. Wenn überhaupt, dann
  anonymisiert und mit eigenem Löschdatum.

## Konfiguration

- `/etc/<projekt>/deploy.env` (root, `600`). Im Repo liegt `deploy/.env.example` mit jedem
  Schlüssel und einem Kommentar.
- Ein Skript erzeugt fehlende Geheimnisse (`deploy/geheimnisse-erzeugen.sh` o. Ä.).
- Die App prüft die Konfiguration beim Start und bricht mit klarer Meldung ab
  ([02](02-architektur.md)).

## Sicherungen (3-2-1)

- **Automatisch vor jeder Migration** (Dump, die letzten 10 bleiben).
- **Täglich** durch den Worker oder per systemd-Timer: Datenbank, Dateien (Storage) und
  Konfiguration ohne Klartext-Geheimnisse.
- **Verschlüsselt mit age:** Auf dem Server liegt nur der öffentliche Schlüssel. Der private
  Schlüssel liegt offline im Passwortmanager. Wer den Server übernimmt, kann alte
  Sicherungen also nicht lesen.
- **Aufbewahrung:** 30 Tage täglich, 12 Monate monatlich. Bei Daten mit gesetzlicher Frist
  (z. B. GoBD) gilt der Export der Bücher als eigene Aufbewahrung, nicht das Backup.
- **Eine Kopie außerhalb der VM** (anderer Speicher oder Ort).
- **Wiederherstellung üben:** mindestens einmal je Minor-Release in einer Wegwerf-Umgebung,
  mit Skript (`deploy/wiederherstellen.sh`). Ergebnis und Datum in der Release-Notiz.

## Überwachung

- `/api/health`: öffentlich nur `ok`/`fehler` und die Version. Details (Datenbank, Worker,
  Speicher) gibt es nur intern.
- **Uptime Kuma** (eine Instanz für alle Projekte) mit einem Monitor je Dienst und
  Benachrichtigung per Mail oder Push.
- Ein Systemstatus in der App für Admins: Dienste, letzte Sicherung, letzter Job-Lauf,
  freier Speicher.

## Mail

- Ein SMTP-Absender je Installation, nur mit TLS. SPF, DKIM und DMARC für die
  Absenderdomain, beschrieben in der Einrichtungsanleitung.
- Mails verschickt der Worker mit Wiederholung. Ein Fehlschlag erscheint im Systemstatus.

## Zeit und Formate

- Server in UTC, Anzeige `Europe/Berlin`. Datum `23.10.2026`, Betrag `1.234,56 €`.
