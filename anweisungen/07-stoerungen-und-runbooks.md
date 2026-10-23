# 07 · Störungen, Fehlersuche und Runbooks

Was zu tun ist, wenn im Betrieb etwas schiefgeht. Der Ablauf ist auf einen Betreiber
(Tobias) und Claude als Helfer zugeschnitten. Rollen wie „Incident Commander“ entfallen.

## Schwere einer Störung

| Stufe | Bedeutung | Beispiel | Reaktion |
|---|---|---|---|
| **S1** | App nicht nutzbar oder Datenverlust/Datenleck möglich | Anmeldung geht nicht, Datenbank weg, fremde Daten sichtbar | sofort; Rückfall auf die alte Version prüfen |
| **S2** | wichtige Funktion gestört, kein Umweg | Buchungen speichern nicht, Mails gehen nicht raus | am selben Tag |
| **S3** | einzelne Funktion gestört, Umweg vorhanden | ein Export scheitert, Bildvorschau fehlt | nächstes Release |
| **S4** | Schönheitsfehler | Darstellung, Text | Aufgabe im Dashboard |

Bei möglichem **Datenleck** (S1) gilt zusätzlich die Meldepflicht nach DSGVO Art. 33:
innerhalb von 72 Stunden an die Aufsichtsbehörde, wenn ein Risiko für Betroffene besteht.
Claude erinnert daran, entscheidet es aber nicht.

## Ablauf

1. **Einordnen:** Stufe festlegen. Was geht nicht, für wen, seit wann? Was hat sich zuletzt
   geändert (Update, Konfiguration, Dienst)?
2. **Eindämmen vor Ursache:** Hilft ein Rückfall auf die alte Version
   ([01](01-runner-ci-release.md) › Rückweg), kommt der zuerst. Bei Datenleck den
   betroffenen Zugang sperren.
3. **Betroffene informieren:** bei S1/S2 ab ca. 30 Minuten Dauer. Kurz und sachlich: was ist
   gestört, was wir tun, wann die nächste Info kommt. Kanal ist der **Störungshinweis** in der
   App, wenn sie läuft, sonst Mail. Das Muster dafür ist die Komponente „Störungshinweis“ im
   Designsystem: ein Band oben in drei Stufen (Wartung, Eingeschränkt, Störung). Es entsteht
   automatisch aus dem Systemstatus oder wird von einem Admin mit Zeitraum und Zielgruppe
   gesetzt.
4. **Fehler suchen** (siehe unten), beheben, mit Test absichern.
5. **Nachbereiten:** Ab S2 schreibt Claude einen **Störungsbericht**
   ([Vorlage](vorlagen/stoerungsbericht.md)) unter `docs/stoerungen/JJJJ-MM-TT-<kurz>.md`.
   Er ist ohne Schuldzuweisung, mit Zeitlinie, Ursache (5× „Warum?“) und Maßnahmen. Jede
   Maßnahme wird eine Aufgabe im Dashboard.

## Fehlersuche (für jeden Fehler, nicht nur im Betrieb)

1. **Nachstellen:** erwartetes und tatsächliches Verhalten, genaue Schritte. Die
   Fehlermeldung wird wörtlich übernommen.
2. **Eingrenzen:** Welche Komponente? Was hat sich geändert (Commits, Abhängigkeiten,
   Konfiguration)? Was sagen die Logs, mit Fehler-ID?
3. **Ursache finden:** Vermutungen aufstellen und einzeln prüfen. Die Ursache wird behoben,
   nicht das Symptom.
4. **Beheben:** Zuerst kommt ein Test, der den Fehler zeigt, dann der Fix. Nebenwirkungen und
   Randfälle prüfen. Bleibt etwas offen, wird es eine Aufgabe, statt es still zu überspringen.

Ein wackeliger Test (mal grün, mal rot) ist ein Fehler wie jeder andere: nachstellen
(z. B. Schnelllauf mit nur dieser Datei, unter Last), Ursache finden. Das Überspringen
mit Aufgabe ist nur eine Übergangslösung.

## Runbooks

Für wiederkehrende Notfälle liegt je ein Runbook unter `docs/runbooks/`
([Vorlage](vorlagen/runbook.md)): wann es gilt, was man braucht, Schritte mit Befehlen,
Rückweg und wann man aufhört und Hilfe holt. Pflicht in jedem Projekt mit Betrieb:

| Runbook | Inhalt |
|---|---|
| `wiederherstellen.md` | Sicherung zurückspielen (ganze Datenbank, einzelne Datei) |
| `rueckfall.md` | auf die vorige Version zurück, mit und ohne Migration |
| `platte-voll.md` | Speicher prüfen, Logs/Images/Sicherungen aufräumen |
| `dienst-startet-nicht.md` | Logs lesen, Healthcheck, Konfiguration prüfen, Neustart |
| `zugang-gesperrt.md` | Admin ohne 2FA-Gerät, Wiederherstellungscode, Sperre aufheben |
| `geheimnis-wechseln.md` | Schlüssel oder Passwort tauschen (Rotation, [04](04-sicherheit.md)) |

Ein Runbook wird beim Üben geprüft (Wiederherstellung je Minor-Release, [05](05-betrieb.md)).
Stimmt etwas nicht, wird es im selben Zug korrigiert.
