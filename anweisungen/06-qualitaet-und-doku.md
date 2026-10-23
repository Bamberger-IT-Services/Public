# 06 · Qualität, Oberfläche und Dokumentation

## Tests

| Ebene | Werkzeug | Was |
|---|---|---|
| Unit | vitest | Rechenregeln, Prüfungen, Hilfsfunktionen |
| Integration | vitest gegen Wegwerf-Datenbank | Dienste, RLS, Migrationen, API-Routen |
| Ende-zu-Ende | Playwright | Kernabläufe: Anmeldung mit 2FA, je Modul ein Hauptweg, Rechte |
| Barrierefreiheit | `@axe-core/playwright` in den E2E-Tests | keine Verstöße der Stufen „serious“/„critical“ |
| Mobil | Playwright bei 390 px Breite | kein waagrechtes Scrollen, alles bedienbar |
| Vertrag | vitest | gemeinsame Typen/Schemas einer API, die eine andere App nutzt (z. B. Telefon-App), auf beiden Seiten |
| Jobs | vitest gegen Wegwerf-Datenbank | jeder Hintergrundjob zweimal ausgeführt = gleiches Ergebnis (idempotent) |
| Rauchtest | CI (`image-probe`) und nach jedem Update | App startet, `/api/health` ist ok |

- **Schwerpunkt:** geschäftskritische Wege, Fehlerbehandlung, Randfälle, Rechte- und
  Mandantengrenzen, Datenintegrität (Geld, Fristen, Löschen). Nicht testen: triviale
  Zugriffe, Framework-Code, Einmal-Skripte.
- **Abdeckung:** wird in der CI gemessen und im Lauf angezeigt. Ziel sind 80 % Zeilen für
  Fach- und Rechenlogik (`lib/`, `src/domain/` o. Ä.). Kein Gesamtziel für die ganze App,
  das belohnt nur Tests für Unwichtiges.
- Jede neue Funktion bringt im PR ihren **Testplan** mit: was wird wie getestet
  (Unit/Integration/E2E), welche Randfälle.
- Jeder behobene Fehler bekommt einen Test, der ihn vorher gefunden hätte.
- Ein Test, der mal grün, mal rot ist, wird repariert oder mit Aufgabe und Begründung
  übersprungen. Er bleibt nicht einfach wackelig im Lauf.

## Oberfläche

- **Barrierefreiheit:** Ziel ist WCAG 2.2 AA:
  - Kontrast der Tokens geprüft;
  - vollständig per Tastatur bedienbar, sichtbarer Fokus;
  - `prefers-reduced-motion` beachtet;
  - Formulare mit Beschriftung und Fehlermeldung am Feld.
- **Design-System:** Tokens aus einer Quelle, per Skript in CSS/TS übernommen. Schriftgrößen
  in `rem`, Hell- und Dunkelmodus. Schriften lokal ausgeliefert, ohne Anfragen an fremde
  Server.
- **Fehlerseiten:** `error.tsx`, `not-found.tsx` und `global-error.tsx` auf Deutsch, mit
  Fehler-ID und einem Weg zurück.
- **Sprache:** Deutsch, `lang="de"`. Die Texte sprechen den Nutzer einheitlich an und
  benutzen die Begriffe der Fachseite.
- Leere Zustände, Ladezustände und Fehlerzustände gibt es für jede Liste.

## Dokumentation im Repo

| Datei | Für wen |
|---|---|
| `README.md` | Was und wozu, Stand (Version, Datum), **Schnellstart lokal in unter 5 Minuten**, nichtfunktionale Anforderungen ([02](02-architektur.md)) |
| `docs/handbuch/` | Nutzer: ein Kapitel je Bereich, mit Bildschirmfotos |
| `docs/EINRICHTUNG.md` | Erstinstallation auf der VM |
| `docs/UPDATE.md` | Update und Rückweg ([Vorlage](vorlagen/UPDATE.md)) |
| `docs/sicherheit/`, `docs/DATENSCHUTZ.md` | siehe [04](04-sicherheit.md) |
| `CHANGELOG.md`, `docs/releases/` | siehe [01](01-runner-ci-release.md) |
| Entscheidungsprotokoll | Wiki-Seite „Entscheidungen“ oder `DECISIONS.md`, nummeriert, mit Datum und Begründung (siehe unten) |
| `docs/api/` | wenn das Projekt eine API für andere Apps hat: Endpunkte mit Beispiel, Anmeldung, Fehlercodes, Drosselung, Seitenweise Abfrage (aus den zod-Schemas erzeugt, wo möglich) |
| `docs/runbooks/`, `docs/stoerungen/` | siehe [07](07-stoerungen-und-runbooks.md) |
| `CLAUDE.md` | Verweis auf diese Anweisungen und die Projektregeln |

- **Verlinken statt kopieren:** Ein Sachverhalt steht an genau einer Stelle, andere
  Dokumente verweisen darauf. Veraltete Doku ist schlimmer als keine.
- **Doku im selben PR:** Was Bedienung, Einrichtung oder Betrieb ändert, bringt die Doku
  gleich mit. Die PR-Vorlage fragt das ab.
- Nach jeder Arbeitsrunde den README-Stand und die offenen Issues mit dem tatsächlichen
  Stand abgleichen.

## Entscheidungen festhalten

- **Produktentscheidungen** (per Auswahlfrage, [00](00-zusammenarbeit.md)): kurzer Eintrag
  `E-nn` mit Frage, Möglichkeiten, Antwort und Datum.
- **Technische Entscheidungen** zu Architektur, Datenmodell, Sicherheit, Betrieb oder neuen
  Abhängigkeiten: eine **ADR** ([Vorlage](vorlagen/adr.md)) mit Ausgangslage, betrachteten
  Möglichkeiten, Abwägung und Folgen. Status: vorgeschlagen, angenommen, abgelöst oder
  verworfen. Eine abgelöste ADR bleibt stehen und verweist auf die neue.
- Was diese Anweisungen schon festlegen, braucht keine eigene ADR. Eine Abweichung davon
  braucht eine.

## Technische Schulden

- Jede bekannte Schwachstelle im Code, in Tests, Abhängigkeiten, Doku oder Betrieb wird eine
  Aufgabe im Dashboard, mit Art (Code, Architektur, Test, Abhängigkeit, Doku, Betrieb).
- **Rangfolge:** (Auswirkung + Risiko) × (6 − Aufwand), je 1–5. Die oberen Punkte kommen
  in das nächste Release, neben den Funktionen.
- Bei jedem Minor-Release prüft Claude die Liste. Ein Punkt verschwindet erst, wenn er
  behoben ist, und nicht dadurch, dass man ihn vergisst.

## Code-Konventionen

- TypeScript strikt, kein `any` ohne Kommentar. ESLint mit der Next.js-Konfiguration.
- Fachbegriffe auf Deutsch im Code, wenn das Projekt es so hält (z. B. `mietvertrag`,
  `buchung`). Technische Begriffe bleiben englisch.
- Beträge in Cent (Ganzzahl), Datum als ISO im Code, formatiert erst in der Oberfläche.
- Commits auf Deutsch, im Imperativ oder als kurze Beschreibung. Der Bezug (`A-nn`, `E-nn`)
  steht im PR.
