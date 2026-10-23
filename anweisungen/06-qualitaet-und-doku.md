# 06 · Qualität, Oberfläche und Dokumentation

## Tests

| Ebene | Werkzeug | Was |
|---|---|---|
| Unit | vitest | Rechenregeln, Prüfungen, Hilfsfunktionen |
| Integration | vitest gegen Wegwerf-Datenbank | Dienste, RLS, Migrationen, API-Routen |
| Ende-zu-Ende | Playwright | Kernabläufe: Anmeldung mit 2FA, je Modul ein Hauptweg, Rechte |
| Barrierefreiheit | `@axe-core/playwright` in den E2E-Tests | keine Verstöße der Stufen „serious“/„critical“ |
| Mobil | Playwright bei 390 px Breite | kein waagrechtes Scrollen, alles bedienbar |

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
| `README.md` | Überblick, Stand (Version, Datum), Schnellstart lokal |
| `docs/handbuch/` | Nutzer: ein Kapitel je Bereich, mit Bildschirmfotos |
| `docs/EINRICHTUNG.md` | Erstinstallation auf der VM |
| `docs/UPDATE.md` | Update und Rückweg ([Vorlage](vorlagen/UPDATE.md)) |
| `docs/sicherheit/`, `docs/DATENSCHUTZ.md` | siehe [04](04-sicherheit.md) |
| `CHANGELOG.md`, `docs/releases/` | siehe [01](01-runner-ci-release.md) |
| Entscheidungsprotokoll | Wiki-Seite „Entscheidungen“ oder `DECISIONS.md`, nummeriert, mit Datum und Begründung |
| `CLAUDE.md` | Verweis auf diese Anweisungen und die Projektregeln |

- **Doku im selben PR:** Was Bedienung, Einrichtung oder Betrieb ändert, bringt die Doku
  gleich mit. Die PR-Vorlage fragt das ab.
- Nach jeder Arbeitsrunde den README-Stand und die offenen Issues mit dem tatsächlichen
  Stand abgleichen.

## Code-Konventionen

- TypeScript strikt, kein `any` ohne Kommentar. ESLint mit der Next.js-Konfiguration.
- Fachbegriffe auf Deutsch im Code, wenn das Projekt es so hält (z. B. `mietvertrag`,
  `buchung`). Technische Begriffe bleiben englisch.
- Beträge in Cent (Ganzzahl), Datum als ISO im Code, formatiert erst in der Oberfläche.
- Commits auf Deutsch, im Imperativ oder als kurze Beschreibung. Der Bezug (`A-nn`, `E-nn`)
  steht im PR.
