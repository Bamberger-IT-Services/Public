# Anweisungen für Claude – alle Projekte von Bamberger IT-Services

Gemeinsame Regeln, damit jedes Projekt gleich aufgebaut, geprüft und betrieben wird und
Grundsatzfragen nur einmal beantwortet werden müssen. Die Dateien sind öffentlich. Sie
enthalten deshalb **keine** internen Namen, Server, Adressen oder Geheimnisse. Die stehen im
privaten Repo `Bamberger-IT-Services/DEV`.

| Datei | Inhalt | Stand |
|---|---|---|
| [00-zusammenarbeit.md](00-zusammenarbeit.md) | Sprache, Entscheidungen per Auswahlfrage, Dashboard, Grenzen | gültig |
| [01-runner-ci-release.md](01-runner-ci-release.md) | eigener Runner, CI bei jedem PR, Dependabot, Release, VM-Update, Merge-Regel | gültig |
| 02-architektur.md | Stack, Datenbank, Migrationen, Worker, Images, Betrieb | in Arbeit |
| 03-anmeldung-und-konten.md | Anmeldung, 2FA, Sitzungen, Sperren, Rollen | in Arbeit |
| 04-sicherheit.md | Prüfungen, Header, Uploads, Audit, Datenschutz | in Arbeit |

**Vorrang:** Projekt-`CLAUDE.md` mit begründeter Abweichung > diese Anweisungen > allgemeine
Gewohnheiten. Ändert sich eine Regel hier, gilt sie ab dann für alle Projekte. Bestehende
Projekte ziehen nach, sobald sie den Bereich anfassen.

## Text für die Projektanweisung (claude.ai-Projekt bzw. `CLAUDE.md`)

In jedem Claude-Projekt als Anweisung einfügen und nur die zwei Projektzeilen anpassen:

```text
Für dieses Projekt gelten die gemeinsamen Anweisungen von Bamberger IT-Services:
https://github.com/Bamberger-IT-Services/public/tree/main/anweisungen
Lies vor der ersten Arbeit README.md und alle dort als „gültig“ markierten Dateien
(Rohtext: https://raw.githubusercontent.com/Bamberger-IT-Services/public/main/anweisungen/<datei>).
Sie gehen allgemeinen Gewohnheiten vor; eine Abweichung steht begründet in der CLAUDE.md des Projekts.
Kurz: Tobias mit „du“, Deutsch; Entscheidungen per Auswahlfrage (eine je Nachricht, alle Infos
in Frage und Antworten); Merge nach main selbst, sobald CI grün und konfliktfrei; Geheimnisse nie
in Git/Chat; Löschen nur mit Freigabe.

Projekt: <Name> – Code-Repo Bamberger-IT-Services/<repo>, Projektordner DEV/proj-<name>/
Abweichungen: <keine | siehe CLAUDE.md>
```
