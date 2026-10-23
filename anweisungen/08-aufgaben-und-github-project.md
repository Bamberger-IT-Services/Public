# 08 · Aufgaben und GitHub-Project

Gilt für jedes Projekt mit eigenem Code-Repository (Tobias, 23.10.2026). Aufgaben stehen an
**genau einer Stelle**: als Issue im Code-Repo, geordnet über ein GitHub-Project. So sehen
Claude und Codex dieselbe Liste, und eine Aufgabe ist erst erledigt, wenn ihr PR gemergt ist.
Entscheidungen bleiben im Entwicklerdashboard ([00](00-zusammenarbeit.md)).

## Auf einen Blick

```
Backlog ──► Ready ──► In Arbeit ──► Review (PR) ──► Erledigt
            ▲                                       ▲
            Tobias legt die Reihenfolge fest        Issue schließt sich beim Merge
```

| Was | Wo |
|---|---|
| Funktionen, Fehler, Ideen, technische Schulden | Issues im Code-Repo |
| Reihenfolge, Status, Zeitleiste | GitHub-Project „&lt;Projekt&gt; Roadmap“ |
| Releases | Milestones (`vX.Y.0`) |
| Entscheidungen (`E-nn`) und Verlauf | Entwicklerdashboard und Entscheidungsprotokoll |

## Einrichten (einmal je Projekt)

Die Einrichtung ändert Einstellungen bei GitHub und braucht deshalb einmal Tobias' OK
([00](00-zusammenarbeit.md) › Grenzen). Danach pflegt Claude Issues und Status selbst.

- **Zugang:** `gh` braucht die Scopes `repo`, `workflow` und `project`. Fehlt `project`, führt
  Tobias `gh auth refresh -s project` aus und bestätigt im Browser.
- **Project:** auf Organisationsebene (`Bamberger-IT-Services`), Name „&lt;Projekt&gt; Roadmap“,
  mit dem Code-Repo verknüpft.
  - Feld **Status:** Backlog, Ready, In Arbeit, Review, Erledigt.
  - Ansichten: **Board** (nach Status), **Tabelle**, **Roadmap** (nach Milestone).
  - Abläufe: neue Issues des Repos automatisch aufnehmen (Status Backlog); geschlossene
    Issues und gemergte PRs auf Erledigt.
- **Issue Types** der Organisation: Epic, Feature, Bug, Task. Fehlende legt Tobias in den
  Organisationseinstellungen an.
- **Labels** (in jedem Projekt gleich): `prio:hoch`, `prio:mittel`, `prio:niedrig`,
  `agent:claude`, `agent:codex`, `blocked`, `technische-schuld`. Dazu Bereichslabels
  `area:…` je Projekt (z. B. `area:web`, `area:mobile`, `area:infra`, `area:docs`).
- **Milestones:** einer je geplantem Release.
- **Issue-Vorlage:** [`vorlagen/issue-aufgabe.yml`](vorlagen/issue-aufgabe.yml) nach
  `.github/ISSUE_TEMPLATE/aufgabe.yml`.
- **Dashboard:** Link auf das Project eintragen ([00](00-zusammenarbeit.md)).
- **`CLAUDE.md` und `AGENTS.md`:** Verweis auf diese Anweisung, damit Claude und Codex nach
  denselben Regeln arbeiten.

## Ein gutes Issue

- **Ein Issue ist ein PR.** Was nicht in einen PR passt, wird ein Epic mit Sub-Issues.
- **Titel als Ergebnis:** „Mieterliste mit Suche“, nicht „Mieter“.
- **Inhalt:** Ziel (ein Satz aus Sicht der Nutzer), prüfbare Akzeptanzkriterien, betroffene
  App bzw. Bereich, Bezug (`E-nn`, andere Issues).
- Typ, Bereichslabel und Milestone sind gesetzt, sobald das Issue nach Ready geht.

## Abarbeiten

- **Nächstes Issue** ist das oberste in Ready ohne `agent:`-Label und ohne `blocked`.
- **Vor dem Start:** Label `agent:claude` (bzw. `agent:codex`) setzen, Status auf In Arbeit.
  Ein Issue mit fremdem `agent:`-Label fasst du nicht an.
- Branch `issue-<nr>-<kurzname>`, PR mit `Closes #<nr>`, Doku im selben PR
  ([06](06-qualitaet-und-doku.md)). Der PR steht auf Review.
- **Merge** wie in [01](01-runner-ci-release.md). Das Issue schließt sich dann selbst und
  wandert auf Erledigt.
- Was unterwegs auffällt (Fehler, Idee, Schuld), wird ein neues Issue im Backlog und nicht
  Teil des laufenden PRs.
- **Am Ende jeder Arbeitsrunde:** Status im Board stimmt, offene Fragen stehen im Issue.

## Entscheidungen und Issues

- Braucht ein Issue eine Entscheidung, kommt sie als Auswahlfrage an Tobias
  ([00](00-zusammenarbeit.md)). Ist er nicht da: Label `blocked`, Frage als offene `E-nn` ins
  Dashboard, Verweis im Issue, weiter mit dem nächsten Issue.
- Löst eine Entscheidung Arbeit aus, entsteht ein Issue mit Verweis auf `E-nn`. Im Dashboard
  steht bei der Entscheidung die Issue-Nummer.

## Neue Design-Version

Für Entwürfe aus Claude Design gilt zusätzlich [06](06-qualitaet-und-doku.md) ›
Design-Übergabe.

1. **Ablegen:** Die neue Version kommt per PR nach `handoff/`.
2. **Planen, noch nicht bauen:** Claude schreibt den Abgleich Design ↔ Code fort und legt ein
   Epic „Design vX umsetzen“ an, mit einem Sub-Issue je Bildschirm oder Funktion. Jedes
   Sub-Issue nennt den Pfad in `handoff/`, die Akzeptanzkriterien und als Prüfung „im
   Browser gegen den Entwurf geprüft, Bildschirmfotos im PR“.
3. Alles landet im Backlog. Claude schlägt die Reihenfolge vor, Tobias legt sie in Ready fest.
4. Lässt der Entwurf etwas offen oder widerspricht er diesen Anweisungen, entsteht eine
   Entscheidung (`E-nn`), und das Issue bekommt `blocked` (siehe oben).
5. **Umsetzen** wie gewohnt: ein Issue je PR. Sind alle Sub-Issues erledigt, schließt Claude
   das Epic.

## Technische Schulden

- Label `technische-schuld`, im Text die Art (Code, Architektur, Test, Abhängigkeit, Doku,
  Betrieb) und der Rang nach der Formel aus [06](06-qualitaet-und-doku.md). Daraus folgt
  das `prio:`-Label.

## Bestehende Projekte umstellen

1. Laufende Arbeit sauber abschließen (PR, Merge, Dashboard gepflegt), erst dann umstellen.
2. Die `A-nn` aus `entwickler-dashboard/daten.js` sammeln. Andere Aufgabenlisten außerhalb
   des Repos werden nicht übernommen und nicht verändert.
3. Für jeden Punkt im Code prüfen, ob er schon erledigt ist. Erledigtes wird kein Issue,
   sondern steht in einer Liste für Tobias.
4. Offene Punkte als Issues bzw. Epics anlegen, im Text die alte Nummer nennen
   („früher A-12“). Alles landet im Backlog; für Ready schlägt Claude eine Reihenfolge vor,
   Tobias legt sie fest.
5. Im Dashboard die Aufgabenliste leeren und den Link aufs Board eintragen. Die alten
   Einträge bleiben in der Git-Historie.
