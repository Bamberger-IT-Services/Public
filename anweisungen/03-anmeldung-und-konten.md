# 03 · Anmeldung, 2FA und Konten

Zielbild für jedes Projekt mit Benutzerkonten. Maßstab ist OWASP ASVS 5.0, Level 2
(Abschnitte Authentifizierung und Sitzungen).

## Konten

- Neue Benutzer kommen **per Einladung**. Eine Selbstregistrierung gibt es nur, wenn das
  Produkt sie braucht, und dann begründet.
- Rollen werden **auf dem Server** geprüft, jede Aktion für sich. RLS ist die zweite Linie
  ([02](02-architektur.md)). Was eine Rolle nicht darf, zeigt die Oberfläche gar nicht erst.
- Die Fehlermeldungen bei Anmeldung, Einladung und „Passwort vergessen“ sind **immer
  gleich**. So lässt sich nicht herausfinden, ob es ein Konto gibt.

## Passwörter (NIST SP 800-63B)

- **Mindestens 12 Zeichen**, höchstens 128. **Keine** Zusammensetzungsregeln (Groß-,
  Kleinbuchstaben, Ziffern, Sonderzeichen). Leerzeichen und Unicode sind erlaubt.
- Abgelehnt werden: Passwörter aus einer Liste geleakter Passwörter (mindestens die
  häufigsten 10.000) sowie Name, E-Mail und Produktname.
- Kein erzwungener Wechsel nach Zeit. Ein Wechsel nur bei Verdacht.
- Ein Passwortmanager muss funktionieren (`autocomplete`-Attribute, kein Einfügeverbot).

## Zweiter Faktor (2FA)

- **TOTP (Authenticator-App) ist Pflicht für jedes Konto.** Eingerichtet wird es bei der
  ersten Anmeldung, ohne 2FA gibt es keinen Zugriff.
- **10 Wiederherstellungscodes** bei der Einrichtung, je einmal verwendbar. Gespeichert
  werden sie als **HMAC-SHA-256 mit Pepper** (Schlüssel aus der Konfiguration), nicht
  als reiner Hash. Ein eingelöster Code verlangt sofort eine neue 2FA-Einrichtung.
- Höchstens 4 TOTP-Faktoren je Konto (z. B. Telefon und Ersatzgerät).
- **Passkeys (WebAuthn):** Ziel, sobald selbst gehostetes Supabase sie stabil anbietet.
  Stand 2026 sind sie dort noch Beta. Dann wird der Passkey der bevorzugte Weg (schützt
  gegen Phishing), TOTP und Codes bleiben Rückfall. Beta-Funktionen kommen nicht in den
  Betrieb.

## Sitzungen

- Eine **eigene Sitzungstabelle**: Geräteliste (Gerät, Ort grob, zuletzt aktiv), jede
  Sitzung einzeln beendbar, „alle anderen abmelden“.
- **Inaktivität** beendet eine Sitzung nach 7 Tagen (Vorgabe, einstellbar). Die
  **Höchstdauer** liegt bei 30 Tagen, danach ist eine neue Anmeldung mit 2FA fällig.
- Ändern sich Passwort oder 2FA, enden alle anderen Sitzungen.
- Cookies sind `HttpOnly`, `Secure` und `SameSite=Lax` und tragen das Präfix `__Host-`, wo
  möglich.
- Eine Telefon-App nutzt kurzlebige Zugriffstokens und Refresh-Tokens im sicheren Speicher
  des Geräts (Keychain/Keystore), nie im normalen Speicher.

## Fehlversuche

- Drosselung **in Postgres** (Tabelle `rate_limits`), nicht im Arbeitsspeicher. So
  übersteht sie einen Neustart und gilt für mehrere Instanzen.
- Vorgabe: **5 Fehlversuche je Konto** und **30 je IP** in 15 Minuten, für Passwort, 2FA und
  Code jeweils getrennt. Zugänge mit gemeinsamer IP (z. B. ein Mieterportal) zählen je
  Konto **und** IP.
- Der Auth-Dienst (GoTrue) ist **nicht öffentlich** erreichbar. Die App spricht ihn intern
  an. Braucht eine Telefon-App ihn direkt, greift die Drosselung vor dem Auth-Dienst.

## E-Mails

- Auth-Mails (Einladung, Passwort zurücksetzen, neues Gerät) verschickt die App selbst,
  mit deutschen Vorlagen im Design des Projekts. Links laufen nach kurzer Zeit ab und
  gelten nur einmal.

## Zusatzdienste ohne eigenes Single Sign-on

- Dienste wie n8n oder DocuSeal bekommen eigene Zugänge mit **langer Sitzung** und
  Passwortmanager. Erreichbar sind sie nur intern oder hinter dem Reverse Proxy mit 2FA
  des Dienstes, wenn er eine hat.
