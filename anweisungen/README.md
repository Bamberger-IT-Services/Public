# Anweisungen für Claude – alle Projekte von Bamberger IT-Services

Gemeinsame Regeln, damit jedes Projekt gleich aufgebaut, geprüft und betrieben wird und
Grundsatzfragen nur einmal beantwortet werden müssen. Alles, was Claude dafür braucht, steht
in diesem Ordner (Anweisungen und [`vorlagen/`](vorlagen/)). Die Dateien sind öffentlich und
enthalten deshalb **keine** internen Namen, Server, Adressen oder Geheimnisse. Solche Werte
stehen im jeweiligen Projekt.

| Datei | Inhalt |
|---|---|
| [00-zusammenarbeit.md](00-zusammenarbeit.md) | Sprache, Entscheidungen per Auswahlfrage, Dashboard, Grenzen |
| [01-runner-ci-release.md](01-runner-ci-release.md) | eigener Runner, CI bei jedem PR, Dependabot, Release, VM-Update, Merge-Regel |
| [02-architektur.md](02-architektur.md) | Stack, Datenbank mit RLS, Migrationen, Jobs, Images |
| [03-anmeldung-und-konten.md](03-anmeldung-und-konten.md) | Einladung, Passwörter, 2FA, Sitzungen, Fehlversuche |
| [04-sicherheit.md](04-sicherheit.md) | automatische Prüfungen, Sicherheitsbericht, HTTP, Uploads, Geheimnisse, Protokolle, Datenschutz |
| [05-betrieb.md](05-betrieb.md) | VM, Netz, Container-Härtung, Konfiguration, Sicherungen, Überwachung, Mail |
| [06-qualitaet-und-doku.md](06-qualitaet-und-doku.md) | Tests, Barrierefreiheit, Oberfläche, Doku-Gerüst, Konventionen |
| [vorlagen/](vorlagen/) | `ci.yml`, `release.yml`, `dependabot.yml`, PR-Vorlage, Compose-Bausteine, Runner-Skript, `UPDATE.md` |

**Neues Projekt:** Es startet nach diesem Zielbild. **Bestehendes Projekt:** Es zieht nach,
sobald es einen Bereich anfasst. Die Lücken stehen als Aufgaben im Entwicklerdashboard des
Projekts.

**Vorrang:** Projekt-`CLAUDE.md` mit begründeter Abweichung > diese Anweisungen > allgemeine
Gewohnheiten. Ändert sich eine Regel hier, gilt sie ab dann für alle Projekte.

## Text für die Projektanweisung (claude.ai-Projekt bzw. `CLAUDE.md`)

In jedem Claude-Projekt als Anweisung einfügen und nur die zwei Projektzeilen anpassen:

```text
Für dieses Projekt gelten die gemeinsamen Anweisungen von Bamberger IT-Services:
https://github.com/Bamberger-IT-Services/public/tree/main/anweisungen
Lies vor der ersten Arbeit README.md und alle dort genannten Anweisungen (00–06)
(Rohtext: https://raw.githubusercontent.com/Bamberger-IT-Services/public/main/anweisungen/<datei>).
Sie gehen allgemeinen Gewohnheiten vor; eine Abweichung steht begründet in der CLAUDE.md des Projekts.
Kurz: Tobias mit „du“, Deutsch; Entscheidungen per Auswahlfrage (eine je Nachricht, alle Infos
in Frage und Antworten); Merge nach main selbst, sobald CI grün und konfliktfrei; Geheimnisse nie
in Git/Chat; Löschen nur mit Freigabe.

Projekt: <Name> – Code-Repo Bamberger-IT-Services/<repo>, lokaler Ordner <pfad>
Abweichungen: <keine | siehe CLAUDE.md>
```
