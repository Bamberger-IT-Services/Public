# 02 · Architektur und Stack

Zielbild für jedes Projekt. Ein neues Projekt startet so. Ein bestehendes zieht nach,
sobald es den Bereich anfasst, oder nach eigener Aufgabe. Eine bewusste Abweichung steht
begründet in der `CLAUDE.md` des Projekts.

## Nichtfunktionale Anforderungen (Vorgabe)

Jedes Projekt nennt im README seine Werte. Ohne eigene Angabe gelten diese Vorgaben für
selbst gehostete Fachanwendungen mit wenigen bis einigen hundert Nutzern:

| Größe | Vorgabe | Folgt daraus |
|---|---|---|
| Verfügbarkeit | Arbeitszeit, kein 24/7-Bereitschaftsdienst; Wartung nach Ankündigung | eine VM ohne Ausfallserver ist in Ordnung |
| **RPO** (höchster Datenverlust) | 24 Stunden, vor Updates 0 (Sicherung vor Migration) | tägliche Sicherung ([05](05-betrieb.md)); wer weniger braucht, ergänzt WAL-Archivierung |
| **RTO** (höchste Ausfallzeit) | 4 Stunden | Wiederherstellung per Runbook geübt ([07](07-stoerungen-und-runbooks.md)) |
| Antwortzeit | Seiten < 1 s (Median), Listen und Suche < 2 s bei realistischer Datenmenge | Indizes, Seitenweise Abfragen (siehe Leistung) |
| Datenmenge | so geplant, dass 10× der heutigen Menge ohne Umbau läuft | keine vollständigen Tabellen in den Speicher laden |

Was die Vorgaben übersteigt (Hochverfügbarkeit, viele Instanzen), braucht eine
Architektur-Entscheidung (ADR, [06](06-qualitaet-und-doku.md)).

## Sprache und Laufzeit

- **TypeScript** im strikten Modus, **Next.js** (App Router) und React in der jeweils
  aktuellen Hauptversion. Für eine App auf dem Telefon kommt **Expo** dazu.
- **Node 24 LTS** überall gleich: `.nvmrc`, `engines` (`>=24`), Docker-Basis
  `node:24-alpine`, `@types/node` 24.
- **Paketmanager:** neue Projekte nehmen **pnpm** (schneller, strenger, eine Sperrdatei
  für das ganze Monorepo). Ein bestehendes npm-Projekt bleibt bei npm, solange ein Wechsel
  mehr kostet als er bringt. Installiert wird immer aus der Sperrdatei (`pnpm install
  --frozen-lockfile` / `npm ci`).
- Konfiguration wird beim Start mit **zod** geprüft (`src/lib/env.ts` o. Ä.). Fehlt etwas
  oder ist etwas falsch, bricht die App mit klarer Meldung ab, statt halb zu laufen.

## Daten

- **Postgres über selbst gehostetes Supabase** (Postgres 17). Es laufen nur die Dienste, die
  das Projekt wirklich braucht (in der Regel db, auth, storage, rest). Realtime,
  Bildumwandlung, Edge-Runtime und Studio nur mit Grund. Studio läuft nur lokal.
- **drizzle** für Schema und Abfragen.
- **Zeilensicherheit (RLS) ist Pflicht und an:** Jede Tabelle bekommt RLS, `REVOKE` für
  `anon`/`authenticated` und eine Richtlinie für die App-Rolle. Die App fragt die Datenbank
  mit einer **eingeschränkten Rolle** ab, nie als `postgres`. Eine zweite, privilegierte
  Verbindung gibt es nur für Migrationen, Hintergrundjobs, Wartung und die Anmeldung.
- Mandanten werden über eine Spalte (`account_id` o. Ä.) plus RLS getrennt, nicht nur im
  App-Code.
- Interne Schemata (`app`, Sitzungen, Rate-Limits) sind nicht über PostgREST erreichbar.
- **Beträge in Cent** als Ganzzahl, Zeitpunkte als `timestamptz`, Zeitzone der Anzeige
  `Europe/Berlin`.

## Leistung

- **Keine Abfrage ohne Grenze:** Jede Liste ist seitenweise (Cursor oder `limit`/`offset`
  mit Obergrenze), jede Suche hat ein `limit`.
- **Keine N+1-Abfragen:** Verknüpfte Daten in einer Abfrage (Join) oder gebündelt laden,
  nicht in einer Schleife.
- **Indizes** für jeden Fremdschlüssel und jede Spalte, nach der regelmäßig gefiltert oder
  sortiert wird. Die Migration legt sie mit an. Langsame Abfragen werden mit
  `EXPLAIN ANALYZE` geprüft.
- **Zeitgrenzen:** `statement_timeout` für App-Verbindungen, Timeouts für jeden Aufruf nach
  außen (Mail, KI, Banken). Lange Arbeit gehört in einen Hintergrundjob.
- Große Dateien werden gestreamt, nicht komplett in den Speicher geladen.

## Migrationen

- Nur im Migrationsordner des Projekts, fortlaufend nummeriert. Die nächste freie Nummer
  steht im Journal.
- Laufen **beim Start automatisch** (eigener Container oder Setup-Schritt) und brauchen
  keinen Handgriff.
- Vorher legt derselbe Schritt **automatisch eine Sicherung** an (Dump, die letzten 10
  bleiben).
- Rückwärts kompatibel für eine Version, wo es geht: erst Spalte hinzufügen, später
  entfernen.

## Hintergrundjobs

- Warteschlange in Postgres, ohne zusätzlichen Dienst. Neue Projekte nehmen **pg-boss**.
  Eine bewährte eigene Warteschlange bleibt.
- Ein Worker-Container. Jobs sind wiederholbar (idempotent) und haben eine Zeitgrenze.

## Dateien

- Supabase Storage. Zugriff nur über die App oder signierte, kurzlebige URLs.
- Prüfungen beim Hochladen: siehe [04](04-sicherheit.md).

## Images und Dienste

- Je Dienst ein Image (z. B. web, worker, migrator), gebaut nur beim Release
  ([01](01-runner-ci-release.md)), mit OCI-Labels und `HEALTHCHECK`, läuft als Nicht-root.
- Gateway zur Datenbank-API: das, was die aktuelle Supabase-Vorlage mitbringt (heute
  Envoy). Ein älteres Kong bleibt bis zum nächsten größeren Supabase-Update.
- Netz `intern` ohne Internetzugang für Datenbank und interne Dienste. Nur die Web-App
  (und, falls nötig, die Auth-API für eine Telefon-App) ist über den Reverse Proxy
  erreichbar.

## Monorepo (wenn mehrere Apps)

- `apps/<name>` je App, `packages/<name>` für gemeinsame Verträge (z. B. die API einer
  Telefon-App). Eine Vertragsänderung prüft beide Seiten im selben PR.
