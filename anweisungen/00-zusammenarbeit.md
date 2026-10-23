# 00 · Zusammenarbeit mit Claude

Gilt in jedem Projekt, im Chat genauso wie im Code.

## Ansprache und Sprache

- Tobias mit „du“ ansprechen, auf Deutsch. Oberflächen, Doku, Commits und Kommentare
  schreibst du ebenfalls auf Deutsch. Code-Bezeichner dürfen deutsch sein, wenn das Projekt
  es so hält.
- Einfache Sprache. Fachbegriffe kurz erklären, wenn Tobias sie entscheiden soll.

## Entscheidungen

- Fakten selbst nachschlagen (Code, Wiki, Doku) und nur echte Entscheidungen vorlegen.
- Fragen als **Auswahlfrage** (AskUserQuestion): **eine Frage je Nachricht**, 2–3 konkrete
  Antworten, die empfohlene zuerst. Alle nötigen Infos stehen in Frage und Antworten.
- Was nach dieser Frage folgen würde, erst nach der Antwort ausgeben.
- Jede Entscheidung festhalten, bevor sie umgesetzt wird. Ort ist das Entscheidungsprotokoll
  des Projekts (Wiki „Entscheidungen“ oder `DECISIONS.md`) und das Entwicklerdashboard.
  Nummern werden fortlaufend vergeben und nie neu.
- Technik, die eine Anweisung hier festlegt, nicht noch einmal fragen.

## Entwicklerdashboard

- Jedes Projekt hat `entwickler-dashboard/` (`index.html` + `daten.js`) für
  **Entscheidungen** (`E-nn`) und **Verlauf**, dazu ein Link auf das GitHub-Project.
- Aufgaben stehen nicht im Dashboard, sondern als Issues im Code-Repo
  ([08](08-aufgaben-und-github-project.md), Tobias, 23.10.2026).
- Am Ende jeder Arbeitsrunde `daten.js` pflegen. `stand` kommt aus
  `TZ=Europe/Berlin date +"%d.%m.%Y %H:%M"`, nie geschätzt. Dazu ein Satz im `verlauf`.
- Entschiedenes nicht löschen, sondern `status: "entschieden"` mit Antwort eintragen.
  Löst die Entscheidung Arbeit aus, steht die Issue-Nummer dabei.

## Arbeiten im Hintergrund

- Erst ein Satz, was du vorhast, dann anfangen. Kein Plan, der auf Freigabe wartet, wenn die
  Aufgabe klar ist.
- Längere Arbeit mit Aufgabenliste. Ist Tobias nicht da, die vernünftigste Lesart nehmen
  und oben vermerken, welche.
- Am Ende kurz: was herauskam, was offen ist, nächster sinnvoller Schritt.

## Grenzen

- Geheimnisse (Passwörter, Tokens, Schlüssel) nie in Git, Chat, Wiki oder Client-Variablen
  (`NEXT_PUBLIC_*`, `EXPO_PUBLIC_*`). `.env*` außer `.env.example` nie committen.
- Daten löschen nur mit ausdrücklicher Freigabe. Lokale Datenbanken nur nach Sicherung ändern.
- Produktive Schritte (Release veröffentlichen, Produktiv-VM umstellen, Einstellungen bei
  GitHub oder anderen Diensten ändern) nur nach OK.
- Merge nach `main` im Code-Repo: Das macht Claude selbst, sobald die CI grün und der PR
  konfliktfrei ist und das Review vor dem Merge erledigt ist (siehe [01](01-runner-ci-release.md)).
