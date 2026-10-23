# 06 · Qualität, Oberfläche und Dokumentation

## Tests

| Ebene | Werkzeug | Was |
|---|---|---|
| Unit | vitest | Rechenregeln, Prüfungen, Hilfsfunktionen |
| Integration | vitest gegen Wegwerf-Datenbank | Dienste, RLS, Migrationen, API-Routen |
| Ende-zu-Ende | Playwright | Kernabläufe: Anmeldung mit 2FA, je Modul ein Hauptweg, Rechte |
| Barrierefreiheit | `@axe-core/playwright` in den E2E-Tests | keine Verstöße der Stufen „serious“/„critical“ |
| Breite | Playwright bei 390 px bzw. 1024 px | Zielbreite je Oberfläche (siehe Oberfläche › Bildschirmbreiten), kein waagrechtes Scrollen |
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

### Gestaltungsgrundlage (Tobias, 23.10.2026: für alle Projekte)

Grundlage ist der Skill **„Apple Design“**: flüssige, physische Oberflächen nach Apples
WWDC-Grundsätzen, übertragen auf das Web. Daraus gilt mindestens:

- **Rückmeldung beim Drücken**, nicht erst beim Loslassen. Keine künstlichen Verzögerungen.
- **Direkt bewegen:** Was man zieht, folgt dem Finger bzw. der Maus 1:1.
- **Unterbrechbar:** Jede Bewegung lässt sich mittendrin greifen und umkehren. Für alles
  Greifbare gibt es Federn statt fester Animationen (Dämpfung 1,0 als Vorgabe, Federn nur
  nach einer Wischbewegung).
- **Gleicher Weg:** Was rechts hereinkommt, geht rechts wieder hinaus. Menüs und Popover
  wachsen aus ihrem Auslöser.
- **Glas** (`backdrop-filter`) nur für schwebende Ebenen wie Leisten und Blätter, nie Glas
  auf Glas. Bei `prefers-reduced-transparency` werden die Flächen deckend.
- **Systemschrift** mit Laufweite je Größe: groß enger, klein leicht weiter.

Das Markenbild (Farben, Logo, Bildsprache) wählt jedes Projekt selbst.

### Bildschirmbreiten (Tobias, 23.10.2026)

| Oberfläche | Zielbreite |
|---|---|
| Anmeldung, Ersteinrichtung, Fehlerseiten | ab **390 px** voll bedienbar |
| Kundenportale (z. B. Mieter) | ab **390 px** voll bedienbar |
| Verwaltungsoberfläche **mit eigener Telefon-App** | ab **1024 px**. Darunter erscheint ein Hinweis auf die Telefon-App |
| Verwaltungsoberfläche **ohne** Telefon-App | ab **390 px** voll bedienbar |

Bis zur Zielbreite gibt es nirgends waagrechtes Scrollen.

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
- **Eigene Farbthemen** (z. B. Markenfarbe je Konto) sind erlaubt (Tobias, 23.10.2026).
  - Die Vorschau prüft den Kontrast nach WCAG.
  - Ein Thema unter 4,5:1 für Text bzw. 3:1 für Bedienelemente lässt sich **nicht
    speichern**. Die Vorschau schlägt dann eine passende Abstufung vor.
  - Hell und Dunkel werden je für sich geprüft.

### Text und Ton

- Deutsch, `lang="de"`.
- **Ansprache** (Tobias, 23.10.2026, für alle Projekte):
  - **„Sie“**, wo Kunden lesen: Anmeldung, Ersteinrichtung, Kundenportale, E-Mails,
    Dokumente.
  - In der **Arbeitsoberfläche keine Anrede**, sondern neutrale Texte („Vertrag speichern“,
    „Keine offenen Vorgänge“).
  - Kein „du“ in Produkten. Für die Zusammenarbeit mit Claude bleibt es beim „du“
    ([00](00-zusammenarbeit.md)).
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

## Dokumentation je Version (Tobias, 23.10.2026)

Die Dokumentation auf GitHub zeigt immer den Stand eines Releases. Jede Version hat ihre
eigene, abrufbare Doku.

- **Bei jedem Release** bringt der Release-PR die gesamte Doku auf den Stand der neuen
  Version ([01](01-runner-ci-release.md) › Release-Prüfliste):
  - **Geänderte** Funktionen und Inhalte sind angepasst: Schritte, Knopfnamen, Felder,
    Einstellungen.
  - **Entfallene** Funktionen sind aus Handbuch, README und Anleitungen entfernt. Was in der
    Oberfläche „Folgt später“ heißt, steht genauso in der Doku.
  - **Bilder und Bildschirmfotos** sind neu aufgenommen. Alte, nicht mehr passende Bilder
    werden gelöscht, nicht nur ersetzt.
  - Jede Doku-Seite trägt oben **„Stand: TT.MM.JJJJ · Version X.Y.Z“**. Der README-Stand ist
    aktualisiert.
- **Bildschirmfotos:**
  - Sie zeigen die **echte App im aktuellen Design**, aufgenommen von einem Skript
    (`docs:bilder`, Playwright) mit Testdaten. Nie echte Daten.
  - Formate: Desktop 1440 px, Telefon 390 px, hell; dunkel nur, wo es etwas zeigt.
  - Feste Dateinamen je Bild, damit Verweise stabil bleiben.
  - Ist ein Bereich noch nicht nach dem neuesten Designvorschlag umgesetzt, darf ein Bild aus
    der Design-Übergabe stehen. Es ist dann deutlich als **„Entwurf (Design vN)“** beschriftet
    und wird ersetzt, sobald der Bereich umgesetzt ist.
- **Versionierte Doku:**
  - Das Git-Tag `vX.Y.Z` friert die Doku dieser Version ein. Es gibt keine kopierten
    Ordner je Version, eine Quelle reicht.
  - Das README hat einen Abschnitt **„Dokumentation nach Version“** mit einer Zeile je
    Minor-Version: Version · Datum · Handbuch
    (`https://github.com/<org>/<repo>/tree/vX.Y.Z/docs/handbuch`) · Release-Notiz.
  - Die neueste Zeile steht oben, ältere bleiben stehen.
  - Der Text des GitHub-Release verlinkt das Handbuch genau dieses Tags.
  - Bei einem Patch (X.Y.Z+1) wird die Zeile der Minor-Version auf das neue Tag gesetzt,
    wenn sich die Doku geändert hat.
- **`main`** zeigt die Doku der nächsten, noch unveröffentlichten Version. Seiten mit
  neuen, noch nicht veröffentlichten Funktionen sind markiert („ab Version X.Y“).

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
  Issue mit Label `technische-schuld` und Art (Code, Architektur, Test, Abhängigkeit, Doku,
  Betrieb), siehe [08](08-aufgaben-und-github-project.md).
- **Rangfolge:** (Auswirkung + Risiko) × (6 − Aufwand), je 1–5. Die oberen Punkte kommen
  in das nächste Release, neben den Funktionen.
- Bei jedem Minor-Release prüft Claude die Liste. Ein Punkt verschwindet erst, wenn er
  behoben ist, und nicht dadurch, dass man ihn vergisst.

## Code-Konventionen

- TypeScript strikt, kein `any` ohne Kommentar. ESLint mit der Next.js-Konfiguration.
- Fachbegriffe auf Deutsch im Code, wenn das Projekt es so hält (z. B. `mietvertrag`,
  `buchung`). Technische Begriffe bleiben englisch.
- Beträge in Cent (Ganzzahl), Datum als ISO im Code, formatiert erst in der Oberfläche.
- Commits auf Deutsch, im Imperativ oder als kurze Beschreibung. Der Bezug (`#nr`, `E-nn`)
  steht im PR.
