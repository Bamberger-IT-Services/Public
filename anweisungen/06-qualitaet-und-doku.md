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

### Barrierefreiheit (WCAG 2.2 AA)

- **Kontrast:** Text mindestens 4,5:1, auch gedämpfter Text. Bedienelemente und ihre Ränder
  (Feld, Checkbox, Fokus) mindestens 3:1. Sehr leise Farben nur für Dekoration, nie für
  lesbaren Text. Die Tokens werden automatisch auf Kontrast geprüft.
- **Fokus:** `:focus-visible` mit einem vollen Ring von 2 px und Abstand, nie
  halbtransparent und nie `outline: none` ohne Ersatz.
- **Tastatur:** Alles ist per Tastatur bedienbar, in sinnvoller Reihenfolge.
- **Zielgrößen:** mindestens 32 px im Web, 44 px auf dem Telefon. Eingabefelder auf dem
  Telefon mit mindestens 16 px Schrift, sonst zoomt iOS beim Antippen.
- **Einstellungen des Systems** werden beachtet:
  - `prefers-reduced-motion`: keine Bewegung, keine automatisch wechselnden Bildstrecken;
  - `prefers-reduced-transparency`: deckende statt gläserne Flächen;
  - `prefers-contrast: more`: kräftigere Ränder;
  - Hell- und Dunkelmodus.
- **Farbe:** Status zeigt nie nur die Farbe, immer auch Text oder Symbol.
- **Formulare:** Beschriftung, Fehlermeldung am Feld, `autocomplete`-Attribute.

### Designsystem

- **Eine Quelle:** `tokens.json` mit Hell und Dunkel. Ein Skript erzeugt daraus `tokens.css`
  und `tokens.ts`; die Quelle darf px enthalten, die Ausgabe nutzt `rem`.
- Dazu gehören:
  - feste Schriftstile statt freier Größen;
  - eine Skala für Radien und Abstände;
  - Ziffern gleicher Breite (`tabular-nums`) für Beträge und Tabellen.
- **Keine fest eingetragenen Farben** im Code. UI-Bibliotheken (z. B. shadcn) werden über
  ihre Variablen auf die Projekt-Tokens abgebildet.
- **Aufbau des Designsystem-Pakets:**
  - `README.md` als Markenbuch: Grundsätze, Farben, Schrift, Ton;
  - `components/<Name>/README.md` mit Regeln und `preview.html`;
  - `assets/` mit Logo hell/dunkel und Bildern;
  - `tokens.*`.
- **Schrift:** Systemschrift (`system-ui`), kein Webfont. Gibt es doch einen Webfont, wird er
  lokal ausgeliefert, ohne Anfragen an fremde Server.
- **Icons:** eine Bibliothek je Projekt (Vorgabe Lucide, Strichstärke 2), lokal gebündelt
  und nicht von einem CDN geladen.
- **Bilder:** lokal, mit Lizenz und Namensnennung in `assets/…/README.md`. Platzhalterbilder
  werden vor dem Betrieb ersetzt.

### Text und Ton

- Deutsch, `lang="de"`. Die Ansprache ist **in einem Projekt überall gleich** (siehe dessen
  Entscheidung).
- Knöpfe sind Verben („Speichern“, „Vertrag anlegen“), die Navigation benennt den Inhalt.
  Keine VERSALIEN als Gestaltung, keine Emojis.
- Fachbegriffe stehen in einem Glossar, die Oberfläche erklärt sie per Hilfe-Blase.
- **Zustände:** Jede Liste hat einen Leer-, Lade- und Fehlerzustand. Leerzustände sind
  ehrlich: ein Satz und eine Aktion, keine erfundenen Zahlen.
- **Fehlerseiten:** `error.tsx`, `not-found.tsx` und `global-error.tsx` auf Deutsch, mit
  Fehler-ID und einem Weg zurück.

### KI in der Oberfläche

- Die KI schlägt vor, der Mensch bestätigt. Nichts wird ohne Bestätigung gespeichert,
  verschickt oder gebucht.
- Vorschläge sind als KI-Vorschlag gekennzeichnet. Antworten nennen ihre Fundstelle
  (Dokument, Datensatz).
- Datenschutz: siehe [04](04-sicherheit.md).

### Design-Übergabe

- Entwürfe (z. B. aus Claude Design) sind **Referenz für Aussehen und Abläufe, kein Code**.
  Umgesetzt wird neu, optisch 1:1.
- Je Version gibt es eine Änderungsdatei. Ältere Versionen liegen unter `versionen/vN/`.
  Überholte Dateien werden als abgelöst gekennzeichnet, damit nie zwei Quellen gelten.
- Ein **Abgleich Design ↔ Code** hält je Bildschirm fest: umgesetzt / teilweise / fehlt.
- Widerspricht ein Entwurf diesen Anweisungen (z. B. Passwortregeln, Kontrast, Fokus),
  gelten die Anweisungen. Der Entwurf bekommt einen Vermerk für die nächste Version.

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
